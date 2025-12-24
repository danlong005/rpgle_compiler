**free
ctl-opt main(TestDate);

dcl-proc TestDate;
  dcl-s today date;
  dcl-s birthdate date inz(d'1990-05-15');
  dcl-s hiredate date inz(d'2020-01-01');
  
  dsply 'Date Data Type Test';
  dsply '===================';
  dsply '';
  
  dsply 'Birth Date: 1990-05-15';
  dsply 'Hire Date: 2020-01-01';
  dsply '';
  
  dsply 'Date variables declared successfully!';
  
  return;
end-proc;
