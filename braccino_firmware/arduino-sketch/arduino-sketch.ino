#include <PacketSerial.h>

PacketSerial packetSerial;

int ledState = LOW;

void setup() {
  packetSerial.begin(38400);
  packetSerial.setPacketHandler(&onPacketReceived);

  pinMode(LED_BUILTIN, OUTPUT);

  uint8_t data[] = {0x00};
  packetSerial.send(data, sizeof(data));
}

void loop() { packetSerial.update(); }

void onPacketReceived(const uint8_t *buffer, size_t size) {
  if (size == 0) return;

  uint8_t packetId = buffer[0];

  switch (packetId) {
    case 0x01:
      onSetAngles(buffer, size);
      break;
  }
}

void onSetAngles(const uint8_t *buffer, size_t size) {
  if (size != 7) return;

  // skip the packetId (buffer[0])
  int base = buffer[1];
  int shoulder = buffer[2];
  int elbow = buffer[3];
  int wrist_ver = buffer[4];
  int wrist_rot = buffer[5];
  int gripper = buffer[6];

  // TODO: set braccio servos
  // for now invert the led just to show that the packet has been received
  digitalWrite(LED_BUILTIN, ledState);
  ledState = ledState == LOW ? HIGH : LOW;
}
