const std = @import("std");
const config = @import("config.zig");
const lottery = @import("lottery.zig");

// Add more color constants
const BOLD = "\x1b[1m";
const CYAN = "\x1b[36m";
const YELLOW = "\x1b[33m";
const GREEN = "\x1b[32m";
const BLUE = "\x1b[34m";
const MAGENTA = "\x1b[35m";

// Add a constant for box width
const BOX_WIDTH = 53; // Width including borders

pub fn init() !void {
    // Clear screen and hide cursor
    try std.io.getStdOut().writer().writeAll("\x1b[2J\x1b[?25l");
}

pub fn deinit() void {
    // Show cursor
    std.io.getStdOut().writer().writeAll("\x1b[?25h") catch {};
}

pub fn showPickingWinningNumbers() !void {
    const stdout = std.io.getStdOut().writer();
    try stdout.writeAll("\x1b[H\x1b[K");
    try stdout.print("{s}╔══════════════════════════════════════╗{s}\n", .{ CYAN, config.COLOR_RESET });
    try stdout.print("{s}║{s}{s} 🎲 Picking winning numbers... 🎲 {s}{s}║{s}\n", .{ CYAN, config.COLOR_RESET, YELLOW, config.COLOR_RESET, CYAN, config.COLOR_RESET });
    try stdout.print("{s}╚══════════════════════════════════════╝{s}\n", .{ CYAN, config.COLOR_RESET });
}

pub fn showWinningNumbersHidden() !void {
    const stdout = std.io.getStdOut().writer();
    try stdout.writeAll("\x1b[H\x1b[K");
    try stdout.print("{s}╔═══════════════════════════════════════════════════╗{s}\n", .{ CYAN, config.COLOR_RESET });
    try stdout.print("{s}║{s} Winning Numbers: XX XX XX XX XX - XX          {s}║{s}\n", .{ CYAN, YELLOW, CYAN, config.COLOR_RESET });
    try stdout.print("{s}╚═══════════════════════════════════════════════════╝{s}\n", .{ CYAN, config.COLOR_RESET });
}

pub fn drawNumberGrid() !void {
    const stdout = std.io.getStdOut().writer();
    try stdout.writeAll("\x1b[4;H"); // Move to line 4 (after winning numbers box)

    // Draw white ball grid header
    try stdout.print("{s}╔═══════════════════════════════════════════════════╗{s}\n", .{ BLUE, config.COLOR_RESET });
    try stdout.print("{s}║{s}{s}           🎱 White Balls (Pick 5) 🎱              {s}{s}║{s}\n", .{ BLUE, config.COLOR_RESET, MAGENTA, config.COLOR_RESET, BLUE, config.COLOR_RESET });
    try stdout.print("{s}╠═══════════════════════════════════════════════════╣{s}\n", .{ BLUE, config.COLOR_RESET });

    // Draw white ball numbers in a 5x14 grid (69 numbers)
    var num: u8 = 1;
    var row: usize = 0;
    while (row < 5) : (row += 1) {
        try stdout.print("{s}║{s} ", .{ BLUE, config.COLOR_RESET });
        var col: usize = 0;
        while (col < 14 and num <= config.WHITE_BALL_MAX) : (col += 1) {
            try stdout.print("{s}{:0>2} ", .{ config.COLOR_WHITE, num });
            num += 1;
        }
        // Pad the last row if needed
        while (col < 14) : (col += 1) {
            try stdout.print("   ", .{});
        }
        try stdout.print("{s}        ║{s}\n", .{ BLUE, config.COLOR_RESET });
    }
    try stdout.print("{s}╠═══════════════════════════════════════════════════╣{s}\n", .{ BLUE, config.COLOR_RESET });

    // Draw power ball grid header
    try stdout.print("{s}║{s}{s}           🔴 Power Ball (Pick 1) 🔴               {s}{s}║{s}\n", .{ GREEN, config.COLOR_RESET, MAGENTA, config.COLOR_RESET, GREEN, config.COLOR_RESET });
    try stdout.print("{s}╠═══════════════════════════════════════════════════╣{s}\n", .{ GREEN, config.COLOR_RESET });

    // Draw power ball numbers in two rows
    var powerball: u8 = 1;
    // First row of 13 numbers
    try stdout.print("{s}║{s} ", .{ GREEN, config.COLOR_RESET });
    while (powerball <= 13) : (powerball += 1) {
        try stdout.print("{s}{:0>2} ", .{ config.COLOR_WHITE, powerball });
    }
    try stdout.print("           {s}║{s}\n", .{ GREEN, config.COLOR_RESET }); // Padding for alignment

    // Second row of 13 numbers
    try stdout.print("{s}║{s} ", .{ GREEN, config.COLOR_RESET });
    while (powerball <= config.RED_BALL_MAX) : (powerball += 1) {
        try stdout.print("{s}{:0>2} ", .{ config.COLOR_WHITE, powerball });
    }
    // Pad the last row
    while (powerball <= 26) : (powerball += 1) {
        try stdout.print("   ", .{});
    }
    try stdout.print("{s}           ║{s}\n", .{ GREEN, config.COLOR_RESET });
    try stdout.print("{s}╚═══════════════════════════════════════════════════╝{s}\n", .{ GREEN, config.COLOR_RESET });
    // Add two blank lines
    try stdout.writeAll("\n\n");
}

