const std = @import("std");
const SplitIterator = std.mem.SplitIterator;
const SplitBackwardsIterator = std.mem.SplitBackwardsIterator;
const split = std.mem.split;
const splitBackwards = std.mem.splitBackwards;

const Iterator = union(enum) {
    forwards: SplitIterator(u8),
    backwards: SplitBackwardsIterator(u8),
    unset,

    pub fn next(self: *@This()) ?[]const u8 {
        return switch (self.*) {
            .unset => unreachable,
            .forwards => |*it| it.next(),
            .backwards => |*it| it.next(),
        };
    }
};

pub const LineIterator = struct {
    lines: []const u8,
    backwards: bool = false,
    it: Iterator = .unset,
    saw_end: bool = false,

    pub fn next(self: *@This()) ?[]const u8 {
        switch (self.it) {
            .unset => {
                if (self.backwards) {
                    self.it = .{ .backwards = splitBackwards(u8, self.lines, "\n") };
                } else {
                    self.it = .{ .forwards = split(u8, self.lines, "\n") };
                }
            },
            else => {},
        }

        if (self.it.next()) |line| {
            if (line.len == 0) {
                self.saw_end = true;
                return null;
            }
            if (self.saw_end) unreachable;

            return line;
        } else return null;
    }
};
