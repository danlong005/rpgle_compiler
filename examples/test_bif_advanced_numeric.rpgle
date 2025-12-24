**FREE
// Test program for advanced RPGLE numeric BIFs
// Tests: %SQRT, %REM, %DIV, %BITAND, %BITOR, %BITXOR, %BITNOT

DCL-PROC Main;
    DCL-S num1 INT(10);
    DCL-S num2 INT(10);
    DCL-S result INT(10);
    DCL-S sqrt_result PACKED(10:5);
    
    num1 = 25;
    num2 = 7;
    
    DSPLY '========================================';
    DSPLY 'Advanced Numeric BIF Test';
    DSPLY '========================================';
    DSPLY '';
    
    // Test %SQRT - square root
    DSPLY 'Testing %SQRT:';
    DSPLY 'Square root of 25';
    sqrt_result = %SQRT(num1);
    DSPLY sqrt_result;
    DSPLY '';
    
    // Test %REM - remainder
    DSPLY 'Testing %REM:';
    DSPLY '25 mod 7';
    result = %REM(num1:num2);
    DSPLY result;
    DSPLY '';
    
    // Test %DIV - integer division
    DSPLY 'Testing %DIV:';
    DSPLY '25 div 7';
    result = %DIV(num1:num2);
    DSPLY result;
    DSPLY '';
    
    // Test bitwise operations
    DSPLY 'Testing Bitwise BIFs:';
    num1 = 12;
    num2 = 10;
    
    DSPLY '%BITAND(12,10):';
    result = %BITAND(num1:num2);
    DSPLY result;
    
    DSPLY '%BITOR(12,10):';
    result = %BITOR(num1:num2);
    DSPLY result;
    
    DSPLY '%BITXOR(12,10):';
    result = %BITXOR(num1:num2);
    DSPLY result;
    
    DSPLY '%BITNOT(12):';
    result = %BITNOT(num1);
    DSPLY result;
    DSPLY '';
    
    DSPLY 'Advanced Numeric BIF Test Complete!';
    DSPLY '========================================';
END-PROC;
