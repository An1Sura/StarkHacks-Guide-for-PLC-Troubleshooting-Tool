# Full Project Execution Guide

This is the practical step-by-step guide to get the entire project working without guessing. Use this as the main runbook. The goal is to get to a believable, repeatable hackathon demo, not to build the perfect long-term architecture on day one.

## 1. What You Are Building

You are building four connected pieces:

1. `CODESYS` runs the control logic.
2. `Factory I/O` simulates the machine.
3. `bridge.py` polls Modbus, tracks events, and generates diagnostics.
4. `dashboard.py` and `main.cpp` display the state to technicians.

The project is strongest when you keep those roles separate.

- PLC: deterministic control
- Factory I/O: machine behavior and sensors
- Python bridge: data integration and AI diagnostics
- ESP32: edge display and local alerting
- Streamlit: operator / engineering dashboard

## 2. Best Build Strategy

Do not build every scenario at once.

Build in this order:

1. One simple conveyor scene
2. One working register block
3. One successful Modbus read from Python
4. One live dashboard update
5. One live ESP32 update
6. One fault scenario with AI explanation
7. Then expand to the other demo scenarios

If you skip this order, debugging gets messy fast.

## 3. Folder Reference

Use these files as your source of truth:

- [README.md](/Users/suraa/Desktop/1/README.md)
- [plc_logic.st](/Users/suraa/Desktop/1/plc_logic.st)
- [register_map.md](/Users/suraa/Desktop/1/register_map.md)
- [factoryio_tag_plan.md](/Users/suraa/Desktop/1/factoryio_tag_plan.md)
- [bridge.py](/Users/suraa/Desktop/1/bridge.py)
- [modbus_smoke_test.py](/Users/suraa/Desktop/1/modbus_smoke_test.py)
- [dashboard.py](/Users/suraa/Desktop/1/dashboard.py)
- [main.cpp](/Users/suraa/Desktop/1/main.cpp)
- [demo_cases.md](/Users/suraa/Desktop/1/demo_cases.md)
- [demo_runbook.md](/Users/suraa/Desktop/1/demo_runbook.md)
- [commissioning_checklist.md](/Users/suraa/Desktop/1/commissioning_checklist.md)

## 4. Machine / OS Reality

The cleanest setup is:

- `Windows machine or VM` for CODESYS and Factory I/O
- `same Windows machine` or a second machine for Python bridge
- `ESP32` on the same Wi-Fi network as the Python bridge

Best hackathon method:

1. Run CODESYS + Factory I/O on one Windows machine.
2. Run Python on the same Windows machine if possible.
3. Use that machine’s LAN IP for the ESP32 connection.

That reduces network confusion.

## 5. Install Order

### Step 1. Install the core tools

Install in this order:

1. CODESYS
2. Factory I/O
3. Python 3.11+
4. Arduino IDE 2.x
5. ESP32 board support
6. Arduino libraries

Use [downloads_and_tools.md](/Users/suraa/Desktop/1/downloads_and_tools.md) while doing this.

### Step 2. Create the Python environment

