**FREE

// Test advanced file positioning operations: SETLL, SETGT, READE, READP, READPE

CTL-OPT DFTACTGRP(*NO) MAIN(testFilePositioning);

DCL-F CUSTFILE;

DCL-DS customer QUALIFIED;
    id INT(10);
    name CHAR(50);
    city CHAR(30);
END-DS;

DCL-PROC testFilePositioning;
    DCL-S key INT(10);
    DCL-S found IND;
    
    DSPLY '=== File Positioning Operations Test ===';
    DSPLY '';
    
    // Open the file
    OPEN CUSTFILE;
    DSPLY 'File opened';
    DSPLY '';
    
    // Test SETLL - Set lower limit (position at/before key)
    DSPLY 'Test 1: SETLL - Position at or before key 100';
    key = 100;
    SETLL key CUSTFILE;
    IF %FOUND();
        DSPLY '  Found position for key';
    ELSE;
        DSPLY '  Key position not found';
    ENDIF;
    DSPLY '';
    
    // Test SETGT - Set greater than (position after key)
    DSPLY 'Test 2: SETGT - Position after key 100';
    SETGT key CUSTFILE;
    IF %FOUND();
        DSPLY '  Positioned after key';
    ELSE;
        DSPLY '  Could not position';
    ENDIF;
    DSPLY '';
    
    // Test READE - Read equal (read next with matching key)
    DSPLY 'Test 3: READE - Read next record with matching key';
    READE CUSTFILE customer;
    IF NOT %EOF(CUSTFILE);
        DSPLY '  Read record:';
        DSPLY '    ID:';
        DSPLY customer.id;
        DSPLY '    Name:';
        DSPLY customer.name;
        DSPLY '    City:';
        DSPLY customer.city;
    ELSE;
        DSPLY '  No matching record found';
    ENDIF;
    DSPLY '';
    
    // Test READP - Read previous record
    DSPLY 'Test 4: READP - Read previous record';
    READP CUSTFILE customer;
    IF NOT %EOF(CUSTFILE);
        DSPLY '  Read previous record:';
        DSPLY '    ID:';
        DSPLY customer.id;
        DSPLY '    Name:';
        DSPLY customer.name;
    ELSE;
        DSPLY '  No previous record';
    ENDIF;
    DSPLY '';
    
    // Test READPE - Read previous equal (read previous with matching key)
    DSPLY 'Test 5: READPE - Read previous with matching key';
    READPE CUSTFILE customer;
    IF %EQUAL();
        DSPLY '  Found matching previous record:';
        DSPLY '    ID:';
        DSPLY customer.id;
        DSPLY '    Name:';
        DSPLY customer.name;
    ELSE;
        DSPLY '  No matching previous record';
    ENDIF;
    DSPLY '';
    
    // Test sequential READE loop
    DSPLY 'Test 6: Loop reading all records with key 100';
    key = 100;
    SETLL key CUSTFILE;
    READE CUSTFILE customer;
    DOW %EQUAL() AND NOT %EOF(CUSTFILE);
        DSPLY '  Record:';
        DSPLY customer.name;
        READE CUSTFILE customer;
    ENDDO;
    DSPLY 'End of matching records';
    DSPLY '';
    
    CLOSE CUSTFILE;
    DSPLY '=== Test Complete ===';
END-PROC;
