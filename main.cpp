#include <Arduino.h>
#include <WiFi.h>
#include <WebSocketsClient.h>
#include <ArduinoJson.h>
#include <Wire.h>
#include <Adafruit_GFX.h>
#include <Adafruit_SSD1306.h>

constexpr char WIFI_SSID[] = "YOUR_WIFI_SSID";
constexpr char WIFI_PASSWORD[] = "YOUR_WIFI_PASSWORD";

// Use the computer running bridge.py, not localhost.
constexpr char BRIDGE_HOST[] = "192.168.1.50";
constexpr uint16_t BRIDGE_PORT = 8000;
constexpr char WS_PATH[] = "/ws/live";

constexpr uint8_t OLED_SDA_PIN = 21;
constexpr uint8_t OLED_SCL_PIN = 22;
constexpr uint8_t OLED_ADDRESS = 0x3C;
constexpr uint8_t SCREEN_WIDTH = 128;
constexpr uint8_t SCREEN_HEIGHT = 64;

constexpr uint8_t STATUS_LED_PIN = 2;
constexpr uint8_t NEXT_PAGE_BUTTON_PIN = 18;
constexpr uint8_t ACK_BUTTON_PIN = 19;

constexpr unsigned long WIFI_RETRY_MS = 8000;
constexpr unsigned long WS_RETRY_MS = 5000;
constexpr unsigned long PAGE_ROTATE_MS = 4500;
constexpr unsigned long BLINK_INTERVAL_MS = 300;

Adafruit_SSD1306 display(SCREEN_WIDTH, SCREEN_HEIGHT, &Wire, -1);
WebSocketsClient webSocket;

struct DeviceState {
  String machineStatus = "BOOTING";
  String issueSummary = "Waiting for backend";
  String troubleshooting = "Connect Wi-Fi and bridge";
  String severity = "NONE";
  String modbusStatus = "DISCONNECTED";
  String aiStatus = "UNKNOWN";
  String lastUpdate = "--";
  bool wifiConnected = false;
  bool websocketConnected = false;
} deviceState;

unsigned long lastWifiAttemptMs = 0;
unsigned long lastWsAttemptMs = 0;
unsigned long lastPageSwitchMs = 0;
unsigned long lastBlinkMs = 0;
bool showTroubleshootingPage = false;
bool ledState = false;
bool previousNextButtonState = HIGH;
bool previousAckButtonState = HIGH;

String clipText(const String &input, size_t limit) {
  if (input.length() <= limit) {
    return input;
  }
  return input.substring(0, limit - 3) + "...";
}

void setDisplayHeader(const String &title) {
  display.setTextColor(SSD1306_WHITE);
  display.setTextSize(1);
  display.setCursor(0, 0);
  display.println(title);
  display.drawLine(0, 10, SCREEN_WIDTH, 10, SSD1306_WHITE);
}

void drawStatusPage() {
  display.clearDisplay();
  setDisplayHeader("Edge Diagnostics");
  display.setCursor(0, 14);
  display.printf("WiFi: %s\n", deviceState.wifiConnected ? "OK" : "DOWN");
  display.printf("WS:   %s\n", deviceState.websocketConnected ? "OK" : "DOWN");
  display.printf("PLC:  %s\n", clipText(deviceState.modbusStatus, 12).c_str());
  display.printf("State:%s\n", clipText(deviceState.machineStatus, 12).c_str());
  display.printf("Sev:  %s\n", deviceState.severity.c_str());
  display.display();
}

void drawIssuePage() {
  display.clearDisplay();
  setDisplayHeader("Current Issue");
  display.setCursor(0, 14);
  display.println(clipText(deviceState.issueSummary, 20));
  display.println("");
  display.println("Next:");
  display.println(clipText(deviceState.troubleshooting, 20));
  display.display();
}

void refreshDisplay() {
  if (showTroubleshootingPage) {
    drawIssuePage();
  } else {
    drawStatusPage();
  }
}

void updateLed() {
  if (deviceState.severity == "HIGH") {
    if (millis() - lastBlinkMs >= BLINK_INTERVAL_MS) {
      lastBlinkMs = millis();
      ledState = !ledState;
      digitalWrite(STATUS_LED_PIN, ledState ? HIGH : LOW);
    }
  } else {
    ledState = (deviceState.websocketConnected && deviceState.wifiConnected);
    digitalWrite(STATUS_LED_PIN, ledState ? HIGH : LOW);
  }
}

void ensureWifi() {
  if (WiFi.status() == WL_CONNECTED) {
    deviceState.wifiConnected = true;
    return;
  }

  deviceState.wifiConnected = false;
  if (millis() - lastWifiAttemptMs < WIFI_RETRY_MS) {
    return;
  }

  lastWifiAttemptMs = millis();
  Serial.println("[WiFi] Reconnecting...");
  WiFi.disconnect(true, true);
  delay(250);
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
}

void ensureWebSocket() {
  if (!deviceState.wifiConnected || deviceState.websocketConnected) {
    return;
  }
  if (millis() - lastWsAttemptMs < WS_RETRY_MS) {
    return;
  }

  lastWsAttemptMs = millis();
  Serial.println("[WS] Connecting...");
  webSocket.begin(BRIDGE_HOST, BRIDGE_PORT, WS_PATH);
  webSocket.setReconnectInterval(WS_RETRY_MS);
}

