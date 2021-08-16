#include <Servo.h>

#ifndef BRACCIO
#define BRACCIO

// The software PWM is connected to PIN 12.
#define SOFT_START_CONTROL_PIN 12

// Low and High Limit Timeout for the Software PWM
#define LOW_LIMIT_TIMEOUT 2000
#define HIGH_LIMIT_TIMEOUT 6000

// The default value for the soft start
#define SOFT_START_DEFAULT_LEVEL 0

struct angles {
  // Base degrees. Allowed values from 0 to 180 degrees.
  int base = 0;

  // Shoulder degrees. Allowed values from 15 to 165 degrees.
  int shoulder = 45;

  // Elbow degrees. Allowed values from 0 to 180 degrees.
  int elbow = 180;

  // Wrist vertical degrees. Allowed values from 0 to 180 degrees.
  int wrist_ver = 180;

  // Wrist rotation degrees. Allowed values from 0 to 180 degrees.
  int wrist_rot = 90;

  // Gripper degrees. Allowed values from 10 to 73 degrees; 10: the gripper is
  // open, 73: the gripper is closed.
  int gripper = 10;
};

class Braccio {
  angles currentAngles;
  unsigned long lastStepTime;
  void softwarePWM(int high_time, int low_time);
  void servoStep(Servo servo, int targetAngle, int *currentAngle);

 public:
  /**
   * The taget angles of the braccio.
   * On each step the braccio will move towards these angles.
   */
  angles targetAngles;

  /**
   * Delay in milliseconds between each step.
   * If the `step()` method is called in an interval that is smalled tahn this
   * number it will have no effect.
   */
  int stepDelay = 10;

  /**
   * Initialize braccio
   * All the servo motors will be positioned in the default position (aka
   * default values in the `angles` struct).
   */
  void begin();

  /**
   * Move all the servos one step closer to the target angles.
   * All consecutive calls to this method that are done in an interval smaller
   * than `stepDelay` will have no effect.
   */
  void step();
};

#endif
