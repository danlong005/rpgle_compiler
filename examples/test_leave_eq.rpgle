**FREE

CTL-OPT MAIN(main);

DCL-PROC main;
    DCL-S i INT(10);
    
    FOR i = 1 TO 10;
        IF i = 5;
            LEAVE;
        ENDIF;
        DSPLY i;
    ENDFOR;
    
    DSPLY 'Done';
END-PROC;
