**FREE

CTL-OPT MAIN(main);

DCL-PROC main;
    DCL-S i INT(10);
    
    DSPLY 'Test ITER:';
    FOR i = 1 TO 10;
        IF i = 3;
            ITER;
        ENDIF;
        DSPLY i;
    ENDFOR;
    
    DSPLY 'Done';
END-PROC;
