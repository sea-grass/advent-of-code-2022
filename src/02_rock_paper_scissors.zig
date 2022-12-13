// The problem:
// We receive a "strategy guide" for an upcoming Rock-Paper Scissors tournament
// and need to calculate the store that the strategy guide would result in.
//
// Each line in the input is composed of a pair of symbols, where the first symbol
// is the opponent's move, represented by the alphabet ABC, and the second symbol
// is is the player's move, represented by the alphabet XYZ.
//
// The score from each round is calculated based on the chosen symbol and the outcome
// of the round.
// A = X = 1
// B = Y = 2
// C = Z = 3
// Loss = 0
// Draw = 3
// Win = 6
//
// The approach:
// There should only be 9 unique pairings of ABC and XYZ. Precalculate the scoring
// for each of the pairings and compare each line of the input with only of the
// precalculated values. Once found, add it to the total score. Print the total score
// at the end.
//
// The part2 problem:
// The meaning of the input symbols has changed.
// A = Opponent chooses Rock
// B = Opponent chooses Paper
// C = Opponent chooses Scissors
// X = Loss
// Y = Draw
// Z = Win
//
// There's still the same amount of information, but we need to deduce the player's choice
// from the opponent's choice and the outcome rather than deducing the outcome from each choice.
// The goal still remains to sum the total score.
//
// The approach:
// Zig has a comptime HashMap struct. Use three HashMaps to interpret what each Symbol means.
// One for ABC, one for XYZ=RPS, and one more for XYZ=Loss/Draw/Win. When the program runs,
// it can choose which two hash maps it wants to use.

const std = @import("std");
const ComptimeStringMap = std.ComptimeStringMap;
const LineIterator = @import("util.zig").LineIterator;

const name = "02_rock_paper_scissors";
const sample_input = @embedFile(name ++ "/sample-input.txt");
const sample_output = @embedFile(name ++ "/sample-output.txt");
const sample_part2_output = @embedFile(name ++ "/sample-part2-output.txt");
const input = @embedFile(name ++ "/input.txt");

const Symbol = enum(u32) {
    rock = 1,
    paper = 2,
    scissors = 3,
};

const Result = enum(u32) {
    loss = 0,
    draw = 3,
    win = 6,
};

const opponent_moves = std.ComptimeStringMap(Symbol, .{
    .{ "A", .rock },
    .{ "B", .paper },
    .{ "C", .scissors },
});

const player_moves = std.ComptimeStringMap(Symbol, .{
    .{ "X", .rock },
    .{ "Y", .paper },
    .{ "Z", .scissors },
});

const round_outcomes = std.ComptimeStringMap(Result, .{
    .{ "X", .loss },
    .{ "Y", .draw },
    .{ "Z", .win },
});

fn computePlayerScore(rounds: []const u8) u32 {
    var rounds_it: LineIterator = .{ .lines = rounds };
    var total_player_score: u32 = 0;
    while (rounds_it.next()) |round| {
        var parts = std.mem.split(u8, round, " ");
        const opponent = opponent_moves.get(parts.next() orelse unreachable) orelse unreachable;
        const player = player_moves.get(parts.next() orelse unreachable) orelse unreachable;
        total_player_score += getPlayerScore(opponent, player);
    }

    return total_player_score;
}

fn computeThrownPlayerScore(rounds: []const u8) u32 {
    var rounds_it: LineIterator = .{ .lines = rounds };
    var total_player_score: u32 = 0;
    while (rounds_it.next()) |round| {
        var parts = std.mem.split(u8, round, " ");
        const opponent = opponent_moves.get(parts.next() orelse unreachable) orelse unreachable;
        const outcome = round_outcomes.get(parts.next() orelse unreachable) orelse unreachable;
        total_player_score += getThrownPlayerScore(opponent, outcome);
    }

    return total_player_score;
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
            const sample_player_score = computePlayerScore(sample_input);
            const expected_player_score = std.fmt.parseInt(u32, std.mem.trimRight(u8, sample_output, "\n"), 10) catch unreachable;
            if (sample_player_score != expected_player_score) unreachable;

            const player_score = computePlayerScore(input);
            try stdout.print("{d}\n", .{player_score});
        },
        .part2 => {
            const sample_player_score = computeThrownPlayerScore(sample_input);
            const expected_player_score = std.fmt.parseInt(u32, std.mem.trimRight(u8, sample_part2_output, "\n"), 10) catch unreachable;
            if (sample_player_score != expected_player_score) unreachable;

            const player_score = computeThrownPlayerScore(input);
            try stdout.print("{d}\n", .{player_score});
        },
    }
}

fn getPlayerScore(opponent: Symbol, player: Symbol) u32 {
    const player_result: Result = switch (player) {
        .rock => switch (opponent) {
            .rock => .draw,
            .paper => .loss,
            .scissors => .win,
        },
        .paper => switch (opponent) {
            .rock => .win,
            .paper => .draw,
            .scissors => .loss,
        },
        .scissors => switch (opponent) {
            .rock => .loss,
            .paper => .win,
            .scissors => .draw,
        },
    };

    return @enumToInt(player) + @enumToInt(player_result);
}

fn getThrownPlayerScore(opponent: Symbol, outcome: Result) u32 {
    return getPlayerScore(opponent, switch (outcome) {
        .loss => switch (opponent) {
            .rock => .scissors,
            .paper => .rock,
            .scissors => .paper,
        },
        .draw => opponent,
        .win => switch (opponent) {
            .rock => .paper,
            .paper => .scissors,
            .scissors => .rock,
        },
    });
}
