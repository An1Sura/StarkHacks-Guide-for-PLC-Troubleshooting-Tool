import os
from typing import Any

import pandas as pd
import requests
import streamlit as st
from dotenv import load_dotenv
from streamlit_autorefresh import st_autorefresh


load_dotenv()

st.set_page_config(
    page_title="Industrial AI Diagnostics Dashboard",
    page_icon="🏭",
    layout="wide",
)


BACKEND_BASE_URL = os.getenv("BACKEND_BASE_URL", "http://127.0.0.1:8000")
REFRESH_MS = int(os.getenv("DASHBOARD_REFRESH_MS", "2000"))


def inject_styles() -> None:
    st.markdown(
        """
        <style>
            .stApp {
                background:
                    radial-gradient(circle at top right, rgba(255, 191, 0, 0.16), transparent 30%),
                    linear-gradient(180deg, #f3f6fa 0%, #e7edf3 100%);
                color: #122033;
            }
            .card {
                background: rgba(255, 255, 255, 0.92);
                border: 1px solid rgba(18, 32, 51, 0.10);
                border-left: 6px solid #25476a;
                border-radius: 12px;
                padding: 16px 18px;
                box-shadow: 0 12px 24px rgba(18, 32, 51, 0.08);
                margin-bottom: 12px;
            }
            .card h4 {
                margin: 0 0 10px 0;
                color: #1d3557;
            }
            .metric-strip {
                display: grid;
                grid-template-columns: repeat(4, minmax(0, 1fr));
                gap: 12px;
                margin-bottom: 12px;
            }
            .metric-box {
                background: rgba(255, 255, 255, 0.94);
                border-radius: 12px;
                border: 1px solid rgba(18, 32, 51, 0.10);
                padding: 14px 16px;
            }
            .metric-label {
                font-size: 0.82rem;
                color: #526375;
                text-transform: uppercase;
                letter-spacing: 0.06em;
            }
            .metric-value {
                font-size: 1.45rem;
                font-weight: 700;
                color: #102033;
                margin-top: 6px;
            }
            .severity-pill {
                display: inline-block;
                padding: 5px 10px;
                border-radius: 999px;
                font-size: 0.85rem;
                font-weight: 700;
                letter-spacing: 0.04em;
            }
            .sev-low { background: #d9f6e3; color: #1f6f43; }
            .sev-medium { background: #fff2c5; color: #8b5d00; }
            .sev-high { background: #ffe0df; color: #9c1f17; }
            .sev-none { background: #e4ebf2; color: #41576d; }
            .small-note {
                color: #5f6e7d;
                font-size: 0.9rem;
            }
        </style>
        """,
        unsafe_allow_html=True,
    )


def get_json(base_url: str, route: str) -> dict[str, Any] | None:
    try:
        response = requests.get(f"{base_url}{route}", timeout=2.5)
        response.raise_for_status()
        return response.json()
    except Exception as exc:
        st.error(f"Backend request failed for {route}: {exc}")
        return None


def post_chat(base_url: str, question: str) -> dict[str, Any] | None:
    try:
        response = requests.post(
            f"{base_url}/api/chat",
            json={"question": question},
            timeout=25,
        )
        response.raise_for_status()
        return response.json()
    except Exception as exc:
        st.error(f"Chat request failed: {exc}")
        return None


def post_json(base_url: str, route: str, payload: dict[str, Any]) -> dict[str, Any] | None:
    try:
        response = requests.post(f"{base_url}{route}", json=payload, timeout=10)
        response.raise_for_status()
        return response.json()
    except Exception as exc:
        st.error(f"Request failed for {route}: {exc}")
        return None


def severity_class(value: str | None) -> str:
    mapping = {
        "LOW": "sev-low",
        "MEDIUM": "sev-medium",
        "HIGH": "sev-high",
        None: "sev-none",
        "": "sev-none",
    }
    return mapping.get(value, "sev-none")


def render_metric_strip(snapshot: dict[str, Any]) -> None:
    active_issue = snapshot.get("active_issue") or {}
    machine = snapshot.get("machine") or {}
    connections = snapshot.get("connections") or {}
    severity = active_issue.get("severity")
    severity_label = severity if severity else "NONE"
    st.markdown(
        f"""
        <div class="metric-strip">
            <div class="metric-box">
                <div class="metric-label">Machine State</div>
                <div class="metric-value">{machine.get("state_label", "UNKNOWN")}</div>
            </div>
            <div class="metric-box">
                <div class="metric-label">Active Severity</div>
                <div class="metric-value">
                    <span class="severity-pill {severity_class(severity)}">{severity_label}</span>
                </div>
            </div>
            <div class="metric-box">
                <div class="metric-label">Mode</div>
                <div class="metric-value">{machine.get("mode_label", "UNKNOWN")}</div>
            </div>
            <div class="metric-box">
                <div class="metric-label">WebSocket Clients</div>
                <div class="metric-value">{connections.get("websocket_clients", 0)}</div>
            </div>
        </div>
        """,
        unsafe_allow_html=True,
    )


