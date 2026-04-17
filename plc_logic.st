(*
    plc_logic.st
    Sample Structured Text logic for the hackathon prototype.

    Notes:
    - Map these variables to the holding registers documented in register_map.md.
    - Factory I/O should drive the simulated sensors and read the actuator outputs.
    - This is a compact demo program, not a production safety program.
*)

PROGRAM PLC_PRG
VAR
    Conveyor_Running : BOOL := FALSE;      (* HR0 *)
    Sensor_Blocked : BOOL := FALSE;        (* HR1 *)
    Motor_Current : INT := 0;              (* HR2 *)
    Safety_OK : BOOL := TRUE;              (* HR3 *)
    Start_Command : BOOL := FALSE;         (* HR4 *)
    Stop_Command : BOOL := FALSE;          (* HR5 *)
    Reset_Command : BOOL := FALSE;         (* HR6 *)
    Tank_Level_Low : BOOL := FALSE;        (* HR7 *)
    Tank_Level_High : BOOL := FALSE;       (* HR8 *)
    Sequence_Timeout : BOOL := FALSE;      (* HR9 *)
    System_Fault_Latch : BOOL := FALSE;    (* HR10 *)
    Pump_Running : BOOL := FALSE;          (* HR11 *)
    HVAC_Fault : BOOL := FALSE;            (* HR12 *)
    Mode_Code : INT := 0;                  (* HR13 *)
    Fault_Code : INT := 0;                 (* HR14 *)

    StartEdge : R_TRIG;
    ResetEdge : R_TRIG;
    JamTimer : TON;
    SequenceTimer : TON;
    FillGuardTimer : TON;
END_VAR

(* Edge detectors *)
StartEdge(CLK := Start_Command);
ResetEdge(CLK := Reset_Command);

(* Defaults *)
Sequence_Timeout := FALSE;

(* Stop command always drops outputs *)
IF Stop_Command THEN
    Conveyor_Running := FALSE;
    Pump_Running := FALSE;
END_IF;

(* Safety blocked start check *)
IF Start_Command AND NOT Safety_OK THEN
    Conveyor_Running := FALSE;
    System_Fault_Latch := TRUE;
    Fault_Code := 101;
END_IF;

(* Healthy start behavior *)
IF StartEdge.Q AND Safety_OK AND NOT System_Fault_Latch THEN
    CASE Mode_Code OF
        1: Conveyor_Running := TRUE;
        2: Conveyor_Running := TRUE;
        3: Pump_Running := Tank_Level_Low AND NOT Tank_Level_High;
        4: Pump_Running := TRUE;
    ELSE
        Conveyor_Running := FALSE;
        Pump_Running := FALSE;
    END_CASE;
END_IF;

(* Conveyor jam logic *)
JamTimer(IN := Conveyor_Running AND Sensor_Blocked, PT := T#3S);
IF JamTimer.Q THEN
    System_Fault_Latch := TRUE;
    Fault_Code := 201;
    Conveyor_Running := FALSE;
END_IF;

(* Sequence timing validation mode *)
SequenceTimer(IN := (Mode_Code = 2) AND Conveyor_Running AND NOT Tank_Level_High, PT := T#8S);
IF SequenceTimer.Q THEN
    Sequence_Timeout := TRUE;
    System_Fault_Latch := TRUE;
    Fault_Code := 301;
    Conveyor_Running := FALSE;
END_IF;

(* Tank fill verification mode *)
IF Mode_Code = 3 THEN
    IF Tank_Level_Low AND NOT System_Fault_Latch THEN
        Pump_Running := TRUE;
    END_IF;

    IF Tank_Level_High THEN
        Pump_Running := FALSE;
    END_IF;

    FillGuardTimer(IN := Tank_Level_Low AND NOT Tank_Level_High AND NOT Pump_Running, PT := T#5S);
    IF FillGuardTimer.Q THEN
        System_Fault_Latch := TRUE;
        Fault_Code := 401;
    END_IF;
END_IF;

(* HVAC / remote pump demo mode *)
IF Mode_Code = 4 THEN
    IF HVAC_Fault THEN
        System_Fault_Latch := TRUE;
        Fault_Code := 501;
        Pump_Running := FALSE;
    END_IF;
END_IF;

(* Motor current model for simulation/diagnostics *)
IF Conveyor_Running AND Sensor_Blocked THEN
    Motor_Current := 46;
ELSIF Conveyor_Running THEN
    Motor_Current := 18;
ELSE
    Motor_Current := 0;
END_IF;

(* Reset logic clears only after fault cause is healthy *)
IF ResetEdge.Q THEN
    IF Safety_OK AND NOT Sensor_Blocked AND NOT HVAC_Fault THEN
        System_Fault_Latch := FALSE;
        Sequence_Timeout := FALSE;
        Fault_Code := 0;
        Conveyor_Running := FALSE;
        IF Mode_Code <> 4 THEN
            Pump_Running := FALSE;
        END_IF;
    END_IF;
END_IF;
