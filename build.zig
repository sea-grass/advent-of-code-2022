const std = @import("std");
const assert = std.debug.assert;

// Problem takes a similar shape to `Exercise` in the build.zig of ziglings.
const Problem = struct {
    main_file: []const u8,

    pub fn baseName(self: @This()) []const u8 {
        assert(std.mem.endsWith(u8, self.main_file, ".zig"));
        return self.main_file[0 .. self.main_file.len - 4];
    }

    pub fn key(self: @This()) []const u8 {
        const end_index = std.mem.indexOfScalar(u8, self.main_file, '_');
        assert(end_index != null);

        var start_index: usize = 0;
        while (self.main_file[start_index] == '0') start_index += 1;
        return self.main_file[start_index..end_index.?];
    }
};

const problems = [_]Problem{
    .{
        .main_file = "01_calorie_counting.zig",
    },
};

pub fn build(b: *std.build.Builder) void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{});

    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const mode = b.standardReleaseOptions();

    for (problems) |p| {
        const base_name = p.baseName();
        const file_path = std.fs.path.join(b.allocator, &[_][]const u8{
            "src", p.main_file,
        }) catch unreachable;
        const build_step = b.addExecutable(base_name, file_path);
        build_step.setTarget(target);
        build_step.setBuildMode(mode);
        build_step.install();

        const key = p.key();

        std.debug.print("step({s})\n", .{key});
        const run_cmd = build_step.run();
        if (b.args) |args| {
            run_cmd.addArgs(args);
        }

        const step = b.step(key, b.fmt("Run {s}", .{p.main_file}));
        step.dependOn(&run_cmd.step);
    }
}

pub fn buildo(b: *std.build.Builder) void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{});

    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const mode = b.standardReleaseOptions();

    const exe = b.addExecutable("advent-of-code-zig", "src/main.zig");
    exe.setTarget(target);
    exe.setBuildMode(mode);
    exe.install();

    const run_cmd = exe.run();
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    const exe_tests = b.addTest("src/main.zig");
    exe_tests.setTarget(target);
    exe_tests.setBuildMode(mode);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&exe_tests.step);
}
