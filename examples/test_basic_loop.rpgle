**FREE

CTL-OPT MAIN(main);

DCL-PROC main;
    DCL-S i INT(10);
    
    FOR i = 1 TO 5;
        DSPLY i;
    ENDFOR;
    
    DSPLY 'Done';
END-PROC;
