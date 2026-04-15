# 6-Bit SAP-1 Computer — Team Red Hell

> A fully designed 6-bit Simple As Possible (SAP-1) computer built from scratch, featuring schematics, PCB layouts, and simulation for every component.

---

## Project Overview

This project implements a **6-bit SAP-1 (Simple As Possible) computer** using discrete logic ICs, flip-flops, and custom PCB designs. The computer includes a clock generator, program counter, memory, registers, ALU interface, and output display, all designed and simulated by Team Red Hell.

---

## Design Phases

### Phase A => Control & Addressing
- Clock Pulse Generator
- Program Counter
- Memory Address Register (MAR)

### Phase B => Memory & Registers
- Accumulator
- B Register
- Output Register
- Random Access Memory (RAM)

---

## Components

### Clock Pulse Generator
Generates clock pulses using a **555 timer IC** in two modes:
- **Astable mode** => automatic pulse generation
- **Monostable mode** => user-triggered pulse via push button

A MUX selects between the two modes. A **HALT** input from the control unit can stop the clock. AND and NOT gates handle mode switching.

[![Clock Pulse Generator](https://img.youtube.com/vi/yE09H5jo6jo/0.jpg)](https://www.youtube.com/watch?v=yE09H5jo6jo)

---

### Program Counter
A 3-bit counter built using three **74HC73 JK flip-flops**. The toggle output of each flip-flop feeds the next through an AND gate connected to the enable (CE) pin. Output is passed to the bus via a **74HC245 bus transceiver** when CE is high.

[![Program Counter](https://img.youtube.com/vi/_vcKQYqeWyQ/0.jpg)](https://www.youtube.com/watch?v=_vcKQYqeWyQ)

---

### Memory Address Register (MAR)
A 3-bit register built with **3 D flip-flops**, capable of addressing up to 8 memory locations (2³ = 8). Receives the address from the bus via the Program Counter. A tristate buffer controlled by the **Memory Address In (MI)** signal gates the address onto the RAM.

[![Memory Address Register](https://img.youtube.com/vi/w6HrN7XlIlU/0.jpg)](https://www.youtube.com/watch?v=w6HrN7XlIlU)

---

### Random Access Memory (RAM)
An **8×6-bit RAM** (48 binary cells) built using the **7489 IC** with a **74HC245 bus transceiver** for bus traffic control.

| Signal | Function |
|--------|----------|
| 6 Data Inputs | Entered manually by the operator |
| 3 Address Inputs (ADRS) | Selects one of 8 memory locations (000–111) |
| R/W | HIGH = Read mode, LOW = Write mode |
| RO | HIGH = RAM drives the bus |
| CS | Chip Select |

[![Random Access Memory](https://img.youtube.com/vi/Lms3fONN6hs/0.jpg)](https://www.youtube.com/watch?v=Lms3fONN6hs)

[![Input Unit and Address Selector](https://img.youtube.com/vi/cr2JjLy_pes/0.jpg)](https://www.youtube.com/watch?v=cr2JjLy_pes)

---

### Accumulator
An 8-bit buffer register (6-bit active) that stores intermediate arithmetic/logic results. Built using **74LS173** and **74LS365 ICs**.

- Inputs: Data (from bus), CLK, AI, Reset, AO
- Outputs: 6-bit to ALU + 6-bit to bus

[![Accumulator SAP-1](https://img.youtube.com/vi/vto_LA4GmE8/0.jpg)](https://www.youtube.com/watch?v=vto_LA4GmE8)

---

### B Register
A 6-bit buffer register built with **6 D flip-flops**, one per data bit. Holds the second operand for ALU add/subtract operations.

- Stores data when: data is on the bus **AND** positive clock edge **AND** BI is HIGH
- Sends output to the ALU

[![B Register](https://img.youtube.com/vi/vQqkdjLHWJI/0.jpg)](https://www.youtube.com/watch?v=vQqkdjLHWJI)

---

### Output Register
The final stage of SAP-1. Stores the result of all operations and drives **six 7-segment displays**.

| Signal | Function |
|--------|----------|
| CLK | HIGH = active, LOW = hold previous output |
| OI | HIGH = output register enabled (set by control unit) |
| RESET | Clears the register |

[![Output Unit](https://img.youtube.com/vi/m2XpYuWnOf0/0.jpg)](https://www.youtube.com/watch?v=m2XpYuWnOf0)

[![Output Register](https://img.youtube.com/vi/AUlU6UNl-cU/0.jpg)](https://www.youtube.com/watch?v=AUlU6UNl-cU)

---

## Additional Reference Videos

### Operation of SAP
[![Operation of SAP](https://img.youtube.com/vi/Y3k2vPMUREE/0.jpg)](https://www.youtube.com/watch?v=Y3k2vPMUREE)

### Arithmetic Logic Unit
[![Arithmetic Logic Unit](https://img.youtube.com/vi/qpgUpnCN3Jk/0.jpg)](https://www.youtube.com/watch?v=qpgUpnCN3Jk)

### Controller Sequencer
[![Controller Sequencer](https://img.youtube.com/vi/WgQtihCgnw8/0.jpg)](https://www.youtube.com/watch?v=WgQtihCgnw8)

### Instruction Register
[![Instruction Register](https://img.youtube.com/vi/eXS13GAtt28/0.jpg)](https://www.youtube.com/watch?v=eXS13GAtt28)

---

## Institution

**Islamic University of Technology (IUT)**  
Group Name: **Team Red Hell**

---

*Designed using Proteus for schematic capture and PCB layout.*
