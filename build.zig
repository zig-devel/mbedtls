const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const upstream = b.dependency("mbedtls", .{});

    const mod = b.createModule(.{
        .link_libc = true,
        .target = target,
        .optimize = optimize,
    });

    _ = mod; // stub
    _ = upstream; // stub

    // Smoke unit test
    const test_mod = b.addModule("test", .{
        .root_source_file = b.path("tests.zig"),
        .target = target,
        .optimize = optimize,
    });
    // TODO: mod.linkLibrary(lib);

    const run_mod_tests = b.addRunArtifact(b.addTest(.{ .root_module = test_mod }));

    const test_step = b.step("test", "Run tests");
    test_step.dependOn(&run_mod_tests.step);
}
