import colorsys
import json
from flask import Flask, jsonify, request
import time
import board
import neopixel

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
    rgb = tuple(round(i * 255) for i in colorsys.hsv_to_rgb(hue, sat, 1.0))
    if on:
        pixels.fill(rgb)
    else:
        pixels.fill((0, 0, 0))
    pixels.write()
    return stat()

# @app.route("/led-strip/fill", methods=['POST'])
# def toggle():
#     body = request.get_json()
#     print(json.dumps(body,indent=2))
#     hue = 0.0
#     sat = 0.0
#     first = 0
#     size = 0
#     brightness = 255
#     if first in body:
#         first = int(body['first'])
#     if size in body:
#         size = int(body['size'])
#     if 'hue' in body:
#         hue = body['hue'] / 360.0
#     if 'sat' in body:
#         sat = body['sat'] / 100.0
#     if 'brightness' in body:
#         brightness = int(body["brightness"])
#     rgb = colorsys.hsv_to_rgb(hue, sat, 1.0)
#     rgb_r = int(rgb[0] * 255)
#     rgb_g = int(rgb[1] * 255)
#     rgb_b = int(rgb[2] * 255)
#     if body['on']:
#         print(f'Fill pixels with {rgb_r} {rgb_g} {rgb_b}')
#         strip_manager.fill(rgb_r, rgb_g, rgb_b, first, size, brightness)
#     # else:
#     #     strip_manager.clear()

#     return jsonify(strip_manager.status())


def stat():
    return {
        'on': on
    }


if __name__ == '__main__':
    app.run(host="0.0.0.0")
