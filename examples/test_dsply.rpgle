**free
ctl-opt main(TestDisplay);

dcl-proc TestDisplay;
  dcl-s message char(50) inz('Hello from RPGLE!');
  dcl-s num int(10) inz(42);
  
  dsply 'Starting test...';
  dsply message;
  dsply 'The answer is:';
  dsply num;
  dsply 'Test complete!';
  
  return;
end-proc;
