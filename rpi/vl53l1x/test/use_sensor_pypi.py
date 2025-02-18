#!/usr/bin/env python

import qwiic_vl53l1x
import time
from datetime import datetime

import RPi.GPIO as GPIO

# I2C addresses for each sensor
ADDRESS_1 = 0x29

# GPIO pins connected to the sensors SHUTX pins
SHUTX_PIN_1 = 23

# Arbitrary sensor id-s, should be unique for each sensor
sensor_id_1 = 1111

GPIO.setwarnings(False)

# Setup GPIO for shutdown pins on
GPIO.setmode(GPIO.BCM)
GPIO.setup(SHUTX_PIN_1, GPIO.OUT)

# Reset sensor
GPIO.output(SHUTX_PIN_1, GPIO.LOW)

time.sleep(0.01)
GPIO.output(SHUTX_PIN_1, GPIO.HIGH)
time.sleep(0.01)

# Init VL53L1X sensor
tof = qwiic_vl53l1x.QwiicVL53L1X()

# Set distance mode short (long = 2)
tof.set_distance_mode(1)

# tof.open()
# tof.add_sensor(sensor_id_1, ADDRESS_1)
# tof.start_ranging(sensor_id_1, 1)

for _ in range(0, 20):
    tof.start_ranging()
    time.sleep(.01)
    distance_mm = tof.get_distance()
    print("Sensor: {} mm".format(distance_mm))
    time.sleep(0.01)
    tof.stop_ranging()

# Clean-up
# tof.close()

GPIO.output(SHUTX_PIN_1, GPIO.LOW)

print("### Done: %s\n" % __file__)
