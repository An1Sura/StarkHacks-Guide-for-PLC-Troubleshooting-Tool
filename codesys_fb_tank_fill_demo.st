(*
    codesys_fb_tank_fill_demo.st
    Function block for the tank fill verification demo.
*)

FUNCTION_BLOCK FB_TankFillDemo
VAR_INPUT
    Tank_Level_Low : BOOL;
    Tank_Level_High : BOOL;
    Stop_Command : BOOL;
    Reset_Command : BOOL;
    Mode_Code : INT;
    FaultLatchedIn : BOOL;
    FillGuardPreset : TIME;
END_VAR
VAR_IN_OUT
    Pump_Running : BOOL;
    System_Fault_Latch : BOOL;
    Fault_Code : INT;
END_VAR
VAR
    ResetEdge : R_TRIG;
    FillGuardTimer : TON;
END_VAR

ResetEdge(CLK := Reset_Command);

IF Mode_Code <> MODE_TANK_FILL THEN
    FillGuardTimer(IN := FALSE, PT := FillGuardPreset);
    RETURN;
END_IF;

IF Stop_Command THEN
    Pump_Running := FALSE;
END_IF;

IF Tank_Level_Low AND NOT Tank_Level_High AND NOT FaultLatchedIn THEN
    Pump_Running := TRUE;
END_IF;

IF Tank_Level_High THEN
    Pump_Running := FALSE;
END_IF;

FillGuardTimer(IN := Tank_Level_Low AND NOT Tank_Level_High AND NOT Pump_Running, PT := FillGuardPreset);
IF FillGuardTimer.Q THEN
    System_Fault_Latch := TRUE;
    Fault_Code := FAULT_TANK_FILL_VERIFY;
END_IF;

IF ResetEdge.Q AND NOT Tank_Level_Low AND NOT Tank_Level_High THEN
    IF Fault_Code = FAULT_TANK_FILL_VERIFY THEN
        Pump_Running := FALSE;
        System_Fault_Latch := FALSE;
        Fault_Code := FAULT_NONE;
    END_IF;
END_IF;
