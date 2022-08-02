const std = @import("std");

const pkgs = struct {
    const zigr = std.build.Pkg{
        .name = "zigr",
        .source = .{ .path = "src/main.zig" },
    };
};

/// https://github.com/fengb/zCord/blob/master/build.zig#L4-L12
const Options = struct {
    mode: std.builtin.Mode,
    target: std.zig.CrossTarget,

    fn apply(self: Options, lib: *std.build.LibExeObjStep) void {
        lib.setTarget(self.target);
        lib.setBuildMode(self.mode);
        lib.linkLibC();
        lib.addIncludePath("libs/tigr");
        lib.addCSourceFile("libs/tigr/tigr.c", &[_][]const u8{});
        lib.linkSystemLibrary("X11");
        lib.linkSystemLibrary("GL");
        lib.linkSystemLibrary("GLU");
    }
};

pub fn build(b: *std.build.Builder) void {
    const target = b.standardTargetOptions(.{});
    const mode = b.standardReleaseOptions();
    const options = Options{
        .target = target,
        .mode = mode,
    };

    const lib = b.addStaticLibrary("zigr", "src/main.zig");
    options.apply(lib);
    lib.install();

    const main_tests = b.addTest("src/main.zig");
    options.apply(main_tests);

    const test_step = b.step("test", "Run library tests");
    test_step.dependOn(&main_tests.step);

    const hello_example = b.addExecutable("hello", "examples/hello.zig");
    options.apply(hello_example);
    hello_example.addPackage(pkgs.zigr);

    const examples_step = b.step("examples", "Builds examples");
    examples_step.dependOn(&b.addInstallArtifact(hello_example).step);
}
