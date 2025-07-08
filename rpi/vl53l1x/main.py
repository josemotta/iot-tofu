# VL53L1X Time Of Flight (ToF) sensor
# Distance up to 4 m
# https://github.com/sparkfun/Qwiic_Distance_VL53L1X

import time
import qwiic
import qwiic_vl53l1x
import RPi.GPIO as GPIO
from flask import Flask, request
# import board

# Back-end for VL53L1X Time-of-Flight (ToF) laser-ranging sensor
VERSION = "0.1"

# GPIO-21 pin connected to the sensor SHUTX pin
# SHUTX_PIN_1 = 21
#
# A T T E N T I O N !   Please note that SHUTX connection to RPI bus was removed from project.
# Tests demonstrated that it is not necessary to reset sensor before each measure.
# The VL53L1X qwiic schematic shows a fixed 2K2 pull-up resistor for XSHUT, keeping it high all times.
# Then, original GPIO-21 may be released from on/off function and can be used for other purposes.
# The code related to SHUTX below is being commented for this reason.
# More details: https://community.st.com/t5/imaging-sensors/vl53l1x-xshut-pin/td-p/101168

app = Flask(__name__)


@app.route('/')
def hello():
    return {
        'chip': "VL53L1X Time-of-Flight (ToF) laser-ranging sensor",
        'version': VERSION
    }


@app.route('/status')
def status():
    print("Start status ...\n")
    GPIO.setwarnings(True)

    # Setup GPIO for shutdown pins on
    # GPIO.setmode(GPIO.BCM)
    # GPIO.setup(SHUTX_PIN_1, GPIO.OUT)

    # Reset sensor
    # GPIO.output(SHUTX_PIN_1, GPIO.LOW)
    # time.sleep(0.01)
    # GPIO.output(SHUTX_PIN_1, GPIO.HIGH)
    # time.sleep(0.01)

    results = qwiic.list_devices()
    scan = qwiic.scan()

    # ToF = qwiic_vl53l1x.QwiicVL53L1X(debug=1)
    # mode = ToF.get_distance_mode()

    print("devices", results, "scan", scan)
    print("End status ...\n")

    return {
        'chip': "VL53L1X Time-of-Flight (ToF) laser-ranging sensor",
        'devices': results,
        # 'mode': mode,
        'scan': scan,
        'version': VERSION
    }


@app.route('/test')
def test():
    print("VL53L1X Qwiic Test\n")

    # Set GPIO for shutdown pin
    # GPIO.setwarnings(True)
    # GPIO.setmode(GPIO.BCM)
    # GPIO.setup(SHUTX_PIN_1, GPIO.OUT)

    # Reset sensor and enable it
    # GPIO.output(SHUTX_PIN_1, GPIO.LOW)
    # time.sleep(0.1)  # wait 100 ms
    # GPIO.output(SHUTX_PIN_1, GPIO.HIGH)
    # time.sleep(0.1)  # wait 100 ms

    ToF = qwiic_vl53l1x.QwiicVL53L1X(debug=1)

    if (ToF.sensor_init() == None):  # returns 0 on a good init
        print("Sensor online!\n")
    else:
        print("Waiting for sensor ...")
        w = 0
        while not (ToF.sensor_init() == None):
            w += 10
            time.sleep(.01)  # wait 10 ms
        print(" ... online after %d ms\n" % w)

    # Take 10 measures in ~600 ms & return the mean value
    i = 0
    distance = 0

    # GPIO.output(SHUTX_PIN_1, GPIO.HIGH)
    # time.sleep(0.1)

    while i < 10:
        try:
            i += 1
            # Write configuration bytes to initiate measurement
            ToF.start_ranging()
            time.sleep(.02)
            # Get the result of the measurement from the sensor
            distance += ToF.get_distance()/10
            time.sleep(.02)
            # Write configuration bytes to finish measurement
            ToF.stop_ranging()
            time.sleep(.02)
            print("Distance(mm): %s " % (distance))

        except Exception as e:
            print(e)

    # Disable sensor
    # GPIO.output(SHUTX_PIN_1, GPIO.LOW)
    # time.sleep(0.1)

    return {
        'chip': "VL53L1X Time-of-Flight (ToF) laser-ranging sensor",
        'distance': distance,
        'version': VERSION
    }


if __name__ == '__main__':
    app.run(host="0.0.0.0")
