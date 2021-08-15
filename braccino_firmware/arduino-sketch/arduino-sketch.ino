#include <PacketSerial.h>

#include "braccio.h"

PacketSerial packetSerial;
Braccio braccio;

int ledState = LOW;

void setup() {
  // Initialize seria connection
  packetSerial.begin(38400);
  packetSerial.setPacketHandler(&onPacketReceived);

  // Inintialize braccio
  braccio.begin();

  // Communicate that we are ready to accept commands
  uint8_t data[] = {0x00};
  packetSerial.send(data, sizeof(data));
}

void loop() {
  packetSerial.update();
  braccio.step();
}

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
  braccio.targetAngles.base = buffer[1];
  braccio.targetAngles.shoulder = buffer[2];
  braccio.targetAngles.elbow = buffer[3];
  braccio.targetAngles.wrist_ver = buffer[4];
  braccio.targetAngles.wrist_rot = buffer[5];
  braccio.targetAngles.gripper = buffer[6];
}
