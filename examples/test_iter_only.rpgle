**FREE

CTL-OPT MAIN(main);

DCL-PROC main;
    DCL-S i INT(10);
    
    FOR i = 1 TO 5;
        DSPLY i;
        ITER;
        DSPLY 'Should not see this';
    ENDFOR;
    
    DSPLY 'Done';
END-PROC;
