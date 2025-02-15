from flask import Flask, request
import board

# Choose an open pin connected to the Data In of the NeoPixel strip, i.e. board.D18
# NeoPixels must be connected to D10, D12, D18 or D21 to work.
pixel_pin = board.D18

on = False

app = Flask(__name__)


@app.route('/')
def hello():
    return {
        'name': "Back-end for VL53L1X Time-of-Flight (ToF) laser-ranging sensor.",
        'version': "0.1"
    }


def stat():
    return {
        'on': on
    }


if __name__ == '__main__':
    app.run(host="0.0.0.0")
