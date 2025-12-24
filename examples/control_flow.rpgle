**free
// Example demonstrating control structures
CTL-OPT DFTACTGRP(*NO) MAIN(findMax);

DCL-S x INT(10);
DCL-S y INT(10);
DCL-S max INT(10);

DCL-PROC findMax;
    x = 42;
    y = 37;
    
    // IF statement
    IF x > y;
        max = x;
    ELSE;
        max = y;
    ENDIF;
    
    RETURN;
END-PROC;
