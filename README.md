# Iot Tofu

This is a development platform using:

- hardware based on Raspberry Pi CM4 mounted on the Tofu board, as shown below,
- a backend generated by IBM LoopBack4 framework, and
- a frontend based on HomeAssistant framework.

![tofu-board](https://github.com/josemotta/iot-tofu/assets/86032/cc103d69-08f9-42e8-bbb8-e5f05c1d34d2)

## Boot-Back

This is the backend. It runs on the x86-64 machine for development but the final app runs on the Tofu Raspberry Pi board.

- the build action 'on push' creates the image 'josemottalopes/boot-back:latest' at docker hub
- the action uses a GitHub self-hosted runner installed at the local Tofu board

### LoopBack 4

The backend application is generated using [LoopBack 4 CLI](https://loopback.io/doc/en/lb4/Command-line-interface.html), please check out the [README](src/README.md).

As shown below, the LB4 provides automatic generation of a swagger-like frontend showing all the API details. It runs on both x86 (for development) and arm64 (for production) hardware.

![x86](https://github.com/josemotta/iot-tofu/assets/86032/411b03e2-00db-4e21-bd13-20b8e340768f)

## Home-Assistant

This is the frontend. It uses the well known [Home Assistant](https://www.home-assistant.io/).
