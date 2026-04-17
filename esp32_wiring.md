# ESP32 Wiring Guide

## Recommended GPIO Choices

| Function | ESP32 Pin | Notes |
| --- | --- | --- |
| OLED SDA | GPIO 21 | Standard I2C SDA |
| OLED SCL | GPIO 22 | Standard I2C SCL |
| OLED VCC | 3.3V | Most SSD1306 modules are 3.3V-safe |
| OLED GND | GND | Common ground |
| Status LED anode | GPIO 2 through 220 ohm resistor | Built-in LED often already on GPIO 2 for many boards |
| Status LED cathode | GND | Common ground |
| Next/Page button | GPIO 18 to GND | Use `INPUT_PULLUP` |
| Ack button | GPIO 19 to GND | Use `INPUT_PULLUP` |

## Basic Wiring

### OLED (SSD1306 I2C)

- `OLED VCC` -> `ESP32 3.3V`
- `OLED GND` -> `ESP32 GND`
- `OLED SDA` -> `ESP32 GPIO 21`
- `OLED SCL` -> `ESP32 GPIO 22`

### LED

- `GPIO 2` -> `220 ohm resistor` -> `LED anode (+)`
- `LED cathode (-)` -> `GND`

### Buttons

Each button is wired as active-low:

- one side of button -> `GPIO 18` or `GPIO 19`
- other side -> `GND`
- firmware uses internal pull-up resistors

## Practical Notes

- If your board already has a built-in LED on `GPIO 2`, you can skip the external LED for the demo.
- Some OLED breakout boards label pins as `SDA/SCK` or `SDA/SCL`; treat `SCK` as the I2C clock line.
- Keep wires short if you are powering from USB on a noisy demo table.

## Enclosure / DIN-Rail Concept

For the hackathon, a realistic packaging story is enough:

- small 3D printed front face with OLED cutout
- side openings for USB power and status LED visibility
- rear clip or screw holes for a DIN-style mount
- label it as a “diagnostics node,” not a controller

That distinction matters because the value proposition is retrofit diagnostics without replacing the PLC.
