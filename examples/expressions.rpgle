**free
// Example with calculations and expressions
CTL-OPT DFTACTGRP(*NO) MAIN(calculate);

DCL-S a INT(10);
DCL-S b INT(10);
DCL-S c INT(10);
DCL-S result INT(10);

DCL-PROC calculate;
    a = 10;
    b = 20;
    c = 30;
    
    // Arithmetic operations
    result = a + b * c;
    result = (a + b) * c;
    result = a - b;
    result = a / b;
    
    // Comparison
    IF a == b OR b < c AND c > a;
        result = 1;
    ENDIF;
    
    RETURN;
END-PROC;
