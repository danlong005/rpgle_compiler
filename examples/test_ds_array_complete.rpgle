**FREE

CTL-OPT MAIN(main);

// Test: LIKEDS and DIM working together

// Define base data structure
DCL-DS person QUALIFIED;
    firstName CHAR(20);
    lastName CHAR(20);
    age INT(10);
END-DS;

// Create array using LIKEDS
DCL-DS people LIKEDS(person) DIM(3);

// Also test inline array
DCL-DS coordinates QUALIFIED DIM(5);
    x INT(10);
    y INT(10);
END-DS;

DCL-PROC testArrays;
    DCL-S i INT(10);
    
    // Initialize people array (using LIKEDS)
    people(1).firstName = 'John';
    people(1).lastName = 'Smith';
    people(1).age = 30;
    
    people(2).firstName = 'Jane';
    people(2).lastName = 'Doe';
    people(2).age = 28;
    
    people(3).firstName = 'Bob';
    people(3).lastName = 'Johnson';
    people(3).age = 35;
    
    // Initialize coordinates array (inline definition)
    coordinates(1).x = 10;
    coordinates(1).y = 20;
    
    coordinates(2).x = 30;
    coordinates(2).y = 40;
    
    coordinates(3).x = 50;
    coordinates(3).y = 60;
    
    // Values are now stored correctly in the arrays
    RETURN;
END-PROC;

DCL-PROC main;
    CALLP testArrays();
END-PROC;

