# What This Project Does And How It Works

This guide explains the project in plain language.

It is not the build manual. It is the “what is this system actually doing?” manual.

## 1. The Big Idea

This project is an industrial diagnostics prototype.

Its job is to watch a machine, read machine state from a PLC, detect meaningful problems, and explain those problems in language that makes sense to:

- technicians
- operators
- controls engineers
- commissioning engineers

It does **not** replace the PLC.

It does **not** take over machine control.

It does **not** run the control loop with AI.

Instead, it adds a separate diagnostics layer on top of normal industrial automation.

## 2. The Main Problem It Solves

In many industrial systems, when something goes wrong, people see:

- raw PLC bits
- generic fault codes
- HMI alarm text that is too short or too vague
- no context on whether the issue is:
  - expected control behavior
  - a sensor issue
  - a timing issue
  - a physical jam
  - a field device fault

This project tries to solve that by combining:

- live tags
- recent event history
- scenario logic context
- AI-generated explanations

The result is a system that can say things like:

“The conveyor did not start because the safety permissive is false.”

or:

“The PLC is reacting correctly, but the blocked sensor and elevated current suggest a physical jam.”

That is much more useful than only showing `Fault_Code = 201`.

## 3. What The Project Actually Includes

The project has five main parts:

1. `CODESYS`
2. `Factory I/O`
3. `Python bridge`
4. `Streamlit dashboard`
5. `ESP32 edge node`

Each one has a specific role.

## 4. Role Of Each Part

### CODESYS

CODESYS is the PLC logic environment.

It is responsible for:

- start/stop logic
- safety permissives
- fault latching
- timer-based sequence behavior
- tank fill logic
- HVAC/pump fault reaction

In other words:

the PLC still owns the control decisions.

### Factory I/O

Factory I/O is the machine simulation.

It gives you:

- a conveyor
- sensors
- moving products
- tank behavior
- fault-like physical interactions

It acts like a digital twin for the machine side.

### Python Bridge

The Python bridge is the central nervous system of the project.

It does the most integration work.

It is responsible for:

- reading PLC registers over Modbus TCP
- decoding the raw register values into named tags
- tracking state over time
- detecting transitions
- storing recent event history
- deciding when something looks abnormal
- triggering AI diagnostics
- broadcasting state to the dashboard and ESP32

It is the layer that turns “raw machine values” into “diagnostic context.”

### Streamlit Dashboard

The dashboard is the software user interface.

It shows:

- connection health
- live tags
- machine state
- active issue
- event history
- AI-generated explanation
- technician chat

This is the main “software HMI” for the prototype.

### ESP32 Edge Node

The ESP32 is a separate external diagnostics device.

It is meant to feel like a small machine-side accessory mounted near equipment.

It shows:

- connection state
- current issue summary
- next troubleshooting step
- severity via LED behavior

This is important because it proves the concept can work as an add-on node instead of replacing the PLC.

## 5. Fundamental Architecture

The architecture is:

```text
Factory I/O -> CODESYS PLC -> Modbus TCP -> Python bridge -> Dashboard + ESP32 + AI explanation
```

More specifically:

```text
Machine simulation changes sensor state
        ↓
PLC logic reacts to that state
        ↓
PLC exposes the state in Modbus registers
        ↓
Python reads those registers repeatedly
        ↓
Python detects state changes and faults
        ↓
Python generates diagnostics
        ↓
Python sends the result to the dashboard and ESP32
```

## 6. Why The Python Bridge Exists

The Python bridge is the most important concept in the project.

Without it, you would just have:

- a PLC
- a simulation
- maybe a dashboard that reads raw values

But the bridge adds:

- state memory
- event history
- logic interpretation
- AI integration
- multi-client broadcasting

This matters because diagnostics are not based on a single PLC bit alone.

Diagnostics become better when the system knows:

- what changed
- when it changed
- what was active before
- what fault code followed
- what scenario the machine is in

That is why the bridge exists.

## 7. Why AI Is Used Here

AI is used for explanation, not control.

That distinction is critical.

The AI is only asked to:

- summarize the issue
- suggest likely causes
- recommend troubleshooting steps
- separate logical behavior from physical causes
- answer operator or technician questions

The AI is **not** used to:

- write PLC outputs
- decide motor commands
- run safety logic
- close the control loop

That makes the prototype much more realistic and safer as an architecture.

## 8. How The System Detects Problems

The system does not send every scan to the AI.

That would be noisy, expensive, and unreliable.

Instead, the Python bridge uses logic like this:

1. Poll Modbus registers
2. Decode current tag values
3. Compare to the previous snapshot
4. Detect important transitions
5. Evaluate scenario-specific fault conditions
6. Create a rule-based issue immediately
7. Optionally call the LLM for a richer explanation

That means the project has two layers of diagnostics:

### Layer 1: deterministic rule-based detection

This is fast and reliable.

Examples:

