# VGA Controller Test Project (Pedroni VHDL)

## Overview
This project implements and tests a VGA controller based on examples from Pedroni’s VHDL book.  
It demonstrates how to display a black & white image on a VGA monitor using ROM initialization with an Altera `.mif` file.

## Features
- **Python utility** to convert 640x480 black & white `.BMP` images into Altera `.mif` format.
- **VHDL VGA controller code** to generate sync signals and pixel data.
- **ROM initialization** with `.mif` file containing image data.
- **Image display** on a VGA monitor via FPGA hardware.

## Workflow
1. Prepare a black & white `.BMP` image (resolution: 640x480).
2. Run the Python script to generate a `.mif` file:
   ```bash
   python bmp_to_mif.py input.bmp output.mif
