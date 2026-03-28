const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // --- GAME EXECUTABLE ---
    const exe = b.addExecutable(.{
        .name = "tlc_at_doom",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });
    exe.linkLibC();
    exe.linkSystemLibrary("SDL2");
    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }
    const run_step = b.step("run", "Run the game");
    run_step.dependOn(&run_cmd.step);
    
    // --- EDITOR EXECUTABLE ---
    const editor_exe = b.addExecutable(.{
        .name = "tlc_editor",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/editor_main.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });
    editor_exe.linkLibC();
    editor_exe.linkSystemLibrary("SDL2");
    b.installArtifact(editor_exe);

    const run_editor_cmd = b.addRunArtifact(editor_exe);
    run_editor_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| { // allow args for the editor too
        run_editor_cmd.addArgs(args);
    }
    const run_editor_step = b.step("editor", "Run the D.O.O.M Editor");
    run_editor_step.dependOn(&run_editor_cmd.step);

    // --- VOXEL EXECUTABLE ---
    const voxel_exe = b.addExecutable(.{
        .name = "tlc_voxel",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/voxel_main.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });
    voxel_exe.linkLibC();
    voxel_exe.linkSystemLibrary("SDL2");
    b.installArtifact(voxel_exe);

    const run_voxel_cmd = b.addRunArtifact(voxel_exe);
    run_voxel_cmd.step.dependOn(b.getInstallStep());
    const run_voxel_step = b.step("voxel", "Run the D.O.O.M Voxel Forge");
    run_voxel_step.dependOn(&run_voxel_cmd.step);

    // --- DESKTOP EXECUTABLE ---
    const desktop_exe = b.addExecutable(.{
        .name = "tlc_desktop",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/desktop_main.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });
    desktop_exe.linkLibC();
    desktop_exe.linkSystemLibrary("SDL2");
    b.installArtifact(desktop_exe);

    const run_desktop_cmd = b.addRunArtifact(desktop_exe);
    run_desktop_cmd.step.dependOn(b.getInstallStep());
    const run_desktop_step = b.step("desktop", "Run the D.O.O.M_OS_311 Desktop");
    run_desktop_step.dependOn(&run_desktop_cmd.step);

    // --- TESTS ---
    const exe_unit_tests = b.addTest(.{
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });
    const run_exe_unit_tests = b.addRunArtifact(exe_unit_tests);
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_exe_unit_tests.step);
}
