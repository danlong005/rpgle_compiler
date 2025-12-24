**FREE
// Test program for RPGLE I/O status BIFs
// Tests: %FOUND, %EOF, %EQUAL, %ERROR, %OPEN

DCL-F MYFILE;

DCL-PROC Main;
    DCL-S found_flag INT(10);
    DCL-S eof_flag INT(10);
    DCL-S equal_flag INT(10);
    DCL-S error_flag INT(10);
    DCL-S open_flag INT(10);
    
    DSPLY '========================================';
    DSPLY 'I/O Status BIF Test';
    DSPLY '========================================';
    DSPLY '';
    
    // Test %FOUND - record found indicator
    DSPLY 'Testing %FOUND:';
    DSPLY 'Check if last I/O found a record';
    found_flag = %FOUND();
    DSPLY found_flag;
    DSPLY '';
    
    // Test %EOF - end of file indicator
    DSPLY 'Testing %EOF:';
    DSPLY 'Check if at end of file';
    eof_flag = %EOF(MYFILE);
    DSPLY eof_flag;
    DSPLY '';
    
    // Test %EQUAL - equal indicator
    DSPLY 'Testing %EQUAL:';
    DSPLY 'Check equal condition from last I/O';
    equal_flag = %EQUAL();
    DSPLY equal_flag;
    DSPLY '';
    
    // Test %ERROR - error indicator
    DSPLY 'Testing %ERROR:';
    DSPLY 'Check if last operation had error';
    error_flag = %ERROR();
    DSPLY error_flag;
    DSPLY '';
    
    // Test %OPEN - file open status
    DSPLY 'Testing %OPEN:';
    DSPLY 'Check if file is open';
    open_flag = %OPEN('MYFILE');
    DSPLY open_flag;
    DSPLY '';
    
    DSPLY 'I/O Status BIF Test Complete!';
    DSPLY 'Note: All indicators return 0 (false)';
    DSPLY 'because no file I/O has been performed';
    DSPLY '========================================';
END-PROC;
