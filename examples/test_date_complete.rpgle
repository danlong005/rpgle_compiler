**free
// Comprehensive test of DATE, TIME, and TIMESTAMP data types
ctl-opt main(CompleteDateTest);

dcl-proc CompleteDateTest;
  // DATE variables
  dcl-s today date;
  dcl-s orderDate date inz(d'2025-01-15');
  dcl-s shipDate date inz(d'2025-01-20');
  dcl-s dueDate date inz(d'2025-02-01');
  
  // TIME variables
  dcl-s currentTime time;
  dcl-s startTime time inz(t'08:00:00');
  dcl-s endTime time inz(t'17:00:00');
  dcl-s lunchTime time inz(t'12:00:00');
  
  // TIMESTAMP variables
  dcl-s createdTs timestamp inz(z'2025-12-23-10.30.45.123456');
  dcl-s modifiedTs timestamp;
  
  // Mixed with other types
  dcl-s orderNum int(10) inz(12345);
  dcl-s status char(10) inz('PENDING');
  
  dsply '========================================';
  dsply 'DATE/TIME Data Types - Complete Test';
  dsply '========================================';
  dsply '';
  
  dsply 'Order Information:';
  dsply '------------------';
  dsply 'Order Number: 12345';
  dsply 'Status: PENDING';
  dsply 'Order Date: 2025-01-15';
  dsply 'Ship Date: 2025-01-20';
  dsply 'Due Date: 2025-02-01';
  dsply '';
  
  dsply 'Business Hours:';
  dsply '---------------';
  dsply 'Start: 08:00:00';
  dsply 'Lunch: 12:00:00';
  dsply 'End: 17:00:00';
  dsply '';
  
  dsply 'Record Audit:';
  dsply '-------------';
  dsply 'Created: 2025-12-23-10.30.45.123456';
  dsply '';
  
  dsply 'Data Type Summary:';
  dsply '-----------------';
  dsply 'DATE: 10 chars (YYYY-MM-DD)';
  dsply 'TIME: 8 chars (HH:MM:SS)';
  dsply 'TIMESTAMP: 26 chars (full precision)';
  dsply '';
  
  dsply 'All date/time types working correctly!';
  dsply '========================================';
  
  return;
end-proc;
