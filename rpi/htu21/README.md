## Backend for SHT21/HTU21 Digital Humidity & Temperature Sensor.

The Humidity and Temperature Sensor carries an SHT21 digital humidity and temperature sensor from Sensirion. The SHT21 utilizes a capacitive sensor element to measure humidity, while the temperature is measured by a band gap sensor. Both sensors are seamlessly coupled to a 14-bit ADC, which then transmits digital data over the I2C protocol. Because of the sensor's tiny size, it has incredibly low power consumption, making it suited for virtually any application.

- Bidirectional communication over a single pin on I2C protocol
- 4 pins: +5V, GND, Clock (SCL), Data (SDA)
- Temperature operating range: -40 to +125℃
- Temperature resolution of 0.01℃
- Relative Humidity operating range: 0-100% RH
- Relative Humidity resolution of 0.03%
- Energy consumption: 80 uW (at 12 bit, 3V, 1 measurement/s)

For more details, please check:

- SHT21/HTU21 Datasheet: https://www.amazon.com/HiLetgo-Digital-Humidity-Temperature-Replace/dp/B01N53H8SI
- PIP Library: https://github.com/MSeal/htu21df_sensor

- C code: https://github.com/leon-anavi/rpi-examples/tree/master/HTU21D/c

- I2C addresses: https://i2cdevices.org/addresses
- SparkFun Qwiic Hat: https://cdn.sparkfun.com/assets/b/6/8/c/8/Qwiic_HAT_for_Raspberry_Pi.pdf
- SparkFun Github: https://github.com/sparkfun/qwiic_vl53l1x_py
- Previous work with VL53L1X: https://github.com/josemotta/vl53l1x-python.

Please note this backend is expected to be **installed at RPIs**, not at Tofu boot server.

### Install backend at RPI

```
git clone https://github.com/josemotta/iot-tofu
cd iot-tofu/rpi/htu21
sudo ./install-htu21.sh

```

### Homeassistant

Please check the ha folder for an example of the Homeassistant configuration for a 'distance sensor'.

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

### Reinstall and restart backend

```
sudo ./restart-vl53l1x.sh

```
