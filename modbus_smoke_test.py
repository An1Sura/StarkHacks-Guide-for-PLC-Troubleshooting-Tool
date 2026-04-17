import asyncio
import os
from typing import Any

from dotenv import load_dotenv
from pymodbus.client import AsyncModbusTcpClient


load_dotenv()

MODBUS_HOST = os.getenv("MODBUS_HOST", "127.0.0.1")
MODBUS_PORT = int(os.getenv("MODBUS_PORT", "502"))
MODBUS_UNIT_ID = int(os.getenv("MODBUS_UNIT_ID", "1"))
REGISTER_COUNT = 15

REGISTER_NAMES = [
    "Conveyor_Running",
    "Sensor_Blocked",
    "Motor_Current",
    "Safety_OK",
    "Start_Command",
    "Stop_Command",
    "Reset_Command",
    "Tank_Level_Low",
    "Tank_Level_High",
    "Sequence_Timeout",
    "System_Fault_Latch",
    "Pump_Running",
    "HVAC_Fault",
    "Mode_Code",
    "Fault_Code",
]


def format_value(index: int, value: int) -> Any:
    if index in {0, 1, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12}:
        return bool(value)
    return value


async def main() -> None:
    client = AsyncModbusTcpClient(host=MODBUS_HOST, port=MODBUS_PORT, timeout=1.5)
    print(f"Connecting to Modbus TCP server at {MODBUS_HOST}:{MODBUS_PORT} (unit {MODBUS_UNIT_ID})")
    connected = await client.connect()
    if not connected:
        raise SystemExit("Could not connect. Check the PLC runtime, IP address, port, and firewall.")

    try:
        response = await client.read_holding_registers(
            address=0,
            count=REGISTER_COUNT,
            slave=MODBUS_UNIT_ID,
        )
        if response.isError():
            raise SystemExit(f"Modbus read failed: {response}")

        print("Read succeeded. Holding register snapshot:")
        for index, name in enumerate(REGISTER_NAMES):
            raw_value = response.registers[index]
            value = format_value(index, raw_value)
            print(f"HR{index:02d}  {name:<20} raw={raw_value:<5} decoded={value}")
    finally:
        client.close()


if __name__ == "__main__":
    asyncio.run(main())
