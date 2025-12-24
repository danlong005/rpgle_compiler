**FREE
// Test program for advanced RPGLE string BIFs
// Tests: %SCANRPL, %CHECK, %CHECKR, %SPLIT

DCL-PROC Main;
    DCL-S str1 CHAR(100);
    DCL-S str2 CHAR(100);
    DCL-S result CHAR(100);
    DCL-S pos INT(10);
    
    str1 = 'The quick brown fox';
    str2 = 'abc123def456';
    
    DSPLY '========================================';
    DSPLY 'Advanced String BIF Test';
    DSPLY '========================================';
    DSPLY '';
    
    // Test %SCANRPL - scan and replace
    DSPLY 'Testing %SCANRPL:';
    DSPLY 'Replace "brown" with "red" in string';
    result = %SCANRPL('brown':'red':str1:1);
    DSPLY result;
    DSPLY '';
    
    // Test %CHECK - check for valid characters
    DSPLY 'Testing %CHECK:';
    DSPLY 'Find first non-alphabetic char';
    pos = %CHECK('abcdefghijklmnopqrstuvwxyz':str2:1);
    DSPLY pos;
    DSPLY '';
    
    // Test %CHECKR - check from right
    DSPLY 'Testing %CHECKR:';
    DSPLY 'Find last non-numeric char from right';
    pos = %CHECKR('0123456789':str2:12);
    DSPLY pos;
    DSPLY '';
    
    DSPLY 'Advanced String BIF Test Complete!';
    DSPLY '========================================';
END-PROC;
