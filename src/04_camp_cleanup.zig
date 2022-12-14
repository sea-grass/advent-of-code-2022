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
//
// The part2 problem:
// Same problem as above, except we need to detect any kind of overlap.
//
// The approach:
// All we need to do is add an `overlaps` function to the `WorkGroup` struct.

const std = @import("std");
const LineIterator = @import("util.zig").LineIterator;

const name = "04_camp_cleanup";
const sample_input = @embedFile(name ++ "/sample-input.txt");
const sample_output = @embedFile(name ++ "/sample-output.txt");
const sample_part2_output = @embedFile(name ++ "/sample-part2-output.txt");
const input = @embedFile(name ++ "/input.txt");

fn getNumCompleteOverlaps(work_groups: []const u8) u32 {
    var wg_it: WorkGroupIterator = .{ .work_groups = work_groups };
    var total_overlaps: u32 = 0;
    while (wg_it.next()) |work_group| {
        if (work_group.has_complete_overlap()) total_overlaps += 1;
    }
    return total_overlaps;
}

fn getNumOverlaps(work_groups: []const u8) u32 {
    var wg_it: WorkGroupIterator = .{ .work_groups = work_groups };
    var total_overlaps: u32 = 0;
    while (wg_it.next()) |work_group| {
        if (work_group.has_overlap()) total_overlaps += 1;
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
            const sample_num_overlaps = getNumCompleteOverlaps(sample_input);
            const expected_num_overlaps = std.fmt.parseInt(u32, std.mem.trimRight(u8, sample_output, "\n"), 10) catch unreachable;
            if (sample_num_overlaps != expected_num_overlaps) unreachable;

            const num_overlaps = getNumCompleteOverlaps(input);
            try stdout.print("{d}\n", .{num_overlaps});
        },
        .part2 => {
            const sample_num_overlaps = getNumOverlaps(sample_input);
            const expected_num_overlaps = std.fmt.parseInt(u32, std.mem.trimRight(u8, sample_part2_output, "\n"), 10) catch unreachable;
            if (sample_num_overlaps != expected_num_overlaps) unreachable;

            const num_overlaps = getNumOverlaps(input);
            try stdout.print("{d}\n", .{num_overlaps});
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
        const min_a = self.a[0];
        const max_a = self.a[1];
        const min_b = self.b[0];
        const max_b = self.b[1];
        return (min_a == min_b and max_a <= max_b) or max_a >= max_b;
    }

    pub fn has_overlap(self: WorkGroup) bool {
        const max_a = self.a[1];
        const min_b = self.b[0];
        if (max_a >= min_b) return true;
        return false;
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
            const first_elf = getWorkAssignment(parts.next() orelse unreachable);
            const second_elf = getWorkAssignment(parts.next() orelse unreachable);
            if (parts.next()) |_| unreachable;

            // we simplify work assignment comparison if they're sorted
            return if (first_elf[0] < second_elf[0]) .{
                .a = first_elf,
                .b = second_elf,
            } else .{
                .a = second_elf,
                .b = first_elf,
            };
        }

        self.done = true;
        return null;
    }
};
