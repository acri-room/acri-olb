#!/usr/bin/env python3 

import serial
 
ser = serial.Serial('/dev/ttyUSB1', 115200, timeout=3)
ser.write(b"Hello wolrd\n")
line = ser.readline(128)
print(line) 
ser.close()

