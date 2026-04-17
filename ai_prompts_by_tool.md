# AI Prompts By Tool

## 1. OpenAI Prompt For Fault Explanation

Use this inside the runtime or when testing prompts manually.

```text
You are an industrial diagnostics assistant.
You are not the PLC and you are not allowed to invent unobserved machine facts.

Use only the provided machine tags, recent event history, and scenario context.

Return valid JSON only with:
- issue_summary
- likely_cause
- severity
- troubleshooting_step
- recommended_checks
- escalation_note
- classification
- control_vs_physical

Current machine state:
{machine_state}

Scenario context:
{issue_context}

Current tags:
{tags_json}

Recent events:
{recent_events_json}
```

## 2. Claude Prompt For Project Planning / Code Generation

```text
Help me plan and refine an industrial AI diagnostics hackathon project.

Constraints:
- PLC logic in CODESYS Structured Text
- Factory I/O simulation
- Python bridge with FastAPI + pymodbus
- ESP32 diagnostics node over WebSockets
- Streamlit dashboard
- AI only for explanations and troubleshooting, not control

Please help with:
1. architecture review
2. failure mode coverage
3. edge cases in event detection
4. practical hackathon demo sequencing
5. code review of Python bridge and ESP32 firmware

Focus on practical implementation details, not generic high-level advice.
```

## 3. Gemini Prompt For Manuals / Protocol / Documentation Research

```text
I am building an industrial diagnostics prototype using:
- CODESYS
- Factory I/O
- Modbus TCP
- ESP32
- Streamlit

Please help me research:
1. common Modbus TCP setup mistakes in CODESYS
2. practical Factory I/O tag mapping advice
3. SSD1306 OLED wiring considerations with ESP32
4. protocol/documentation references I should read first

Please summarize findings in a concise implementation checklist.
```

## 4. Copilot Prompt For Coding Assistance

Use this as an in-editor note or task description:

```text
Generate or refine code for an industrial diagnostics prototype.

Requirements:
- Python FastAPI backend with Modbus polling and WebSocket broadcast
- debounce AI requests on issue changes
- maintain recent event history
- Streamlit dashboard with live tags and chat
- ESP32 firmware using WebSockets + ArduinoJson + SSD1306

Please prefer small, reliable functions and keep the protocol payload simple.
```

## 5. Rule-Based Fallback Design Prompt

Use this to design or review the deterministic fallback layer:

```text
Design a rule-based industrial diagnostics fallback for these scenarios:
- motor start blocked by safety
- sequence timeout
- tank fill verification issue
- conveyor jam
- fault latch requiring reset
- HVAC/pump failure

For each rule, define:
- trigger condition from tags
- operator-facing summary
- likely cause
- first troubleshooting step
- 3 recommended checks
- whether the issue looks more like PLC logic behavior or a physical device problem
```

## Practical Tool Split

- Use `OpenAI` for live runtime explanations.
- Use `Claude` when you want planning depth or architecture critique.
- Use `Gemini` when you need research on manuals, standards, or tooling docs.
- Use `Copilot` when you are in the IDE writing code fast.
- Always keep a `rule-based fallback` in the product so the demo survives network or API issues.
