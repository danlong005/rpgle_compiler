**FREE

CTL-OPT MAIN(main);

DCL-PROC testDOW;
    DCL-S x INT(10);
    
    DSPLY 'Test DOW with = condition:';
    x = 0;
    DOW x = 0;
        DSPLY 'x is 0';
        x = 1;
    ENDDO;
    DSPLY 'Exited DOW';
    DSPLY '';
    RETURN;
END-PROC;

DCL-PROC testDOU;
    DCL-S x INT(10);
    
    DSPLY 'Test DOU with = condition:';
    x = 0;
    DOU x = 1;
        DSPLY x;
        x = x + 1;
    ENDDO;
    DSPLY 'Exited DOU';
    DSPLY '';
    RETURN;
END-PROC;

DCL-PROC testNestedConditions;
    DCL-S i INT(10);
    DCL-S target INT(10);
    
    DSPLY 'Test nested = conditions:';
    target = 5;
    i = 0;
    DOW i < 10;
        i = i + 1;
        IF i = target;
            DSPLY 'Found target:';
            DSPLY i;
            LEAVE;
        ENDIF;
    ENDDO;
    DSPLY '';
    RETURN;
END-PROC;

DCL-PROC main;
    DSPLY '========================================';
    DSPLY 'Equality in All Loop Types Test';
    DSPLY '========================================';
    DSPLY '';
    
    CALLP testDOW();
    CALLP testDOU();
    CALLP testNestedConditions();
    
    DSPLY '========================================';
    DSPLY 'Test Complete!';
    DSPLY '========================================';
END-PROC;
