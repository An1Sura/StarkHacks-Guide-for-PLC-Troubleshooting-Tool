(*
    codesys_constants.st
    Add this as a DUT or global constants list in CODESYS.
    Use these values so the PLC code, Modbus map, Python bridge, and docs all speak the same language.
*)

VAR_GLOBAL CONSTANT
    MODE_IDLE : INT := 0;
    MODE_CONVEYOR : INT := 1;
    MODE_SEQUENCE_TEST : INT := 2;
    MODE_TANK_FILL : INT := 3;
    MODE_HVAC_PUMP : INT := 4;

    FAULT_NONE : INT := 0;
    FAULT_START_BLOCKED_SAFETY : INT := 101;
    FAULT_CONVEYOR_JAM : INT := 201;
    FAULT_SEQUENCE_TIMEOUT : INT := 301;
    FAULT_TANK_FILL_VERIFY : INT := 401;
    FAULT_HVAC_OR_PUMP : INT := 501;
END_VAR
