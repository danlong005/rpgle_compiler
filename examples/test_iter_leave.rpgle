**FREE

CTL-OPT MAIN(main);

// Test ITER and LEAVE control flow

DCL-PROC testIter;
    DCL-S i INT(10);
    DCL-S sum INT(10);
    DCL-S isEven INT(10);
    
    DSPLY 'Testing ITER (skip even numbers):';
    sum = 0;
    FOR i = 1 TO 10;
        // Skip even numbers
        isEven = i / 2 * 2;
        IF isEven = i;
            ITER;
        ENDIF;
        sum = sum + i;
        DSPLY i;
    ENDFOR;
    DSPLY 'Sum of odd numbers 1-10:';
    DSPLY sum;
    DSPLY '';
    
    RETURN;
END-PROC;

DCL-PROC testLeave;
    DCL-S i INT(10);
    
    DSPLY 'Testing LEAVE (exit at 5):';
    FOR i = 1 TO 10;
        IF i = 5;
            LEAVE;
        ENDIF;
        DSPLY i;
    ENDFOR;
    DSPLY 'Loop exited early';
    DSPLY '';
    
    RETURN;
END-PROC;

DCL-PROC testIterDOW;
    DCL-S i INT(10);
    DCL-S count INT(10);
    DCL-S isMult3 INT(10);
    
    DSPLY 'Testing ITER in DOW loop:';
    i = 0;
    count = 0;
    DOW i < 10;
        i = i + 1;
        // Skip multiples of 3
        isMult3 = i / 3 * 3;
        IF isMult3 = i;
            ITER;
        ENDIF;
        count = count + 1;
        DSPLY i;
    ENDDO;
    DSPLY 'Count of non-multiples of 3:';
    DSPLY count;
    DSPLY '';
    
    RETURN;
END-PROC;

DCL-PROC testLeaveDOU;
    DCL-S i INT(10);
    
    DSPLY 'Testing LEAVE in DOU loop:';
    i = 0;
    DOU i >= 100;
        i = i + 1;
        DSPLY i;
        IF i = 3;
            LEAVE;
        ENDIF;
    ENDDO;
    DSPLY 'Exited DOU loop early';
    DSPLY '';
    
    RETURN;
END-PROC;

DCL-PROC main;
    DSPLY '========================================';
    DSPLY 'ITER and LEAVE Control Flow Test';
    DSPLY '========================================';
    DSPLY '';
    
    CALLP testIter();
    CALLP testLeave();
    CALLP testIterDOW();
    CALLP testLeaveDOU();
    
    DSPLY '========================================';
    DSPLY 'Test Complete!';
    DSPLY '========================================';
END-PROC;
