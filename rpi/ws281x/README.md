## Ws281x Service

Back-end for the Ws281x led strip manager at RPIs managed by the boot server. It is inspired on [home-office-lights2](https://github.com/jamesridgway/home-office-lights2) but upgraded to a supercharged version of the original driver.

Please note this back-end is expected to be installed at RPIs, and it was not tested at Tofu boot server.

### Install

```
git clone https://github.com/josemotta/iot-tofu
sudo iot-tofu/rpi/ws281x/install-ws281x.sh ws281x.service

```

### Using the API

The API is shown below to turn on/off the leds & set their color and brightness.

#### Show version: /

```
curl http://127.0.0.1:5000/
```

#### Show led strip status: /led-strip

```
curl http://127.0.0.1:5000/led-strip
```

#### Set whole led strip color & brightness: /led-strip/{on, hue, sat, brightness}

```
curl -d '{"on":true, "hue":360, "sat":100, "brightness":255}' \
     -H "Content-Type: application/json" \
     -X POST http://127.0.0.1:5000/led-strip
```

#### Turn off the led strip: /led-strip/{"on":false}

```
curl -d '{"on":false}' -H "Content-Type: application/json" -X POST http://127.0.0.1:5000/led-strip

```