def render_issue_card(snapshot: dict[str, Any]) -> None:
    issue = snapshot.get("active_issue")
    if not issue:
        st.markdown(
            """
            <div class="card">
                <h4>No Active Fault</h4>
                <p class="small-note">The bridge is connected and no abnormal condition is currently classified.</p>
            </div>
            """,
            unsafe_allow_html=True,
        )
        return

    checks = issue.get("recommended_checks") or []
    checks_html = "".join([f"<li>{item}</li>" for item in checks])
    st.markdown(
        f"""
        <div class="card">
            <h4>AI Diagnostics Summary</h4>
            <p><strong>Issue:</strong> {issue.get("issue_summary", "N/A")}</p>
            <p><strong>Likely Cause:</strong> {issue.get("likely_cause", "N/A")}</p>
            <p><strong>Technician Step:</strong> {issue.get("troubleshooting_step", "N/A")}</p>
            <p><strong>Control vs Physical:</strong> {issue.get("control_vs_physical", "N/A")}</p>
            <p><strong>Escalation:</strong> {issue.get("escalation_note", "N/A")}</p>
            <p><strong>Classification:</strong> {issue.get("classification", "N/A")} | <strong>Generated By:</strong> {issue.get("generated_by", "N/A")}</p>
            <ul>{checks_html}</ul>
        </div>
        """,
        unsafe_allow_html=True,
    )


def render_tag_table(snapshot: dict[str, Any]) -> None:
    register_map = snapshot.get("register_map") or []
    tags = snapshot.get("tags") or {}
    rows = []
    for item in register_map:
        rows.append(
            {
                "Register": item["register"],
                "Tag": item["name"],
                "Type": item["data_type"],
                "Value": tags.get(item["name"]),
                "Description": item["description"],
            }
        )
    tag_df = pd.DataFrame(rows)
    st.dataframe(tag_df, use_container_width=True, hide_index=True)


def render_events(snapshot: dict[str, Any]) -> None:
    events = snapshot.get("recent_events") or []
    if not events:
        st.info("No events yet.")
        return
    event_rows = [
        {
            "Timestamp": event["timestamp"],
            "Severity": event["severity"],
            "Category": event["category"],
            "Message": event["message"],
        }
        for event in events
    ]
    st.dataframe(pd.DataFrame(event_rows), use_container_width=True, hide_index=True)


def render_chat(snapshot: dict[str, Any], base_url: str) -> None:
    st.subheader("Technician AI Chat")
    for item in reversed(snapshot.get("chat_history") or []):
        role = item.get("role", "assistant")
        with st.chat_message("assistant" if role == "assistant" else "user"):
            st.write(item.get("message", ""))
            if item.get("source"):
                st.caption(f"Source: {item['source']}")

    question = st.chat_input("Ask why the machine is stopped, what to check next, or how to separate logic from physical causes.")
    if question:
        answer = post_chat(base_url, question)
        if answer:
            st.rerun()


def main() -> None:
    inject_styles()
    with st.sidebar:
        st.header("Connection")
        base_url = st.text_input("Backend URL", value=BACKEND_BASE_URL)
        refresh_ms = st.slider("Refresh ms", min_value=1000, max_value=10000, value=REFRESH_MS, step=500)
        st.caption("Point this at the FastAPI bridge. Use the machine IP, not localhost, from other devices.")

    st_autorefresh(interval=refresh_ms, key="bridge-refresh")

    st.title("Industrial AI Diagnostics")
    st.caption("External diagnostics node + dashboard for PLC simulation, fault explanation, and technician guidance.")

    snapshot = get_json(base_url, "/api/state")
    if not snapshot:
        st.stop()

    with st.sidebar:
        st.divider()
        st.subheader("Runtime")
        st.write(f"Data source: `{snapshot['bridge'].get('data_source', 'unknown')}`")
        if snapshot.get("mock", {}).get("enabled"):
            st.caption("Mock mode is enabled. Use these buttons to rehearse demo scenarios without CODESYS/Factory I/O.")
            for scenario in snapshot["mock"].get("available_scenarios", []):
                label = scenario["label"]
                scenario_name = scenario["name"]
                suffix = " (active)" if scenario_name == snapshot["mock"].get("active_scenario") else ""
                if st.button(f"{label}{suffix}", use_container_width=True):
                    result = post_json(base_url, "/api/mock/scenario", {"scenario": scenario_name})
                    if result:
                        st.rerun()

    render_metric_strip(snapshot)

    left, right = st.columns([1.15, 0.85])
    with left:
        render_issue_card(snapshot)
        st.markdown('<div class="card"><h4>Live Tags</h4>', unsafe_allow_html=True)
        render_tag_table(snapshot)
        st.markdown("</div>", unsafe_allow_html=True)
    with right:
        st.markdown(
            f"""
            <div class="card">
                <h4>Bridge Status</h4>
                <p><strong>Modbus:</strong> {snapshot['connections']['modbus']}</p>
                <p><strong>AI Layer:</strong> {snapshot['connections']['ai']}</p>
                <p><strong>Target:</strong> {snapshot['connections']['modbus_target']}</p>
                <p><strong>Last Poll:</strong> {snapshot['machine'].get('last_poll_timestamp', 'N/A')}</p>
                <p><strong>Fault Label:</strong> {snapshot['machine'].get('fault_label', 'N/A')}</p>
                <p><strong>Timestamp:</strong> {snapshot.get('timestamp', 'N/A')}</p>
            </div>
            """,
            unsafe_allow_html=True,
        )
        st.markdown('<div class="card"><h4>Recent Events</h4>', unsafe_allow_html=True)
        render_events(snapshot)
        st.markdown("</div>", unsafe_allow_html=True)

    render_chat(snapshot, base_url)


if __name__ == "__main__":
    main()
