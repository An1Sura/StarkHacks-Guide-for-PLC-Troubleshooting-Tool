# Demo Runbook

This is the talk track and operator flow for the live demo.

## 1. Demo Goal

Show that:

- the PLC still owns control
- the machine behavior is simulated live
- a separate external diagnostics node can observe the machine
- AI can explain faults and guide troubleshooting without replacing the PLC

## 2. Best Window Layout

Use this layout:

1. `Factory I/O` on the left
2. `CODESYS` watch table on the top right
3. `Streamlit dashboard` on the bottom right
4. `ESP32` physically visible beside the laptop

That layout makes the signal chain easy to understand.

## 3. Demo Script

### Intro

Say:

“Here the PLC is running the logic in CODESYS, Factory I/O is acting as the machine, and this Python bridge is reading the PLC state over Modbus. The AI is only used as a diagnostics and explanation layer. This ESP32 is a separate edge diagnostics node near the machine.”

### Scenario 1: Motor Start Blocked

Steps:

1. Put the system in conveyor mode.
2. Make `Safety_OK` false.
3. Trigger `Start_Command`.
4. Show:
   - conveyor does not run
   - CODESYS shows the safety input is false
   - dashboard shows a start-blocked issue
   - ESP32 displays the issue summary

What to say:

“Here the system is not broken. The PLC is intentionally preventing motion because the safety permissive is false. The AI explains that in plain language instead of just showing a raw bit.”

### Scenario 2: Conveyor Jam

Steps:

1. Put the system back into a healthy run state.
2. Start the conveyor.
3. Force or create a blocked sensor condition.
4. Let the jam timer trip.
5. Show:
   - `Sensor_Blocked = 1`
   - `Motor_Current` rises
   - `System_Fault_Latch = 1`
   - `Fault_Code = 201`
   - HIGH severity appears
   - ESP32 LED blinks

What to say:

“Now this looks like a real runtime problem. The PLC is latching the fault, but the AI layer is telling the technician what is likely happening and what to check first.”

### Scenario 3: Fault + Reset

Steps:

1. Clear the jam condition.
2. Show the fault is still latched.
3. Trigger `Reset_Command`.
4. Show:
   - fault clears
   - machine returns to idle
   - dashboard event history tells the story

What to say:

“This shows the difference between removing the cause and actually recovering from a latched fault.”

### Scenario 4: Sequence Timeout

Steps:

1. Switch to sequence test mode.
2. Prevent the expected transition from occurring.
3. Let the timer expire.
4. Show timeout and engineering-focused diagnostics.

What to say:

“This scenario is useful during commissioning because the issue may be timing, mapping, or sequence design rather than a broken machine.”

### Scenario 5: Tank Fill

Steps:

1. Switch to tank fill mode.
2. Force low level without the expected pump feedback.
3. Show the verification/fault behavior.

What to say:

“This is where the same platform helps controls engineers validate process logic during system development.”

### Scenario 6: HVAC / Pump

Steps:

1. Switch to HVAC/pump mode.
2. Trigger `HVAC_Fault`.
3. Show the field-device style explanation.

What to say:

“The concept is not limited to conveyors. The same diagnostics approach can sit beside remote equipment and explain field alarms.”

## 4. Best Chat Questions

Ask these on the dashboard:

- “Why is the conveyor not starting?”
- “Does this look like a logic issue or a physical issue?”
- “What should the technician check first?”
- “Why is reset not enough by itself?”

## 5. If Something Goes Wrong Live

### If AI is slow

Say:

“Even without the cloud response, the platform still classifies the issue and provides fallback guidance from deterministic rules.”

### If ESP32 disconnects

Say:

“The edge node is optional for the core logic; the backend and dashboard still prove the concept.”

### If Factory I/O glitches

Switch to a forced-tag demo in CODESYS and show the Modbus-to-dashboard chain.

That is still a valid demonstration of the architecture.
