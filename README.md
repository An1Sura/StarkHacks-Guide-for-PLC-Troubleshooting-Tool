# Industrial AI Diagnostics Prototype

This project is a practical hackathon prototype for industrial diagnostics using a real separation of roles:

- `CODESYS + Structured Text` runs the PLC logic
- `Factory I/O` acts as the machine / digital twin
- `bridge.py` is the central Python integration layer
- `main.cpp` runs on an `ESP32` as a separate external diagnostics node
- `dashboard.py` provides a technician-friendly Streamlit dashboard
- an external LLM API provides explanations, troubleshooting, and structured fault summaries

The ESP32 is intentionally **not** the PLC. It behaves like a machine-side edge diagnostics accessory that subscribes to live state and displays useful fault guidance near the machine.

## File Tree

```text
industrial-ai-diagnostics/
├── README.md
├── .env.example
├── requirements.txt
├── bridge.py
├── modbus_smoke_test.py
├── dashboard.py
├── main.cpp
├── plc_logic.st
├── project_execution_guide.md
├── factoryio_tag_plan.md
├── commissioning_checklist.md
├── demo_runbook.md
├── register_map.md
├── prompts.md
├── esp32_wiring.md
├── demo_cases.md
├── downloads_and_tools.md
├── ai_tools_comparison.md
└── ai_prompts_by_tool.md
```

## Architecture

```text
Factory I/O machine simulation
        ↓
CODESYS PLC logic (Structured Text)
        ↓ Modbus TCP Server
Python bridge (pymodbus + FastAPI)
        ├── event/state tracking
        ├── AI diagnostics triggers
        ├── REST API
        └── WebSocket fan-out
             ├── ESP32 diagnostics node
             └── Streamlit dashboard
```

## Why The Separate Hardware Module Matters

This prototype is stronger when the diagnostics node is independent from the PLC:

- it reflects how a real edge retrofit device would behave
- it does not interfere with control execution
- it can be mounted near the machine for technicians
- it proves that AI diagnostics can be added to existing automation systems without replacing the PLC
- it creates a believable upgrade path for brownfield equipment

## Hardware Components

- ESP32 DevKit board
- SSD1306 I2C OLED display
- 1x LED with 220 ohm resistor
- 2x buttons
- breadboard / jumpers
- optional 3D printed enclosure
- optional DIN-rail clip concept

## Software Stack

- CODESYS Development System V3
- Factory I/O
- Python 3.11+
- FastAPI
- pymodbus
- Streamlit
- OpenAI-compatible LLM API
- Arduino IDE 2.x
- ESP32 Arduino core

## Communication Protocols

- `Modbus TCP`
  - CODESYS exposes holding registers
  - Python polls the register block with `pymodbus`
- `REST`
  - Streamlit reads `/api/state`, `/api/events`, and `/api/diagnostics`
- `WebSocket`
  - ESP32 subscribes to `/ws/live`
  - Python broadcasts machine snapshots and AI diagnostics
- `JSON`
  - WebSocket payloads are compact JSON snapshots
- `HTTP API`
  - Python sends prompt + machine context to the external LLM API

## What `bridge.py` Does

- connects to the PLC Modbus TCP server
- polls the holding registers
- normalizes tag names and values
- detects transitions and builds an event history
- classifies active issues
- generates immediate rule-based diagnostics
- triggers AI only on meaningful issue changes or debounce expiry
- broadcasts state to the dashboard and ESP32
- exposes a small technician chat endpoint

## What `dashboard.py` Does

- shows live machine status and connection health
- displays the Modbus register values in operator-friendly form
- displays recent events
- displays the current AI/rule-based diagnostic summary
- provides a lightweight technician chat panel

## What `main.cpp` Does

- connects the ESP32 to Wi-Fi
- subscribes to the FastAPI WebSocket endpoint
- stores the latest machine state locally
- shows connection, severity, and issue summary on the OLED
- blinks the LED on `GPIO 2` when severity is `HIGH`
- includes simple button placeholders for paging and acknowledge behavior

## Setup

If you want the most complete step-by-step build order, start with [project_execution_guide.md](/Users/suraa/Desktop/1/project_execution_guide.md). The README is the overview; the execution guide is the actual runbook.

