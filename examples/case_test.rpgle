**FREE
ctl-opt MAIN(TestProc);

Dcl-S myVar INT(10);
dcl-s result int(10);

DCL-PROC TestProc;
    myVar = 10;
    
    If myVar > 5;
        result = myVar + 1;
    EndIf;
    
    for myVar = 1 to 10;
        result = result + myVar;
    endfor;
    
    Return;
END-PROC;
