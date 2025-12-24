**free
// Simple file I/O demonstration
CTL-OPT DFTACTGRP(*NO) MAIN(simpleFileIO);

DCL-F datafile;
DCL-S line1 CHAR(50);
DCL-S line2 CHAR(50);
DCL-S line3 CHAR(50);

DCL-PROC simpleFileIO;
    // Create and write to file
    OPEN datafile;
    
    line1 = 'First line of data';
    WRITE datafile line1;
    
    line2 = 'Second line of data';
    WRITE datafile line2;
    
    line3 = 'Third line of data';
    WRITE datafile line3;
    
    CLOSE datafile;
    
    DSPLY 'File written successfully';
    
    // Reopen and read file
    OPEN datafile;
    
    READ datafile line1;
    DSPLY 'Line 1:';
    DSPLY line1;
    
    READ datafile line2;
    DSPLY 'Line 2:';
    DSPLY line2;
    
    READ datafile line3;
    DSPLY 'Line 3:';
    DSPLY line3;
    
    CLOSE datafile;
    
    DSPLY 'File operations complete';
    
    RETURN;
END-PROC;
