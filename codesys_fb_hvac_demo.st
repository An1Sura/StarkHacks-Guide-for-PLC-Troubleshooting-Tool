(*
    codesys_fb_hvac_demo.st
    Function block for the HVAC / remote pump demo.
*)

FUNCTION_BLOCK FB_HVACDemo
VAR_INPUT
    HVAC_Fault : BOOL;
    Start_Command : BOOL;
    Stop_Command : BOOL;
    Reset_Command : BOOL;
    Mode_Code : INT;
END_VAR
VAR_IN_OUT
    Pump_Running : BOOL;
    System_Fault_Latch : BOOL;
    Fault_Code : INT;
END_VAR
VAR
    ResetEdge : R_TRIG;
END_VAR

ResetEdge(CLK := Reset_Command);

IF Mode_Code <> MODE_HVAC_PUMP THEN
    RETURN;
END_IF;

IF Stop_Command THEN
    Pump_Running := FALSE;
END_IF;

IF Start_Command AND NOT HVAC_Fault AND NOT System_Fault_Latch THEN
    Pump_Running := TRUE;
END_IF;

IF HVAC_Fault THEN
    Pump_Running := FALSE;
    System_Fault_Latch := TRUE;
    Fault_Code := FAULT_HVAC_OR_PUMP;
END_IF;

IF ResetEdge.Q AND NOT HVAC_Fault THEN
    IF Fault_Code = FAULT_HVAC_OR_PUMP THEN
        Pump_Running := FALSE;
        System_Fault_Latch := FALSE;
        Fault_Code := FAULT_NONE;
    END_IF;
END_IF;
