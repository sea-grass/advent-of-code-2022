// The problem:
// There are N stacks each containing supplies that may need to be moved between
// the stacks. Follow the steps provided to move crates between the stacks.
// Once you've moved all of the creates according to the procedure, print out
// the name of each of the crates on the top of each stack.
//
// The input begins with a graphical representation of the stacks of crates,
// followed by an empty line and finally instructions to move crates between
// stacks.
//
// The approach:
// Parsing the input will be a bit more of a challenge than the previous problems,
// mainly because of the graphical representation. The main change this will
// incur is backtracking to previous lines, or at least processing some of them
// in reverse.
//
// First, we can split the input on "\n\n". The first slice will be the graphical
// representation of the stacks and the second slice will be the instructions
// to follow, one per line.
//
// In the graphical representation, each line is fully padded with spaces. This
// means that we can look at the number of characters on the first line and know
// immediately how many stacks there are. Each stack is three characters wide
// and each stack is separated by a single whitespace character. The formula to
// calculate the number of characters, with `n` stacks is:
//
// line = 3n + (n-1)
// line = 4n-1
//
// If we already know the line length, we can make a formula for n:
//
// line = 4n-1
// 4n = line+1
// n = (line + 1) / 4
//
// Since we know what n is on the first line, we don't need to read the final line
// and backtrack. Instead, the final line with the stack numbers indicate we're finished
// reading the stacks.
//
// We're reading stacks from top to bottom. Each line, we iterate over our stacks and
// compute an offset for each stack's location on the line. Check for symbols like `[a]`
// and, if present, plop them onto a stack.
//
// Our stack will need a pushBottom to suit this style, or we could just iterate over
// the lines in reverse.
//
//
// The instructions have 3 bits of information on each line:
// - number of stacks to move
// - source stack
// - destination stack
//
// Our stack will need a pushMany and popMany. Moving crates between stacks will look like:
//
// stack[destination].pushMany(stack[source].popMany(num_stacks));
//
// The stack will also need a peek. At the end of the program, we peek onto each stack
// and print its top crate.
//
// A memory-efficient version might be to count the number of total creates, which you could do
// easily by counting the "[" characters for example, and store data about where each crate is:
// the stack it's placed on and the position in the stack, and use it as the backing store for
// a virtual 2D array, where you know you have less than MxN items but want a grid size greater
// than MxN. Or it might be better to use linked lists, where the root holds a reference to the
// head of N stacks. That definitely seems like the simplest and it might be nice to have the root
// control moving items between stacks.

const std = @import("std");
const ArrayList = std.ArrayList;
const LineIterator = @import("util.zig").LineIterator;

const name = "05_supply_stacks";
const sample_input = @embedFile(name ++ "/sample-input.txt");
const sample_output = @embedFile(name ++ "/sample-output.txt");
const sample_part2_output = @embedFile(name ++ "/sample-part2-output.txt");
const input = @embedFile(name ++ "/input.txt");

const Stack = struct {
    array_list: ArrayList(u8),

    pub fn push(self: *@This(), item: u8) void {
        self.array_list.append(item) catch unreachable;
    }

    pub fn pop(self: *@This()) u8 {
        return self.array_list.pop();
    }

    pub fn peek(self: @This()) u8 {
        return self.array_list.items[self.array_list.items.len - 1];
    }
};

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
            // part 1
            var buffer: [9]u8 = undefined;

            const sample_stack_summary = try getStackSummary(&buffer, allocator, sample_input);
            const expected_stack_summary = std.mem.trimRight(u8, sample_output, "\n");
            if (!std.mem.eql(u8, sample_stack_summary, expected_stack_summary)) {
                std.debug.print("stacks({s}) != expected({s})\n", .{ sample_stack_summary, expected_stack_summary });
                unreachable;
            }

            const stack_summary = try getStackSummary(&buffer, allocator, input);
            try stdout.print("{s}\n", .{stack_summary});
        },
        .part2 => {
            // part 2
            var buffer: [9]u8 = undefined;

            const sample_stack_summary = try getEfficientStackSummary(&buffer, allocator, sample_input);
            const expected_stack_summary = std.mem.trimRight(u8, sample_part2_output, "\n");
            if (!std.mem.eql(u8, sample_stack_summary, expected_stack_summary)) {
                std.debug.print("stacks({s}) != expected({s})\n", .{ sample_stack_summary, expected_stack_summary });
                unreachable;
            }

            const stack_summary = try getEfficientStackSummary(&buffer, allocator, input);
            try stdout.print("{s}\n", .{stack_summary});
        },
    }
}

