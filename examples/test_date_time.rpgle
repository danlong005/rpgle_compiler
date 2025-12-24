**free
ctl-opt main(TestDateTime);

dcl-proc TestDateTime;
  dcl-s mydate date inz(d'2025-12-23');
  dcl-s mytime time inz(t'14:30:00');
  dcl-s mytimestamp timestamp inz(z'2025-12-23-14.30.00.000000');
  
  dsply 'Date/Time Data Types Test';
  dsply '==========================';
  dsply '';
  
  dsply 'Date: 2025-12-23';
  dsply 'Time: 14:30:00';
  dsply 'Timestamp: 2025-12-23-14.30.00.000000';
  dsply '';
  
  dsply 'All date/time types declared successfully!';
  
  return;
end-proc;
