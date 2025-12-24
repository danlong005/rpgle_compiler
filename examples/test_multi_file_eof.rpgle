**FREE

CTL-OPT MAIN(main);

// Test multiple files with separate EOF tracking

DCL-F FILE1;
DCL-F FILE2;

DCL-DS fileRec QUALIFIED;
    data CHAR(50);
END-DS;

DCL-PROC testMultiFileEOF;
    DCL-S count1 INT(10);
    DCL-S count2 INT(10);
    
    // Write to FILE1
    OPEN FILE1;
    fileRec.data = 'File 1 Record 1';
    WRITE FILE1 fileRec;
    fileRec.data = 'File 1 Record 2';
    WRITE FILE1 fileRec;
    CLOSE FILE1;
    
    // Write to FILE2
    OPEN FILE2;
    fileRec.data = 'File 2 Record 1';
    WRITE FILE2 fileRec;
    fileRec.data = 'File 2 Record 2';
    WRITE FILE2 fileRec;
    fileRec.data = 'File 2 Record 3';
    WRITE FILE2 fileRec;
    CLOSE FILE2;
    
    // Read FILE1 (2 records)
    OPEN FILE1;
    count1 = 0;
    READ FILE1 fileRec;
    DOW NOT %EOF(FILE1);
        count1 = count1 + 1;
        READ FILE1 fileRec;
    ENDDO;
    
    // Read FILE2 (3 records) - FILE1 EOF should be independent
    OPEN FILE2;
    count2 = 0;
    READ FILE2 fileRec;
    DOW NOT %EOF(FILE2);
        count2 = count2 + 1;
        READ FILE2 fileRec;
    ENDDO;
    
    // Verify both counts are correct
    DSPLY 'FILE1 records:';
    DSPLY count1;
    DSPLY 'FILE2 records:';
    DSPLY count2;
    
    CLOSE FILE1;
    CLOSE FILE2;
    RETURN;
END-PROC;

DCL-PROC main;
    CALLP testMultiFileEOF();
END-PROC;
