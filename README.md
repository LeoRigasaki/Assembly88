# Retro 2048 in Assembly

This is a 2048 game implementation in 16-bit x86 Assembly, designed to run in a DOS environment.

## Prerequisites

To run this game on macOS, you need:
- **NASM**: The Netwide Assembler, to compile the code.
- **DOSBox**: An emulator to run the DOS executable.

You can install these via Homebrew:
```bash
brew install nasm dosbox
```

## Building and Running

A helper script is provided to assemble and run the game in one step:

```bash
./run_game.sh
```

Alternatively, you can run the commands manually:

1.  **Assemble**:
    ```bash
    nasm -f bin 2048.asm -o 2048.com
    ```

2.  **Run**:
    ```bash
    dosbox 2048.com
    ```

## Controls
- **Arrow Keys**: Move tiles (Up, Down, Left, Right)
- **Esc**: Exit the game
