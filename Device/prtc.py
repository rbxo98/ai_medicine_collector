import time
import serial

ser = serial.Serial('/dev/ttyAMA4',9600)

def send(command):
    command = command
    ser.write(command.encode('utf-8'))
    print('send')
    time.sleep(1)

def rcv():
    send('distance')
    a=0
    for x in ser.read():
        a+=x
    return a