### 1. Python Environment

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
cp .env.example .env
```

Edit `.env` and set:

- `OPENAI_API_KEY`
- `MODBUS_HOST`
- `MODBUS_PORT`
- `FASTAPI_HOST`
- `FASTAPI_PORT`
- `AI_MODEL`

### 2. CODESYS + Factory I/O

1. Create a CODESYS project with the sample logic from [plc_logic.st](/Users/suraa/Desktop/1/plc_logic.st).
2. Add a Modbus TCP server/slave device.
3. Map the global variables to the register addresses in [register_map.md](/Users/suraa/Desktop/1/register_map.md).
4. In Factory I/O, map the relevant sensors and actuators to those CODESYS variables.
5. Start simple: verify one conveyor sensor bit changes in CODESYS before wiring every scenario.

### 3. Python Bridge

Before starting the full bridge, prove Modbus connectivity first:

```bash
python modbus_smoke_test.py
```

Then start the bridge:

```bash
python bridge.py
```

Health check:

```bash
curl http://127.0.0.1:8000/health
```

### 4. Streamlit Dashboard

```bash
streamlit run dashboard.py
```

### 5. ESP32 Firmware

1. Open [main.cpp](/Users/suraa/Desktop/1/main.cpp) in Arduino IDE.
2. Install the libraries listed in [downloads_and_tools.md](/Users/suraa/Desktop/1/downloads_and_tools.md).
3. Set:
   - `WIFI_SSID`
   - `WIFI_PASSWORD`
   - `BRIDGE_HOST` to the computer IP running `bridge.py`
4. Upload to the ESP32.

## Run Order

1. Start CODESYS runtime / simulation and confirm Modbus TCP is serving the register block.
2. Start Factory I/O and verify at least one sensor changes the PLC variable.
3. Run `python modbus_smoke_test.py`.
4. Run `python bridge.py`.
4. Run `streamlit run dashboard.py`.
5. Power the ESP32 and confirm WebSocket connection.
6. Trigger demo scenarios one by one.

## 24-Hour Hackathon Build Order

### Phase 1: The Loop (PLC -> Factory I/O)

- Build a one-conveyor scene in Factory I/O.
- Map `Sensor_Blocked` and a conveyor start bit into CODESYS.
- Verify moving a box changes a CODESYS variable.

### Phase 2: The Data Pipe (PLC -> Python)

- Start with the Modbus register map only.
- Run `bridge.py`.
- Confirm the terminal logs and `/api/state` show live values.

### Phase 3: The Edge (Python -> ESP32)

- Start the FastAPI bridge.
- Connect the ESP32 over Wi-Fi.
- Verify the ESP32 receives snapshots and displays status on the OLED.

### Phase 4: The Intelligence

- Set `OPENAI_API_KEY`.
- Trigger a conveyor jam or start-blocked fault.
- Confirm the bridge creates a structured diagnostic.
- Verify the dashboard and ESP32 update with the AI output.

### Phase 5: UI & Polish

- tune the Streamlit layout
- verify event history is readable
- rehearse the demo script
- clean the enclosure / DIN-rail concept story

## Demo Flow

1. Show the digital twin in Factory I/O.
2. Show CODESYS variables changing live.
3. Open the dashboard and show raw tags.
4. Trigger a fault.
5. Let the AI explanation appear.
6. Show the ESP32 edge node blinking and displaying the issue.
7. Ask a technician-style question in the dashboard chat.
8. Clear the fault and show recovery.

For the live talk track and operator steps, use [demo_runbook.md](/Users/suraa/Desktop/1/demo_runbook.md).

## Demo Scenarios

See [demo_cases.md](/Users/suraa/Desktop/1/demo_cases.md) for the full set of six use cases:

- Motor Start Blocked
- Sequence Timing Failure
- Tank Fill Control Verification
- Conveyor Jam Fault
- Fault + Reset Recovery
- HVAC / Pump Failure

Use [factoryio_tag_plan.md](/Users/suraa/Desktop/1/factoryio_tag_plan.md) when you build the Factory I/O mapping, and use [commissioning_checklist.md](/Users/suraa/Desktop/1/commissioning_checklist.md) before the final demo.

## Manual Configuration Steps You Still Need

- create the actual Factory I/O scene and tag mappings
- map CODESYS variables to Modbus holding registers manually
- set the ESP32 Wi-Fi credentials and bridge IP
- set the real AI API key in `.env`
- tune timer presets for the exact Factory I/O scene speed

These are realistic manual tasks for a hackathon and not worth over-automating on day one.

## Honest Constraints

- The ESP32 should not run the AI model locally for this prototype.
- Factory I/O and CODESYS setup is partly manual because those tools are GUI-driven.
- The AI explanations are only as grounded as the tags and event history you provide.
- If the PLC exposes incorrect or incomplete tags, the diagnostics quality drops quickly.
- For a hackathon, the fastest reliable path is:
  - simple register map
  - clean event history
  - focused scenarios
  - concise AI output

## Future Improvements

- replace Streamlit with React + FastAPI WebSocket UI
- add MQTT bridge mode for plant integration
- add historian storage with SQLite or TimescaleDB
- add QR-code machine pages for field technicians
- add role-specific views for operators vs controls engineers
- add acknowledgement workflows and alarm shelving
- add enclosure CAD and a real DIN-rail clip print
