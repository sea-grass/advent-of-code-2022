const std = @import("std");
const SplitIterator = std.mem.SplitIterator;
const split = std.mem.split;

pub const LineIterator = struct {
    lines: []const u8,
    lines_it: ?SplitIterator(u8) = null,
    saw_end: bool = false,

    pub fn next(self: *@This()) ?[]const u8 {
        if (self.lines_it == null) self.lines_it = split(u8, self.lines, "\n");

        if (self.lines_it.?.next()) |line| {
            if (line.len == 0) {
                self.saw_end = true;
                return null;
            }
            if (self.saw_end) unreachable;

            return line;
        } else return null;
    }
};
