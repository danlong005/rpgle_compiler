**FREE

CTL-OPT MAIN(main);

// Test file I/O with data structures

DCL-F EMPFILE;

// Employee record structure
DCL-DS employee QUALIFIED;
    name CHAR(30);
    id INT(10);
    dept CHAR(10);
    salary PACKED(9:2);
END-DS;

DCL-PROC testDSFileIO;
    DCL-S count INT(10);
    
    // Open file for writing
    OPEN EMPFILE;
    
    // Write employee records as data structures
    employee.name = 'John Smith';
    employee.id = 1001;
    employee.dept = 'Sales';
    employee.salary = 75000.00;
    WRITE EMPFILE employee;
    
    employee.name = 'Jane Doe';
    employee.id = 1002;
    employee.dept = 'Marketing';
    employee.salary = 82000.50;
    WRITE EMPFILE employee;
    
    employee.name = 'Bob Johnson';
    employee.id = 1003;
    employee.dept = 'IT';
    employee.salary = 95000.75;
    WRITE EMPFILE employee;
    
    // Close and reopen for reading
    CLOSE EMPFILE;
    OPEN EMPFILE;
    
    // Read employee records back into data structure
    count = 0;
    READ EMPFILE employee;
    DOW NOT %EOF(EMPFILE);
        count = count + 1;
        // Data structure fields are now populated from the file
        // employee.name, employee.id, employee.dept, employee.salary
        READ EMPFILE employee;
    ENDDO;
    
    CLOSE EMPFILE;
    RETURN;
END-PROC;

DCL-PROC main;
    CALLP testDSFileIO();
END-PROC;
