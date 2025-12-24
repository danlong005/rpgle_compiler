**FREE

CTL-OPT MAIN(main);

// Test: Arrays of data structures with LIKEDS

// Define base employee data structure
DCL-DS employee QUALIFIED;
    name CHAR(50);
    id INT(10);
    salary PACKED(9:2);
END-DS;

// Create array of employees using LIKEDS
DCL-DS employees LIKEDS(employee) DIM(5);

DCL-PROC testDSArray;
    DCL-S i INT(10);
    
    // Initialize first employee
    employees(1).name = 'John Smith';
    employees(1).id = 1001;
    employees(1).salary = 75000.00;
    
    // Initialize second employee
    employees(2).name = 'Jane Doe';
    employees(2).id = 1002;
    employees(2).salary = 82000.50;
    
    // Initialize third employee
    employees(3).name = 'Bob Johnson';
    employees(3).id = 1003;
    employees(3).salary = 68000.75;
    
    // Display all employees
    FOR i = 1 TO 3;
        DSPLY 'Employee:';
        DSPLY employees(i).name;
        DSPLY 'ID:';
        DSPLY employees(i).id;
        DSPLY 'Salary:';
        DSPLY employees(i).salary;
    ENDFOR;
END-PROC;

DCL-PROC main;
    CALLP testDSArray();
END-PROC;
