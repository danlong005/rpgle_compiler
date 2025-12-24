**FREE

CTL-OPT MAIN(main);

// Test file I/O round-trip with data structures

DCL-F EMPFILE;

// Employee record structure
DCL-DS employee QUALIFIED;
    name CHAR(30);
    id INT(10);
    dept CHAR(10);
    salary PACKED(9:2);
END-DS;

DCL-PROC testRoundTrip;
    // Open file for writing
    OPEN EMPFILE;
    
    // Write test record
    employee.name = 'John Smith';
    employee.id = 1001;
    employee.dept = 'Sales';
    employee.salary = 75000.00;
    WRITE EMPFILE employee;
    
    // Close and reopen for reading
    CLOSE EMPFILE;
    OPEN EMPFILE;
    
    // Read record back
    READ EMPFILE employee;
    IF NOT %EOF(EMPFILE);
        DSPLY employee.name;
        DSPLY employee.id;
        DSPLY employee.dept;
        DSPLY employee.salary;
    ENDIF;
    
    CLOSE EMPFILE;
    RETURN;
END-PROC;

DCL-PROC main;
    CALLP testRoundTrip();
END-PROC;