In the repo root:

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
cp .env.example .env
```

Edit `.env`:

```env
OPENAI_API_KEY=your_real_key
MODBUS_HOST=127.0.0.1
MODBUS_PORT=502
MODBUS_UNIT_ID=1
FASTAPI_HOST=0.0.0.0
FASTAPI_PORT=8000
BACKEND_BASE_URL=http://127.0.0.1:8000
AI_MODEL=gpt-4o-mini
```

If Python runs on a different machine than CODESYS, set `MODBUS_HOST` to the Windows machine IP.

## 6. CODESYS Build Steps

### Step 1. Create the project

1. Open CODESYS.
2. Create a standard project.
3. Choose a normal IEC application target that supports Structured Text and Modbus server/slave setup.
4. Add an application if one is not already present.

### Step 2. Add the program logic

1. Create or open `PLC_PRG`.
2. Copy the contents of [plc_logic.st](/Users/suraa/Desktop/1/plc_logic.st) into it.
3. Make sure the variable names exactly match the register map.

### Step 3. Add Modbus TCP server/slave

1. In the device tree, add Modbus TCP server/slave support.
2. Create holding register mappings for the variables in [register_map.md](/Users/suraa/Desktop/1/register_map.md).
3. Keep the addresses exactly aligned with the documentation.

Do not improvise the addresses midway through the build.

### Step 4. Make the first proof

Before connecting Factory I/O:

1. Force or toggle one boolean in CODESYS.
2. Use [modbus_smoke_test.py](/Users/suraa/Desktop/1/modbus_smoke_test.py) to confirm Python can read it.

If this does not work, stop there and fix Modbus before touching the rest of the stack.

## 7. Factory I/O Build Steps

Use [factoryio_tag_plan.md](/Users/suraa/Desktop/1/factoryio_tag_plan.md) as the mapping plan.

### Step 1. Build the minimum conveyor scene

Start with:

- one conveyor
- one product source
- one jam/photo-eye sensor
- one start action

Do not start with tank + HVAC + conveyor together.

### Step 2. Connect Factory I/O to CODESYS

You want Factory I/O to interact with the PLC variables used in the ST program.

Initial minimum tag set:

- `Start_Command`
- `Conveyor_Running`
- `Sensor_Blocked`
- `Safety_OK`
- `System_Fault_Latch`
- `Fault_Code`

### Step 3. Verify the loop

Do this exact proof:

1. Move a box in Factory I/O.
2. Confirm the sensor changes in Factory I/O.
3. Confirm the matching variable changes in CODESYS.
4. Confirm the matching holding register changes in Modbus.
5. Confirm Python reads the same change.

If any one of those links fails, do not move forward yet.

## 8. Python Bridge Steps

### Step 1. Prove Modbus only

Run:

```bash
python modbus_smoke_test.py
```

What you want to see:

- `Conveyor_Running`
- `Sensor_Blocked`
- `Safety_OK`
- `Fault_Code`

changing as expected.

### Step 2. Run the bridge

```bash
python bridge.py
```

Check:

```bash
curl http://127.0.0.1:8000/health
curl http://127.0.0.1:8000/api/state
```

You want:

- `modbus: CONNECTED`
- current tags populated
- `machine.state_label` updating

### Step 3. Trigger a fault before using AI

First confirm the rule-based fallback works.

Example:

- set `Start_Command=1`
- set `Safety_OK=0`

Then inspect `/api/state` and make sure `active_issue` appears.

Only after that should you verify the LLM API behavior.

## 9. Streamlit Dashboard Steps

### Step 1. Start it

```bash
streamlit run dashboard.py
```

### Step 2. Verify the minimum view

You should see:

- machine state
- active severity
- live tags
- recent events
- AI diagnostics card

### Step 3. Test the chat

Ask questions like:

- “Why is the conveyor not starting?”
- “Does this look like logic or a physical jam?”
- “What should the technician check first?”

If the chat feels too vague, use shorter, more grounded prompts and keep the tags clean.

## 10. ESP32 Build Steps

Use [esp32_wiring.md](/Users/suraa/Desktop/1/esp32_wiring.md) for hardware and [main.cpp](/Users/suraa/Desktop/1/main.cpp) for firmware.

### Step 1. Wire it

At minimum:

- OLED
- LED on GPIO 2
- USB power

Buttons are optional for the first demo pass.

### Step 2. Configure the firmware

Edit:

- `WIFI_SSID`
- `WIFI_PASSWORD`
- `BRIDGE_HOST`

Important:

- `BRIDGE_HOST` must be the computer IP running `bridge.py`
- it must not be `127.0.0.1`
- it must not be `localhost`

### Step 3. Upload and verify

Open Serial Monitor and confirm:

- Wi-Fi connects
- WebSocket connects
- messages arrive

Then verify:

- OLED shows connection state
- HIGH severity makes LED blink
- active issue summary appears

## 11. AI Setup Steps

### Step 1. Make sure the non-AI system already works

You should already have:

- live tags
- event log
- issue classification
- rule-based diagnostic summary

before using the API.

### Step 2. Add the API key

Set in `.env`:

```env
OPENAI_API_KEY=...
AI_MODEL=gpt-4o-mini
```

### Step 3. Trigger a clean scenario

Start with `Motor Start Blocked` or `Conveyor Jam`.

Those are the easiest for the AI to explain clearly because the tag story is simple.

## 12. Best Demo Strategy

The strongest demo sequence is:

1. `Motor Start Blocked`
2. `Conveyor Jam`
3. `Fault + Reset`
4. `Sequence Timeout`
5. `Tank Fill`
6. `HVAC / Pump`

Why this order works:

- first shows the AI understands intended PLC behavior
- second shows physical fault interpretation
- third shows recovery behavior
- fourth and fifth show engineering validation value
- sixth proves the concept is not only for conveyors

## 13. Recommended Scope For A Good Hackathon Demo

If time gets tight, lock scope to these “must-win” pieces:

1. One good conveyor scene
2. One working Modbus register block
3. One working dashboard
4. One working ESP32 display
5. Two excellent scenarios:
   - Motor Start Blocked
   - Conveyor Jam

Everything beyond that is a bonus.

That is enough for a convincing pitch.

## 14. Common Failure Points

### Modbus is not reading

Check:

- correct IP
- correct port
- correct slave/unit ID
- holding register offset
- firewall on the Windows machine

### Factory I/O changes but CODESYS does not

Check:

- tag mapping direction
- wrong PLC variable linked
- scene object mapped to the wrong signal

### CODESYS changes but Python does not

Check:

- holding register mapping
- off-by-one addressing confusion
- wrong Modbus target IP

### Dashboard works but ESP32 does not

Check:

- `BRIDGE_HOST`
- same Wi-Fi network
- WebSocket path `/ws/live`
- OLED wiring

### AI output is weak

Check:

- tags are too sparse
- event history is empty
- wrong scenario state
- too many scenarios mixed together at once

## 15. Final Pre-Demo Checklist

Use [commissioning_checklist.md](/Users/suraa/Desktop/1/commissioning_checklist.md) and [demo_runbook.md](/Users/suraa/Desktop/1/demo_runbook.md).

If you only remember one rule:

Make the signal chain observable at every step:

Factory I/O -> CODESYS -> Modbus -> Python -> Dashboard -> ESP32

That is what makes the demo feel real and controllable.
