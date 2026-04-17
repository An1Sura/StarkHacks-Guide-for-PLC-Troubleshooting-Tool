# Ultimate Guide

This is the main document for the project.

If you feel lost, come back to this file.

This guide is meant to be the single “command center” for the project so you do not need to bounce between a bunch of documents just to understand what is going on.

## 1. What This Project Is

This project is an industrial AI diagnostics prototype.

It combines:

- a PLC logic layer in `CODESYS`
- a machine simulation layer in `Factory I/O`
- a Python bridge that reads PLC data and creates diagnostics
- a computer dashboard UI in `Streamlit`
- a separate external hardware diagnostics node using an `ESP32`

The key idea is:

the PLC still controls the machine, and the AI only explains what is happening.

That means:

- the PLC remains deterministic
- the AI does not run the control loop
- the ESP32 is not pretending to be the PLC
- the system feels like a realistic retrofit diagnostics product

## 2. What Problem It Solves

Normal industrial systems often expose only:

- raw PLC bits
- short alarm text
- generic fault codes

That is not enough for operators or technicians.

This project improves that by taking:

- live machine tags
- recent event history
- scenario context
- fault codes

and turning them into:

- readable issue summaries
- likely cause explanations
- troubleshooting steps
- control-vs-physical reasoning

## 3. Core Architecture

The full architecture is:

```text
Factory I/O -> CODESYS PLC -> Modbus TCP -> Python bridge -> Dashboard + ESP32 + AI diagnostics
```

More practically:

1. Factory I/O simulates the machine.
2. CODESYS runs the control logic.
3. CODESYS exposes live state as Modbus holding registers.
4. Python reads those registers repeatedly.
5. Python detects changes and active issues.
6. Python creates rule-based diagnostics immediately.
7. Python optionally asks an external LLM for a grounded explanation.
8. Python sends the result to the dashboard and the ESP32.

## 4. What Each Code File Does

### Computer-side software

- [bridge.py](/Users/suraa/Desktop/1/bridge.py)
  Central backend. Polls Modbus, tracks events, detects issues, calls AI, and serves REST/WebSocket data.

- [dashboard.py](/Users/suraa/Desktop/1/dashboard.py)
  Computer dashboard UI. Shows tags, state, events, diagnostics, and chat.

- [modbus_smoke_test.py](/Users/suraa/Desktop/1/modbus_smoke_test.py)
  Small test script used before the full backend. Proves that Python can read the PLC registers.

### ESP32 hardware-side software

- [main.cpp](/Users/suraa/Desktop/1/main.cpp)
  Firmware for the external diagnostics node. Connects to Wi-Fi, listens to the backend, drives the OLED, and blinks the LED for high severity.

### PLC / CODESYS code

- [codesys_main_program.st](/Users/suraa/Desktop/1/codesys_main_program.st)
  Recommended main PLC program for the final demo.

- [codesys_globals.st](/Users/suraa/Desktop/1/codesys_globals.st)
  Global variables shared across the scenarios and Modbus map.

- [codesys_constants.st](/Users/suraa/Desktop/1/codesys_constants.st)
  Shared mode and fault-code constants.

- [codesys_fb_conveyor_demo.st](/Users/suraa/Desktop/1/codesys_fb_conveyor_demo.st)
  Conveyor logic, start blocked logic, jam logic, and sequence timeout behavior.

- [codesys_fb_tank_fill_demo.st](/Users/suraa/Desktop/1/codesys_fb_tank_fill_demo.st)
  Tank fill demo logic.

- [codesys_fb_hvac_demo.st](/Users/suraa/Desktop/1/codesys_fb_hvac_demo.st)
  HVAC / remote pump demo logic.

- [codesys_demo_supervisor.st](/Users/suraa/Desktop/1/codesys_demo_supervisor.st)
  Keeps unrelated outputs quiet when switching modes.

- [plc_logic.st](/Users/suraa/Desktop/1/plc_logic.st)
  Backup single-file PLC implementation. Use this only if you want a simpler emergency path.

### Configuration and reference files

- [.env.example](/Users/suraa/Desktop/1/.env.example)
  Template for API key, Modbus host, ports, and dashboard settings.

- [requirements.txt](/Users/suraa/Desktop/1/requirements.txt)
  Python package list.

- [register_map.md](/Users/suraa/Desktop/1/register_map.md)
  The source of truth for the Modbus holding register map.

- [esp32_wiring.md](/Users/suraa/Desktop/1/esp32_wiring.md)
  Hardware wiring guide for the ESP32 node.

## 5. Which Files You Actually Need To Follow

To avoid overload, use only these files as your main workflow:

1. [ULTIMATE_GUIDE.md](/Users/suraa/Desktop/1/ULTIMATE_GUIDE.md)
2. [codesys_import_guide.md](/Users/suraa/Desktop/1/codesys_import_guide.md)
3. [register_map.md](/Users/suraa/Desktop/1/register_map.md)
4. [factoryio_tag_plan.md](/Users/suraa/Desktop/1/factoryio_tag_plan.md)
5. [commissioning_checklist.md](/Users/suraa/Desktop/1/commissioning_checklist.md)
6. [demo_runbook.md](/Users/suraa/Desktop/1/demo_runbook.md)

