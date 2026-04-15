# Auto Manual Vacuum Cleaner 

An Arduino-based smart vacuum cleaner project featuring dual-mode operation: **Autonomous Obstacle Avoidance** and **Manual Control** via Serial/Bluetooth. This project utilizes an ultrasonic sensor for navigation and a relay-controlled suction system.

---
![Project Simulation](Pic1.png)

## Features

* **Dual Mode Logic:** Seamlessly switch between manual steering and self-driving mode.
* **Intelligent Navigation:** Uses a Servo-mounted HC-SR04 sensor to scan 180° for the clearest path.
* **Non-Blocking Code:** Implements `millis()` for relay cycling and sensor checks, preventing the "stuttering" often caused by `delay()`.
* **Timed Suction:** A dedicated relay control cycles the vacuum motor to manage power efficiency.
* **Differential Drive:** Full 360° maneuverability using an L298N motor driver.

---

## Hardware Requirements

| Component | Pin / Type | Purpose |
| :--- | :--- | :--- |
| **Arduino Uno** | Microcontroller | Central processing unit |
| **L298N Driver** | Pins 3, 5, 6, 11 | Controls DC motor direction and speed |
| **HC-SR04** | Pins A2 (Echo), A3 (Trig) | Detects obstacles |
| **SG90 Servo** | Pin 9 | Rotates the "eye" (Ultrasonic sensor) |
| **Relay Module** | Pin A5 | Controls the Vacuum Motor power |
| **Mode Switch** | Pin A7 | Toggles between Auto and Manual |

---

## Connection Diagram

### Motor Driver (L298N)
* **Left Motor Forward:** Pin 5
* **Left Motor Backward:** Pin 6
* **Right Motor Forward:** Pin 3
* **Right Motor Backward:** Pin 11

### Peripherals
* **Servo Motor:** Pin 9
* **Ultrasonic Trig:** A3
* **Ultrasonic Echo:** A2
* **Relay Pin:** A5
* **Mode Toggle (Auto):** A7 (Analog read > 900 triggers Auto)

---

## Operation

### Autonomous Mode
When the `auto_pin` is high, the robot moves forward. Upon detecting an obstacle within **20cm**:
1.  It stops and reverses slightly.
2.  The servo scans **Right (10°)** and **Left (170°)**.
3.  The robot compares distances and turns toward the clear path.
4.  If both sides are blocked, it performs a wide right turn to U-turn.

### Manual Mode
The robot listens for Serial characters (Compatible with Bluetooth Terminal apps):
* `F` : Forward
* `B` : Backward
* `L` : Turn Left
* `R` : Turn Right
* `S` : Stop

---

## Software Installation

1.  **Install Libraries:**
    * `NewPing`: For high-performance ultrasonic ranging.
    * `Servo`: For controlling the sensor sweep.
2.  **Upload Code:** Use the Arduino IDE to flash the `.ino` file to your board.
3.  **Adjust Thresholds:** You can modify the `motorSpeed` (default 100) or `maximum_distance` in the variables section of the code.

---

## 📜 License
This project is open-source. Feel free to fork and modify!
