**FREE

CTL-OPT MAIN(main);

DCL-PROC testComplexEquality;
    DCL-S i INT(10);
    DCL-S j INT(10);
    DCL-S count INT(10);
    
    DSPLY 'Test multiple = in same condition:';
    count = 0;
    FOR i = 1 TO 10;
        FOR j = 1 TO 10;
            IF i = 5;
                IF j = 5;
                    count = count + 1;
                    DSPLY 'Found i=5, j=5';
                ENDIF;
            ENDIF;
        ENDFOR;
    ENDFOR;
    DSPLY 'Count:';
    DSPLY count;
    DSPLY '';
    RETURN;
END-PROC;

DCL-PROC testEqualityAndOther;
    DCL-S x INT(10);
    
    DSPLY 'Test = with other operators:';
    x = 0;
    DOW x < 5;
        x = x + 1;
        IF x = 3;
            DSPLY 'x equals 3';
        ENDIF;
        IF x > 2;
            IF x = 4;
                DSPLY 'x equals 4';
            ENDIF;
        ENDIF;
    ENDDO;
    DSPLY '';
    RETURN;
END-PROC;

DCL-PROC testEqualityInDOU;
    DCL-S running INT(10);
    DCL-S counter INT(10);
    
    DSPLY 'Test = in DOU condition with ITER:';
    running = 1;
    counter = 0;
    DOU running = 0;
        counter = counter + 1;
        DSPLY counter;
        IF counter = 2;
            ITER;
        ENDIF;
        IF counter = 3;
            running = 0;
        ENDIF;
    ENDDO;
    DSPLY 'Final counter:';
    DSPLY counter;
    DSPLY '';
    RETURN;
END-PROC;

DCL-PROC main;
    DSPLY '========================================';
    DSPLY 'Comprehensive Equality Test';
    DSPLY '========================================';
    DSPLY '';
    
    CALLP testComplexEquality();
    CALLP testEqualityAndOther();
    CALLP testEqualityInDOU();
    
    DSPLY '========================================';
    DSPLY 'All Tests Passed!';
    DSPLY '========================================';
END-PROC;