void parseSnapshot(const JsonDocument &doc) {
  if (!doc["payload"].is<JsonObject>()) {
    return;
  }

  JsonObject payload = doc["payload"].as<JsonObject>();
  JsonObject machine = payload["machine"].as<JsonObject>();
  JsonObject connections = payload["connections"].as<JsonObject>();
  JsonVariant activeIssue = payload["active_issue"];

  deviceState.machineStatus = String(machine["state_label"] | "UNKNOWN");
  deviceState.modbusStatus = String(connections["modbus"] | "UNKNOWN");
  deviceState.aiStatus = String(connections["ai"] | "UNKNOWN");
  deviceState.lastUpdate = String(payload["timestamp"] | "--");

  if (activeIssue.is<JsonObject>()) {
    JsonObject issue = activeIssue.as<JsonObject>();
    deviceState.issueSummary = String(issue["issue_summary"] | "Issue active");
    deviceState.troubleshooting = String(issue["troubleshooting_step"] | "Check dashboard");
    deviceState.severity = String(issue["severity"] | "NONE");
  } else {
    deviceState.issueSummary = "No active issue";
    deviceState.troubleshooting = "Monitor process";
    deviceState.severity = "NONE";
  }
}

void parseDiagnostic(const JsonDocument &doc) {
  if (!doc["payload"].is<JsonObject>()) {
    return;
  }

  JsonObject issue = doc["payload"].as<JsonObject>();
  deviceState.issueSummary = String(issue["issue_summary"] | "Issue active");
  deviceState.troubleshooting = String(issue["troubleshooting_step"] | "Check dashboard");
  deviceState.severity = String(issue["severity"] | "NONE");
}

void sendAckIfPressed() {
  bool ackButtonState = digitalRead(ACK_BUTTON_PIN);
  if (previousAckButtonState == HIGH && ackButtonState == LOW && deviceState.websocketConnected) {
    StaticJsonDocument<160> doc;
    doc["type"] = "edge_ack";
    doc["device"] = "esp32-diagnostics-node";
    doc["timestamp_ms"] = millis();
    String payload;
    serializeJson(doc, payload);
    webSocket.sendTXT(payload);
    Serial.println("[WS] ACK button pressed.");
  }
  previousAckButtonState = ackButtonState;
}

void handleNextPageButton() {
  bool nextButtonState = digitalRead(NEXT_PAGE_BUTTON_PIN);
  if (previousNextButtonState == HIGH && nextButtonState == LOW) {
    showTroubleshootingPage = !showTroubleshootingPage;
    refreshDisplay();
  }
  previousNextButtonState = nextButtonState;
}

void webSocketEvent(WStype_t type, uint8_t *payload, size_t length) {
  switch (type) {
    case WStype_DISCONNECTED:
      deviceState.websocketConnected = false;
      Serial.println("[WS] Disconnected");
      break;

    case WStype_CONNECTED:
      deviceState.websocketConnected = true;
      Serial.printf("[WS] Connected to: %s\n", payload);
      webSocket.sendTXT("{\"type\":\"hello\",\"device\":\"esp32-diagnostics-node\"}");
      break;

    case WStype_TEXT: {
      StaticJsonDocument<4096> doc;
      DeserializationError error = deserializeJson(doc, payload, length);
      if (error) {
        Serial.printf("[JSON] Parse error: %s\n", error.c_str());
        return;
      }

      String messageType = String(doc["type"] | "");
      if (messageType == "snapshot") {
        parseSnapshot(doc);
        refreshDisplay();
      } else if (messageType == "diagnostic") {
        parseDiagnostic(doc);
        refreshDisplay();
      }
      break;
    }

    default:
      break;
  }
}

void setupDisplay() {
  Wire.begin(OLED_SDA_PIN, OLED_SCL_PIN);
  if (!display.begin(SSD1306_SWITCHCAPVCC, OLED_ADDRESS)) {
    Serial.println("[OLED] SSD1306 not found");
    return;
  }
  display.clearDisplay();
  display.display();
}

void setup() {
  Serial.begin(115200);
  pinMode(STATUS_LED_PIN, OUTPUT);
  pinMode(NEXT_PAGE_BUTTON_PIN, INPUT_PULLUP);
  pinMode(ACK_BUTTON_PIN, INPUT_PULLUP);

  setupDisplay();
  refreshDisplay();

  WiFi.mode(WIFI_STA);
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);

  webSocket.onEvent(webSocketEvent);
  webSocket.setReconnectInterval(WS_RETRY_MS);
}

void loop() {
  ensureWifi();
  ensureWebSocket();
  webSocket.loop();

  if (millis() - lastPageSwitchMs >= PAGE_ROTATE_MS) {
    lastPageSwitchMs = millis();
    showTroubleshootingPage = !showTroubleshootingPage;
    refreshDisplay();
  }

  handleNextPageButton();
  sendAckIfPressed();
  updateLed();
}
