**free
ctl-opt main(DateTimeBIFDemo);

dcl-proc DateTimeBIFDemo;
  dcl-s currentDate date;
  dcl-s currentTime time;
  dcl-s testDate date inz(d'2025-12-23');
  dcl-s counter int(10);
  
  dsply '========================================';
  dsply '%DATE and %TIME Built-in Functions';
  dsply '========================================';
  dsply '';
  
  // Get current date and time
  currentDate = %date();
  currentTime = %time();
  
  dsply 'Current date retrieved using %DATE()';
  dsply 'Current time retrieved using %TIME()';
  dsply '';
  
  dsply 'Test Date: 2025-12-23';
  dsply '';
  
  // Use in a loop
  dsply 'Testing in loop:';
  for counter = 1 to 3;
    currentTime = %time();
    dsply 'Iteration:';
    dsply counter;
  endfor;
  dsply '';
  
  dsply 'BIF Demo Complete!';
  dsply '========================================';
  
  return;
end-proc;
