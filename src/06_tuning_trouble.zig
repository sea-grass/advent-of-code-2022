// The problem:
// The communication device receives signals in the form of random alphabetical
// characters. We need to identify the start-of-packet marker within the
// stream, identified by a sequence of four unique characters.
//
// The approach:
// This is a substring search problem. We'll create a slice of length 4 at each
// index and check that slice for uniqueness. Once we find the target slice,
// we can output the start index where it occurs in the string.

const std = @import("std");
const LineIterator = @import("util.zig").LineIterator;

const name = "06_tuning_trouble";
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
            const sample_index = findSubstringIndex(sample_input) orelse unreachable;
            const expected_index = std.fmt.parseInt(usize, std.mem.trimRight(u8, sample_output, "\n"), 10) catch unreachable;
            if (sample_index != expected_index) {
                std.debug.print("sample_index({d}) != expected_index({d})\n", .{ sample_index, expected_index });
                unreachable;
            }

            const substring_index = findSubstringIndex(input) orelse unreachable;
            try stdout.print("{d}\n", .{substring_index});
        },
        .part2 => {
            unreachable;
        },
    }
}

fn findSubstringIndex(string: []const u8) ?usize {
    const seq_len = 4;
    const start_index: ?usize = substr: {
        loop: for (string) |_, i| {
            if (i + seq_len >= string.len) break;

            const sub = string[i .. i + seq_len];
            for (sub) |c, sub_i| {
                if (sub_i + 1 >= sub.len) break;
                for (sub[sub_i + 1 ..]) |other| {
                    if (c == other) continue :loop;
                }
            }

            break :substr i;
        }

        break :substr null;
    };

    if (start_index) |i| return i + seq_len;

    return null;
}
