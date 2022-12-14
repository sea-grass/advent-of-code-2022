// The problem:
// Elves are tasked to clean up numbered sections and have split off in pairs
// to do so. We need to identify each pair where their assigned sections
// overlap and one fully contains the other, and count the number of such
// occurences.
//
// In the input, each line contains a pair of work assignments, separated
// by a comma. Each work assignment is a range in the form `min-max`. An
// input line might look like the following:
//
// 2-8,3-7
//
// The approach:
// I like how the `BadgeIterator` from yesterday's problem turned out, so I'll
// likely create a `WorkGroupIterator` or similar that will return a struct
// called `WorkGroup` that holds the section ranges for each work assignment
// and has a function to determine whether one section completely overlaps with
// the other. The comparison itself will be fairly trival, something like:
//
// (min_a >= min_b and max_a <= max_b) or (min_b >= min_a and max_b <= max_a)

const std = @import("std");
const LineIterator = @import("util.zig").LineIterator;

const name = "04_camp_cleanup";
const sample_input = @embedFile(name ++ "/sample-input.txt");
const sample_output = @embedFile(name ++ "/sample-output.txt");
const sample_part2_output = @embedFile(name ++ "/sample-part2-output.txt");
const input = @embedFile(name ++ "/input.txt");

fn getNumOverlaps(work_groups: []const u8) u32 {
    var wg_it: WorkGroupIterator = .{ .work_groups = work_groups };
    var total_overlaps: u32 = 0;
    while (wg_it.next()) |work_group| {
        if (work_group.has_complete_overlap()) total_overlaps += 1;
    }
    return total_overlaps;
}

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    const allocator = std.heap.page_allocator;

    var args_it = try std.process.argsWithAllocator(allocator);
    defer args_it.deinit();

    const problem: enum { part1, part2 } = blk: {
        _ = args_it.skip();
        if (args_it.next()) |arg| {
            if (std.mem.eql(u8, arg, "part2")) {
                break :blk .part2;
            }
        }
        break :blk .part1;
    };

    switch (problem) {
        .part1 => {
            const sample_num_overlaps = getNumOverlaps(sample_input);
            const expected_num_overlaps = std.fmt.parseInt(u32, std.mem.trimRight(u8, sample_output, "\n"), 10) catch unreachable;
            if (sample_num_overlaps != expected_num_overlaps) unreachable;

            const num_overlaps = getNumOverlaps(input);
            try stdout.print("{d}\n", .{num_overlaps});
        },
        .part2 => {
            // todo: part2
            unreachable;
        },
    }
}

const WorkAssignment = [2]u32;

fn getWorkAssignment(section_range: []const u8) WorkAssignment {
    var parts = std.mem.split(u8, section_range, "-");
    const start: u32 = std.fmt.parseInt(u32, parts.next() orelse unreachable, 10) catch unreachable;
    const end: u32 = std.fmt.parseInt(u32, parts.next() orelse unreachable, 10) catch unreachable;
    return .{ start, end };
}

const WorkGroup = struct {
    a: WorkAssignment,
    b: WorkAssignment,

    pub fn has_complete_overlap(self: WorkGroup) bool {
        return (self.a[0] >= self.b[0] and self.a[1] <= self.b[1]) or (self.b[0] >= self.a[0] and self.b[1] <= self.a[1]);
    }
};

const WorkGroupIterator = struct {
    line_it: ?LineIterator = null,
    work_groups: []const u8,
    done: bool = false,

    pub fn next(self: *@This()) ?WorkGroup {
        if (self.done) unreachable;
        if (self.line_it == null) self.line_it = .{ .lines = self.work_groups };

        if (self.line_it.?.next()) |line| {
            var parts = std.mem.split(u8, line, ",");
            const first_elf = parts.next() orelse unreachable;
            const second_elf = parts.next() orelse unreachable;
            if (parts.next()) |_| unreachable;

            return .{
                .a = getWorkAssignment(first_elf),
                .b = getWorkAssignment(second_elf),
            };
        }

        self.done = true;
        return null;
    }
};
