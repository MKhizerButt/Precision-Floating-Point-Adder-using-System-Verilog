# Precision 16-Bit Floating-Point (bfloat16) Adder using SystemVerilog

## Overview
This repository contains the RTL implementation, testbench verification, and FPGA deployment of a synchronous, parameter-reduced **16-bit Floating-Point Adder** compliant with the `bfloat16` arithmetic structure (1 sign bit, 8 biased exponent bits, and 7 mantissa bits).

The architecture is driven by a robust **9-state Finite State Machine (FSM)** implemented sequentially within a synchronous `always_ff` framework. The design incorporates automated structural parsing, unique-case priority exception checking, alignment barrel-shifting, dynamic rounding, and post-computation normalisation.

---

## Key Features
* **Synchronous FSM Sequencer:** Coordinates input latching, intermediate alignment, and result compilation step-by-step to optimize timing and critical paths.
* **Comprehensive Corner-Case Handling:** Hardware-level handlers isolate and evaluate special IEEE-754 states—including zeros ($0+0$), Positive/Negative Infinities ($\pm\infty$), and Not-a-Number (NaN) calculations—routing them instantly to final output staging.
* **Resource-Optimized Datapath:** Built with structural optimizations that merge active buffer registers during physical mapping, resulting in minimal footprint overhead.
* **Hardware-Validated:** Verified natively via ModelSim behavioral testbenches and fully synthesized using Intel Quartus Prime for the **Intel/Altera Cyclone-V (5CSEMA5F31) FPGA** on the DE1-SoC platform.

---

## Hardware Architecture & Datapath

### Detailed Functionality

#### Extraction & Special Cases
The inputs are split into the respective sign bit, biased exponent bits, and mantissa with a leading 1 restored. Once extracted, special cases (e.g., zeros, infinity, and Not-a-Number) are detected. If such a case is found, the state machine jumps directly to the result state and concludes. For valid inputs, the exponents are compared, and the mantissa with the restored 1 is shifted accordingly. The mantissa with the larger exponent is stored in the non-shift register and vice versa.

#### Alignment & Sum/Difference Operation
The exponent of the result is determined at this stage (it may be incremented or decremented in the final normalisation step as per the location of the most significant 1 of the sum/difference register). The sign bit of the result is also assigned according to the sign of the higher exponent, or the larger mantissa if the exponents are equal. Once both numbers are equivalent in terms of the exponents, the shifted and non-shifted mantissas are then added or subtracted based on the sign bits. The result is stored in a 9-bit register to handle a potential overflow due to the addition of MSB 1s.

#### Normalisation & Result
Once the mathematical operation between the shifted and non-shifted mantissas is computed, the most significant 1 is located, and the bits following this 1 are extracted and saved as the resultant mantissa. This is done to comply with the IEEE-754 standard, as the leading 1 is assumed and not part of the result. Due to the 9-bit limitation, a rounding to the nearest smaller number may occur depending on the leading 1-bit location. The exponent of the result is adjusted either by incrementing or decrementing with respect to the bit position of the leading 1. The resultant sign bit, exponent bits, and mantissa bits are finally concatenated in the `sum` register and are output through the bus, while simultaneously asserting the `ready` output to indicate the start of the next addition sequence.

---

## Testing and Verification

### 1. Simulation (ModelSim)
To test and verify the working of the adder, ModelSim can be used to compile and simulate the Adder code and the test bench. Upon compiling, syntax and compilation errors can be identified. The `$display` and `$monitor` constructs have been used in the main module to monitor intermediate values and aid in debugging the code.

The inputs in the test bench can manually be changed for each run and are converted to the bfloat32 format using `$shortrealtobits` in the test bench. To test multiple values, the test bench has been modified to include random numbers using the `min + $random() % (max - min)` equation and perform multiple tests with the `$repeat()` construct. The simulation waveforms can be used to verify the availability of the result and the assertion of the `ready` signal, which has been implemented by introducing a separate state in the tested code to indicate when the design expects the next input in the subsequent clock cycle.

### 2. Synthesis (Intel Quartus Prime)
Quartus can be used to compile the design. Testing was performed on the DE1-SoC development board. The summary report indicated that logic utilisation was less than 1% (**196 / 32,070 Adaptive Logic Modules**), with a total of **112 registers** and **51 pins** out of the total 457 pins used. 

Optimisation during synthesis resulted in a merger between the `mantissa b` register and the restored `mantissa b` register, leading to a decrement of **42 registers**. The RTL view generated using the Netlist Viewer tool of Quartus depicts the final hardware implementation showing the number of adders, multipliers, and logic gates required for deployment.

---

## Project Structure
```text
├── rtl/
│   └── bfloat16_adder.sv          # Complete core FSM & arithmetic hardware block
├── sim/
│   └── test_bfloat16_adder.v      # Floating-point randomized 
