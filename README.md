# RGB Image Noise Filtering System (FPGA)

This VHDL project implements a hardware-based pipeline for real-time noise reduction in RGB images. It processes all three color channels (Red, Green, Blue) in parallel and is designed to remove **Salt & Pepper noise** from input images using a fully modular and synthesizable FPGA architecture.

---

##  Project Summary

- **Input**: RGB image data from ROMs (`.mif`)
- **Output**: Denoised image data written to RAMs (`.mem`)
- **Architecture**: Three identical processing paths (R/G/B) with their own control logic, pipeline filter, ROM, and RAM
- **Use Case**: FPGA-based real-time image enhancement / denoising

---

##  Directory Structure

```plaintext
rgb_denoise_fpga/
├── src/
│   ├── control.vhd
│   ├── pipe.vhd
│   ├── rgb_system.vhd
│   ├── ROM_RED.vhd
│   ├── RAM_RED.vhd
│   ├── Pix_conv_pack.vhd
├── testbench/
│   └── tb_rgb_system.vhd
├── images/
│   ├── Baboon - 5% multicolor noise S&P.jpg
│   ├── Filtered Baboon.jpg
│   ├── Lena - 5% multicolor noise S&P.jpg
│   ├── Filtered Lena.jpg
│   └── full system.PNG
├── /input mif files
│   ├── ROMmemR.mif        # Input image data (Red)
│   ├── ROMmemG.mif        # Input image data (Green)
│   ├── ROMmemB.mif        # Input image data (Blue)
├── /output MEM files
│   ├── out_red.mem        # Output result from RAM (Red)
│   ├── out_green.mem      # Output result from RAM (Green)
│   ├── out_blue.mem       # Output result from RAM (Blue)
├── README.md
└── LICENSE (optional)
```

---

##  Architecture Overview

Each color channel is independently processed with:
- A **ROM** feeding raw pixel data
- A **Pipeline** implementing the noise filtering logic
- A **Control unit** orchestrating buffer enable/write
- A **RAM** capturing the filtered result

![System RTL Block Diagram](./images/full%20system.PNG)

---

##  Example Results

###  Baboon Image (Noisy vs Filtered)
| Input (5% S&P Noise) | Output |
|----------------------|--------|
| ![Baboon Noisy](./images/Baboon%20-%205%%20multicolor%20noise%20S%26P.jpg) | ![Baboon Clean](./images/Filtered%20Baboon.jpg) |

###  Lena Image (Noisy vs Filtered)
| Input (5% S&P Noise) | Output |
|----------------------|--------|
| ![Lena Noisy](./images/Lena%20-%205%%20multicolor%20noise%20S%26P.jpg) | ![Lena Clean](./images/Filtered%20Lena.jpg) |

---

##  Simulation

To run the simulation using **ModelSim**:

```tcl
vlib work
vcom src/Pix_conv_pack.vhd
vcom src/*.vhd
vcom testbench/tb_rgb_system.vhd
vsim tb_rgb_system
run -all
```

 You can compare the `.mem` RAM output files with the original `.mif` image ROMs for verification.

---

##  Features

- Triple parallel processing for R/G/B channels
- Modular design for synthesis and simulation
- Salt & Pepper noise reduction
- File I/O using `.mif` and `.mem` format
- RTL + testbench + visualization ready

---

##  Author

Developed by **Eldar Saltoun**  
 FPGA project for digital image processing using structural VHDL

---

##  License

This project is open source. 

