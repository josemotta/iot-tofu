## Back-end for VL53L1X Time-of-Flight (ToF) laser-ranging sensor.

The VL53L1X is a state-of-the-art, Time-of-Flight (ToF) laser-ranging sensor, enhancing the ST FlightSense product family. It is the fastest miniature ToF sensor on the market with accurate ranging up to 4 m and fast ranging frequency up to 50 Hz.

For more details, please check first version at https://github.com/josemotta/vl53l1x-python.

This revision uses the latest Qwiic sparkfun-qwiic-vl53l1x at https://qwiic-vl53l1x-py.readthedocs.io/en/latest/index.html

Please note this is expected to be installed at RPIs, not at Tofu boot server.

### Install

```
git clone https://github.com/josemotta/iot-tofu
cd iot-tofu/rpi/vl53l1x
sudo ./install-vl53l1x.sh

```

### Using the API

The API parameters are detailed below. The operations are used to turn on/off the leds & set their color and brightness. 'First & size' parameters allows managing a pixel segment, and the 'line' parameter allows repetition in a simplified matrix behaviour.

- **on**: true or false, indicates if pixels should be turned on or off
- **hue, sat, brightness**: pixel hue, saturation and brightness to be set
- **first, size**: a segment starting at 'first' pixel with 'size' pixels
- **line**: if not zero, keep repeating the operation, skipping 'line' pixels

If 'hue & sat' are not provided, the white color is applied. If 'size' is not provided, the whole led strip is applied. If 'line' is not provided, the operation is done just once.

#### Show version

- /

```
curl http://127.0.0.1:5000/
```

#### Show led strip status

- /led-strip

```
curl http://127.0.0.1:5000/led-strip
```

#### Turn on white led strip

- /led-strip/{on}

```
curl -d '{"on":true}' -H "Content-Type: application/json" -X POST http://127.0.0.1:5000/led-strip
```

#### Set led strip color & brightness

- /led-strip/{on, hue, sat, brightness}

```
curl -d '{"on":true, "hue":360, "sat":100, "brightness":255}' \
     -H "Content-Type: application/json" \
     -X POST http://127.0.0.1:5000/led-strip
```

#### Set led strip segment with color & brightness

- /led-strip/{on, hue, sat, brightness, first, size}

```
curl -d '{"on":true, "hue":360, "sat":100, "brightness":255, "first": 2, "size": 5}' \
     -H "Content-Type: application/json" \
     -X POST http://127.0.0.1:5000/led-strip
```

#### Set a column of led strip segments with color & brightness

- /led-strip/{on, hue, sat, brightness, first, size, line}

```
curl -d '{"on":true, "hue":360, "sat":100, "brightness":255, "first": 0, "size": 3, "line" : 9}' \
     -H "Content-Type: application/json" \
     -X POST http://127.0.0.1:5000/led-strip
```

Suppose a led strip with 45 pixels organized in 5 lines with 9 pixels each. Each line is grouped in a couple segments with 3 and 6 pixels respectively. The above command lights up the first 3 pixels at all 5 lines.

#### Turn off led strip

- /led-strip/{on}

```
curl -d '{"on":false}' -H "Content-Type: application/json" -X POST http://127.0.0.1:5000/led-strip

```

#### Turn off a led strip segment

- /led-strip/{on, first, size}

```
curl -d '{"on":false, "first": 2, "size": 5}' \
     -H "Content-Type: application/json" \
     -X POST http://127.0.0.1:5000/led-strip
```

#### Turn off a column of led strip segments

- /led-strip/{on, first, size, line}

```
curl -d '{"on":false, "first": 0, "size": 3, "line" : 9}' \
     -H "Content-Type: application/json" \
     -X POST http://127.0.0.1:5000/led-strip
```
