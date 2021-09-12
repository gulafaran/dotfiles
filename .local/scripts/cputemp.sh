#!/bin/bash

value=$(</sys/class/hwmon/hwmon5/temp1_input)
celcius=$(($value / 1000))

echo "${celcius}C° "
