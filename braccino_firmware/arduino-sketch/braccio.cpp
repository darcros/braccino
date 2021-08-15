#include "braccio.h"

#include <Arduino.h>
#include <Servo.h>

// braccio servos
Servo base;
Servo shoulder;
Servo elbow;
Servo wrist_rot;
Servo wrist_ver;
Servo gripper;

void Braccio::softwarePWM(int high_time, int low_time) {
  digitalWrite(SOFT_START_CONTROL_PIN, HIGH);
  delayMicroseconds(high_time);
  digitalWrite(SOFT_START_CONTROL_PIN, LOW);
  delayMicroseconds(low_time);
}

void Braccio::begin() {
  // connect pins for soft start
  pinMode(SOFT_START_CONTROL_PIN, OUTPUT);
  digitalWrite(SOFT_START_CONTROL_PIN, LOW);

  // connect pins for servos
  base.attach(11);
  shoulder.attach(10);
  elbow.attach(9);
  wrist_ver.attach(6);
  wrist_rot.attach(5);
  gripper.attach(3);

  // set the initial position
  base.write(currentAngles.base);
  shoulder.write(currentAngles.shoulder);
  elbow.write(currentAngles.elbow);
  wrist_ver.write(currentAngles.wrist_ver);
  wrist_rot.write(currentAngles.wrist_rot);
  gripper.write(currentAngles.gripper);

  // do soft start
  long int tmp = millis();
  while (millis() - tmp < LOW_LIMIT_TIMEOUT)
    softwarePWM(80, 450);  // the sum should be 530usec

  while (millis() - tmp < HIGH_LIMIT_TIMEOUT)
    softwarePWM(75, 430);  // the sum should be 505usec

  digitalWrite(SOFT_START_CONTROL_PIN, HIGH);
}

void Braccio::servoStep(Servo servo, int targetAngle, int *currentAngle) {
  if (targetAngle != *currentAngle) {
    if (targetAngle > *currentAngle) {
      (*currentAngle)++;
    }

    if (targetAngle < *currentAngle) {
      (*currentAngle)--;
    }

    servo.write(*currentAngle);
  }
}

void Braccio::step() {
  // Apply a delay between each step
  unsigned long now = millis();
  if (now - lastStepTime < stepDelay) {
    return;
  }
  lastStepTime = now;

  // Check values, to avoid dangerous positions for the Braccio
  if (stepDelay > 30) stepDelay = 30;
  if (stepDelay < 10) stepDelay = 10;
  if (targetAngles.base < 0) targetAngles.base = 0;
  if (targetAngles.base > 180) targetAngles.base = 180;
  if (targetAngles.shoulder < 15) targetAngles.shoulder = 15;
  if (targetAngles.shoulder > 165) targetAngles.shoulder = 165;
  if (targetAngles.elbow < 0) targetAngles.elbow = 0;
  if (targetAngles.elbow > 180) targetAngles.elbow = 180;
  if (targetAngles.wrist_ver < 0) targetAngles.wrist_ver = 0;
  if (targetAngles.wrist_ver > 180) targetAngles.wrist_ver = 180;
  if (targetAngles.wrist_rot > 180) targetAngles.wrist_rot = 180;
  if (targetAngles.wrist_rot < 0) targetAngles.wrist_rot = 0;
  if (targetAngles.gripper < 10) targetAngles.gripper = 10;
  if (targetAngles.gripper > 73) targetAngles.gripper = 73;

  // For each servo motor if next degree is not the same as the previous then
  // do the movement
  servoStep(base, targetAngles.base, &currentAngles.base);
  servoStep(shoulder, targetAngles.shoulder, &currentAngles.shoulder);
  servoStep(elbow, targetAngles.elbow, &currentAngles.elbow);
  servoStep(wrist_ver, targetAngles.wrist_ver, &currentAngles.wrist_ver);
  servoStep(wrist_rot, targetAngles.wrist_rot, &currentAngles.wrist_rot);
  servoStep(gripper, targetAngles.gripper, &currentAngles.gripper);
}