pub fn highlightGuessedNumbers(numbers: lottery.Numbers) !void {
    const stdout = std.io.getStdOut().writer();

    // Highlight white balls
    for (numbers.white_balls) |num| {
        const row = (num - 1) / 14; // 14 numbers per row
        const col = (num - 1) % 14;
        try stdout.print("\x1b[{};{}H{s}{:0>2}", .{
            row + 7, // Adjust for header (3 lines), box drawing (2 lines), and title line
            col * 3 + 3, // Adjust for left border and spacing
            config.COLOR_RED,
            num,
        });
    }

    // Highlight power ball
    var powerball_row: u8 = 0;
    var col: u8 = 0;
    if (numbers.power_ball > 13) {
        powerball_row = 16; // Second powerball row
        col = (numbers.power_ball - 14) % 13;
    } else {
        powerball_row = 15; // First powerball row
        col = (numbers.power_ball - 1) % 13;
    }

    try stdout.print("\x1b[{};{}H{s}{:0>2}", .{
        powerball_row,
        col * 3 + 3, // Adjust for left border and spacing
        config.COLOR_RED,
        numbers.power_ball,
    });
}

pub fn showGuessedNumbers(numbers: lottery.Numbers) !void {
    const stdout = std.io.getStdOut().writer();
    try stdout.print("\x1b[19;H\x1b[K{s}Your Numbers:{s} ", .{ BOLD, config.COLOR_RESET });
    for (numbers.white_balls) |num| {
        try stdout.print("{s}{:0>2}{s} ", .{ YELLOW, num, config.COLOR_RESET });
    }
    try stdout.print("{s}-{s} {s}{:0>2}{s}\n", .{ BOLD, config.COLOR_RESET, config.COLOR_RED, numbers.power_ball, config.COLOR_RESET });
}

fn formatDollarAmount(amount: f64, writer: anytype) !void {
    // Get the whole number part
    const whole = @floor(amount);
    const decimal = @mod(amount, 1.0) * 100;

    // Convert to integer for easier processing
    const whole_int = @as(u64, @intFromFloat(whole));

    // Format with commas
    if (whole_int >= 1_000) {
        const billions = whole_int / 1_000_000_000;
        const millions = (whole_int % 1_000_000_000) / 1_000_000;
        const thousands = (whole_int % 1_000_000) / 1_000;
        const ones = whole_int % 1_000;

        if (billions > 0) {
            try writer.print("{d},", .{billions});
        }
        if (billions > 0 or millions > 0) {
            try writer.print("{:0>3},", .{millions});
        }
        if (billions > 0 or millions > 0 or thousands > 0) {
            try writer.print("{:0>3},", .{thousands});
        }
        try writer.print("{:0>3}.{:0>2}", .{ ones, @as(u32, @intFromFloat(decimal)) });
    } else {
        try writer.print("{d}.{:0>2}", .{ whole_int, @as(u32, @intFromFloat(decimal)) });
    }
}

