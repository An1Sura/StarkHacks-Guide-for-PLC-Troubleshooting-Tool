(*
    codesys_fb_conveyor_demo.st
    Function block for conveyor-related demo behavior:
    - start blocked by safety
    - conveyor running logic
    - jam detection
    - sequence timeout support when Mode_Code = 2
*)

FUNCTION_BLOCK FB_ConveyorDemo
VAR_INPUT
    Safety_OK : BOOL;
    Start_Command : BOOL;
    Stop_Command : BOOL;
    Reset_Command : BOOL;
    Sensor_Blocked : BOOL;
    Mode_Code : INT;
    FaultLatchedIn : BOOL;
    JamTimerPreset : TIME;
    SequenceTimerPreset : TIME;
END_VAR
VAR_IN_OUT
    Conveyor_Running : BOOL;
    Motor_Current : INT;
    Sequence_Timeout : BOOL;
    System_Fault_Latch : BOOL;
    Fault_Code : INT;
END_VAR
VAR
    StartEdge : R_TRIG;
    ResetEdge : R_TRIG;
    JamTimer : TON;
    SequenceTimer : TON;
END_VAR

StartEdge(CLK := Start_Command);
ResetEdge(CLK := Reset_Command);

IF Stop_Command THEN
    Conveyor_Running := FALSE;
END_IF;

IF Start_Command AND NOT Safety_OK THEN
    Conveyor_Running := FALSE;
    System_Fault_Latch := TRUE;
    Fault_Code := FAULT_START_BLOCKED_SAFETY;
END_IF;

IF StartEdge.Q AND Safety_OK AND NOT FaultLatchedIn AND (Mode_Code = MODE_CONVEYOR OR Mode_Code = MODE_SEQUENCE_TEST) THEN
    Conveyor_Running := TRUE;
END_IF;

JamTimer(IN := (Mode_Code = MODE_CONVEYOR) AND Conveyor_Running AND Sensor_Blocked, PT := JamTimerPreset);
IF JamTimer.Q THEN
    Conveyor_Running := FALSE;
    System_Fault_Latch := TRUE;
    Fault_Code := FAULT_CONVEYOR_JAM;
END_IF;

SequenceTimer(IN := (Mode_Code = MODE_SEQUENCE_TEST) AND Conveyor_Running AND NOT Sensor_Blocked, PT := SequenceTimerPreset);
IF SequenceTimer.Q THEN
    Sequence_Timeout := TRUE;
    Conveyor_Running := FALSE;
    System_Fault_Latch := TRUE;
    Fault_Code := FAULT_SEQUENCE_TIMEOUT;
END_IF;

IF Conveyor_Running AND Sensor_Blocked THEN
    Motor_Current := 46;
ELSIF Conveyor_Running THEN
    Motor_Current := 18;
ELSE
    Motor_Current := 0;
END_IF;

IF ResetEdge.Q AND Safety_OK AND NOT Sensor_Blocked THEN
    IF Fault_Code = FAULT_CONVEYOR_JAM OR Fault_Code = FAULT_START_BLOCKED_SAFETY OR Fault_Code = FAULT_SEQUENCE_TIMEOUT THEN
        Conveyor_Running := FALSE;
        Sequence_Timeout := FALSE;
        IF Fault_Code <> FAULT_HVAC_OR_PUMP AND Fault_Code <> FAULT_TANK_FILL_VERIFY THEN
            System_Fault_Latch := FALSE;
            Fault_Code := FAULT_NONE;
        END_IF;
    END_IF;
END_IF;
