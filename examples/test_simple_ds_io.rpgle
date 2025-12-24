**FREE

CTL-OPT MAIN(main);

// Simple demonstration of DS file I/O

DCL-F PERSONFILE;

DCL-DS person QUALIFIED;
    name CHAR(20);
    age INT(10);
END-DS;

DCL-PROC testSimpleDSIO;
    DCL-S total INT(10);
    
    // Write records
    OPEN PERSONFILE;
    
    person.name = 'Alice';
    person.age = 25;
    WRITE PERSONFILE person;
    
    person.name = 'Bob';
    person.age = 30;
    WRITE PERSONFILE person;
    
    person.name = 'Charlie';
    person.age = 35;
    WRITE PERSONFILE person;
    
    CLOSE PERSONFILE;
    
    // Read records back
    OPEN PERSONFILE;
    total = 0;
    
    READ PERSONFILE person;
    DOW NOT %EOF(PERSONFILE);
        total = total + person.age;
        READ PERSONFILE person;
    ENDDO;
    
    CLOSE PERSONFILE;
    
    // Total should be 90 (25+30+35)
    RETURN;
END-PROC;

DCL-PROC main;
    CALLP testSimpleDSIO();
END-PROC;
