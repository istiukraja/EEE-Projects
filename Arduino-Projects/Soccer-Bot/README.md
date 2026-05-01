# Bluetooth Controlled Robot Car (Arduino + BTS Motor Driver)

This project is an Arduino-based Bluetooth controlled robot car using a BTS dual motor driver. The system receives commands via Bluetooth and controls the movement of a differential drive robot.

---
![Project Simulation](soccebot.jpg)
## Overview

The robot is controlled wirelessly using serial commands sent from a smartphone or any Bluetooth terminal application. The Arduino reads the incoming characters and drives the motors accordingly using PWM signals.

---

## Features

- Wireless control using Bluetooth
- Forward, backward, left, right, and stop movement
- Support for diagonal and combined movements
- Dual motor driver configuration
- Simple single-character command system

---

## Hardware Requirements

- Arduino Uno / Nano / Mega
- Bluetooth module (HC-05 or HC-06)
- BTS motor driver module (dual channel)
- DC motors (2 or 4 depending on chassis)
- Battery pack for motors
- Robot chassis
- Jumper wires

---

## Pin Configuration

### Motor Driver 1
- Pin 2 → Enable (L_EN / R_EN)
- Pin 3 → Enable (L_EN / R_EN)
- Pin 5 → PWM input
- Pin 6 → PWM input

### Motor Driver 2
- Pin 12 → Enable (L_EN / R_EN)
- Pin 13 → Enable (L_EN / R_EN)
- Pin 9 → PWM input
- Pin 10 → PWM input

---

## Bluetooth Commands

| Command | Function            |
|----------|--------------------|
| F        | Move forward       |
| B        | Move backward      |
| L        | Turn left          |
| R        | Turn right         |
| S        | Stop all motors    |
| G / I    | Forward left/right |
| H / J    | Backward left/right|

---

## Working Principle

The Arduino continuously checks for incoming serial data from the Bluetooth module. When a valid command is received, it sets the motor direction and speed using PWM outputs. Each command corresponds to a predefined motor state.

---

## Future Improvements

- Variable speed control using analog input values
- Integration of obstacle detection sensors
- Mobile application with graphical controls instead of terminal commands
- Improved motion control with smoother acceleration

---

## Author

This project was developed as a robotics control system using Arduino and Bluetooth communication.

---

## License

This project is intended for educational use.
