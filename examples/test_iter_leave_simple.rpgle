**FREE

CTL-OPT MAIN(main);

// Simple test for ITER and LEAVE

DCL-PROC testLeave;
    DCL-S i INT(10);
    
    DSPLY 'Testing LEAVE - stop at 5:';
    FOR i = 1 TO 10;
        DSPLY i;
        IF i = 5;
            LEAVE;
        ENDIF;
    ENDFOR;
    DSPLY 'After loop';
    RETURN;
END-PROC;

DCL-PROC testIter;
    DCL-S i INT(10);
    
    DSPLY 'Testing ITER - skip 3 and 7:';
    FOR i = 1 TO 10;
        IF i = 3;
            ITER;
        ENDIF;
        IF i = 7;
            ITER;
        ENDIF;
        DSPLY i;
    ENDFOR;
    DSPLY 'After loop';
    RETURN;
END-PROC;

DCL-PROC main;
    CALLP testLeave();
    DSPLY '';
    CALLP testIter();
END-PROC;
