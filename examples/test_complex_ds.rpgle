**FREE

// Test: Data structures with various types

// Qualified customer data structure
DCL-DS customer QUALIFIED;
    firstName CHAR(30);
    lastName CHAR(30);
    customerId INT(10);
    balance PACKED(9:2);
    lastOrder DATE;
    isActive IND;
END-DS;

// Non-qualified address fields
DCL-DS address;
    street CHAR(50);
    city CHAR(30);
    state CHAR(2);
    zipCode CHAR(10);
END-DS;

DCL-PROC testComplexDS;
    // Initialize customer
    customer.firstName = 'Jane';
    customer.lastName = 'Doe';
    customer.customerId = 54321;
    customer.balance = 1250.75;
    customer.lastOrder = d'2024-01-15';
    customer.isActive = *ON;
    
    // Initialize address
    street = '123 Main Street';
    city = 'Springfield';
    state = 'IL';
    zipCode = '62701';
    
    // Display customer info
    DSPLY 'Customer Information:';
    DSPLY customer.firstName;
    DSPLY customer.lastName;
    DSPLY customer.customerId;
    DSPLY customer.balance;
    
    // Display address
    DSPLY 'Address:';
    DSPLY street;
    DSPLY city;
    DSPLY state;
    DSPLY zipCode;
    
    // Test boolean
    IF customer.isActive;
        DSPLY 'Customer is active';
    ELSE;
        DSPLY 'Customer is inactive';
    ENDIF;
    
    // Modify values
    customer.balance = customer.balance + 500;
    DSPLY 'New balance:';
    DSPLY customer.balance;
END-PROC;

// Call the procedure
DCL-PROC main;
    CALLP testComplexDS();
END-PROC;
