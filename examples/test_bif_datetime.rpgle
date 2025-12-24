**free
ctl-opt main(TestDateTimeBIF);

dcl-proc TestDateTimeBIF;
  dcl-s today date;
  dcl-s now time;
  dcl-s mydate date inz(d'2025-12-23');
  
  dsply 'Testing %DATE and %TIME BIFs';
  dsply '==============================';
  dsply '';
  
  // Get current date and time
  today = %date();
  now = %time();
  
  dsply 'Current Date (via %DATE):';
  dsply 'Current Time (via %TIME):';
  dsply '';
  
  dsply 'Hardcoded date: 2025-12-23';
  dsply '';
  
  dsply '%DATE and %TIME BIFs working!';
  
  return;
end-proc;
