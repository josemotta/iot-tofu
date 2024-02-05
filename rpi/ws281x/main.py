import colorsys
import json
from flask import Flask, request
import board
import neopixel
# import time

# Choose an open pin connected to the Data In of the NeoPixel strip, i.e. board.D18
# NeoPixels must be connected to D10, D12, D18 or D21 to work.
pixel_pin = board.D18

# The number of NeoPixels
num_pixels = 20

# For RGBW NeoPixels, simply change the ORDER to RGBW or GRBW.
ORDER = neopixel.GRB

pixels = neopixel.NeoPixel(
    pixel_pin, num_pixels, brightness=0.2, auto_write=True, pixel_order=ORDER
)

on = False

app = Flask(__name__)


@app.route('/')
def hello():
    return {
        'name': "Back-end for ws281x led-strip",
        'version': "0.1"
    }


@app.route("/led-strip")
def status():
    return stat()


@app.route("/led-strip", methods=['POST'])
def fill():
    body = request.get_json()
    print(json.dumps(body, indent=2))
    hue = 0.0
    sat = 0.0
    brightness = 255
    if 'hue' in body:
        hue = body['hue'] / 360.0
    if 'sat' in body:
        sat = body['sat'] / 100.0
    if 'brightness' in body:
        brightness = int(body["brightness"])
    if 'on' in body:
        on = bool(body["on"])
    rgb = tuple(round(i * 255)
                for i in colorsys.hsv_to_rgb(hue, sat, brightness/255.0))
    if on:
        pixels.fill(rgb)
    else:
        pixels.fill((0, 0, 0))
    pixels.show()
    return stat()


def stat():
    return {
        'on': on
    }


if __name__ == '__main__':
    app.run(host="0.0.0.0")
