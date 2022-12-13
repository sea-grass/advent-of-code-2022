// The problem:
// The elves are all carrying one or more food items and we need to know which
// elf is carrying the most calories.
//
// In the input, each line is either an item's calory count or a blank line.
// A blank line divides each elf's inventory.
// When we read a line with a calory count on it, we need to add that number to
// the total calory count for the current elf. When we see a blank line, it means
// we've reached the end of that elf's inventory, so when we next see a calory
// count line we need to start counting from 0 again.
//
// The approach:
// We'll use Zig's std.mem.split on two successive newlines ("\n\n") to get an iterator
// of each elf's inventory lines. We can use std.mem.split again for each elf's
// inventory on a single newline ("\n") to get an iterator of each of item the elf is
// carrying. Then, we parse each integer and sum them together. We take the sum
// and then set our `max_sum` to `@max(sum, max_sum)`. At the end, we print the
// maximum sum.
//
// Part 2 problem:
// We need to know the total calories carried by the top three elves carrying the
// most calories.
//
// The input to part 2 is identical to the input in part 1. This will be true for all
// Advent of Code problems.
//
// The approach:
// We'll keep an array of size 4, each slot initialized to 0. Once we've calculated
// each Elf's max size, we'll set the last element of this array to their sum and
// then sort the array largest to smallest. At the end, the first three elements
// of the array will be the largest inventories. We sum those together and print
// the result.

const std = @import("std");

const name = "01_calorie_counting";
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
        // skip executable name
        _ = args_it.skip();
        if (args_it.next()) |arg| {
            std.debug.print("arg({s})\n", .{arg});
            if (std.mem.eql(u8, arg, "part2")) {
                break :blk .part2;
            }
        }
        break :blk .part1;
    };

    switch (problem) {
        .part1 => {
            const sample_calory_count = get_max_calory_count(sample_input);
            const expected_calory_count = std.fmt.parseInt(u32, std.mem.trimRight(u8, sample_output, "\n"), 10) catch unreachable;
            if (sample_calory_count != expected_calory_count) unreachable;

            const max_calory_count = get_max_calory_count(input);
            try stdout.print("{d}\n", .{max_calory_count});
        },
        .part2 => {
            const sample_sum_max_calory_count = get_sum_max_calory_count(sample_input, 3);
            const expected_sum_calory_count = std.fmt.parseInt(u32, std.mem.trimRight(u8, sample_part2_output, "\n"), 10) catch unreachable;
            if (sample_sum_max_calory_count != expected_sum_calory_count) unreachable;

            const sum_max_calory_count = get_sum_max_calory_count(input, 3);
            try stdout.print("{d}\n", .{sum_max_calory_count});
        },
    }
}

fn get_max_calory_count(elf_inventory: []const u8) u32 {
    var max_calory_count: u32 = 0;
    var inventory_it = inventory(elf_inventory);
    while (inventory_it.next()) |calory_count| {
        max_calory_count = @max(max_calory_count, calory_count);
    }

    return max_calory_count;
}

fn get_sum_max_calory_count(elf_inventory: []const u8, comptime num_sums: u32) u32 {
    var max_calory_counts = [_]u32{0} ** (num_sums + 1);
    var inventory_it = inventory(elf_inventory);
    while (inventory_it.next()) |calory_count| {
        max_calory_counts[3] = calory_count;
        std.sort.sort(u32, &max_calory_counts, {}, comptime std.sort.desc(u32));
    }
    const vec: @Vector(3, u32) = max_calory_counts[0..3].*;
    return @reduce(.Add, vec);
}

fn inventory(elf_inventory: []const u8) InventoryIterator {
    return InventoryIterator.init(elf_inventory);
}

const InventoryIterator = struct {
    elves: std.mem.SplitIterator(u8),
    saw_end: bool,

    pub fn init(elf_inventory: []const u8) @This() {
        return .{
            .elves = std.mem.split(u8, elf_inventory, "\n\n"),
            .saw_end = false,
        };
    }

    pub fn next(self: *@This()) ?u32 {
        if (self.elves.next()) |elf| {
            var items = std.mem.split(u8, elf, "\n");
            var total_calory_count: u32 = 0;
            while (items.next()) |item| {
                if (std.mem.eql(u8, item, "")) {
                    // The only blank line we expect is at the end of the file.
                    self.saw_end = true;
                    break;
                }
                // If we continue to see tokens after the expected end, it's a problem.
                if (self.saw_end) unreachable;

                const calory_count = std.fmt.parseInt(u32, item, 10) catch unreachable;
                total_calory_count += calory_count;
            }
            return total_calory_count;
        } else {
            return null;
        }
    }
};
