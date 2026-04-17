# AI Tools Comparison

## Comparison Table

| Tool | Best Use In This Project | Pros | Cons | Hackathon Speed | Structured JSON Reliability | Recommendation |
| --- | --- | --- | --- | --- | --- | --- |
| OpenAI | Live fault explanation, technician chat, structured summaries from tags/events | Strong API ecosystem, good multimodal/product maturity, reliable JSON mode, easy Python integration | API cost, requires careful prompt grounding | Fast | High | Best primary runtime choice |
| Claude | Architecture planning, long-form reasoning, documentation drafting, code review help | Strong writing and planning quality, often good at tradeoff analysis | JSON/API behavior can be less predictable depending on prompting and wrapper | Fast for planning, not always first choice for strict runtime JSON | Medium | Strong secondary build-time assistant |
| Gemini | Research helper for manuals, device docs, protocol summaries, broad documentation assistance | Good context handling and broad Google ecosystem tie-in | Runtime structured fault output consistency can vary more than a tighter JSON-mode workflow | Medium | Medium | Useful research/support tool, not my first runtime choice |
| Microsoft Copilot | Coding assistance inside IDE during implementation | Convenient in-editor workflow, helpful for small code scaffolds | Not ideal as the live diagnostics runtime engine, limited control over structured machine-facing outputs | Fast for coding | Low to Medium | Good implementation helper, weak primary runtime layer |
| Rule-based fallback only | Safety net when API is unavailable | Deterministic, cheap, easy to verify, no external dependency | Less flexible, explanations become repetitive, weaker operator experience | Very fast | Very high | Must exist as backup, but not enough as the headline demo |

## Practical Read

### OpenAI

Best for the actual runtime AI layer in this project.

- strongest fit for:
  - `issue_summary`
  - `likely_cause`
  - `troubleshooting_step`
  - short technician chat
- easy to call from `bridge.py`
- good enough JSON behavior for a demo if you keep the schema tight

### Claude

Best as a build-time copilot, not necessarily the live runtime engine.

- useful for:
  - architecture refinement
  - README polish
  - scenario brainstorming
  - reviewing PLC logic and diagnostics rules

### Gemini

Best for research-oriented support work.

- useful for:
  - finding protocol docs
  - reading manuals
  - summarizing product references

### Microsoft Copilot

Best for rapid coding help inside the editor.

- useful for:
  - autocomplete
  - boilerplate reduction
  - fast iteration during the hackathon

### Rule-Based Fallback

This project should absolutely have one.

- if the LLM API fails, the system should still:
  - detect the issue
  - show a probable cause
  - show next checks
  - keep the ESP32 and dashboard useful

## Final Recommendation

Use this split:

1. `OpenAI` as the primary runtime diagnostics API
2. `Rule-based fallback` inside `bridge.py` for reliability
3. `Claude` for planning/documentation/code assistance during the build
4. `Gemini` for manuals and protocol research when needed
5. `Copilot` as optional IDE acceleration only

For a hackathon, that gives the best balance of:

- implementation speed
- reliable structured output
- believable demo quality
- graceful degradation when the API is unavailable
