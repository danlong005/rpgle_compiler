**FREE

CTL-OPT MAIN(main);

DCL-PROC main;
    DCL-S x INT(10);
    DCL-S y INT(10);
    
    x = 5;
    y = 10;
    
    DSPLY 'x:';
    DSPLY x;
    DSPLY 'y:';
    DSPLY y;
    
    IF x = 5;
        DSPLY 'x equals 5';
    ENDIF;
    
    IF y = x;
        DSPLY 'y equals x';
    ELSE;
        DSPLY 'y does not equal x';
    ENDIF;
    
    y = x;
    
    IF y = x;
        DSPLY 'Now y equals x';
    ENDIF;
    
    DSPLY 'Done';
END-PROC;
