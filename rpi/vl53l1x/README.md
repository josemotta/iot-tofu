## Back-end for VL53L1X Time-of-Flight (ToF) laser-ranging sensor.

The VL53L1X is a state-of-the-art, Time-of-Flight (ToF) laser-ranging sensor, enhancing the ST FlightSense product family. It is the fastest miniature ToF sensor on the market with accurate ranging up to 4 m and fast ranging frequency up to 50 Hz.

For more details, please check https://github.com/josemotta/vl53l1x-python. This revision uses the latest Qwiic sparkfun-qwiic-vl53l1x at https://qwiic-vl53l1x-py.readthedocs.io/en/latest/index.html

Please note this is expected _to be installed at RPIs_, not at Tofu boot server.

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
curl http://127.0.0.1:5000/
{
     "chip": "VL53L1X Time-of-Flight (ToF) laser-ranging sensor",
     "version": "0.1"
}
```

#### Show Qwiic VL53L1X status

Call Qwiic methods list_devices() and scan(), returning their results.

- /status

```
curl http://127.0.0.1:5000/status
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
curl http://127.0.0.1:5000/test
{
     "chip": "VL53L1X Time-of-Flight (ToF) laser-ranging sensor",
     "distance": 70.1,
     "version": "0.1"
}
```
