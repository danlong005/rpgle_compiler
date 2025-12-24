**free
// Test data structures
CTL-OPT DFTACTGRP(*NO) MAIN(testDataStructures);

DCL-DS employee QUALIFIED;
    name CHAR(50);
    id INT(10);
    salary INT(10);
END-DS;

DCL-DS point;
    x INT(10);
    y INT(10);
END-DS;

DCL-PROC testDataStructures;
    // Test qualified data structure
    employee.name = 'John Smith';
    employee.id = 12345;
    employee.salary = 75000;
    
    DSPLY 'Employee Name:';
    DSPLY employee.name;
    DSPLY 'Employee ID:';
    DSPLY employee.id;
    DSPLY 'Employee Salary:';
    DSPLY employee.salary;
    
    // Test non-qualified data structure
    x = 10;
    y = 20;
    
    DSPLY 'Point X:';
    DSPLY x;
    DSPLY 'Point Y:';
    DSPLY y;
    
    RETURN;
END-PROC;
