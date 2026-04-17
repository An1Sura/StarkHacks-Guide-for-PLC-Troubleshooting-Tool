# Start Here

This is the single page to follow when building the project.

If you only open one file first, make it this one.

## 1. What This Project Is

You are building an industrial AI diagnostics prototype with:

- `CODESYS` as the PLC logic layer
- `Factory I/O` as the machine simulation
- `Python` as the Modbus + AI + API bridge
- `Streamlit` as the dashboard
- `ESP32` as the external diagnostics node

The ESP32 is not the PLC. The AI is not the control loop.

## 2. Build Order

Follow this exact order:

1. Install tools
2. Set up Python
3. Build the CODESYS PLC logic
4. Build and map the Factory I/O scene
5. Prove Modbus with the smoke test
6. Run the Python bridge
7. Run the Streamlit dashboard
8. Flash and test the ESP32
9. Rehearse the demo scenarios

## 3. Open These Files In This Order

### Step 1. Tool installs

Open:

- [downloads_and_tools.md](/Users/suraa/Desktop/1/downloads_and_tools.md)

Use it to install:

- CODESYS
- Factory I/O
- Python
- Arduino IDE
- ESP32 support
- Arduino libraries

### Step 2. Full build guide

Open:

- [project_execution_guide.md](/Users/suraa/Desktop/1/project_execution_guide.md)

This is the main step-by-step build manual.

### Step 3. PLC and register plan

Open:

- [plc_logic.st](/Users/suraa/Desktop/1/plc_logic.st)
- [register_map.md](/Users/suraa/Desktop/1/register_map.md)

Use these to:

- build the PLC logic in CODESYS
- map the holding registers correctly

### Step 4. Factory I/O mapping

Open:

- [factoryio_tag_plan.md](/Users/suraa/Desktop/1/factoryio_tag_plan.md)

Use it to decide:

- what scene to build first
- what tags to map first
- what not to overbuild too early

### Step 5. Prove PLC -> Python

Open:

- [modbus_smoke_test.py](/Users/suraa/Desktop/1/modbus_smoke_test.py)

Run it before the full backend.

This tells you whether Modbus is working.

### Step 6. Backend

Open:

- [bridge.py](/Users/suraa/Desktop/1/bridge.py)
- [.env.example](/Users/suraa/Desktop/1/.env.example)

Use these to:

- set IPs, ports, and API key
- run the FastAPI bridge
- poll Modbus
- trigger diagnostics

### Step 7. Dashboard

Open:

- [dashboard.py](/Users/suraa/Desktop/1/dashboard.py)

Use it to verify:

- tags
- events
- active issue
- AI explanations

### Step 8. ESP32 hardware node

Open:

- [esp32_wiring.md](/Users/suraa/Desktop/1/esp32_wiring.md)
- [main.cpp](/Users/suraa/Desktop/1/main.cpp)

Use these to:

- wire the OLED, LED, and buttons
- set Wi-Fi credentials
- point the ESP32 at the Python bridge

### Step 9. AI prompt behavior

Open:

- [prompts.md](/Users/suraa/Desktop/1/prompts.md)

Optional supporting files:

- [ai_tools_comparison.md](/Users/suraa/Desktop/1/ai_tools_comparison.md)
- [ai_prompts_by_tool.md](/Users/suraa/Desktop/1/ai_prompts_by_tool.md)

### Step 10. Demo prep

Open:

- [demo_cases.md](/Users/suraa/Desktop/1/demo_cases.md)
- [demo_runbook.md](/Users/suraa/Desktop/1/demo_runbook.md)
- [commissioning_checklist.md](/Users/suraa/Desktop/1/commissioning_checklist.md)

Use these to:

- choose the strongest scenarios
- rehearse the live demo
- make sure nothing is missing

## 4. Recommended Minimum Demo

If time gets tight, focus on this:

1. `Motor Start Blocked`
2. `Conveyor Jam`
3. `Fault + Reset`

That is enough for a strong demo.

## 5. Best Practical Path

If you want the fastest route to success:

1. Get one conveyor scene working
2. Get one Modbus read working
3. Get one dashboard update working
4. Get one ESP32 update working
5. Get one fault explanation working
6. Then expand

## 6. If Something Breaks

Go back one layer:

- Factory I/O issue -> check [factoryio_tag_plan.md](/Users/suraa/Desktop/1/factoryio_tag_plan.md)
- Modbus issue -> run [modbus_smoke_test.py](/Users/suraa/Desktop/1/modbus_smoke_test.py)
- backend issue -> check [bridge.py](/Users/suraa/Desktop/1/bridge.py)
- ESP32 issue -> check [esp32_wiring.md](/Users/suraa/Desktop/1/esp32_wiring.md) and [main.cpp](/Users/suraa/Desktop/1/main.cpp)
- demo issue -> check [commissioning_checklist.md](/Users/suraa/Desktop/1/commissioning_checklist.md)

## 7. One-Line Summary

If you want the shortest answer:

Start with [project_execution_guide.md](/Users/suraa/Desktop/1/project_execution_guide.md), and use this page as your navigation hub for everything else.
