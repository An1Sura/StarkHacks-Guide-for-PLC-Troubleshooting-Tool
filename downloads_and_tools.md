# Downloads And Tools

This list is optimized for a hackathon demo build, not for a production purchasing decision.

## Required Tools

| Tool | Purpose | Required | Recommended Version / Track | Search / Download | Install Notes |
| --- | --- | --- | --- | --- | --- |
| CODESYS Development System V3 | PLC programming and Modbus server setup | Required | `3.5.22.10` track is a practical current baseline | Search: `CODESYS Development System V3 download` | Install the full engineering environment and create a standard control project |
| Factory I/O | Digital twin / machine simulation | Required | `2.5.10` or current `2.5.x` | Search: `Factory I/O download` | Prefer an edition that supports Modbus TCP such as Modbus & OPC Edition or Ultimate |
| Python | Runs bridge and dashboard | Required | `3.11.x` | Search: `Python 3.11 download` | Use a virtual environment |
| Arduino IDE | ESP32 firmware build/upload | Required | `2.x` current stable | Search: `Arduino IDE download` | Install board manager support for ESP32 |
| ESP32 Arduino Core by Espressif | Adds ESP32 target support to Arduino IDE | Required | `3.3.5` or current `3.3.x` | Search: `esp32 by Espressif board manager` | Install through Arduino Boards Manager |
| FastAPI + Uvicorn | REST and WebSocket server in Python | Required | install from `requirements.txt` | `pip install -r requirements.txt` | Uvicorn launches the backend |
| pymodbus | Reads CODESYS holding registers | Required | install from `requirements.txt` | `pip install -r requirements.txt` | Keep address mapping simple for the hackathon |
| Streamlit | Dashboard UI | Required | install from `requirements.txt` | `pip install -r requirements.txt` | Good enough for day-one UI |
| OpenAI-compatible API key | AI diagnostics and chat | Required for AI mode | Start with `gpt-4o-mini` class model | Search: `OpenAI API keys` | If absent, bridge falls back to rule-based summaries |

## Required Arduino Libraries

| Library | Purpose | Required | Recommended Version | Search / Download | Install Notes |
| --- | --- | --- | --- | --- | --- |
| ArduinoJson | JSON parsing on ESP32 | Required | latest 7.x or 6.x stable | Search in Arduino Library Manager: `ArduinoJson` | Used for parsing WebSocket payloads |
| WebSockets by Markus Sattler | WebSocket client for ESP32 | Required | current stable | Search in Library Manager: `WebSockets` | Needed for `/ws/live` subscription |
| Adafruit SSD1306 | OLED driver | Required | current stable | Search in Library Manager: `Adafruit SSD1306` | Install dependency libraries if prompted |
| Adafruit GFX Library | Graphics dependency for SSD1306 | Required | current stable | Search in Library Manager: `Adafruit GFX` | Usually installed automatically |

## Optional Tools

| Tool | Purpose | Required | Recommended Version / Track | Search / Download | Install Notes |
| --- | --- | --- | --- | --- | --- |
| VS Code + PlatformIO | Alternative firmware environment | Optional | current stable | Search: `PlatformIO IDE` | Useful if you outgrow the Arduino sketch flow |
| Postman / Insomnia | REST endpoint testing | Optional | current stable | Search: `Postman download` | Helpful for `/health` and `/api/state` testing |
| Wireshark | Modbus or TCP troubleshooting | Optional | current stable | Search: `Wireshark download` | Useful if tags are not updating |
| 3D CAD tool (Fusion / Onshape / FreeCAD) | Enclosure concept | Optional | current stable | Search: preferred CAD tool | Only needed for the packaging story |

## Search / Download Targets

- CODESYS official: [codesys.com](https://www.codesys.com/)
- Factory I/O official: [factoryio.com](https://factoryio.com/)
- Python official: [python.org](https://www.python.org/downloads/)
- Arduino IDE official: [arduino.cc](https://www.arduino.cc/en/software)
- ESP32 Arduino core releases: [github.com/espressif/arduino-esp32](https://github.com/espressif/arduino-esp32)
- OpenAI platform: [platform.openai.com](https://platform.openai.com/)

## Practical Install Advice

- Install CODESYS and Factory I/O before writing much code.
- Prove Modbus with one tag before building the full event model.
- Do not wait for the enclosure to start the electronics demo.
- For the hackathon, reliability beats fidelity:
  - one good conveyor scene
  - one good jam fault
  - one good reset story
  - one solid AI explanation
