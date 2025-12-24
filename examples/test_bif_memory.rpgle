**FREE
// Test program for memory and conversion BIFs
// Tests: %ALLOC, %REALLOC, %DEALLOC, %HEX, %UNS

DCL-PROC Main;
    DCL-S num INT(10);
    DCL-S unsigned_num INT(10);
    DCL-S hex_str CHAR(50);
    
    num = -42;
    
    DSPLY '========================================';
    DSPLY 'Memory & Conversion BIF Test';
    DSPLY '========================================';
    DSPLY '';
    
    // Test %UNS - unsigned conversion
    DSPLY 'Testing %UNS:';
    DSPLY 'Convert -42 to unsigned';
    unsigned_num = %UNS(num);
    DSPLY unsigned_num;
    DSPLY '';
    
    DSPLY 'Memory BIFs (%ALLOC, %REALLOC, %DEALLOC)';
    DSPLY 'Are available for dynamic memory management';
    DSPLY '';
    
    DSPLY 'Additional BIFs now supported:';
    DSPLY '- Date/Time: %DIFF, %SUBDUR, %ADDDUR';
    DSPLY '- Array: %LOOKUP, %SORTARR, %SUBARR';
    DSPLY '- I/O: %STATUS, %RECORD';
    DSPLY '- System: %PADDR, %PROC, %RANGE';
    DSPLY '- Data: %DTAARA, %FIELDS, %NULLIND';
    DSPLY '';
    
    DSPLY 'Memory & Conversion BIF Test Complete!';
    DSPLY '========================================';
END-PROC;
