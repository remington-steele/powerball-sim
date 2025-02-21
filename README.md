# PowerBall Simulator

A terminal-based PowerBall lottery simulator written in Zig that visualizes the process of playing the lottery until hitting the jackpot. The simulator features a colorful, interactive display showing real-time statistics and lottery results.

## Features

- 🎱 Simulates PowerBall lottery gameplay with:
  - 5 white balls (numbers 1-69)
  - 1 red PowerBall (numbers 1-26)
- 💰 Real-time statistics tracking:
  - Total tickets purchased
  - Total money spent
  - Current jackpot amount
- 🎨 Interactive terminal UI with:
  - Color-coded number grid
  - Live number highlighting
  - Animated number selection
  - Dynamic winning number reveal
- 📊 Jackpot win statistics:
  - Final jackpot amount
  - Tax calculations
  - Take-home amount
  - Total attempts needed

## Prerequisites

- [Zig](https://ziglang.org/download/) (latest version recommended)
- A terminal that supports ANSI escape codes (such as a Linux terminal, or Windows WSL)

## Building and Running the Project

To build and run the project, run:

```bash
zig build run
```

## How It Works

The simulator continuously generates random lottery number combinations and compares them against a winning set of numbers. It keeps track of:

- Number of attempts
- Total money spent on tickets ($2 per ticket)
- Growing jackpot amount
- Matching numbers

When a jackpot is hit (all numbers match), the simulator displays:
- The final jackpot amount
- Tax deductions
- Net winnings
- Total number of attempts needed

## Screenshots

![image](https://github.com/user-attachments/assets/a0715462-c04a-44eb-bf0c-1ed583a8a196)

## Configuration

The simulator uses default PowerBall rules, but you can modify various settings in the config.zig file:
- Initial jackpot amount
- Ticket cost
- Tax rate
- Number ranges
- Display refresh rates


