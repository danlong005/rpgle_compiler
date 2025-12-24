**free
// Test equality in SELECT/WHEN
CTL-OPT DFTACTGRP(*NO) MAIN(testWhen);

DCL-S value INT(10);

DCL-PROC testWhen;
    DSPLY 'Testing = in WHEN clauses:';
    
    value = 1;
    SELECT;
        WHEN value = 1;
            DSPLY 'Value is 1';
        WHEN value = 2;
            DSPLY 'Value is 2';
        OTHER;
            DSPLY 'Value is other';
    ENDSL;
    
    value = 3;
    SELECT;
        WHEN value = 1;
            DSPLY 'Should not see this';
        WHEN value = 3;
            DSPLY 'Value is 3';
        OTHER;
            DSPLY 'Should not see this either';
    ENDSL;
    
    RETURN;
END-PROC;
