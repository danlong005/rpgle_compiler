**free
ctl-opt main(TestDateInit);

dcl-proc TestDateInit;
  dcl-s mydate date inz('2025-12-23');
  dsply 'Date with string initialization works!';
  return;
end-proc;
