# Full Build Manual

This is the most detailed manual in the repo. It is written to reduce guesswork as much as possible.

## 1. Read This First

Use this file with:

- [START_HERE.md](/Users/suraa/Desktop/1/START_HERE.md)
- [project_execution_guide.md](/Users/suraa/Desktop/1/project_execution_guide.md)
- [codesys_import_guide.md](/Users/suraa/Desktop/1/codesys_import_guide.md)

If `START_HERE.md` is the map, this file is the long-form field manual.

## 2. Final Deliverable Checklist

By the end, you should have:

- CODESYS project compiling
- Factory I/O scene mapped
- Modbus TCP server responding
- `modbus_smoke_test.py` reading registers
- `bridge.py` polling and serving state
- `dashboard.py` showing live diagnostics
- `main.cpp` running on the ESP32
- at least 3 polished demo scenarios working

## 3. Best Overall Method

The cleanest build method is:

1. Build the signal chain first
2. Add AI second
3. Add polish last

That means:

1. Factory I/O -> CODESYS works
2. CODESYS -> Modbus works
3. Modbus -> Python works
4. Python -> Dashboard works
5. Python -> ESP32 works
6. AI explanations work

## 4. Recommended Demo Quality Bar

For the demo to feel strong, each scenario needs:

- a visible trigger
- a visible PLC reaction
- a visible fault or state code
- a readable AI explanation
- a clear recovery path

If one of those is missing, the scenario feels weaker.

## 5. Best Three Scenarios To Polish First

If time is limited, make these excellent:

### Motor Start Blocked

Why it is strong:

- easy to trigger
- easy to explain
- proves the AI understands control intent

### Conveyor Jam

Why it is strong:

- feels like a real machine problem
- shows fault latch + severity
- works well on the ESP32 LED/OLED

### Fault + Reset

Why it is strong:

- demonstrates recovery behavior
- makes the event history useful
- helps explain the difference between “fault cause removed” and “system reset”

## 6. CODESYS Build Recommendation

Use the modular CODESYS code package:

- [codesys_constants.st](/Users/suraa/Desktop/1/codesys_constants.st)
- [codesys_globals.st](/Users/suraa/Desktop/1/codesys_globals.st)
- [codesys_fb_conveyor_demo.st](/Users/suraa/Desktop/1/codesys_fb_conveyor_demo.st)
- [codesys_fb_tank_fill_demo.st](/Users/suraa/Desktop/1/codesys_fb_tank_fill_demo.st)
- [codesys_fb_hvac_demo.st](/Users/suraa/Desktop/1/codesys_fb_hvac_demo.st)
- [codesys_demo_supervisor.st](/Users/suraa/Desktop/1/codesys_demo_supervisor.st)
- [codesys_main_program.st](/Users/suraa/Desktop/1/codesys_main_program.st)

Reason:

- easier to explain
- easier to debug
- easier to isolate scenarios

## 7. Factory I/O Scene Recommendation

Do not try to build one giant scene.

Use one main scene with:

- conveyor section
- jam sensor
- start/stop interaction
- optional tank section

Then simulate HVAC/pump mostly through toggles and indicators if needed.

That is more realistic for hackathon timing.

## 8. Python Integration Recommendation

Use this order:

1. [modbus_smoke_test.py](/Users/suraa/Desktop/1/modbus_smoke_test.py)
2. [bridge.py](/Users/suraa/Desktop/1/bridge.py)
3. [dashboard.py](/Users/suraa/Desktop/1/dashboard.py)

Never skip the smoke test.

## 9. ESP32 Recommendation

For the first successful run, use:

- OLED
- built-in LED or GPIO 2 LED

Keep buttons optional until the core loop is stable.

## 10. AI Recommendation

Use AI as a thin explanation layer only.

It should answer:

- what happened
- why it is likely happening
- what to check first
- whether it looks like logic or a physical issue

It should not try to “operate” the system.

## 11. Exact File Set You Now Have

### Core app files

- [bridge.py](/Users/suraa/Desktop/1/bridge.py)
- [dashboard.py](/Users/suraa/Desktop/1/dashboard.py)
- [main.cpp](/Users/suraa/Desktop/1/main.cpp)
- [modbus_smoke_test.py](/Users/suraa/Desktop/1/modbus_smoke_test.py)

### Core PLC files

- [plc_logic.st](/Users/suraa/Desktop/1/plc_logic.st)
- [codesys_constants.st](/Users/suraa/Desktop/1/codesys_constants.st)
- [codesys_globals.st](/Users/suraa/Desktop/1/codesys_globals.st)
- [codesys_fb_conveyor_demo.st](/Users/suraa/Desktop/1/codesys_fb_conveyor_demo.st)
- [codesys_fb_tank_fill_demo.st](/Users/suraa/Desktop/1/codesys_fb_tank_fill_demo.st)
- [codesys_fb_hvac_demo.st](/Users/suraa/Desktop/1/codesys_fb_hvac_demo.st)
- [codesys_demo_supervisor.st](/Users/suraa/Desktop/1/codesys_demo_supervisor.st)
- [codesys_main_program.st](/Users/suraa/Desktop/1/codesys_main_program.st)

### Build manuals

- [START_HERE.md](/Users/suraa/Desktop/1/START_HERE.md)
- [project_execution_guide.md](/Users/suraa/Desktop/1/project_execution_guide.md)
- [full_build_manual.md](/Users/suraa/Desktop/1/full_build_manual.md)
- [codesys_import_guide.md](/Users/suraa/Desktop/1/codesys_import_guide.md)
- [factoryio_tag_plan.md](/Users/suraa/Desktop/1/factoryio_tag_plan.md)
- [commissioning_checklist.md](/Users/suraa/Desktop/1/commissioning_checklist.md)
- [demo_runbook.md](/Users/suraa/Desktop/1/demo_runbook.md)

### Reference docs

- [register_map.md](/Users/suraa/Desktop/1/register_map.md)
- [prompts.md](/Users/suraa/Desktop/1/prompts.md)
- [demo_cases.md](/Users/suraa/Desktop/1/demo_cases.md)
- [downloads_and_tools.md](/Users/suraa/Desktop/1/downloads_and_tools.md)
- [esp32_wiring.md](/Users/suraa/Desktop/1/esp32_wiring.md)

## 12. Honest Boundary

What is fully included:

- backend code
- dashboard code
- ESP32 firmware
- PLC ST source files
- register map
- prompts
- demo runbook
- installation and commissioning documentation

What still must be done manually in external tools:

- create the actual CODESYS project objects
- map Modbus registers in the CODESYS GUI
- create the Factory I/O scene and signal mappings
- flash the ESP32
- set IP addresses, Wi-Fi credentials, and API key

That manual work cannot be eliminated completely because those tools are GUI-driven.

## 13. If You Want The Best Chance Of Success

Do this on build day:

1. Finish one clean conveyor demo completely
2. Freeze the register map
3. Freeze the Python bridge contract
4. Add ESP32
5. Add AI
6. Only then expand to the extra scenarios

That is the best practical path.
