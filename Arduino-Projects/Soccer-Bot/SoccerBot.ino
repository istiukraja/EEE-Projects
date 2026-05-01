void setup() {
  Serial.begin(9600);  // Initialize serial communication (Bluetooth module) at 9600 baud rate

  pinMode(2, OUTPUT);   // BTS motor driver 1: L_EN / R_EN
  pinMode(3, OUTPUT);   // BTS motor driver 1: L_EN / R_EN
  pinMode(5, OUTPUT);   // BTS motor driver 1: L_PWM / R_PWM
  pinMode(6, OUTPUT);   // BTS motor driver 1: L_PWM / R_PWM

  pinMode(12, OUTPUT);  // BTS motor driver 2: L_EN / R_EN
  pinMode(13, OUTPUT);  // BTS motor driver 2: L_EN / R_EN
  pinMode(9, OUTPUT);   // BTS motor driver 2: L_PWM / R_PWM
  pinMode(10, OUTPUT);  // BTS motor driver 2: L_PWM / R_PWM
}

void loop() {
  // Enable both motor drivers
  digitalWrite(2, HIGH);
  digitalWrite(3, HIGH);
  digitalWrite(12, HIGH);
  digitalWrite(13, HIGH);

  // Check if any serial data is received
  if (Serial.available() > 0) {
    char letter = Serial.read();   // Read incoming command character
    Serial.println(letter);        // Echo received command to Serial Monitor

    if (letter == 'F') {
      // Move forward
      analogWrite(9, 255);   // Left motors forward full speed
      analogWrite(10, 0);    // Left motors reverse off
      analogWrite(5, 255);   // Right motors forward full speed
      analogWrite(6, 0);     // Right motors reverse off
    }

    if ((letter == 'B') || (letter == 'H') || (letter == 'J')) {
      // Move backward
      analogWrite(9, 0);
      analogWrite(10, 255);
      analogWrite(5, 0);
      analogWrite(6, 255);
    }

    if ((letter == 'R') || (letter == 'I')) {
      // Turn right (right pivot)
      analogWrite(9, 255);
      analogWrite(10, 0);
      analogWrite(5, 0);
      analogWrite(6, 255);
    }

    if ((letter == 'L') || (letter == 'G')) {
      // Turn left (left pivot)
      analogWrite(9, 0);
      analogWrite(10, 255);
      analogWrite(5, 255);
      analogWrite(6, 0);
    }

    if (letter == 'S') {
      // Stop all motors
      analogWrite(9, 0);
      analogWrite(10, 0);
      analogWrite(5, 0);
      analogWrite(6, 0);
    }
  }
}
