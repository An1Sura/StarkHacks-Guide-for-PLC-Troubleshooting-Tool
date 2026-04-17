# Demo Cases

## A. During System Design / Engineering Phase

### 1. Motor Start Blocked (Safety Interlock Logic Check)

- Description:
  Start command is active, but the conveyor does not run because the safety circuit is not healthy.
- Expected tags:
  `Start_Command=1`, `Safety_OK=0`, `Conveyor_Running=0`, `Fault_Code=101`
- Fault condition:
  Start is intentionally blocked by logic/permissive design.
- Expected AI explanation:
  The PLC is refusing to run because the safety input is not healthy. Check the E-stop string, guard switches, and safety relay feedback.
- Classification:
  `engineering_phase`
- Logic vs physical:
  Mostly logic/permissive interpretation first, then safety wiring/sensor validation second.

### 2. Sequence Timing Failure (Sensor/Timer Logic Validation)

- Description:
  A sequence step times out waiting for an expected transition.
- Expected tags:
  `Sequence_Timeout=1`, `System_Fault_Latch=1`, `Mode_Code=2`, `Fault_Code=301`
- Fault condition:
  Timer expired before expected process confirmation.
- Expected AI explanation:
  The sequence did not complete in time. Validate the timer preset, expected sensor transition, and Factory I/O tag mapping.
- Classification:
  `engineering_phase`
- Logic vs physical:
  Primarily logic/timing/mapping verification.

### 3. Tank Fill Control (Process Logic Verification)

- Description:
  Low-level demand exists, but the pump response or level behavior does not match expectations.
- Expected tags:
  `Tank_Level_Low=1`, `Tank_Level_High=0`, `Pump_Running=0`, `Mode_Code=3`, `Fault_Code=401`
- Fault condition:
  Fill sequence behavior is inconsistent with the expected process design.
- Expected AI explanation:
  The tank should be filling, but the pump or level sequence does not match the intended logic. Check level switch polarity and pump command/feedback mapping.
- Classification:
  `engineering_phase`
- Logic vs physical:
  Mostly process logic validation.

## B. After System Deployment / Technician Operations

### 4. Conveyor Jam Fault (Real-Time Failure + Troubleshooting)

- Description:
  Product is stuck on the conveyor, photo-eye remains blocked, and current rises.
- Expected tags:
  `Conveyor_Running=1`, `Sensor_Blocked=1`, `Motor_Current>=35`, `System_Fault_Latch=1`, `Fault_Code=201`
- Fault condition:
  Jam or stalled product condition.
- Expected AI explanation:
  The conveyor likely jammed. Stop the machine, clear the obstruction, inspect the sensor, and reset after the blocked signal clears.
- Classification:
  `technician_operations`
- Logic vs physical:
  Strongly physical/mechanical.

### 5. Fault + Reset (Latched Fault Recovery)

- Description:
  A fault stays latched after the triggering condition until the operator clears the cause and applies reset.
- Expected tags:
  `System_Fault_Latch=1`, `Reset_Command=0`, `Fault_Code` remains active
- Fault condition:
  Intentional latched-fault behavior.
- Expected AI explanation:
  The PLC is intentionally holding the fault. Fix the original cause first, then apply reset only after the system returns to a safe state.
- Classification:
  `technician_operations`
- Logic vs physical:
  PLC latching is intentional; original root cause may be either physical or logical.

### 6. HVAC / Pump Failure (Field Diagnostics Outside Factory)

- Description:
  A remote pump or HVAC package reports fault or fails to run when expected.
- Expected tags:
  `HVAC_Fault=1` or `Pump_Running=0` with a latched fault, `Mode_Code=4`, `Fault_Code=501`
- Fault condition:
  Field-device issue, overload, breaker trip, or missing permissive.
- Expected AI explanation:
  The controls side is seeing a remote device fault or missing feedback. Check the local unit, overloads, utility conditions, and device-level alarms.
- Classification:
  `technician_operations`
- Logic vs physical:
  Usually physical field diagnostics first.

## Recommended Demo Order

1. Motor Start Blocked
2. Conveyor Jam Fault
3. Fault + Reset
4. Sequence Timing Failure
5. Tank Fill Verification
6. HVAC / Pump Failure

This order tells the clearest story:

- first show intentional control logic
- then show real physical-like faults
- then show recovery
- then show broader applicability beyond a factory conveyor
