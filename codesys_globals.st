(*
    codesys_globals.st
    Create a Global Variable List (GVL) in CODESYS and paste this content into it.
    These variables are the shared machine state used by all demo scenarios and the Modbus map.
*)

{attribute 'qualified_only'}
VAR_GLOBAL
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

    Demo_EnableAutoCurrentModel : BOOL := TRUE;
    Demo_JamTimerPreset : TIME := T#3S;
    Demo_SequenceTimerPreset : TIME := T#8S;
    Demo_FillGuardPreset : TIME := T#5S;
END_VAR
