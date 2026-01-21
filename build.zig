const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const zigr_mod = b.addModule("zigr", .{
        .optimize = optimize,
        .target = target,
        .root_source_file = b.path("src/main.zig"),
        .sanitize_c = .off,
    });
    zigr_mod.link_libc = true;
    zigr_mod.addIncludePath(b.dependency("tigr", .{}).path(""));
    zigr_mod.addCSourceFile(.{ .file = b.dependency("tigr", .{}).path("tigr.c") });
    switch (target.result.os.tag) {
        .windows => {
            zigr_mod.linkSystemLibrary("opengl32", .{});
            zigr_mod.linkSystemLibrary("gdi32", .{});
        },
        .macos => {
            if (std.process.getEnvVarOwned(b.graph.arena, "SDKROOT")) |sdkroot| {
                zigr_mod.addFrameworkPath(std.Build.LazyPath{
                    .cwd_relative = b.fmt("{s}/System/Library/Frameworks", .{sdkroot}),
                });
            } else |_| {}

            zigr_mod.linkFramework("Cocoa", .{});
            zigr_mod.linkFramework("OpenGL", .{});
        },
        else => {
            zigr_mod.linkSystemLibrary("X11", .{});
            zigr_mod.linkSystemLibrary("GL", .{});
            zigr_mod.linkSystemLibrary("GLU", .{});
        },
    }

    const lib = b.addLibrary(.{
        .linkage = .static,
        .name = "zigr",
        .root_module = zigr_mod,
    });

    b.installArtifact(lib);

    const tests = b.addTest(.{ .root_module = zigr_mod });
    const run_tests = b.addRunArtifact(tests);

    const test_step = b.step("test", "Makes sure everything compiles");
    test_step.dependOn(&run_tests.step);

    const hello_example = b.addExecutable(.{
        .name = "hello",
        .root_module = b.createModule(.{
            .optimize = optimize,
            .target = target,
            .root_source_file = b.path("examples/hello.zig"),
            .imports = &.{std.Build.Module.Import{ .name = "zigr", .module = zigr_mod }},
        }),
    });

    const examples_step = b.step("example", "Builds the example");
    examples_step.dependOn(&b.addInstallArtifact(hello_example, .{}).step);

    // This command takes the header file from the zig cache,
    // and translates it to zig.
    const bindgen_cmd = b.addSystemCommand(&.{ "zig", "translate-c" });
    bindgen_cmd.addFileArg(b.dependency("tigr", .{}).path("tigr.h"));
    const bindgen_output = bindgen_cmd.captureStdOut();
    // This command takes the output from the previous command,
    // and writes it to `src/c.zig`.
    const bindgen_copy = b.addSystemCommand(&.{"cp"});
    bindgen_copy.addFileArg(bindgen_output);
    bindgen_copy.addFileArg(b.path("src/c.zig"));

    // the extra step should be as simple as running `git apply bindings.patch`,
    // but you should run it with `--check` to make sure it still works with the latest versions.
    const bindgen_step = b.step("bindgen", "Generates the zig bindings for the latest version of tigr. Takes some manual changes to get working.");
    bindgen_step.dependOn(&bindgen_copy.step);
}
