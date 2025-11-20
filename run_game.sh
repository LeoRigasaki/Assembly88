#!/bin/bash
nasm -f bin 2048.asm -o 2048.com
/Applications/dosbox.app/Contents/MacOS/DOSBox 2048.com 
