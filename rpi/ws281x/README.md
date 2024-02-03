## Ws281x Service

Back-end for the Ws281x led strip manager at RPIs managed by the boot server. It is based on James Ridgway's [home-office-lights2](https://github.com/jamesridgway/home-office-lights2). Please note this is expected to be installed at RPIs, it was not tested at Tofu boot server.

### Install

```
sudo install-ws281x.sh ws281x.service

```

### Libs installed

Added to /usr/local/lib/python3.9/dist-packages.

```
pip                 23.3.2
flask               3.0.1
rpi_ws281x>=5.0.0   5.0.0
Werkzeug>=3.0.0     3.0.1
Jinja2>=3.1.2       3.1.3
itsdangerous        2.1.2
click>=8.1.3        8.1.7
blinker>=1.6.2      1.7.0
importlib-metadata  7.0.1
zipp>=0.5           3.17.0
MarkupSafe>=2.0     2.1.4
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
