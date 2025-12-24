**free
// Example demonstrating SELECT statement
CTL-OPT DFTACTGRP(*NO) MAIN(gradeCalculator);

DCL-S gradeValue INT(10);
DCL-S score INT(10);

DCL-PROC gradeCalculator;
    score = 85;
    
    // SELECT statement (like switch/case)
    SELECT;
        WHEN score >= 90;
            gradeValue = 4;
        WHEN score >= 80;
            gradeValue = 3;
        WHEN score >= 70;
            gradeValue = 2;
        WHEN score >= 60;
            gradeValue = 1;
        OTHER;
            gradeValue = 0;
    ENDSL;
    
    RETURN;
END-PROC;
