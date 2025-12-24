**free
ctl-opt main(TestDsply);

dcl-proc TestDsply;
  dcl-s count int(10) inz(0);
  dcl-s total int(10) inz(100);
  
  dsply 'RPGLE DSPLY Test';
  dsply '==================';
  
  for count = 1 to 5;
    dsply count;
  endfor;
  
  dsply 'Total:';
  dsply total;
  dsply 'Done!';
  
  return;
end-proc;
