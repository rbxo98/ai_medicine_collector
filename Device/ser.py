import time
import serial

ser = serial.Serial('/dev/ttyAMA4',9600)

def send(command):
    command = command
    ser.write(command.encode('utf-8'))
    print('send')
    time.sleep(1)
    	
    	
#def rcv(command):    
while True:
    send('distance')
    a = ser.readline()
    a = a.decode('utf-8')
    print(a)
    time.sleep(1)
