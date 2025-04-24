import time
import qwiic
import qwiic_vl53l1x
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


@app.route('/status')
def status():
    results = qwiic.list_devices()
    print(results)
    return {
        'name': "Status from VL53L1X Time-of-Flight (ToF) laser-ranging sensor.",
        'version': "0.1",
        'status': "stat"
    }


@app.route('/test')
def test():

    print("VL53L1X Qwiic Test\n")
    ToF = qwiic_vl53l1x.QwiicVL53L1X(debug=1)
    if (ToF.sensor_init(debug=1) == None):		    # Begin returns 0 on a good init
        print("Sensor online!\n")

    while True:
        try:
            ToF.start_ranging()				# Write configuration bytes to initiate measurement
            time.sleep(.005)
            distance = ToF.get_distance()   # Get the result of the measurement from the sensor
            time.sleep(.005)
            ToF.stop_ranging()

            print("Distance(mm): %s " % (distance))

        except Exception as e:
            print(e)

    return stat()


def stat():
    return {
        'on': on
    }


if __name__ == '__main__':
    app.run(host="0.0.0.0")
