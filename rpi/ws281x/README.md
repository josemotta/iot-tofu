## Back-end for ws281x led-strip

Back-end for the Ws281x led-strip connected to a RPI 4. It is supposed that this RPI is managed by the Tofu boot server. The idea was inspired by the [home-office-lights2](https://github.com/jamesridgway/home-office-lights2) but then upgraded to a supercharged version of the original driver.

This APi is going to be used by Homeassistant, see more about [using a template](https://www.jamesridgway.co.uk/using-a-template-light-to-control-a-custom-light-in-home-assistant/). Please note this is expected to be installed at RPIs, not at Tofu boot server.

### Install

```
git clone https://github.com/josemotta/iot-tofu
sudo iot-tofu/rpi/ws281x/install-ws281x.sh ws281x.service

```

### Using the API

The API parameters are detailed below. The operations are used to turn on/off the leds & set their color and brightness. 'First & size' parameters allows managing a pixel segment, and the 'line' parameter allows repetition in a simplified matrix behaviour.

- **on**: true or false, indicates if pixels should be turned on or off
- **hue, sat**: hue and saturation to be set
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
