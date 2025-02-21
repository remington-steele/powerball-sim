const std = @import("std");
const lottery = @import("lottery.zig");
const display = @import("display.zig");
const config = @import("config.zig");

pub fn main() !void {
    // Set smaller font size
    try std.io.getStdOut().writer().writeAll("\x1b[?3l"); // Set 80x25 mode
    defer std.io.getStdOut().writer().writeAll("\x1b[?3h") catch {}; // Restore on exit

    // Initialize PRNG
    var prng = std.Random.Xoshiro256.init(blk: {
        var seed: u64 = undefined;
        try std.posix.getrandom(std.mem.asBytes(&seed));
        break :blk seed;
    });
    const random = prng.random();

    // Initialize display
    try display.init();
    defer display.deinit();

    // Generate winning numbers
    try display.showPickingWinningNumbers();
    const winning_numbers = try lottery.generateNumbers(std.crypto.random);
    try display.showWinningNumbersHidden();

    var stats = lottery.Stats{
        .total_spend = 0,
        .total_jackpot = config.INITIAL_JACKPOT,
        .attempts = 0,
    };

    // Main simulation loop
    var refresh_index: u32 = 0;
    while (true) {
        const guess = try lottery.generateNumbers(random);
        const matches = lottery.checkMatches(winning_numbers, guess);
        const is_jackpot = lottery.isJackpot(matches);

        refresh_index += 1;
        stats.attempts += 1;
        stats.total_spend += config.TICKET_COST;
        stats.total_jackpot += config.JACKPOT_INCREASE_PER_TICKET;

        if (refresh_index > config.GUESS_REFRESH_RATE) {
            refresh_index = 0;
            try drawScreen(guess, winning_numbers, matches, is_jackpot, stats);
        }

        // Check for jackpot
        if (lottery.isJackpot(matches)) {
            try drawScreen(guess, winning_numbers, matches, is_jackpot, stats);
            break;
        }

        if (config.GUESS_DELAY_MS > 0) {
            std.time.sleep(config.GUESS_DELAY_MS * 1_000_000);
        }
    }
}

pub fn drawScreen(guess: lottery.Numbers, winning_numbers: lottery.Numbers, matches: lottery.Matches, is_jackpot: bool, stats: lottery.Stats) !void {
    // Display current state
    try display.drawNumberGrid();
    try display.highlightGuessedNumbers(guess);
    try display.showGuessedNumbers(guess);
    try display.showStats(stats);

    if (is_jackpot or config.SHOW_MATCHING_NUMBERS) {
        try display.updateWinningNumbersDisplay(winning_numbers, matches);
    }

    // Check for jackpot
    if (lottery.isJackpot(matches)) {
        const taxes = stats.total_jackpot * config.TAX_RATE;
        const take_home = stats.total_jackpot - taxes;
        try display.showJackpotWin(stats.total_jackpot, taxes, take_home, stats.attempts);
    }
}
