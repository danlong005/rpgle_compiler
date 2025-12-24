**FREE

CTL-OPT MAIN(main);

DCL-PROC main;
    DCL-S i INT(10);
    
    FOR i = 1 TO 10;
        DSPLY i;
        LEAVE;
    ENDFOR;
    
    DSPLY 'Done';
END-PROC;