fn getStackSummary(buffer: []u8, allocator: std.mem.Allocator, stack_data: []const u8) ![]const u8 {
    var parts = std.mem.split(u8, stack_data, "\n\n");

    const diagram = parts.next() orelse unreachable;
    var diagram_it: LineIterator = .{ .lines = diagram, .backwards = true };

    const num_stacks = stacks: {
        const line = diagram_it.next() orelse unreachable;
        break :stacks try std.fmt.parseInt(u32, line[line.len - 2 .. line.len - 1], 10);
    };

    var stacks = try allocator.alloc(Stack, num_stacks);
    defer allocator.free(stacks);

    for (stacks) |*s| {
        s.array_list = ArrayList(u8).init(allocator);
    }

    defer {
        for (stacks) |*s| {
            s.array_list.deinit();
        }
    }

    while (diagram_it.next()) |line| {
        var i: usize = 0;
        while (i < num_stacks) : (i += 1) {
            const column_size: usize = 3;
            const offset = i * column_size + i;
            const item = line[offset .. offset + column_size];
            if (item[0] == '[' and item[2] == ']') {
                stacks[i].push(item[1]);
            } else if (!std.mem.eql(u8, item, "   ")) unreachable;
        }
    }

    const instructions = parts.next() orelse unreachable;
    var instructions_it: LineIterator = .{ .lines = instructions };
    while (instructions_it.next()) |instruction| {
        var instruction_parts: std.mem.TokenIterator(u8) = .{ .buffer = instruction, .delimiter_bytes = " ", .index = 0 };

        // "move X from Y to Z"
        if (!std.mem.eql(u8, "move", instruction_parts.next() orelse unreachable)) unreachable;
        const num = std.fmt.parseInt(u32, instruction_parts.next() orelse unreachable, 10) catch unreachable;

        if (!std.mem.eql(u8, "from", instruction_parts.next() orelse unreachable)) unreachable;
        const source = std.fmt.parseInt(u32, instruction_parts.next() orelse unreachable, 10) catch unreachable;

        if (!std.mem.eql(u8, "to", instruction_parts.next() orelse unreachable)) unreachable;
        const dest = std.fmt.parseInt(u32, instruction_parts.next() orelse unreachable, 10) catch unreachable;

        if (instruction_parts.next()) |_| unreachable;

        var i: usize = 0;
        while (i < num) : (i += 1) {
            stacks[dest - 1].push(stacks[source - 1].pop());
        }
    }

    for (stacks) |s, i| {
        buffer.ptr[i] = s.peek();
    }

    return buffer[0..num_stacks];
}

fn getEfficientStackSummary(buffer: []u8, allocator: std.mem.Allocator, stack_data: []const u8) ![]const u8 {
    var parts = std.mem.split(u8, stack_data, "\n\n");

    const diagram = parts.next() orelse unreachable;
    var diagram_it: LineIterator = .{ .lines = diagram, .backwards = true };

    const num_stacks = stacks: {
        const line = diagram_it.next() orelse unreachable;
        break :stacks try std.fmt.parseInt(u32, line[line.len - 2 .. line.len - 1], 10);
    };

    var stacks = try allocator.alloc(Stack, num_stacks);
    defer allocator.free(stacks);

    for (stacks) |*s| {
        s.array_list = ArrayList(u8).init(allocator);
    }

    defer {
        for (stacks) |*s| {
            s.array_list.deinit();
        }
    }

    while (diagram_it.next()) |line| {
        var i: usize = 0;
        while (i < num_stacks) : (i += 1) {
            const column_size: usize = 3;
            const offset = i * column_size + i;
            const item = line[offset .. offset + column_size];
            if (item[0] == '[' and item[2] == ']') {
                stacks[i].push(item[1]);
            } else if (!std.mem.eql(u8, item, "   ")) unreachable;
        }
    }

    const instructions = parts.next() orelse unreachable;
    var instructions_it: LineIterator = .{ .lines = instructions };
    while (instructions_it.next()) |instruction| {
        var instruction_parts: std.mem.TokenIterator(u8) = .{ .buffer = instruction, .delimiter_bytes = " ", .index = 0 };

        // "move X from Y to Z"
        if (!std.mem.eql(u8, "move", instruction_parts.next() orelse unreachable)) unreachable;
        const num = std.fmt.parseInt(u32, instruction_parts.next() orelse unreachable, 10) catch unreachable;

        if (!std.mem.eql(u8, "from", instruction_parts.next() orelse unreachable)) unreachable;
        const source = std.fmt.parseInt(u32, instruction_parts.next() orelse unreachable, 10) catch unreachable;

        if (!std.mem.eql(u8, "to", instruction_parts.next() orelse unreachable)) unreachable;
        const dest = std.fmt.parseInt(u32, instruction_parts.next() orelse unreachable, 10) catch unreachable;

        if (instruction_parts.next()) |_| unreachable;

        var items = try allocator.alloc(u8, num);
        defer allocator.free(items);

        var i: usize = 0;
        while (i < num) : (i += 1) {
            items[i] = stacks[source - 1].pop();
        }
        i = num;
        while (i > 0) : (i -= 1) {
            stacks[dest - 1].push(items[i - 1]);
        }
    }

    for (stacks) |s, i| {
        buffer.ptr[i] = s.peek();
    }

    return buffer[0..num_stacks];
}
