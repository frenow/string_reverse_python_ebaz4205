import sys
import time
import serial


SERIAL_PORT = 'COM20'
SERIAL_BAUD = 115200
ser = serial.Serial(SERIAL_PORT, SERIAL_BAUD, timeout=1)


def current_time():
    return time.strftime("%H:%M:%S", time.localtime())


def send_to_fpga(pmsg):
    msg = f"{pmsg}\n"
    ser.write(msg.encode('utf-8'))
    ser.flush()
    print(f'{current_time()} : Sent to FPGA: {msg.strip()}')


def read_from_fpga():
    line = ser.readline().decode('utf-8').strip()
    return line


message = 'Emerson Duarte\n'

try:
    print(f'{current_time()} : Reverse system from fpga EBAZ4205')
    send_to_fpga(message)
    result = read_from_fpga()
    print(result)
except Exception as e:
    print(f'{current_time()} : Error occurred: {e}, retrying in 5s.')
    time.sleep(5)