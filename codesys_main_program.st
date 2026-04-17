(*
    codesys_main_program.st
    Recommended main PLC program for the demo.

    This version is more modular than plc_logic.st.
    Use this if you want a cleaner CODESYS structure with separate function blocks per scenario.
*)

PROGRAM PLC_PRG
VAR
    ConveyorDemo : FB_ConveyorDemo;
    TankFillDemo : FB_TankFillDemo;
    HVACDemo : FB_HVACDemo;
    DemoSupervisor : FB_DemoSupervisor;
END_VAR

IF GVL_Diagnostics.Reset_Command THEN
    IF GVL_Diagnostics.Safety_OK AND NOT GVL_Diagnostics.Sensor_Blocked AND NOT GVL_Diagnostics.HVAC_Fault THEN
        GVL_Diagnostics.Sequence_Timeout := FALSE;
    END_IF;
END_IF;

DemoSupervisor(
    Mode_Code := GVL_Diagnostics.Mode_Code,
    Stop_Command := GVL_Diagnostics.Stop_Command,
    Conveyor_Running := GVL_Diagnostics.Conveyor_Running,
    Pump_Running := GVL_Diagnostics.Pump_Running
);

ConveyorDemo(
    Safety_OK := GVL_Diagnostics.Safety_OK,
    Start_Command := GVL_Diagnostics.Start_Command,
    Stop_Command := GVL_Diagnostics.Stop_Command,
    Reset_Command := GVL_Diagnostics.Reset_Command,
    Sensor_Blocked := GVL_Diagnostics.Sensor_Blocked,
    Mode_Code := GVL_Diagnostics.Mode_Code,
    FaultLatchedIn := GVL_Diagnostics.System_Fault_Latch,
    JamTimerPreset := GVL_Diagnostics.Demo_JamTimerPreset,
    SequenceTimerPreset := GVL_Diagnostics.Demo_SequenceTimerPreset,
    Conveyor_Running := GVL_Diagnostics.Conveyor_Running,
    Motor_Current := GVL_Diagnostics.Motor_Current,
    Sequence_Timeout := GVL_Diagnostics.Sequence_Timeout,
    System_Fault_Latch := GVL_Diagnostics.System_Fault_Latch,
    Fault_Code := GVL_Diagnostics.Fault_Code
);

TankFillDemo(
    Tank_Level_Low := GVL_Diagnostics.Tank_Level_Low,
    Tank_Level_High := GVL_Diagnostics.Tank_Level_High,
    Stop_Command := GVL_Diagnostics.Stop_Command,
    Reset_Command := GVL_Diagnostics.Reset_Command,
    Mode_Code := GVL_Diagnostics.Mode_Code,
    FaultLatchedIn := GVL_Diagnostics.System_Fault_Latch,
    FillGuardPreset := GVL_Diagnostics.Demo_FillGuardPreset,
    Pump_Running := GVL_Diagnostics.Pump_Running,
    System_Fault_Latch := GVL_Diagnostics.System_Fault_Latch,
    Fault_Code := GVL_Diagnostics.Fault_Code
);

HVACDemo(
    HVAC_Fault := GVL_Diagnostics.HVAC_Fault,
    Start_Command := GVL_Diagnostics.Start_Command,
    Stop_Command := GVL_Diagnostics.Stop_Command,
    Reset_Command := GVL_Diagnostics.Reset_Command,
    Mode_Code := GVL_Diagnostics.Mode_Code,
    Pump_Running := GVL_Diagnostics.Pump_Running,
    System_Fault_Latch := GVL_Diagnostics.System_Fault_Latch,
    Fault_Code := GVL_Diagnostics.Fault_Code
);
