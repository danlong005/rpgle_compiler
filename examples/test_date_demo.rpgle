**free
// Comprehensive DATE data type demonstration
ctl-opt main(DateDemo);

dcl-proc DateDemo;
  dcl-s orderDate date inz(d'2025-01-15');
  dcl-s shipDate date inz(d'2025-01-20');
  dcl-s deliveryDate date;
  dcl-s startTime time inz(t'08:00:00');
  dcl-s endTime time inz(t'17:00:00');
  dcl-s recordTs timestamp inz(z'2025-12-23-10.30.45.123456');
  
  dsply '========================================';
  dsply 'RPGLE Date/Time Data Type Demo';
  dsply '========================================';
  dsply '';
  
  dsply 'Order Processing System';
  dsply '------------------------';
  dsply 'Order Date: 2025-01-15';
  dsply 'Ship Date: 2025-01-20';
  dsply '';
  
  dsply 'Business Hours';
  dsply '--------------';
  dsply 'Start: 08:00:00';
  dsply 'End: 17:00:00';
  dsply '';
  
  dsply 'Record Timestamp';
  dsply '----------------';
  dsply 'Created: 2025-12-23-10.30.45.123456';
  dsply '';
  
  dsply 'Date types supported:';
  dsply '- DATE: YYYY-MM-DD format (10 chars)';
  dsply '- TIME: HH:MM:SS format (8 chars)';
  dsply '- TIMESTAMP: Full precision (26 chars)';
  dsply '';
  
  dsply 'Demo completed successfully!';
  
  return;
end-proc;
