**FREE
// Test program for RPGLE numeric BIFs
// Tests: %ABS, %INT, %FLOAT, %DEC, %CHAR, %EDITC

DCL-PROC Main;
    DCL-S num1 INT(10);
    DCL-S num2 PACKED(7:2);
    DCL-S num3 PACKED(10:5);
    DCL-S result CHAR(50);
    
    // Initialize test values
    num1 = -42;
    num2 = 123.45;
    num3 = 3.14159;
    
    DSPLY '========================================';
    DSPLY 'Numeric BIF Test';
    DSPLY '========================================';
    DSPLY '';
    
    // Test %ABS - absolute value
    DSPLY 'Testing %ABS:';
    DSPLY 'Absolute value of -42';
    num1 = %ABS(num1);
    DSPLY num1;
    DSPLY '';
    
    // Test %INT - convert to integer
    DSPLY 'Testing %INT:';
    DSPLY 'Convert 123.45 to integer';
    num1 = %INT(num2);
    DSPLY num1;
    DSPLY '';
    
    // Test %FLOAT - convert to float
    DSPLY 'Testing %FLOAT:';
    DSPLY 'Convert 42 to float';
    num3 = %FLOAT(num1);
    DSPLY num3;
    DSPLY '';
    
    // Test %DEC - convert to decimal
    DSPLY 'Testing %DEC:';
    DSPLY 'Convert to decimal (7,2)';
    num2 = %DEC(num3:7:2);
    DSPLY num2;
    DSPLY '';
    
    // Test %CHAR - convert to string
    DSPLY 'Testing %CHAR:';
    DSPLY 'Convert 42 to character';
    result = %CHAR(num1);
    DSPLY result;
    DSPLY '';
    
    // Test %EDITC - edit with edit code
    DSPLY 'Testing %EDITC:';
    DSPLY 'Format 123.45 with edit code';
    result = %EDITC(num2:'J':'$');
    DSPLY result;
    DSPLY '';
    
    DSPLY 'Numeric BIF Test Complete!';
    DSPLY '========================================';
END-PROC;
