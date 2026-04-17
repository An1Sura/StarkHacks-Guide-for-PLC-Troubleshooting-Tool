# Commissioning Checklist

Use this before the final demo and again on demo day.

## 1. Tooling Ready

- [ ] CODESYS opens and project builds cleanly
- [ ] Factory I/O launches and scene loads
- [ ] Python virtual environment is installed
- [ ] `pip install -r requirements.txt` completed
- [ ] Arduino IDE sees the ESP32 board
- [ ] OLED libraries and WebSocket libraries are installed

## 2. PLC / Simulation Ready

- [ ] `plc_logic.st` copied into the CODESYS project
- [ ] Modbus TCP server/slave is enabled in CODESYS
- [ ] Holding registers match [register_map.md](/Users/suraa/Desktop/1/register_map.md)
- [ ] Factory I/O tags are mapped to the right variables
- [ ] One box movement changes at least one PLC variable

## 3. Modbus Ready

- [ ] `python modbus_smoke_test.py` connects successfully
- [ ] Register values match the live PLC watch table
- [ ] No address offset mismatch is present
- [ ] Firewall is not blocking Modbus TCP

## 4. Backend Ready

- [ ] `.env` exists and has the correct IP/port values
- [ ] `python bridge.py` starts cleanly
- [ ] `/health` returns `status: ok`
- [ ] `/api/state` shows current tags
- [ ] events appear when tags change
- [ ] `active_issue` appears during a fault

## 5. Dashboard Ready

- [ ] `streamlit run dashboard.py` launches
- [ ] backend URL is correct in the sidebar
- [ ] live tags update
- [ ] recent event history updates
- [ ] AI diagnostics card updates
- [ ] chat responses work or fallback works cleanly

## 6. ESP32 Ready

- [ ] OLED wiring is correct
- [ ] LED on GPIO 2 works
- [ ] ESP32 joins Wi-Fi
- [ ] ESP32 connects to `/ws/live`
- [ ] machine state appears on OLED
- [ ] HIGH severity blinks LED

## 7. AI Ready

- [ ] `OPENAI_API_KEY` is set
- [ ] one known fault returns a structured diagnostic
- [ ] AI output is concise and grounded
- [ ] fallback behavior still works if the API fails

## 8. Demo Scenarios Ready

- [ ] Motor Start Blocked
- [ ] Conveyor Jam
- [ ] Fault + Reset
- [ ] Sequence Timeout
- [ ] Tank Fill
- [ ] HVAC / Pump

## 9. Presentation Ready

- [ ] dashboard window sized and readable
- [ ] Factory I/O visible
- [ ] CODESYS watch window prepared
- [ ] ESP32 powered and visible
- [ ] browser tab / app order rehearsed
- [ ] backup explanation ready if AI API is slow

## 10. Backup Plan

- [ ] cached or fallback rule-based diagnostics still tell the story
- [ ] at least two scenarios can be shown without touching code
- [ ] local network details written down
- [ ] backup USB cable and power bank available
