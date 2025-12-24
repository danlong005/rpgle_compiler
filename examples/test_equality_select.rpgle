**FREE

CTL-OPT MAIN(main);

DCL-S value INT(10);
DCL-S i INT(10);

DCL-PROC testSelect;
    DSPLY 'Test = in SELECT/WHEN:';
    
    FOR i = 1 TO 5;
        value = i;
        SELECT;
            WHEN value = 1;
                DSPLY 'One';
            WHEN value = 2;
                DSPLY 'Two';
            WHEN value = 3;
                DSPLY 'Three';
            WHEN value > 3;
                DSPLY 'Greater than three';
            OTHER;
                DSPLY 'Unknown';
        ENDSL;
    ENDFOR;
    
    DSPLY 'Done';
    RETURN;
END-PROC;

DCL-PROC main;
    CALLP testSelect();
END-PROC;
