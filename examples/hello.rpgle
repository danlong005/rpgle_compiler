**free
// Simple RPGLE program demonstrating basic features
CTL-OPT DFTACTGRP(*NO) MAIN(runProgram);

// Declare variables
DCL-S message CHAR(50);
DCL-S counter INT(10) INZ(0);
DCL-S result INT(10);

// Main procedure
DCL-PROC runProgram;
    // Simple loop
    FOR counter = 1 TO 10;
        result = counter * 2;
    ENDFOR;
    
    RETURN;
END-PROC;