Everything else is code or supporting reference.

## 6. Best Build Order

Follow this exact order:

If you want the fastest path to see the software stack working before the real PLC/simulation are wired, skip ahead briefly to [local_demo_mode.md](/Users/suraa/Desktop/1/local_demo_mode.md), then come back to the real build.

### Phase 1. Install the tools

Use:

- [downloads_and_tools.md](/Users/suraa/Desktop/1/downloads_and_tools.md)

Install:

- CODESYS
- Factory I/O
- Python
- Arduino IDE
- ESP32 board support
- Arduino libraries

### Phase 2. Set up the Python environment

Run:

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

### Phase 3. Build the PLC project in CODESYS

Use:

- [codesys_import_guide.md](/Users/suraa/Desktop/1/codesys_import_guide.md)

Recommended PLC path:

1. Create `GVL_Diagnostics`
2. Create `GVL_Constants`
3. Add the four function blocks
4. Replace `PLC_PRG` with [codesys_main_program.st](/Users/suraa/Desktop/1/codesys_main_program.st)
5. Build

### Phase 4. Map the Modbus registers

Use:

- [register_map.md](/Users/suraa/Desktop/1/register_map.md)

Important:

- do not improvise addresses
- keep the first 15 registers exactly as documented
- keep `Mode_Code` and `Fault_Code` stable across all scenarios

### Phase 5. Build the Factory I/O scene

Use:

- [factoryio_tag_plan.md](/Users/suraa/Desktop/1/factoryio_tag_plan.md)

Best first scene:

- one conveyor
- one jam/photo-eye sensor
- one start
- one stop
- one visible fault path

### Phase 6. Prove PLC -> Python

Run:

```bash
python modbus_smoke_test.py
```

Do not skip this.

If this fails, the rest of the project is not ready yet.

### Phase 7. Start the backend

Run:

```bash
python bridge.py
```

Then check:

```bash
curl http://127.0.0.1:8000/health
curl http://127.0.0.1:8000/api/state
```

What you want:

- backend alive
- Modbus connected
- tags populated
- machine state visible

If you are using local simulated mode instead of a real PLC source:

- set `DATA_SOURCE=mock`
- use [local_demo_mode.md](/Users/suraa/Desktop/1/local_demo_mode.md)

### Phase 8. Start the computer UI

Run:

```bash
streamlit run dashboard.py
```

This is the UI that runs on the computer.

It should show:

- machine state
- severity
- tags
- event history
- AI diagnostics
- technician chat

### Phase 9. Flash the ESP32

Use:

- [esp32_wiring.md](/Users/suraa/Desktop/1/esp32_wiring.md)
- [main.cpp](/Users/suraa/Desktop/1/main.cpp)

Set:

- Wi-Fi SSID
- Wi-Fi password
- `BRIDGE_HOST` to the computer IP running `bridge.py`

Important:

- not `localhost`
- not `127.0.0.1`
- use the real LAN IP

### Phase 10. Rehearse the demos

Use:

- [demo_cases.md](/Users/suraa/Desktop/1/demo_cases.md)
- [demo_runbook.md](/Users/suraa/Desktop/1/demo_runbook.md)
- [commissioning_checklist.md](/Users/suraa/Desktop/1/commissioning_checklist.md)

## 7. Best Demo Strategy

Do not try to polish every scenario equally.

Make these three excellent first:

1. `Motor Start Blocked`
2. `Conveyor Jam`
3. `Fault + Reset`

Why:

- they are the clearest
- they show both control logic and physical fault reasoning
- they work well on the dashboard and ESP32

Then expand to:

4. `Sequence Timeout`
5. `Tank Fill`
6. `HVAC / Pump`

## 8. What The Computer UI Does

The computer UI is:

- [dashboard.py](/Users/suraa/Desktop/1/dashboard.py)

It runs with Streamlit and is the main software interface for the user.

It shows:

- connection status
- current machine state
- current mode
- current fault/severity
- live register values
- recent event history
- AI or fallback diagnostics
- technician chat

How it gets data:

1. `bridge.py` exposes REST endpoints
2. `dashboard.py` polls those endpoints
3. the dashboard renders the returned state

In short:

the dashboard is the computer-side operator / technician UI.

It can run in two ways:

- real mode: reading data that originated from CODESYS over Modbus
- mock mode: using the backend’s built-in scenario simulator for rehearsal and UI testing

## 9. How The Whole System Works Fundamentally

The logic is:

### PLC

The PLC decides what the machine should do.

### Python bridge

The bridge decides how to interpret and explain what the PLC is doing.

### AI

The AI turns grounded context into human-friendly explanation.

### ESP32

The ESP32 displays the result near the machine.

That is the whole design in one sentence.

## 10. Common “Lost” Points And What To Do

### “I don’t know what to open first.”

