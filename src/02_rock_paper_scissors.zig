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

const std = @import("std");

const name = "02_rock_paper_scissors";
const sample_input = @embedFile(name ++ "/sample-input.txt");
const sample_output = @embedFile(name ++ "/sample-output.txt");
const sample_part2_output = @embedFile(name ++ "/sample-part2-output.txt");
const input = @embedFile(name ++ "/input.txt");

const scores = [_]struct { id: []const u8, outcome: Outcome }{
    .{ .id = "A X", .outcome = Outcome.init(.rock, .rock) },
    .{ .id = "B X", .outcome = Outcome.init(.paper, .rock) },
    .{ .id = "C X", .outcome = Outcome.init(.scissors, .rock) },
    .{ .id = "A Y", .outcome = Outcome.init(.rock, .paper) },
    .{ .id = "B Y", .outcome = Outcome.init(.paper, .paper) },
    .{ .id = "C Y", .outcome = Outcome.init(.scissors, .paper) },
    .{ .id = "A Z", .outcome = Outcome.init(.rock, .scissors) },
    .{ .id = "B Z", .outcome = Outcome.init(.paper, .scissors) },
    .{ .id = "C Z", .outcome = Outcome.init(.scissors, .scissors) },
};

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();

    const sample_player_score = computePlayerScore(sample_input);
    const expected_player_score = std.fmt.parseInt(u32, std.mem.trimRight(u8, sample_output, "\n"), 10) catch unreachable;
    if (sample_player_score != expected_player_score) {
        std.debug.print("Expected {d}. Found {d}.\n", .{ expected_player_score, sample_player_score });
        unreachable;
    }

    const player_score = computePlayerScore(input);

    try stdout.print("{d}\n", .{player_score});
}

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

const Outcome = struct {
    opponent: Symbol,
    player: Symbol,
    player_score: u32,

    pub fn init(opponent: Symbol, player: Symbol) @This() {
        const player_score = @This().getPlayerScore(opponent, player);
        return .{
            .opponent = opponent,
            .player = player,
            .player_score = player_score,
        };
    }

    pub fn getPlayerScore(opponent: Symbol, player: Symbol) u32 {
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
};

fn computePlayerScore(rounds: []const u8) u32 {
    var rounds_it = std.mem.split(u8, rounds, "\n");
    var total_player_score: u32 = 0;
    var saw_end = false;
    while (rounds_it.next()) |round| {
        if (std.mem.eql(u8, round, "")) {
            // The only blank line we expect is at the end of the file.
            saw_end = true;
            continue;
        }
        // If we continue to see tokens after the expected end, it's a problem.
        if (saw_end) unreachable;

        const player_score = getRoundOutcome(round).player_score;
        total_player_score += player_score;
    }

    return total_player_score;
}

pub fn getRoundOutcome(round: []const u8) Outcome {
    for (scores) |score| {
        if (std.mem.eql(u8, round, score.id)) return score.outcome;
    }

    unreachable;
}
