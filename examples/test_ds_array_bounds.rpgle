**FREE

// Test: Verify DS arrays are properly 1-based in RPGLE

// Define base structure
DCL-DS item QUALIFIED;
    itemid INT(10);
    itemvalue INT(10);
END-DS;

// Create array of items (indices 1-5 in RPGLE, 0-4 in C)
DCL-DS items LIKEDS(item) DIM(5);

DCL-PROC testBounds;
    DCL-S sum INT(10);
    DCL-S i INT(10);
    
    // RPGLE arrays are 1-based: valid indices are 1 to 5
    items(1).itemid = 101;  // First element (becomes C index 0)
    items(1).itemvalue = 10;
    
    items(2).itemid = 102;  // Second element (becomes C index 1)
    items(2).itemvalue = 20;
    
    items(3).itemid = 103;  // Third element (becomes C index 2)
    items(3).itemvalue = 30;
    
    items(4).itemid = 104;  // Fourth element (becomes C index 3)
    items(4).itemvalue = 40;
    
    items(5).itemid = 105;  // Fifth element (becomes C index 4)
    items(5).itemvalue = 50;
    
    // Calculate sum using 1-based loop
    sum = 0;
    FOR i = 1 TO 5;  // Loop from 1 to 5 (RPGLE 1-based)
        sum = sum + items(i).itemvalue;
    ENDFOR;
    
    // Sum should be 150 (10+20+30+40+50)
    RETURN;
END-PROC;

DCL-PROC main;
    CALLP testBounds();
END-PROC;

