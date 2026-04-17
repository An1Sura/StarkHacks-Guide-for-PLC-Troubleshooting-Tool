# CODESYS Import Guide

This guide tells you exactly how to turn the ST files in this repo into a working CODESYS project.

## 1. Which PLC Code Option To Use

You have two options in this repo:

### Option A: Fastest path

Use:

- [plc_logic.st](/Users/suraa/Desktop/1/plc_logic.st)

Use this when:

- you need the quickest single-file demo
- you want minimal CODESYS project structure

### Option B: Better structured path

Use:

- [codesys_constants.st](/Users/suraa/Desktop/1/codesys_constants.st)
- [codesys_globals.st](/Users/suraa/Desktop/1/codesys_globals.st)
- [codesys_fb_conveyor_demo.st](/Users/suraa/Desktop/1/codesys_fb_conveyor_demo.st)
- [codesys_fb_tank_fill_demo.st](/Users/suraa/Desktop/1/codesys_fb_tank_fill_demo.st)
- [codesys_fb_hvac_demo.st](/Users/suraa/Desktop/1/codesys_fb_hvac_demo.st)
- [codesys_demo_supervisor.st](/Users/suraa/Desktop/1/codesys_demo_supervisor.st)
- [codesys_main_program.st](/Users/suraa/Desktop/1/codesys_main_program.st)

Use this when:

- you want cleaner separation per demo
- you want the best CODESYS organization for explaining the design

Recommended choice: `Option B`

## 2. Recommended CODESYS Object Structure

Create these objects:

1. `GVL_Diagnostics`
2. `PLC_PRG`
3. `FB_ConveyorDemo`
4. `FB_TankFillDemo`
5. `FB_HVACDemo`
6. `FB_DemoSupervisor`

If your target supports DUT / global constants cleanly, also add:

7. `GVL_Constants`

## 3. Exact Import Steps

### Step 1. Create project

1. Open CODESYS.
2. Create a new standard project.
3. Choose a target that supports IEC 61131-3 ST programming and Modbus TCP server/slave setup.

### Step 2. Add the GVL

1. Right-click `Application`.
2. Add Object -> Global Variable List.
3. Name it `GVL_Diagnostics`.
4. Paste in [codesys_globals.st](/Users/suraa/Desktop/1/codesys_globals.st).

### Step 3. Add constants

1. Add a second Global Variable List or constants object.
2. Name it `GVL_Constants`.
3. Paste in [codesys_constants.st](/Users/suraa/Desktop/1/codesys_constants.st).

If your environment does not like this exact object style, you can inline the constants directly in the main program as a fallback.

### Step 4. Add the function blocks

Create function blocks with these names and paste the matching file contents:

- `FB_ConveyorDemo` -> [codesys_fb_conveyor_demo.st](/Users/suraa/Desktop/1/codesys_fb_conveyor_demo.st)
- `FB_TankFillDemo` -> [codesys_fb_tank_fill_demo.st](/Users/suraa/Desktop/1/codesys_fb_tank_fill_demo.st)
- `FB_HVACDemo` -> [codesys_fb_hvac_demo.st](/Users/suraa/Desktop/1/codesys_fb_hvac_demo.st)
- `FB_DemoSupervisor` -> [codesys_demo_supervisor.st](/Users/suraa/Desktop/1/codesys_demo_supervisor.st)

### Step 5. Add the main program

Open `PLC_PRG` and replace its contents with:

- [codesys_main_program.st](/Users/suraa/Desktop/1/codesys_main_program.st)

### Step 6. Build

Build the application.

If you get name-resolution errors:

- confirm object names match exactly
- confirm `GVL_Diagnostics` exists
- confirm constants are available
- confirm standard library FBs `R_TRIG` and `TON` are available

## 4. Modbus Mapping Steps

After the PLC code builds:

1. Add a Modbus TCP server/slave device in the device tree.
2. Create holding register mappings for the variables from `GVL_Diagnostics`.
3. Use [register_map.md](/Users/suraa/Desktop/1/register_map.md) as the address source of truth.

Map these exact variables:

- `GVL_Diagnostics.Conveyor_Running` -> HR0
- `GVL_Diagnostics.Sensor_Blocked` -> HR1
- `GVL_Diagnostics.Motor_Current` -> HR2
- `GVL_Diagnostics.Safety_OK` -> HR3
- `GVL_Diagnostics.Start_Command` -> HR4
- `GVL_Diagnostics.Stop_Command` -> HR5
- `GVL_Diagnostics.Reset_Command` -> HR6
- `GVL_Diagnostics.Tank_Level_Low` -> HR7
- `GVL_Diagnostics.Tank_Level_High` -> HR8
- `GVL_Diagnostics.Sequence_Timeout` -> HR9
- `GVL_Diagnostics.System_Fault_Latch` -> HR10
- `GVL_Diagnostics.Pump_Running` -> HR11
- `GVL_Diagnostics.HVAC_Fault` -> HR12
- `GVL_Diagnostics.Mode_Code` -> HR13
- `GVL_Diagnostics.Fault_Code` -> HR14

## 5. Demo Mode Method

Use `GVL_Diagnostics.Mode_Code` to switch scenarios:

- `1` conveyor
- `2` sequence timeout
- `3` tank fill
- `4` HVAC / pump

This is the easiest way to drive all demo scenarios from one project.

## 6. Best Validation Order

Validate in this order:

1. Build project successfully
2. Toggle one boolean in watch view
3. Verify register changes via [modbus_smoke_test.py](/Users/suraa/Desktop/1/modbus_smoke_test.py)
4. Verify the Python bridge reads the same values
5. Verify dashboard and ESP32 update

## 7. Practical Advice

- Use the modular files for the final demo.
- Keep the single-file [plc_logic.st](/Users/suraa/Desktop/1/plc_logic.st) as a backup.
- Do not try to over-model every machine behavior in the PLC.
- What matters most is clear, repeatable state transitions that the diagnostics layer can explain.
