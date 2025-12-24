**FREE
// Test program for RPGLE string BIFs
// Tests: %TRIM, %TRIMR, %TRIML, %SCAN, %SUBST, %REPLACE, %XLATE

DCL-PROC Main;
    DCL-S str1 CHAR(50);
    DCL-S str2 CHAR(50);
    DCL-S str3 CHAR(50);
    DCL-S result CHAR(50);
    DCL-S pos INT(10);
    
    // Initialize test strings
    str1 = '  Hello World  ';
    str2 = 'abcdef';
    str3 = 'The quick brown fox';
    
    DSPLY '========================================';
    DSPLY 'String BIF Test';
    DSPLY '========================================';
    DSPLY '';
    
    // Test %TRIMR - trim trailing spaces
    DSPLY 'Testing %TRIMR:';
    DSPLY 'Original: "  Hello World  "';
    result = %TRIMR(str1);
    DSPLY result;
    DSPLY '';
    
    // Test %TRIML - trim leading spaces
    DSPLY 'Testing %TRIML:';
    DSPLY 'Original: "  Hello World  "';
    result = %TRIML(str1);
    DSPLY result;
    DSPLY '';
    
    // Test %TRIM - trim both
    DSPLY 'Testing %TRIM:';
    DSPLY 'Original: "  Hello World  "';
    result = %TRIM(str1);
    DSPLY result;
    DSPLY '';
    
    // Test %SCAN - find substring
    DSPLY 'Testing %SCAN:';
    DSPLY 'Search for "quick" in "The quick brown fox"';
    pos = %SCAN('quick':str3:1);
    DSPLY pos;
    DSPLY '';
    
    // Test %SUBST - substring extraction
    DSPLY 'Testing %SUBST:';
    DSPLY 'Extract from position 5, length 5 from "abcdef"';
    result = %SUBST(str2:1:3);
    DSPLY result;
    DSPLY '';
    
    // Test %REPLACE - replace substring
    DSPLY 'Testing %REPLACE:';
    DSPLY 'Replace "quick" with "slow"';
    result = %REPLACE('slow':str3:5:5);
    DSPLY result;
    DSPLY '';
    
    // Test %XLATE - translate characters
    DSPLY 'Testing %XLATE:';
    DSPLY 'Translate a->X, b->Y in "abcdef"';
    result = %XLATE('ab':'XY':str2:1);
    DSPLY result;
    DSPLY '';
    
    DSPLY 'String BIF Test Complete!';
    DSPLY '========================================';
END-PROC;
