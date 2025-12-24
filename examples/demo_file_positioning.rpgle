**FREE

// Comprehensive demonstration of all file positioning operations

CTL-OPT DFTACTGRP(*NO) MAIN(demonstrateFileOps);

DCL-F PRODUCTS;

DCL-PROC demonstrateFileOps;
    DCL-S key INT(10);
    DCL-S count INT(10);
    
    DSPLY '========================================';
    DSPLY 'File Positioning Operations Demo';
    DSPLY '========================================';
    DSPLY '';
    
    OPEN PRODUCTS;
    
    // Demo 1: SETLL - Position at or before key
    DSPLY 'Demo 1: SETLL (Set Lower Limit)';
    DSPLY '  Position file at or before key 200';
    key = 200;
    SETLL key PRODUCTS;
    IF %FOUND();
        DSPLY '  SUCCESS: File positioned';
    ELSE;
        DSPLY '  Key not found';
    ENDIF;
    DSPLY '';
    
    // Demo 2: SETGT - Position after key
    DSPLY 'Demo 2: SETGT (Set Greater Than)';
    DSPLY '  Position file after key 100';
    key = 100;
    SETGT key PRODUCTS;
    IF %FOUND();
        DSPLY '  SUCCESS: Positioned after key';
    ELSE;
        DSPLY '  Could not position';
    ENDIF;
    DSPLY '';
    
    // Demo 3: READE - Read matching records in loop
    DSPLY 'Demo 3: READE (Read Equal)';
    DSPLY '  Read all records with key 150';
    key = 150;
    count = 0;
    SETLL key PRODUCTS;
    READE PRODUCTS;
    DOW %EQUAL() AND NOT %EOF(PRODUCTS);
        count = count + 1;
        DSPLY '  Found matching record';
        READE PRODUCTS;
    ENDDO;
    DSPLY '  Total matching records:';
    DSPLY count;
    DSPLY '';
    
    // Demo 4: READP - Read previous
    DSPLY 'Demo 4: READP (Read Previous)';
    DSPLY '  Read previous 3 records';
    count = 0;
    DOW count < 3 AND NOT %EOF(PRODUCTS);
        READP PRODUCTS;
        IF NOT %EOF(PRODUCTS);
            count = count + 1;
            DSPLY '  Read previous record';
        ENDIF;
    ENDDO;
    DSPLY '';
    
    // Demo 5: READPE - Read previous equal
    DSPLY 'Demo 5: READPE (Read Previous Equal)';
    DSPLY '  Read previous with matching key';
    key = 100;
    SETGT key PRODUCTS;
    READPE PRODUCTS;
    IF %EQUAL();
        DSPLY '  Found matching previous record';
    ELSE;
        DSPLY '  No matching previous record';
    ENDIF;
    DSPLY '';
    
    // Demo 6: Combined operations
    DSPLY 'Demo 6: Forward and Backward';
    DSPLY '  Read forward 2, then backward 1';
    key = 100;
    SETLL key PRODUCTS;
    
    DSPLY '  Forward...';
    READE PRODUCTS;
    IF %EQUAL();
        DSPLY '    Record 1';
    ENDIF;
    READE PRODUCTS;
    IF %EQUAL();
        DSPLY '    Record 2';
    ENDIF;
    
    DSPLY '  Backward...';
    READPE PRODUCTS;
    IF %EQUAL();
        DSPLY '    Back to Record 1';
    ENDIF;
    DSPLY '';
    
    CLOSE PRODUCTS;
    
    DSPLY '========================================';
    DSPLY 'All Demonstrations Complete';
    DSPLY '========================================';
END-PROC;
