# Homeassistant

## VL53L1X Time-of-Flight (ToF) laser-ranging sensor.

The VL53L1X is a state-of-the-art, Time-of-Flight (ToF) laser-ranging sensor, enhancing the ST FlightSense product family. It is the fastest miniature ToF sensor on the market with accurate ranging up to 4 m and fast ranging frequency up to 50 Hz.

Install the [configuration](configuration.yaml) for the Homeassistant 'distance sensor':

```
git clone https://github.com/josemotta/iot-tofu
cd iot-tofu/rpi/vl53l1x/ha
sudo install-ha.sh

```

Please note the configuration is expected to be **installed at RPIs** with proper sensor, not at Tofu boot server.

### Screenshots

![Screenshot from Boot server terminal](vl53l1x-screenshot.jpg)

![Homeassistant Graph from distance sensor](vl53l1x-ha-test-8.png)

![Prototype](vl53l1x-test.jpg)
