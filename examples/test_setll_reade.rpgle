**FREE

// Simple test of file positioning - SETLL and READE

CTL-OPT DFTACTGRP(*NO) MAIN(testBasicPositioning);

DCL-F DATAFILE;

DCL-PROC testBasicPositioning;
    DCL-S searchKey INT(10);
    DCL-S dataKey INT(10);
    DCL-S dataValue CHAR(20);
    
    DSPLY '=== Testing SETLL and READE ===';
    
    OPEN DATAFILE;
    
    // Position at key 100
    searchKey = 100;
    DSPLY 'Setting position to key 100';
    SETLL searchKey DATAFILE;
    
    IF %FOUND();
        DSPLY 'Position set successfully';
        
        // Read matching records
        DSPLY 'Reading matching records:';
        READE DATAFILE;
        DOW %EQUAL() AND NOT %EOF(DATAFILE);
            DSPLY 'Found matching record';
            READE DATAFILE;
        ENDDO;
    ELSE;
        DSPLY 'Key not found';
    ENDIF;
    
    CLOSE DATAFILE;
    DSPLY '=== Test Complete ===';
END-PROC;