pub fn showStats(stats: lottery.Stats) !void {
    const stdout = std.io.getStdOut().writer();
    try stdout.print("\x1b[20;H\x1b[K{s}TOTAL TICKETS:{s} {s}", .{ BOLD, config.COLOR_RESET, config.COLOR_RED });
    try formatNumber(stats.attempts, stdout);
    try stdout.print("{s}\n", .{config.COLOR_RESET});

    try stdout.print("\x1b[21;H\x1b[K{s}💰 TOTAL SPEND:{s} ${s}", .{ BOLD, config.COLOR_RESET, config.COLOR_RED });
    try formatDollarAmount(stats.total_spend, stdout);
    try stdout.print("{s}\n", .{config.COLOR_RESET});

    try stdout.print("\x1b[22;H\x1b[K{s}🏆 JACKPOT:{s} ${s}", .{ BOLD, config.COLOR_RESET, GREEN });
    try formatDollarAmount(stats.total_jackpot, stdout);
    try stdout.print("{s}\n", .{config.COLOR_RESET});
}

pub fn updateWinningNumbersDisplay(numbers: lottery.Numbers, matches: lottery.Matches) !void {
    const stdout = std.io.getStdOut().writer();
    try stdout.writeAll("\x1b[H\x1b[K");
    try stdout.print("{s}╔═══════════════════════════════════════════════════╗{s}\n", .{ CYAN, config.COLOR_RESET });
    try stdout.print("{s}║{s} Winning Numbers: ", .{ CYAN, YELLOW });

    for (numbers.white_balls, matches.white_matches) |num, match| {
        if (match) {
            try stdout.print("{s}{:0>2}{s} ", .{ config.COLOR_RED, num, YELLOW });
        } else {
            try stdout.print("XX ", .{});
        }
    }

    try stdout.writeAll("- ");
    if (matches.power_match) {
        try stdout.print("{s}{:0>2}{s}", .{ config.COLOR_RED, numbers.power_ball, YELLOW });
    } else {
        try stdout.writeAll("XX");
    }

    // Add padding to align right border
    try stdout.print("              {s}║{s}\n", .{ CYAN, config.COLOR_RESET });
    try stdout.print("{s}╚═══════════════════════════════════════════════════╝{s}\n", .{ CYAN, config.COLOR_RESET });
}

fn formatNumber(number: u64, writer: anytype) !void {
    if (number >= 1_000) {
        const billions = number / 1_000_000_000;
        const millions = (number % 1_000_000_000) / 1_000_000;
        const thousands = (number % 1_000_000) / 1_000;
        const ones = number % 1_000;

        if (billions > 0) {
            try writer.print("{d},", .{billions});
        }
        if (billions > 0 or millions > 0) {
            try writer.print("{:0>3},", .{millions});
        }
        if (billions > 0 or millions > 0 or thousands > 0) {
            try writer.print("{:0>3},", .{thousands});
        }
        try writer.print("{:0>3}", .{ones});
    } else {
        try writer.print("{d}", .{number});
    }
}

pub fn showJackpotWin(jackpot: f64, taxes: f64, take_home: f64, attempts: u64) !void {
    const stdout = std.io.getStdOut().writer();
    try stdout.print("\x1b[24;H\x1b[K{s}🎉 JACKPOT! 🎉{s}\n", .{ YELLOW, config.COLOR_RESET });

    try stdout.print("\x1b[25;H\x1b[K{s}You just won ${s}", .{ BOLD, GREEN });
    try formatDollarAmount(jackpot, stdout);
    try stdout.print("{s}!\n", .{config.COLOR_RESET});

    try stdout.print("\x1b[26;H\x1b[K{s}Taxes:{s} ${s}", .{ BOLD, config.COLOR_RESET, config.COLOR_RED });
    try formatDollarAmount(taxes, stdout);
    try stdout.print("{s}\n", .{config.COLOR_RESET});

    try stdout.print("\x1b[27;H\x1b[K{s}Take Home:{s} ${s}", .{ BOLD, config.COLOR_RESET, GREEN });
    try formatDollarAmount(take_home, stdout);
    try stdout.print("{s}\n", .{config.COLOR_RESET});

    try stdout.print("\x1b[28;H\x1b[K{s}Total tickets purchased:{s} {s}", .{ BOLD, config.COLOR_RESET, YELLOW });
    try formatNumber(attempts, stdout);
    try stdout.print("{s}\n", .{config.COLOR_RESET});

    // Add celebration ASCII art
    try stdout.print("\x1b[30;H\x1b[K{s}   🎊 🎈 🎉 CONGRATULATIONS! 🎉 🎈 🎊   {s}\n", .{ YELLOW, config.COLOR_RESET });
    try stdout.print("\x1b[31;H\x1b[K{s}          You're a WINNER!          {s}\n", .{ MAGENTA, config.COLOR_RESET });
}
