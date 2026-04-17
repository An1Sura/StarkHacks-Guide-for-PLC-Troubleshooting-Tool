# Local Demo Mode

This mode lets you run the project without waiting for CODESYS and Factory I/O to be fully configured.

It uses the same register map and scenario logic shape, but the backend generates the machine states internally instead of reading a live Modbus server.

Use this when:

- you want to test the dashboard now
- you want to test the ESP32 now
- you want to rehearse the AI demo flow now
- you are still wiring CODESYS or Factory I/O

## 1. What Still Works In Local Demo Mode

These parts still work:

- [bridge.py](/Users/suraa/Desktop/1/bridge.py)
- [dashboard.py](/Users/suraa/Desktop/1/dashboard.py)
- [main.cpp](/Users/suraa/Desktop/1/main.cpp)
- AI diagnostics
- event logging
- chat
- dashboard UI
- ESP32 OLED/LED behavior

What is simulated:

- the PLC register values
- the machine scenarios

## 2. How To Enable It

In `.env`, set:

```env
DATA_SOURCE=mock
MOCK_SCENARIO=idle
```

Keep your other normal settings too.

Example:

```env
DATA_SOURCE=mock
MOCK_SCENARIO=idle
FASTAPI_HOST=0.0.0.0
FASTAPI_PORT=8000
BACKEND_BASE_URL=http://127.0.0.1:8000
AI_MODEL=gpt-4o-mini
```

## 3. How To Run It

Start the backend:

```bash
python bridge.py
```

Then start the dashboard:

```bash
streamlit run dashboard.py
```

## 4. How To Use It

Open the dashboard.

In the sidebar, you will see mock scenario buttons.

Use those to switch between:

- Idle / healthy
- Normal conveyor run
- Motor start blocked
- Conveyor jam fault
- Fault + reset recovery
- Sequence timeout
- Tank fill verification
- HVAC / pump fault

## 5. What Happens

When you click a scenario:

1. the backend changes the active simulated machine state
2. the tag values update
3. the event history updates
4. the issue classifier runs
5. the AI or rule-based diagnostics update
6. the dashboard refreshes
7. the ESP32 updates if connected

## 6. Best Use

This is not a replacement for the real CODESYS + Factory I/O demo.

It is a staging mode so you can:

- prove the software stack
- verify the UI
- verify the ESP32 behavior
- practice the talk track

Then, once CODESYS and Factory I/O are ready, switch back to:

```env
DATA_SOURCE=modbus
```

## 7. Best Demo Rehearsal Path

Use this order:

1. `motor_start_blocked`
2. `conveyor_jam`
3. `fault_reset_demo`
4. `sequence_timeout`
5. `tank_fill_verify`
6. `hvac_fault`

## 8. Important Note

The dashboard and ESP32 do not need to change between mock mode and real mode.

Only the backend data source changes.

That is what makes this useful.
