# BraccinoFirmware

Firmware for the Raspberry Pi 3b.
This project also contains the arduino sketch inside `arduino-sketch`.

## Targets

This code has been written for, and tested only on, the Raspberry Pi 3b with an Arduino Due.

Using a different Nerves target will probably work.

Using a different Arduino board will probably not work because the arduino sketch is uploaded using [`bossac`](https://github.com/shumatech/BOSSA/) which is made for ARM boards, so it won't work with AVR boards such as the Arduino Uno.

## Arduino flashing

The compiled arduino sketch and the `bossac` tool are included in the firmware image at compile time (see the [Makefile](./Makefile)).
When the Raspberry Pi boots, it will automatically flash the compiled sketch onto the Arduino Due using `bossac`.

## Communication protocol

The Arduino Due is connected to the Raspberry Pi via a USB cable and they communicate through UART.

### Packet format

- Each packet is [COBS](https://en.wikipedia.org/wiki/Consistent_Overhead_Byte_Stuffing) encoded.
- The end of each packet is market by the `0x00` byte.

#### General packet structure

| Name             | Size (bytes) | Description                                   |
| ---------------- | ------------ | --------------------------------------------- |
| `packet_id`      | 1            | Packet id                                     |
| packet fields... |              | Various packet fields depending on the packet |

### Packet list

#### Arduino Due -> Raspberry Pi

#### `0x00` ready

Sent to signal that the Arduino is ready (Braccio arm has been initialized and is ready to accept commands).
This packet does not contain any data.
This packet does not expect any response.

| name      | type | value  | description |
| --------- | ---- | ------ | ----------- |
| packet_id | byte | `0x00` |             |

#### Raspberry Pi -> Arduino Due

#### `0x01` set angles

Sent to the Arduino to set the Braccio position.
This packet does not expect any response.

| name      | type | value    | description                             |
| --------- | ---- | -------- | --------------------------------------- |
| packet_id | byte | `0x01`   |                                         |
| base      | byte | 0 - 180  | Desired position of the base joint      |
| shoulder  | byte | 15 - 165 | Desired position of the shoulder joint  |
| elbow     | byte | 0 - 180  | Desired position of the elbow joint     |
| wrist_ver | byte | 0 - 180  | Desired position of the wrist_ver joint |
| wrist_rot | byte | 0 - 180  | Desired position of the wrist_rot joint |
| gripper   | byte | 10 - 73  | Desired position of the gripper joint   |
