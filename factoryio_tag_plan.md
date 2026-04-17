# Factory I/O Tag Plan

This guide tells you what to build in Factory I/O and how to map it cleanly into the PLC variables used by this project.

## 1. Best First Scene

Build this first:

- one conveyor
- one product source
- one photo-eye / blocked sensor
- one start action
- one stop action
- one jam condition you can force manually

This is enough to prove:

- live machine behavior
- PLC logic reaction
- Modbus telemetry
- AI diagnostics

## 2. Minimum Tags To Map First

| Factory I/O Concept | PLC Variable | Direction | Why It Matters |
| --- | --- | --- | --- |
| Start button | `Start_Command` | Factory I/O -> PLC | Start request |
| Stop button | `Stop_Command` | Factory I/O -> PLC | Safe stop path |
| Jam / blocked sensor | `Sensor_Blocked` | Factory I/O -> PLC | Primary jam trigger |
| Safety healthy switch | `Safety_OK` | Factory I/O -> PLC | Start blocked demo |
| Conveyor actuator | `Conveyor_Running` | PLC -> Factory I/O | Confirms PLC output |
| Fault lamp or state | `System_Fault_Latch` | PLC -> Factory I/O or view only | Fault visibility |
| Fault code display / indicator | `Fault_Code` | PLC -> Factory I/O or view only | Scenario visibility |

## 3. Recommended Expansion Tags

After the conveyor works, add:

| Factory I/O Concept | PLC Variable | Direction | Use |
| --- | --- | --- | --- |
| Tank low level switch | `Tank_Level_Low` | Factory I/O -> PLC | Fill demand |
| Tank high level switch | `Tank_Level_High` | Factory I/O -> PLC | Fill stop |
| Pump actuator / feedback | `Pump_Running` | PLC -> Factory I/O | Tank / HVAC scenarios |
| Reset button | `Reset_Command` | Factory I/O -> PLC | Fault reset story |
| Mode selector | `Mode_Code` | PLC internal / HMI style | Switch demo scenario |
| HVAC fault toggle | `HVAC_Fault` | Factory I/O -> PLC | Field diagnostics story |

## 4. Recommended Demo Object Mapping

### Conveyor Scenario

- Source creates box
- Conveyor moves product
- Photo-eye detects blocked condition
- Operator button starts/stops conveyor
- Manual jam can be created by stopping product flow or holding product at the sensor

### Tank Fill Scenario

- Tank object with low and high level detection
- Pump fills tank
- PLC starts pump on low level and stops on high level

### HVAC / Pump Scenario

This can be simple for the hackathon.

You do not need a photorealistic HVAC scene.

A valid demo version is:

- toggle switch for `HVAC_Fault`
- pump run indicator
- fault lamp
- dashboard + ESP32 explain the field diagnostics logic

## 5. Best Mapping Method

When you map tags, do it in a table outside the tool first.

Use this checklist format:

| Done | Scene Object | Direction | PLC Variable | Register | Notes |
| --- | --- | --- | --- | --- | --- |
| [ ] | Start pushbutton | Input | `Start_Command` | HR4 | Momentary |
| [ ] | Stop pushbutton | Input | `Stop_Command` | HR5 | Momentary |
| [ ] | Reset pushbutton | Input | `Reset_Command` | HR6 | Momentary |
| [ ] | Jam sensor | Input | `Sensor_Blocked` | HR1 | Active high |
| [ ] | Safety toggle | Input | `Safety_OK` | HR3 | Active high |
| [ ] | Conveyor motor | Output | `Conveyor_Running` | HR0 | Visualized in scene |
| [ ] | Pump output | Output | `Pump_Running` | HR11 | Tank/HVAC only |

If a signal behaves backwards, fix polarity immediately before building more.

## 6. The Best Practical Method

Use this exact order:

1. Build object in Factory I/O
2. Map it to a PLC variable
3. Watch that variable live in CODESYS
4. Read the matching holding register from Python
5. Trigger a visible response

That loop is how you avoid mystery bugs.

## 7. Common Tag Mapping Mistakes

- mapping the wrong direction
- forgetting a signal is active-low
- changing variable names after mapping
- inconsistent fault code handling
- mixing scenario logic too early

## 8. Recommended Scenario Control Method

Use `Mode_Code` inside the PLC to switch behavior.

Suggested values:

- `1` conveyor
- `2` sequence timing
- `3` tank fill
- `4` HVAC/pump

This is faster than rebuilding the PLC logic for each demo.

## 9. Best Hackathon Advice

Do not chase full realism in Factory I/O.

A good demo scene needs:

- believable motion
- clear sensor changes
- repeatable faults
- easy reset path

That is enough.
