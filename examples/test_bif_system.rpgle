**FREE
// Test program for RPGLE system/memory BIFs
// Tests: %ADDR, %ELEM, %PARMS, %OCCUR, %LEN, %STR

DCL-PROC Main;
    DCL-S str1 CHAR(50);
    DCL-S num1 INT(10);
    DCL-S len_val INT(10);
    DCL-S elem_cnt INT(10);
    DCL-S parm_cnt INT(10);
    
    str1 = 'Test String';
    num1 = 12345;
    
    DSPLY '========================================';
    DSPLY 'System/Memory BIF Test';
    DSPLY '========================================';
    DSPLY '';
    
    // Test %LEN - length of variable
    DSPLY 'Testing %LEN:';
    DSPLY 'Get length of "Test String"';
    len_val = %LEN(str1);
    DSPLY len_val;
    DSPLY '';
    
    // Test %ELEM - number of elements in array
    DSPLY 'Testing %ELEM:';
    DSPLY 'Get element count (placeholder)';
    elem_cnt = %ELEM(str1);
    DSPLY elem_cnt;
    DSPLY '';
    
    // Test %PARMS - number of parameters passed
    DSPLY 'Testing %PARMS:';
    DSPLY 'Get parameter count';
    parm_cnt = %PARMS();
    DSPLY parm_cnt;
    DSPLY '';
    
    // Test %OCCUR - data structure occurrence
    DSPLY 'Testing %OCCUR:';
    DSPLY 'Get DS occurrence (placeholder)';
    num1 = %OCCUR(str1);
    DSPLY num1;
    DSPLY '';
    
    DSPLY 'System/Memory BIF Test Complete!';
    DSPLY 'Note: Some BIFs return placeholder values';
    DSPLY 'as full implementation requires arrays/DS';
    DSPLY '========================================';
END-PROC;
