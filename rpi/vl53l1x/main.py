from flask import Flask, request
# import board

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
