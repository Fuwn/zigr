const std = @import("std");

fn apply(b: *std.Build, lib: *std.Build.Step.Compile) void {
    lib.root_module.link_libc = true;
    lib.root_module.addIncludePath(b.dependency("tigr", .{}).path(""));
    lib.root_module.addCSourceFile(.{ .file = b.dependency("tigr", .{}).path("tigr.c") });
    lib.root_module.linkSystemLibrary("X11", .{});
    lib.root_module.linkSystemLibrary("GL", .{});
    lib.root_module.linkSystemLibrary("GLU", .{});
}

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const zigr_mod = b.addModule("zigr", .{
        .optimize = optimize,
        .target = target,
        .root_source_file = b.path("src/main.zig"),
        .sanitize_c = .off,
    });
    const lib = b.addLibrary(.{
        .linkage = .static,
        .name = "zigr",
        .root_module = zigr_mod,
    });

    apply(b, lib);
    b.installArtifact(lib);

    const tests = b.addTest(.{ .root_module = zigr_mod });
    const run_tests = b.addRunArtifact(tests);

    const test_step = b.step("test", "Runs all tests");
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

    const examples_step = b.step("examples", "Builds examples");
    examples_step.dependOn(&b.addInstallArtifact(hello_example, .{}).step);
}
