# braccino

A simple Elixir application to control the Tinkerkit Braccio robotic arm through a web interface.

The name comes from Braccio (which is the name of the robot but also the Italian word for "arm") + Arduino.

## Hardware

- Raspberry Pi 3b
- Arduino Due
- Tinkerkit Braccio

## Project structure

- [braccino](./braccino): shared code between the firmware and the web interface
- [braccino_firmware](./braccino_firmware): the firmware for the Raspberry Pi 3b, created using Nerves
  - [arduino-sketch](./braccino_firmware/arduino-sketch): contains Arduino sketch files
- [braccino_ui](./braccino_ui): the web interface, created using Phoenix Live View

## How it works

The Tinkerkit Braccio robotic arm is controlled by an Arduino Due.
The Arduino Due is connected to the Raspberry Pi 3b via a USB cable and they communicate through UART.
The Raspberry Pi hosts a web interface to control the arm.

## Setting up

1. Clone this repository
2. Install the dependencies of `braccino`

    ```bash
    # inside braccino/
    mix deps.get
    ```

3. Install the dependencies of `braccino_ui`

    ```bash
    # inside braccino_ui/
    mix deps.get
    npm install --prefix assets
    ```

4. Build static assets of the web UI.

    ```bash
    # inside braccino_ui/
    npm install --prefix assets --production
    npm run deploy --prefix assets
    mix phx.digest
    ```

5. Install the dependencies of `braccino_firmware`

    ```bash
    # inside braccino_firmware/
    export MIX_TARGET=rpi3
    mix deps.get
    ```

6. Build the firmware

    ```bash
    # inside braccino_firmware/
    export MIX_TARGET=rpi3
    mix firmware
    ```

7. Either burn the firmware to an SD card or upload it to the Raspberry Pi 3b.

    ```bash
    # inside braccino_firmware/
    export MIX_TARGET=rpi3

    # to burn the firmware to an SD card
    mix firmware.burn

    # to upload the firmware
    mix upload
    ```

## Development

If you are using vscode there are two workspaces:

- `frontend.code-workspace` to use in the development of the web interface
- `full-stack.code-workspace` to use in the development of the firmware + web interface

These workspaces contain extension recommendations and configuration.

### Frontend

This workspace includes only the `braccino` and `braccino_ui` folders.

To start the development server, first install the dependencies, then run `mix phx.server`.

### Fullstack

This workspace includes the `braccino`, `braccino_firmware` and `braccino_ui` folders.
It also contains various tasks to automate building the firmware and the web interface and to deploy to the Raspberry Pi.
