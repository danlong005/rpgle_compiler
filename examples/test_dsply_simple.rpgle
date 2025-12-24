**free
ctl-opt main(SimpleTest);

dcl-proc SimpleTest;
  dcl-s num int(10) inz(42);
  
  dsply 'Hello, World!';
  dsply 'The answer is 42';
  dsply num;
  
  return;
end-proc;
