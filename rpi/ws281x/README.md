# Ws281x Service

Back-end for the led strip manager.

Based on https://github.com/jamesridgway/home-office-lights2.

# Install

```
cd /home/jo/led-strip
sudo install-ws281x.sh ws281x.service

```
# Packages added to /usr/local/lib/python3.9/dist-packages

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

# Examples

The examples below turn off the leds and set them with color and brightness.

```
curl -d '{"on":false}' -H "Content-Type: application/json" -X POST http://127.0.0.1:5000/led-strip

curl -d '{"on":true, "hue":360, "sat":100, "brightness":255}' \
     -H "Content-Type: application/json" \
     -X POST http://127.0.0.1:5000/led-strip

```
