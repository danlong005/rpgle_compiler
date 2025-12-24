**FREE

CTL-OPT MAIN(main);

// Test field I/O with various data types

DCL-F TESTFILE;

DCL-DS dataRec QUALIFIED;
    textField CHAR(20);
    intField INT(10);
    decimalField PACKED(9:2);
    anotherText CHAR(15);
END-DS;

DCL-PROC testTypes;
    // Write records with different types
    OPEN TESTFILE;
    
    dataRec.textField = 'Hello World';
    dataRec.intField = 42;
    dataRec.decimalField = 123.45;
    dataRec.anotherText = 'Test Data';
    WRITE TESTFILE dataRec;
    
    dataRec.textField = 'Foo Bar';
    dataRec.intField = -999;
    dataRec.decimalField = 0.01;
    dataRec.anotherText = 'More';
    WRITE TESTFILE dataRec;
    
    CLOSE TESTFILE;
    OPEN TESTFILE;
    
    // Read and display
    READ TESTFILE dataRec;
    DOW NOT %EOF(TESTFILE);
        DSPLY dataRec.textField;
        DSPLY dataRec.intField;
        DSPLY dataRec.decimalField;
        DSPLY dataRec.anotherText;
        READ TESTFILE dataRec;
    ENDDO;
    
    CLOSE TESTFILE;
    RETURN;
END-PROC;

DCL-PROC main;
    CALLP testTypes();
END-PROC;
