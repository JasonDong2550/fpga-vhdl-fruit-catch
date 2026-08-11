# FPGA Fruit Catch
A fruit-catching game built in VHDL for FPGA hardware. The design generates VGA graphics in real time and implements gameplay entirely in hardware, including player movement, collision detection, score tracking, lives management, game states, and pseudo-random fruit spawning.

## Features
- 640×480 VGA output at 60 Hz
- 25 MHz pixel clock generated from a 50 MHz system clock
- Custom bitmap font rendering system
- Real-time basket movement using FPGA pushbuttons
- Falling fruits and bombs
- Collision detection system
- Score tracking and life management
- Pause and resume functionality
- Countdown timer before gameplay resumes
- Finite State Machine (FSM) game control
- LFSR-based pseudo-random fruit generation
- Hardware-based graphics and text generation using pixel coordinates

## Technologies Used
- VHDL
- Intel Quartus Prime

## Target Hardware
- Board: Terasic SoCKit
- FPGA: Cyclone V SoC
- Device: 5CSXFC6D6F31C6

## Hardware Requirements
- Terasic SoCKit FPGA development board
- VGA monitor
- VGA cable

## Controls
- KEY3 – Move Left
- KEY2 – Pause Game
- KEY1 – Start / Resume / Restart
- KEY0 – Move Right
- SW0 – Reset Game

## Usage
1. Open `catch_fruit.qpf` in Quartus Prime.
2. Verify the proper target device and pin assignments.
3. Compile the project.
4. Program the FPGA using Quartus Programmer.
5. Connect a VGA monitor to the board.
6. Use the pushbuttons to play the game.
**Note:** Pin assignments and project settings are included in `catch_fruit.qsf`.

## Files
- `catch_fruit.vhd` – Main game logic and VGA rendering system
- `catch_fruit.qpf` – Quartus project file
- `catch_fruit.qsf` – Pin assignments and project settings

## Technical Concepts Demonstrated
- Digital Logic Design
- Finite State Machines (FSMs)
- VGA Timing Generation
- Synchronous Sequential Logic
- Collision Detection
- Pseudo-Random Number Generation using LFSRs
- Custom Font Rendering
- FPGA-Based Game Development

## Hardware Demonstration
*Insert gameplay screenshot or video here.*
