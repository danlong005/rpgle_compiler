**FREE

CTL-OPT DFTACTGRP(*NO) MAIN(testBooleans);

DCL-PROC testBooleans;
    DCL-S isActive IND;
    DCL-S isComplete IND;
    DCL-S hasError IND;
    DCL-S result INT(10);
    
    DSPLY '=== Testing Boolean Indicators ===';
    
    // Test *ON constant
    isActive = *ON;
    DSPLY 'isActive set to *ON';
    IF isActive;
        DSPLY 'isActive is TRUE';
    ELSE;
        DSPLY 'isActive is FALSE';
    ENDIF;
    
    // Test *OFF constant
    isComplete = *OFF;
    DSPLY 'isComplete set to *OFF';
    IF isComplete;
        DSPLY 'isComplete is TRUE';
    ELSE;
        DSPLY 'isComplete is FALSE';
    ENDIF;
    
    // Test boolean logic
    hasError = *OFF;
    IF NOT hasError;
        DSPLY 'No errors detected';
    ENDIF;
    
    // Test boolean in conditions
    isActive = *ON;
    isComplete = *ON;
    IF isActive AND isComplete;
        DSPLY 'Both active and complete';
    ENDIF;
    
    // Test boolean assignment from comparison
    result = 10;
    isActive = (result > 5);
    IF isActive;
        DSPLY 'Result is greater than 5';
    ENDIF;
    
    DSPLY '=== Test Complete ===';
END-PROC;