- `Start_Command = 1` and `Safety_OK = 0` -> start blocked
- `Sensor_Blocked = 1` and `Motor_Current` high -> likely jam
- `Sequence_Timeout = 1` -> sequence timing fault

### Layer 2: AI-generated explanation

This turns the machine context into better human-facing language.

That combination is important:

- rules detect
- AI explains

## 9. Why Event History Matters

A lot of industrial diagnostics are hard because the current state alone is not enough.

For example:

- a fault might already be latched
- the trigger condition may have already disappeared
- the operator sees only the end result

By tracking events, the bridge can tell a more useful story:

- `Start_Command changed from 0 to 1`
- `Safety_OK stayed false`
- `System_Fault_Latch changed from 0 to 1`
- `Fault_Code changed from 0 to 101`

That history makes the AI and the dashboard much more grounded.

## 10. Why The Separate ESP32 Matters

The ESP32 is not just there for show.

It proves a practical product idea:

an external machine-side diagnostics node.

Why that matters:

- many real machines already have PLCs
- replacing the PLC is expensive and risky
- retrofit diagnostics are more realistic
- a small external node can be mounted on or near a machine
- technicians often want guidance at the machine, not only on a laptop

So the ESP32 helps demonstrate a believable commercialization path.

## 11. Why There Are Different Demo Scenarios

The project is split into two categories:

### Engineering / design phase scenarios

These show value during:

- logic development
- commissioning
- sequence validation
- simulation testing

Examples:

- Motor Start Blocked
- Sequence Timing Failure
- Tank Fill Verification

### Technician / deployed operations scenarios

These show value after the machine is installed.

Examples:

- Conveyor Jam
- Fault + Reset
- HVAC / Pump Failure

That split is important because it shows the platform is useful both before and after deployment.

## 12. Fundamental Data Flow

Here is the real data flow in practical terms:

### Step 1. A sensor or simulated condition changes

Example:

- product blocks a photo-eye
- safety input goes false
- tank reaches high level
- HVAC fault input goes true

### Step 2. The PLC logic reacts

The PLC might:

- prevent start
- latch a fault
- stop the conveyor
- stop the pump
- set a fault code

### Step 3. The Modbus register map reflects that state

The PLC exposes those values through holding registers.

Example:

- `HR1 = Sensor_Blocked`
- `HR10 = System_Fault_Latch`
- `HR14 = Fault_Code`

### Step 4. The Python bridge polls the registers

The bridge reads those registers on a short interval and stores the snapshot.

### Step 5. The bridge evaluates meaning

It determines:

- whether something changed
- whether a fault condition is active
- what kind of issue it looks like

### Step 6. The bridge publishes the result

It sends the state to:

- the dashboard
- the ESP32

### Step 7. The AI explains it

If appropriate, the bridge also asks the LLM for a grounded explanation using:

- tags
- machine mode
- fault code
- recent event history

## 13. What Makes This Different From A Normal HMI

A normal HMI might show:

- alarms
- fault bits
- buttons
- simple status text

This project adds:

- event-aware interpretation
- issue classification
- control-vs-physical reasoning
- technician-friendly explanation
- an external edge diagnostics device

So it is closer to an intelligent diagnostics assistant than a normal HMI alone.

## 14. What Makes The Architecture Good

The best part of this architecture is the separation of responsibilities.

### PLC

Still deterministic, still trusted, still in charge of control.

### Python bridge

Handles interpretation and integration.

### AI

Handles explanation only.

### ESP32

Handles edge display and alerting.

That separation keeps the design realistic and easier to defend technically.

## 15. What The Demo Is Really Proving

The demo is proving three things:

### 1. Industrial controls data can be observed in real time

This comes from:

- CODESYS
- Factory I/O
- Modbus polling

### 2. A separate diagnostics layer can add real value

This comes from:

- event logging
- issue classification
- dashboard visibility
- edge device visibility

### 3. AI can be useful without being unsafe

This comes from:

- limiting AI to explanation
- grounding it in real tags and events
- keeping the PLC in charge

## 16. What “Success” Looks Like

A successful version of this project does not need to be huge.

It just needs to clearly show:

- one machine behavior
- one fault
- one clear explanation
- one useful technician action
- one separate edge device reacting correctly

If that works cleanly, the concept is strong.

## 17. Best Simple Summary

If you need the shortest explanation possible:

This project watches PLC-controlled machine behavior, reads live state over Modbus, keeps recent history, detects faults, explains them using AI, and displays those diagnostics both on a dashboard and on a separate ESP32 edge device near the machine.

## 18. Related Files

If you want to go from “what it is” into “how to build it,” go next to:

- [START_HERE.md](/Users/suraa/Desktop/1/START_HERE.md)
- [project_execution_guide.md](/Users/suraa/Desktop/1/project_execution_guide.md)
- [full_build_manual.md](/Users/suraa/Desktop/1/full_build_manual.md)
- [codesys_import_guide.md](/Users/suraa/Desktop/1/codesys_import_guide.md)
