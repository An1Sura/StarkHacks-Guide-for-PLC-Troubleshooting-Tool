# Modbus Register Map

This prototype assumes CODESYS is configured as a Modbus TCP server and exposes the following holding registers starting at address `0`.

## Core Registers

| Register | Tag | Type | Meaning | Example Use |
| --- | --- | --- | --- | --- |
| 0 | `Conveyor_Running` | BOOL | Conveyor motor run feedback or simulated run status | Verify conveyor actually started |
| 1 | `Sensor_Blocked` | BOOL | Photo-eye or jam sensor active | Jam detection |
| 2 | `Motor_Current` | INT | Motor current in deci-amps | Distinguish jam/stall from healthy running |
| 3 | `Safety_OK` | BOOL | Safety chain healthy | Start permissive |
| 4 | `Start_Command` | BOOL | Start request from panel/HMI | Start blocked diagnostics |
| 5 | `Stop_Command` | BOOL | Stop request | Sequence stop behavior |
| 6 | `Reset_Command` | BOOL | Fault reset request | Latched-fault recovery |
| 7 | `Tank_Level_Low` | BOOL | Low-level switch active | Tank fill demand |
| 8 | `Tank_Level_High` | BOOL | High-level switch active | Tank full stop condition |
| 9 | `Sequence_Timeout` | BOOL | Sequence step timeout bit | Engineering validation |
| 10 | `System_Fault_Latch` | BOOL | Master latched fault bit | Global fault state |
| 11 | `Pump_Running` | BOOL | Pump run feedback | Pump/HVAC scenario |
| 12 | `HVAC_Fault` | BOOL | External HVAC or skid fault input | Field diagnostics |
| 13 | `Mode_Code` | INT | Scenario selector | Distinguish demo modes |
| 14 | `Fault_Code` | INT | Fault code enum | Feed AI context and operator UI |

## Suggested `Mode_Code` Values

| Value | Label | Demo Scenario |
| --- | --- | --- |
| 0 | `IDLE` | System idle / commissioning |
| 1 | `CONVEYOR` | Conveyor run + jam demo |
| 2 | `SEQUENCE_TEST` | Timer / sequence validation |
| 3 | `TANK_FILL` | Tank fill verification |
| 4 | `HVAC_PUMP` | Remote equipment diagnostics |

## Suggested `Fault_Code` Values

| Value | Label | Meaning |
| --- | --- | --- |
| 0 | `NO_FAULT` | Normal operation |
| 101 | `START_BLOCKED_SAFETY` | Start request blocked because `Safety_OK = 0` |
| 201 | `CONVEYOR_JAM` | Jam/stall condition on conveyor |
| 301 | `SEQUENCE_TIMEOUT` | Expected step completion did not occur in time |
| 401 | `TANK_FILL_VERIFY` | Tank fill did not behave as expected |
| 501 | `HVAC_OR_PUMP_FAULT` | External equipment or pump problem |

## CODESYS Mapping Notes

1. Create global variables in CODESYS for each tag.
2. Add a Modbus TCP server/slave device in the device tree.
3. Map each variable to a holding register at the exact addresses above.
4. Keep boolean registers as `0` or `1` for easy decoding in Python.
5. Use `Mode_Code` and `Fault_Code` as simple integers rather than strings.

## Factory I/O Mapping Notes

1. In Factory I/O, map conveyor sensors, pushbuttons, tank levels, and actuators to the same PLC variables used in CODESYS.
2. Start with a single conveyor sensor pair before wiring all scenarios.
3. During the hackathon, validate one tag at a time:
   - move a box in Factory I/O
   - verify the CODESYS variable changes
   - verify the Modbus holding register changes
   - verify `bridge.py` shows the updated tag

## Practical Hackathon Advice

- Do not over-expand the map on day one.
- The baseline 15 registers are enough to prove the concept.
- If you add more registers, append them above `100` to keep the first block stable for the demo.
