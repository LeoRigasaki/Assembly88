# Assembly88 - Retro 2048 Game

A classic 2048 puzzle game implementation written entirely in x86 assembly language for DOS. This project was developed as a university assignment, showcasing low-level programming skills and retro game development.

![Platform](https://img.shields.io/badge/Platform-DOS-blue)
![Assembler](https://img.shields.io/badge/Assembler-NASM-green)
![License](https://img.shields.io/badge/License-MIT-yellow)

## 📖 Overview

This is a fully functional 2048 game that runs on DOS systems or DOSBox. The game features colorful tile displays, smooth keyboard controls, and all the classic 2048 mechanics you know and love - all implemented in pure x86 assembly!

## ✨ Features

- **Classic 2048 Gameplay**: 4x4 grid with tile merging mechanics
- **Color-Coded Tiles**: 12 different colors representing values from 2 to 2048
- **Arrow Key Controls**: Intuitive up/down/left/right movement
- **Random Tile Generation**: Uses BIOS system time for randomization
- **Welcome Screen**: Countdown timer and player information display
- **Text Mode Graphics**: Direct video memory manipulation for fast rendering
- **Pure Assembly**: Written entirely in x86 assembly language (16-bit real mode)
- **Compact Size**: Small footprint COM executable

## 🎮 Game Mechanics

- Use arrow keys (↑ ↓ ← →) to slide tiles in any direction
- When two tiles with the same number touch, they merge into one
- Each move spawns a new tile (value of 2)
- Tiles are color-coded based on their value for easy identification
- Press ESC to exit the game at any time

## 🔧 Requirements

### To Build:
- **NASM** (Netwide Assembler) - version 2.0 or higher
- Any text editor

### To Run:
- **DOSBox** - DOS emulator (recommended for modern systems)
- OR any DOS-compatible environment
- OR a real DOS/x86 machine (for the authentic retro experience!)

## 📦 Installation & Build

### Building the Game

1. Clone this repository:
```bash
git clone https://github.com/yourusername/Assembly88.git
cd Assembly88
```

2. Assemble the source code using NASM:
```bash
nasm -f bin x1.asm -o 2048.com
```

Alternatively, if you want to enable DOS-specific features:
```bash
nasm -f bin -dDOS x1.asm -o 2048.com
```

### Running the Game

#### Using DOSBox (Recommended for modern systems):

1. Install DOSBox:
   - **macOS**: `brew install dosbox`
   - **Linux**: `sudo apt-get install dosbox` or `sudo yum install dosbox`
   - **Windows**: Download from [dosbox.com](https://www.dosbox.com/)

2. Run the game:
```bash
dosbox 2048.com
```

Or mount the directory in DOSBox:
```
C:\> mount c ~/Assembly88
C:\> c:
C:\> 2048.com
```

#### On a real DOS system:
```
C:\> 2048.com
```

## 🎯 How to Play

1. Launch the game - you'll see a welcome screen with a 5-second countdown
2. The game starts with two random tiles on a 4x4 grid
3. Use the arrow keys to move tiles:
   - **↑** - Move tiles up
   - **↓** - Move tiles down
   - **←** - Move tiles left
   - **→** - Move tiles right
4. Tiles with the same number merge when they collide
5. Try to create a tile with the value 2048!
6. Press **ESC** to quit

## 🛠️ Technical Details

### Architecture
- **Language**: x86 Assembly (16-bit real mode)
- **Assembler**: NASM
- **Target**: DOS COM executable
- **Video Mode**: Text mode with direct VGA memory access (0xB800)
- **Origin**: 0x0100 (COM program format)

### BIOS Interrupts Used
- `INT 10h` - Video services (screen clearing, text printing, mode setting)
- `INT 16h` - Keyboard services (reading arrow key input)
- `INT 1Ah` - System time (for random number generation)
- `INT 20h` - Program termination

### Key Components
- **Grid Rendering**: Direct manipulation of video memory at 0xB800
- **Movement Logic**: Offset-based computation for 4-directional movement
- **Tile Merging**: In-place array manipulation with value doubling
- **Random Generation**: System clock-based random tile placement
- **Color Scheme**: Custom color attributes for each tile value

### Color Map
The game uses the following color scheme for tiles:
```
0    → Black (empty)
2    → Bright White on Green
4    → Bright White on Blue
8    → White on Red
16   → White on Magenta
32   → White on Brown
64   → White on Light Gray
128  → White on Green
256  → White on Cyan
512  → Yellow on Magenta
1024 → White on Light Red
2048 → Yellow on Blue
```

## 📁 Project Structure

```
Assembly88/
├── x1.asm          # Main source code (assembly)
├── README.md       # This file
└── 2048.com        # Compiled executable (generated)
```

## 🎓 Educational Value

This project demonstrates:
- Low-level programming concepts
- Direct hardware/BIOS interaction
- Memory management and addressing
- Efficient algorithm implementation in assembly
- Video memory manipulation
- Real-mode x86 programming
- Game logic implementation without high-level abstractions

## 🐛 Known Limitations

- Game doesn't detect win condition (reaching 2048)
- No game over detection when grid is full
- No score tracking
- Limited to 4x4 grid size
- DOS/DOSBox only (no modern OS support without emulation)

## 🔮 Running on Modern Systems

### macOS
1. Install DOSBox via Homebrew: `brew install dosbox`
2. Run: `dosbox 2048.com`

### Linux
1. Install DOSBox: `sudo apt install dosbox`
2. Run: `dosbox 2048.com`

### Windows
1. Download DOSBox from [dosbox.com](https://www.dosbox.com/)
2. Run: `dosbox 2048.com`

### Web Browser (Experimental)
You can also try running it in a browser using:
- [JS-DOS](https://js-dos.com/) - JavaScript DOS emulator
- [EM-DOSBOX](https://github.com/dreamlayers/em-dosbox) - Emscripten port of DOSBox

Upload the compiled `2048.com` file to these online emulators.

## 👨‍💻 Author

**Sohaib Ahmed**

This was a university project completed 3 years ago that earned excellent marks. It represents a deep dive into assembly language programming and retro game development.

## 📄 License

This project is licensed under the MIT License - see below for details:

```
MIT License

Copyright (c) 2025 Sohaib Ahmed

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

## 🙏 Acknowledgments

- Inspired by the original 2048 game by Gabriele Cirulli
- Built as a university assignment to explore assembly language programming
- Thanks to the DOSBox team for keeping DOS alive

## 🔗 Links

- [Original 2048 Game](https://github.com/gabrielecirulli/2048)
- [NASM Documentation](https://www.nasm.us/docs.php)
- [DOSBox](https://www.dosbox.com/)
- [x86 Assembly Guide](https://www.cs.virginia.edu/~evans/cs216/guides/x86.html)

---

**Note**: This is a retro project from 2022 preserved for educational and nostalgic purposes. Feel free to learn from it, modify it, or use it as inspiration for your own assembly projects!

**Enjoy the game!** 🎮✨
