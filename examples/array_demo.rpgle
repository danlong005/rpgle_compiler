**FREE

// Comprehensive Array Test - demonstrates all array capabilities

DCL-PROC array_demo;
    // Integer arrays
    DCL-S fibonacci INT(10) DIM(10);
    DCL-S primes INT(10) DIM(5);
    
    // Counters and temp variables
    DCL-S i INT(10);
    DCL-S j INT(10);
    DCL-S sum INT(10);
    DCL-S product INT(10);
    DCL-S max_val INT(10);
    
    // Initialize fibonacci sequence
    fibonacci(1) = 1;
    fibonacci(2) = 1;
    FOR i = 3 TO %ELEM(fibonacci);
        fibonacci(i) = fibonacci(i-1) + fibonacci(i-2);
    ENDFOR;
    
    // Display fibonacci sequence
    DSPLY '=== Fibonacci Sequence ===';
    FOR i = 1 TO %ELEM(fibonacci);
        DSPLY fibonacci(i);
    ENDFOR;
    
    // Initialize primes array
    primes(1) = 2;
    primes(2) = 3;
    primes(3) = 5;
    primes(4) = 7;
    primes(5) = 11;
    
    // Calculate sum of primes
    sum = 0;
    FOR i = 1 TO %ELEM(primes);
        sum = sum + primes(i);
    ENDFOR;
    
    DSPLY '=== Sum of first 5 primes ===';
    DSPLY sum;  // Should be 28
    
    // Calculate product of first 3 primes
    product = 1;
    FOR i = 1 TO 3;
        product = product * primes(i);
    ENDFOR;
    
    DSPLY '=== Product of first 3 primes ===';
    DSPLY product;  // Should be 30
    
    // Find maximum in fibonacci array
    max_val = fibonacci(1);
    FOR i = 2 TO %ELEM(fibonacci);
        IF fibonacci(i) > max_val;
            max_val = fibonacci(i);
        ENDIF;
    ENDFOR;
    
    DSPLY '=== Max fibonacci value ===';
    DSPLY max_val;  // Should be 55
    
    // Copy and modify array
    FOR i = 1 TO 5;
        fibonacci(i) = fibonacci(i) * 2;
    ENDFOR;
    
    DSPLY '=== First 5 fibonacci doubled ===';
    FOR i = 1 TO 5;
        DSPLY fibonacci(i);
    ENDFOR;
    
    // Demonstrate %ELEM with different arrays
    DSPLY '=== Array Sizes ===';
    DSPLY %ELEM(fibonacci);  // 10
    DSPLY %ELEM(primes);     // 5
    
END-PROC;
