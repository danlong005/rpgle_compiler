**free
// Test file I/O operations
CTL-OPT DFTACTGRP(*NO) MAIN(testFileIO);

DCL-F myfile;
DCL-S recdata CHAR(100);
DCL-S name CHAR(50);
DCL-S counter INT(10);

DCL-PROC testFileIO;
    // Open file
    OPEN myfile;
    
    // Write some records
    name = 'John Smith';
    WRITE myfile name;
    
    name = 'Jane Doe';
    WRITE myfile name;
    
    name = 'Bob Johnson';
    WRITE myfile name;
    
    // Close and reopen for reading
    CLOSE myfile;
    OPEN myfile;
    
    // Read and display records
    counter = 0;
    READ myfile recdata;
    DOW recdata <> '';
        counter = counter + 1;
        DSPLY 'Record';
        DSPLY recdata;
        READ myfile recdata;
    ENDDO;
    
    DSPLY 'Total records';
    DSPLY counter;
    
    // Clean up
    CLOSE myfile;
    
    RETURN;
END-PROC;
