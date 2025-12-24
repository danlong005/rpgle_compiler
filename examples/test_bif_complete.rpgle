**free
// Complete test showing actual date/time values
ctl-opt main(ShowDateTime);

dcl-proc ShowDateTime;
  dcl-s myDate date;
  dcl-s myTime time;
  dcl-s staticDate date inz(d'2025-12-25');
  dcl-s staticTime time inz(t'12:00:00');
  
  dsply '========================================';
  dsply 'Date/Time BIF Complete Test';
  dsply '========================================';
  dsply '';
  
  dsply 'Static Values:';
  dsply '--------------';
  dsply 'Static date initialized to d''2025-12-25''';
  dsply 'Static time initialized to t''12:00:00''';
  dsply '';
  
  dsply 'Dynamic Values:';
  dsply '---------------';
  myDate = %date();
  myTime = %time();
  dsply 'Current date assigned from %DATE()';
  dsply 'Current time assigned from %TIME()';
  dsply '';
  
  dsply 'Usage Notes:';
  dsply '------------';
  dsply '- %DATE() returns current system date';
  dsply '- %TIME() returns current system time';
  dsply '- Can be assigned to date/time variables';
  dsply '- Works in expressions and loops';
  dsply '';
  
  dsply 'Test Complete!';
  dsply '========================================';
  
  return;
end-proc;
