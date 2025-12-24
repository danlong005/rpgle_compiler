**FREE
// Test program for date/time extraction BIFs
// Tests: %YEARS, %MONTHS, %DAYS, %HOURS, %MINUTES, %SECONDS

DCL-PROC Main;
    DCL-S testDate CHAR(11);
    DCL-S testTime CHAR(9);
    DCL-S year INT(10);
    DCL-S month INT(10);
    DCL-S day INT(10);
    DCL-S hour INT(10);
    DCL-S minute INT(10);
    DCL-S second INT(10);
    
    testDate = '2025-12-23';
    testTime = '14:30:45';
    
    DSPLY '========================================';
    DSPLY 'Date/Time Extraction BIF Test';
    DSPLY '========================================';
    DSPLY '';
    
    DSPLY 'Test Date: 2025-12-23';
    
    // Extract year
    DSPLY '%YEARS:';
    year = %YEARS(testDate);
    DSPLY year;
    
    // Extract month
    DSPLY '%MONTHS:';
    month = %MONTHS(testDate);
    DSPLY month;
    
    // Extract day
    DSPLY '%DAYS:';
    day = %DAYS(testDate);
    DSPLY day;
    DSPLY '';
    
    DSPLY 'Test Time: 14:30:45';
    
    // Extract hour
    DSPLY '%HOURS:';
    hour = %HOURS(testTime);
    DSPLY hour;
    
    // Extract minutes
    DSPLY '%MINUTES:';
    minute = %MINUTES(testTime);
    DSPLY minute;
    
    // Extract seconds
    DSPLY '%SECONDS:';
    second = %SECONDS(testTime);
    DSPLY second;
    DSPLY '';
    
    DSPLY 'Date/Time Extraction BIF Test Complete!';
    DSPLY '========================================';
END-PROC;
