(*
    codesys_demo_supervisor.st
    Optional helper block for demo stability.
    Call this once per scan to keep unrelated outputs quiet when switching modes.
*)

FUNCTION_BLOCK FB_DemoSupervisor
VAR_INPUT
    Mode_Code : INT;
    Stop_Command : BOOL;
END_VAR
VAR_IN_OUT
    Conveyor_Running : BOOL;
    Pump_Running : BOOL;
END_VAR

IF Stop_Command THEN
    Conveyor_Running := FALSE;
    Pump_Running := FALSE;
END_IF;

CASE Mode_Code OF
    MODE_CONVEYOR, MODE_SEQUENCE_TEST:
        Pump_Running := FALSE;
    MODE_TANK_FILL, MODE_HVAC_PUMP:
        Conveyor_Running := FALSE;
ELSE
    Conveyor_Running := FALSE;
    Pump_Running := FALSE;
END_CASE;
