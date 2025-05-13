## Backend for VL53L1X Time-of-Flight (ToF) laser-ranging sensor.

The VL53L1X is a state-of-the-art, Time-of-Flight (ToF) laser-ranging sensor, enhancing the ST FlightSense product family. It is the fastest miniature ToF sensor on the market with accurate ranging up to 4 m and fast ranging frequency up to 50 Hz.

For more details, please check:

- VL53L1X Datasheet: https://cdn.sparkfun.com/assets/b/f/2/9/8/VL53L1X_Datasheet.pdf
- Qwiic_VL53L1X_Py API: https://qwiic-vl53l1x-py.readthedocs.io/en/latest/index.html
- API Reference: https://qwiic-vl53l1x-py.readthedocs.io/en/latest/apiref.html
- SparkFun API docs: https://docs.sparkfun.com/qwiic_vl53l1x_py/index.html
- PyPi: https://pypi.org/project/sparkfun-qwiic-vl53l1x/
- ST docs: https://www.st.com/en/imaging-and-photonics-solutions/vl53l1x.html#documentation
- ST manual: https://www.st.com/resource/en/user_manual/um2356-vl53l1x-api-user-manual-stmicroelectronics.pdf
- ST app: https://www.st.com/resource/en/application_presentation/ultra-low-power-tof-sensors.pdf
- SparkFun: https://www.sparkfun.com/sparkfun-distance-sensor-breakout-4-meter-vl53l1x-qwiic.html
- SparkFun Schematics: https://cdn.sparkfun.com/assets/3/5/c/e/2/Qwiic_Distance_Sensor_-_VL53L1X.pdf
- SparkFun Qwiic Hat: https://cdn.sparkfun.com/assets/b/6/8/c/8/Qwiic_HAT_for_Raspberry_Pi.pdf
- SparkFun Github: https://github.com/sparkfun/qwiic_vl53l1x_py
- Previous work with VL53L1X: https://github.com/josemotta/vl53l1x-python.

Please note this backend is expected to be **installed at RPIs**, not at Tofu boot server.

### Install backend

```
git clone https://github.com/josemotta/iot-tofu
cd iot-tofu/rpi/vl53l1x
sudo ./install-vl53l1x.sh

```

### Reinstall and restart backend

```
sudo ./restart-vl53l1x.sh

```

### Using the API

The API calls & responses are detailed below.

#### Show version

- /

```
curl http://127.0.0.1:5001/
{
     "chip": "VL53L1X Time-of-Flight (ToF) laser-ranging sensor",
     "version": "0.1"
}
```

#### Show Qwiic VL53L1X status

Call Qwiic methods list_devices() and scan(), returning their results.

- /status

```
curl http://127.0.0.1:5001/status
{
     "chip": "VL53L1X Time-of-Flight (ToF) laser-ranging sensor",
     "devices": [[41, "Qwiic 4m Distance Sensor (ToF)", "QwiicVL53L1X"]],
     "scan": [41],
     "version": "0.1"
}
```

#### Test Qwiic VL53L1X

Takes 10 measures within 1 second and return the mean value.

- /test

```
curl http://127.0.0.1:5001/test
{
     "chip": "VL53L1X Time-of-Flight (ToF) laser-ranging sensor",
     "distance": 70.1,
     "version": "0.1"
}
```

### Measure every second

Continuous testing.

```
watch -x -n 1 curl http://127.0.0.1:5001/test
```