Open:

- [ULTIMATE_GUIDE.md](/Users/suraa/Desktop/1/ULTIMATE_GUIDE.md)

### “I don’t know how to import the PLC code.”

Open:

- [codesys_import_guide.md](/Users/suraa/Desktop/1/codesys_import_guide.md)

### “I don’t know which tags to map in Factory I/O.”

Open:

- [factoryio_tag_plan.md](/Users/suraa/Desktop/1/factoryio_tag_plan.md)

### “I don’t know whether Modbus is even working.”

Run:

```bash
python modbus_smoke_test.py
```

### “I don’t know what the UI on the computer is.”

Open:

- [dashboard.py](/Users/suraa/Desktop/1/dashboard.py)

and run:

```bash
streamlit run dashboard.py
```

### “I don’t know if the whole demo is ready.”

Use:

- [commissioning_checklist.md](/Users/suraa/Desktop/1/commissioning_checklist.md)

## 11. Repo Organization

Think of the repo in five buckets:

### Bucket 1. Main guide

- [ULTIMATE_GUIDE.md](/Users/suraa/Desktop/1/ULTIMATE_GUIDE.md)

### Bucket 2. Core code

- [bridge.py](/Users/suraa/Desktop/1/bridge.py)
- [dashboard.py](/Users/suraa/Desktop/1/dashboard.py)
- [main.cpp](/Users/suraa/Desktop/1/main.cpp)
- [modbus_smoke_test.py](/Users/suraa/Desktop/1/modbus_smoke_test.py)

### Bucket 3. PLC code

- [codesys_main_program.st](/Users/suraa/Desktop/1/codesys_main_program.st)
- [codesys_globals.st](/Users/suraa/Desktop/1/codesys_globals.st)
- [codesys_constants.st](/Users/suraa/Desktop/1/codesys_constants.st)
- [codesys_fb_conveyor_demo.st](/Users/suraa/Desktop/1/codesys_fb_conveyor_demo.st)
- [codesys_fb_tank_fill_demo.st](/Users/suraa/Desktop/1/codesys_fb_tank_fill_demo.st)
- [codesys_fb_hvac_demo.st](/Users/suraa/Desktop/1/codesys_fb_hvac_demo.st)
- [codesys_demo_supervisor.st](/Users/suraa/Desktop/1/codesys_demo_supervisor.st)

### Bucket 4. Build docs

- [codesys_import_guide.md](/Users/suraa/Desktop/1/codesys_import_guide.md)
- [register_map.md](/Users/suraa/Desktop/1/register_map.md)
- [factoryio_tag_plan.md](/Users/suraa/Desktop/1/factoryio_tag_plan.md)
- [esp32_wiring.md](/Users/suraa/Desktop/1/esp32_wiring.md)
- [downloads_and_tools.md](/Users/suraa/Desktop/1/downloads_and_tools.md)

### Bucket 5. Demo docs

- [demo_cases.md](/Users/suraa/Desktop/1/demo_cases.md)
- [demo_runbook.md](/Users/suraa/Desktop/1/demo_runbook.md)
- [commissioning_checklist.md](/Users/suraa/Desktop/1/commissioning_checklist.md)

## 12. What To Ignore For Now

If you are overwhelmed, ignore these until later:

- [ai_tools_comparison.md](/Users/suraa/Desktop/1/ai_tools_comparison.md)
- [ai_prompts_by_tool.md](/Users/suraa/Desktop/1/ai_prompts_by_tool.md)
- [project_execution_guide.md](/Users/suraa/Desktop/1/project_execution_guide.md)
- [full_build_manual.md](/Users/suraa/Desktop/1/full_build_manual.md)
- [how_it_works.md](/Users/suraa/Desktop/1/how_it_works.md)

They are still useful, but they are not your primary working path anymore.

## 13. Your Main Working Path

If you want the shortest “do this in order” list:

1. Install tools
2. Build CODESYS project with [codesys_import_guide.md](/Users/suraa/Desktop/1/codesys_import_guide.md)
3. Map Modbus with [register_map.md](/Users/suraa/Desktop/1/register_map.md)
4. Build Factory I/O tags with [factoryio_tag_plan.md](/Users/suraa/Desktop/1/factoryio_tag_plan.md)
5. Run `python modbus_smoke_test.py`
6. Run `python bridge.py`
7. Run `streamlit run dashboard.py`
8. Flash [main.cpp](/Users/suraa/Desktop/1/main.cpp)
9. Use [commissioning_checklist.md](/Users/suraa/Desktop/1/commissioning_checklist.md)
10. Rehearse with [demo_runbook.md](/Users/suraa/Desktop/1/demo_runbook.md)

## 14. Final Truth

The code is there.

The UI on the computer is there.

The ESP32 code is there.

The PLC demo code is there.

The biggest remaining work is the manual integration inside:

- CODESYS
- Factory I/O
- Arduino IDE
- your network setup

That is normal for this kind of project.

If you forget everything else:

use this file as your home base and only branch out when this guide tells you to.
