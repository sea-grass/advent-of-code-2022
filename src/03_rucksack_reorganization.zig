// The problem:
// We need to identify items in both compartments of a rucksack and compute
// a priority based on that number, then sum the priorities of all rucksacks.
//
// Each line of the input will contain the contents of the rucksack. The first
// half of the characters belong to the first compartment and the second half
// of the line belong to the second compartment of the rucksack. It's guaranteed
// that each compartment will share a single character, representing an item in the
// rucksack. Each item is given a numeric priority.
// a-z have priorities 1-26.
// A-Z have priorities 27-52.
//
// The approach:
// Use a `LineIterator` to go over each line. Create two slices from each line for
// each rucksack compartment. We need to compare these two and find out which character
// occurs in both.
//
// The path of least resistance would lead to a brute-force solution. Take each slice as is,
// and traverse them in tandem in a nested for loop. Looking through these unsorted lists
// results in a worst case of O(n^2). This is a toy program, however, so if it works, it works.
//
// I'll need to convert each character into the decimal representation to get its priority.

const std = @import("std");
const LineIterator = @import("util.zig").LineIterator;

const name = "03_rucksack_reorganization";
const sample_input = @embedFile(name ++ "/sample-input.txt");
const sample_output = @embedFile(name ++ "/sample-output.txt");
const sample_part2_output = @embedFile(name ++ "/sample-part2-output.txt");
const input = @embedFile(name ++ "/input.txt");

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
            const sample_total_priority = getTotalPriority(sample_input);
            const expected_priority = std.fmt.parseInt(u32, std.mem.trimRight(u8, sample_output, "\n"), 10) catch unreachable;
            if (sample_total_priority != expected_priority) unreachable;

            const total_priority = getTotalPriority(input);
            try stdout.print("{d}\n", .{total_priority});
        },
        .part2 => {
            // todo: part2
            unreachable;
        },
    }
}

fn getTotalPriority(rucksacks: []const u8) u32 {
    var rucksacks_it: LineIterator = .{ .lines = rucksacks };
    var total_priority: u32 = 0;
    while (rucksacks_it.next()) |rucksack| {
        if (@mod(rucksack.len, 2) != 0) unreachable;

        var first_compartment = rucksack[0 .. rucksack.len / 2];
        var second_compartment = rucksack[rucksack.len / 2 ..];
        const item_priority: u8 = blk: {
            for (first_compartment) |item| for (second_compartment) |other_item| if (item == other_item) break :blk switch (item) {
                'a'...'z' => |x| x - 96,
                'A'...'Z' => |x| x - 38,
                else => unreachable,
            };
            unreachable;
        };

        total_priority += item_priority;
    }

    return total_priority;
}
