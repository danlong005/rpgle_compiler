**free
// Comprehensive RPGLE Free Format Example
CTL-OPT DFTACTGRP(*NO) MAIN(calculateSum);

DCL-S counter INT(10);
DCL-S total INT(10);
DCL-S maxValue INT(10);
DCL-S minValue INT(10);
DCL-S a INT(10);
DCL-S b INT(10);
DCL-S result INT(10);

DCL-PROC calculateSum;
    total = 0;
    FOR counter = 1 TO 10;
        total = total + counter;
    ENDFOR;
    RETURN;
END-PROC;

DCL-PROC findMinMax;
    a = 42;
    b = 27;
    
    IF a > b;
        maxValue = a;
        minValue = b;
    ELSE;
        maxValue = b;
        minValue = a;
    ENDIF;
    RETURN;
END-PROC;