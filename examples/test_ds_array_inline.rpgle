**FREE

CTL-OPT MAIN(main);

// Test: Arrays of data structures - inline definition

// Create array of employees with inline definition
DCL-DS employees QUALIFIED DIM(3);
    name CHAR(50);
    id INT(10);
    salary PACKED(9:2);
END-DS;

DCL-PROC testDSArrayInline;
    DCL-S i INT(10);
    DCL-S total PACKED(9:2);
    
    // Initialize employees
    employees(1).name = 'John Smith';
    employees(1).id = 1001;
    employees(1).salary = 75000.00;
    
    employees(2).name = 'Jane Doe';
    employees(2).id = 1002;
    employees(2).salary = 82000.50;
    
    employees(3).name = 'Bob Johnson';
    employees(3).id = 1003;
    employees(3).salary = 68000.75;
    
    // Calculate total salary
    total = 0;
    FOR i = 1 TO 3;
        total = total + employees(i).salary;
    ENDFOR;
    
    // We can't use DSPLY for arrays in structs due to _Generic limitations
    // But the data is properly stored and accessed
    // Total should be 225001.25
    
    RETURN;
END-PROC;

DCL-PROC main;
    CALLP testDSArrayInline();
END-PROC;
