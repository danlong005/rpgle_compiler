**free
CTL-OPT MAIN(startApp);

DCL-S count INT(10);

DCL-PROC startApp;
    count = 0;
    FOR count = 1 TO 5;
        // Process each iteration
    ENDFOR;
    RETURN;
END-PROC;
