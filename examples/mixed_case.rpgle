**free
// Demonstrating case insensitivity in RPGLE
ctl-OPT main(MyMainProc);

// Mixed case variable declarations
DCL-s counter INT(10);
dcl-S total int(10);
Dcl-s result INT(10);

// Mixed case procedure
dcl-PROC MyMainProc;
    counter = 0;
    total = 0;
    
    // Mixed case FOR loop
    FOR counter = 1 to 10;
        total = total + counter;
    endfor;
    
    // Mixed case IF
    iF total > 50;
        result = 1;
    ELSE;
        result = 0;
    endif;
    
    // Mixed case SELECT
    select;
        when result == 1;
            counter = 100;
        OTHER;
            counter = 0;
    ENDSL;
    
    RETURN;
end-PROC;
