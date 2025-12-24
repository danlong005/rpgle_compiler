**FREE

// Comprehensive test showing *ON and *OFF as true/false boolean values

CTL-OPT DFTACTGRP(*NO) MAIN(demonstrateBooleans);

DCL-PROC demonstrateBooleans;
    DCL-S enabled IND;
    DCL-S disabled IND;
    DCL-S flag1 IND;
    DCL-S flag2 IND;
    DCL-S count INT(10);
    
    DSPLY '=== RPGLE Boolean Indicator Demonstration ===';
    DSPLY '';
    
    // Initialize with *ON (true)
    enabled = *ON;
    DSPLY 'enabled = *ON';
    IF enabled;
        DSPLY '  -> enabled is TRUE';
    ENDIF;
    DSPLY '';
    
    // Initialize with *OFF (false)
    disabled = *OFF;
    DSPLY 'disabled = *OFF';
    IF NOT disabled;
        DSPLY '  -> disabled is FALSE (NOT disabled = TRUE)';
    ENDIF;
    DSPLY '';
    
    // Boolean AND operation
    flag1 = *ON;
    flag2 = *ON;
    DSPLY 'flag1 = *ON, flag2 = *ON';
    IF flag1 AND flag2;
        DSPLY '  -> Both flags are TRUE';
    ENDIF;
    DSPLY '';
    
    // Boolean OR operation
    flag1 = *ON;
    flag2 = *OFF;
    DSPLY 'flag1 = *ON, flag2 = *OFF';
    IF flag1 OR flag2;
        DSPLY '  -> At least one flag is TRUE';
    ENDIF;
    DSPLY '';
    
    // Using in loops
    enabled = *ON;
    count = 0;
    DSPLY 'Loop while enabled = *ON:';
    DOW enabled AND count < 3;
        count = count + 1;
        DSPLY count;
        IF count = 3;
            enabled = *OFF;
        ENDIF;
    ENDDO;
    DSPLY 'Loop ended (enabled set to *OFF)';
    DSPLY '';
    
    // Boolean from comparison
    DSPLY 'Setting flag from comparison:';
    count = 10;
    enabled = (count > 5);
    IF enabled;
        DSPLY '  -> count > 5 is TRUE';
    ENDIF;
    
    disabled = (count < 5);
    IF NOT disabled;
        DSPLY '  -> count < 5 is FALSE';
    ENDIF;
    DSPLY '';
    
    DSPLY '=== All Boolean Tests Complete ===';
END-PROC;
