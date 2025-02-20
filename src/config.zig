pub const INITIAL_JACKPOT: f64 = 20_000_000.0;
pub const TICKET_COST: f64 = 2.0;
pub const JACKPOT_INCREASE_PER_TICKET: f64 = 1.0;
pub const TAX_RATE: f64 = 0.5;
pub const SHOW_MATCHING_NUMBERS: bool = true;
pub const GUESS_DELAY_MS: u64 = 500;

pub const WHITE_BALL_COUNT: usize = 5;
pub const WHITE_BALL_MAX: u8 = 69;
pub const RED_BALL_MAX: u8 = 26;

// How many guesses to draw before refreshing the display
pub const GUESS_REFRESH_RATE: u32 = 55_555;

pub const COLOR_RESET = "\x1b[0m";
pub const COLOR_RED = "\x1b[91m";
pub const COLOR_WHITE = "\x1b[97m";

// Add these new color constants
pub const BOLD = "\x1b[1m";
pub const CYAN = "\x1b[36m";
pub const YELLOW = "\x1b[33m";
pub const GREEN = "\x1b[32m";
pub const BLUE = "\x1b[34m";
pub const MAGENTA = "\x1b[35m";
