**FREE

// Test RPGLE array support

DCL-PROC test_arrays;
    // Declare integer arrays
    DCL-S numbers INT(10) DIM(5);
    DCL-S scores INT(10) DIM(10);
    DCL-S count INT(10);
    DCL-S i INT(10);
    DCL-S total INT(10);
    
    // Declare string arrays
    DCL-S names CHAR(20) DIM(3);
    
    // Initialize integer array elements
    numbers(1) = 10;
    numbers(2) = 20;
    numbers(3) = 30;
    numbers(4) = 40;
    numbers(5) = 50;
    
    // Test reading array elements
    DSPLY numbers(1);
    DSPLY numbers(3);
    DSPLY numbers(5);
    
    // Initialize string array
    names(1) = 'Alice';
    names(2) = 'Bob';
    names(3) = 'Charlie';
    
    // Display string array elements
    DSPLY names(1);
    DSPLY names(2);
    DSPLY names(3);
    
    // Test %ELEM BIF
    count = %ELEM(numbers);
    DSPLY count;
    
    count = %ELEM(names);
    DSPLY count;
    
    // Calculate sum using loop
    total = 0;
    FOR i = 1 TO %ELEM(numbers);
        total = total + numbers(i);
    ENDFOR;
    
    DSPLY total;
    
    // Initialize scores array in a loop
    FOR i = 1 TO %ELEM(scores);
        scores(i) = i * 5;
    ENDFOR;
    
    // Display some scores
    DSPLY scores(1);
    DSPLY scores(5);
    DSPLY scores(10);
    
END-PROC;
