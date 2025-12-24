**FREE

CTL-OPT MAIN(main);

// Test ITER and LEAVE control flow

DCL-PROC testLeave;
    DCL-S i INT(10);
    
    DSPLY 'Test LEAVE - stop when i > 5:';
    FOR i = 1 TO 10;
        IF i > 5;
            LEAVE;
        ENDIF;
        DSPLY i;
    ENDFOR;
    DSPLY 'Loop exited';
    DSPLY '';
    RETURN;
END-PROC;

DCL-PROC testIter;
    DCL-S i INT(10);
    
    DSPLY 'Test ITER - skip when i > 3 AND i < 8:';
    FOR i = 1 TO 10;
        IF i > 3;
            IF i < 8;
                ITER;
            ENDIF;
        ENDIF;
        DSPLY i;
    ENDFOR;
    DSPLY 'Loop complete';
    DSPLY '';
    RETURN;
END-PROC;

DCL-PROC testDOW;
    DCL-S i INT(10);
    
    DSPLY 'Test LEAVE in DOW loop:';
    i = 0;
    DOW i < 100;
        i = i + 1;
        DSPLY i;
        IF i > 3;
            LEAVE;
        ENDIF;
    ENDDO;
    DSPLY 'Exited DOW loop';
    DSPLY '';
    RETURN;
END-PROC;

DCL-PROC testDOU;
    DCL-S i INT(10);
    DCL-S count INT(10);
    
    DSPLY 'Test ITER in DOU loop:';
    i = 0;
    count = 0;
    DOU i >= 10;
        i = i + 1;
        IF i < 4;
            ITER;
        ENDIF;
        IF i > 7;
            ITER;
        ENDIF;
        count = count + 1;
        DSPLY i;
    ENDDO;
    DSPLY 'Count:';
    DSPLY count;
    DSPLY '';
    RETURN;
END-PROC;

DCL-PROC main;
    DSPLY '========================================';
    DSPLY 'ITER and LEAVE Control Flow Test';
    DSPLY '========================================';
    DSPLY '';
    
    CALLP testLeave();
    CALLP testIter();
    CALLP testDOW();
    CALLP testDOU();
    
    DSPLY '========================================';
    DSPLY 'All Tests Complete!';
    DSPLY '========================================';
END-PROC;
