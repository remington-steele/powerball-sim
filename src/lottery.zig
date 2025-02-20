const std = @import("std");
const config = @import("config.zig");

pub const Numbers = struct {
    white_balls: [config.WHITE_BALL_COUNT]u8,
    power_ball: u8,
};

pub const Stats = struct {
    total_spend: f64,
    total_jackpot: f64,
    attempts: u64,
};

pub const Matches = struct {
    white_matches: [config.WHITE_BALL_COUNT]bool,
    power_match: bool,
};

pub fn generateNumbers(random: std.Random) !Numbers {
    var numbers: Numbers = undefined;
    var used_numbers = std.AutoHashMap(u8, void).init(std.heap.page_allocator);
    defer used_numbers.deinit();

    // Generate white balls
    var i: usize = 0;
    while (i < config.WHITE_BALL_COUNT) {
        const num = random.intRangeAtMost(u8, 1, config.WHITE_BALL_MAX);
        if (!used_numbers.contains(num)) {
            try used_numbers.put(num, {});
            numbers.white_balls[i] = num;
            i += 1;
        }
    }

    // Generate power ball
    numbers.power_ball = random.intRangeAtMost(u8, 1, config.RED_BALL_MAX);

    return numbers;
}

pub fn checkMatches(winning: Numbers, guess: Numbers) Matches {
    // Create a lookup table for winning white balls with counts
    var white_lookup = [_]u8{0} ** (config.WHITE_BALL_MAX + 1);
    for (winning.white_balls) |num| {
        white_lookup[num] += 1;
    }

    // Check each guessed white ball against the lookup table
    var white_matches = [_]bool{false} ** config.WHITE_BALL_COUNT;
    for (guess.white_balls, 0..) |num, i| {
        if (white_lookup[num] > 0) {
            white_matches[i] = true;
            white_lookup[num] -= 1; // Mark this winning number as used
        }
    }

    return Matches{
        .white_matches = white_matches,
        .power_match = winning.power_ball == guess.power_ball,
    };
}

pub fn isJackpot(matches: Matches) bool {
    // All white balls must match and powerball must match
    for (matches.white_matches) |match| {
        if (!match) return false;
    }
    return matches.power_match;
}

fn checkMatchesHashMap(winning: Numbers, guess: Numbers) !Matches {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    var winning_set = std.AutoHashMap(u8, u8).init(arena.allocator());

    // Add winning numbers with counts
    for (winning.white_balls) |num| {
        const entry = try winning_set.getOrPut(num);
        if (!entry.found_existing) {
            entry.value_ptr.* = 0;
        }
        entry.value_ptr.* += 1;
    }

    var white_matches = [_]bool{false} ** config.WHITE_BALL_COUNT;
    for (guess.white_balls, 0..) |num, i| {
        if (winning_set.getPtr(num)) |count| {
            if (count.* > 0) {
                white_matches[i] = true;
                count.* -= 1;
            }
        }
    }

    return Matches{
        .white_matches = white_matches,
        .power_match = winning.power_ball == guess.power_ball,
    };
}

test "lottery number matching" {
    const testing = std.testing;

    // Test exact match
    {
        const winning = Numbers{ .white_balls = [_]u8{ 1, 2, 3, 4, 5 }, .power_ball = 1 };
        const guess = Numbers{ .white_balls = [_]u8{ 1, 2, 3, 4, 5 }, .power_ball = 1 };
        const matches = checkMatches(winning, guess);
        try testing.expect(isJackpot(matches));
    }

    // Test match in different order
    {
        const winning = Numbers{ .white_balls = [_]u8{ 1, 2, 3, 4, 5 }, .power_ball = 1 };
        const guess = Numbers{ .white_balls = [_]u8{ 5, 4, 3, 2, 1 }, .power_ball = 1 };
        const matches = checkMatches(winning, guess);
        try testing.expect(isJackpot(matches));
    }

    // Test no matches
    {
        const winning = Numbers{ .white_balls = [_]u8{ 1, 2, 3, 4, 5 }, .power_ball = 1 };
        const guess = Numbers{ .white_balls = [_]u8{ 6, 7, 8, 9, 10 }, .power_ball = 2 };
        const matches = checkMatches(winning, guess);
        try testing.expect(!isJackpot(matches));
        for (matches.white_matches) |match| {
            try testing.expect(!match);
        }
    }

    // Test duplicate numbers in guess (should not match multiple times)
    {
        const winning = Numbers{ .white_balls = [_]u8{ 1, 2, 3, 4, 5 }, .power_ball = 1 };
        const guess = Numbers{ .white_balls = [_]u8{ 1, 1, 1, 1, 1 }, .power_ball = 1 };
        const matches = checkMatches(winning, guess);
        var match_count: u8 = 0;
        for (matches.white_matches) |match| {
            if (match) match_count += 1;
        }
        try testing.expect(match_count == 1); // Only one '1' should match
    }

    // Test partial matches
    {
        const winning = Numbers{ .white_balls = [_]u8{ 1, 2, 3, 4, 5 }, .power_ball = 1 };
        const guess = Numbers{ .white_balls = [_]u8{ 1, 2, 3, 9, 10 }, .power_ball = 1 };
        const matches = checkMatches(winning, guess);
        var match_count: u8 = 0;
        for (matches.white_matches) |match| {
            if (match) match_count += 1;
        }
        try testing.expect(match_count == 3); // Three numbers should match
    }
}
