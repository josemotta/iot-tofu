import time
import qwiic
import qwiic_vl53l1x
import RPi.GPIO as GPIO
from flask import Flask, request
# import board

# Back-end for VL53L1X Time-of-Flight (ToF) laser-ranging sensor
VERSION = "0.1"

# GPIO-21 pin connected to the sensor SHUTX pin
SHUTX_PIN_1 = 21

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
    GPIO.setmode(GPIO.BCM)
    GPIO.setup(SHUTX_PIN_1, GPIO.OUT)

    # Reset sensor
    GPIO.output(SHUTX_PIN_1, GPIO.LOW)
    time.sleep(0.01)
    GPIO.output(SHUTX_PIN_1, GPIO.HIGH)
    time.sleep(0.01)

    results = qwiic.list_devices()
    print(results)

    scan = qwiic.scan()
    print(scan)

    print("End status ...\n")
    return {
        'chip': "VL53L1X Time-of-Flight (ToF) laser-ranging sensor",
        'devices': results,
        'scan': scan,
        'version': VERSION
    }


@app.route('/test')
def test():
    print("VL53L1X Qwiic Test\n")

    # Set GPIO for shutdown pin
    GPIO.setwarnings(True)
    GPIO.setmode(GPIO.BCM)
    GPIO.setup(SHUTX_PIN_1, GPIO.OUT)

    # Reset sensor and enable it
    GPIO.output(SHUTX_PIN_1, GPIO.LOW)
    time.sleep(0.1)
    GPIO.output(SHUTX_PIN_1, GPIO.HIGH)
    time.sleep(0.1)

    ToF = qwiic_vl53l1x.QwiicVL53L1X(debug=1)

    if (ToF.sensor_init() == None):  # returns 0 on a good init
        print("Sensor online!\n")

    # Test takes 10 measures and return the mean value
    i = 0
    distance = 0

    # GPIO.output(SHUTX_PIN_1, GPIO.HIGH)
    # time.sleep(0.1)

    while i < 10:
        try:
            i += 1
            # Write configuration bytes to initiate measurement
            ToF.start_ranging()
            time.sleep(.05)
            # Get the result of the measurement from the sensor
            distance += ToF.get_distance()/10
            time.sleep(.05)
            # Write configuration bytes to finish measurement
            ToF.stop_ranging()
            time.sleep(.05)
            print("Distance(mm): %s " % (distance))

        except Exception as e:
            print(e)

    # Disable sensor
    GPIO.output(SHUTX_PIN_1, GPIO.LOW)
    time.sleep(0.1)

    return {
        'chip': "VL53L1X Time-of-Flight (ToF) laser-ranging sensor",
        'distance': distance,
        'version': VERSION
    }


if __name__ == '__main__':
    app.run(host="0.0.0.0")
