**free
// Example demonstrating various loop types
CTL-OPT DFTACTGRP(*NO) MAIN(loopExamples);

DCL-S i INT(10);
DCL-S sum INT(10);
DCL-S done IND;

DCL-PROC loopExamples;
    // FOR loop
    sum = 0;
    FOR i = 1 TO 100;
        sum = sum + i;
    ENDFOR;
    
    // DOW loop
    i = 0;
    DOW i < 10;
        i = i + 1;
    ENDDO;
    
    // DOU loop
    i = 0;
    DOU i >= 5;
        i = i + 1;
    ENDDO;
    
    RETURN;
END-PROC;
