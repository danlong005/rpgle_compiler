**free
ctl-opt main(DsplyDemo);

dcl-proc DsplyDemo;
  dcl-s name char(30) inz('John Doe');
  dcl-s age int(10) inz(25);
  dcl-s score int(10) inz(95);
  dcl-s result int(10);
  
  // Display string literals
  dsply '=================================';
  dsply 'RPGLE DSPLY Demonstration';
  dsply '=================================';
  dsply '';
  
  // Display variables
  dsply 'Name: (would show as char array address)';
  dsply 'Age:';
  dsply age;
  dsply 'Score:';
  dsply score;
  dsply '';
  
  // Display expressions
  dsply 'Calculations:';
  result = age + 10;
  dsply result;
  
  result = score * 2;
  dsply result;
  dsply '';
  
  // Display in conditional
  if score > 90;
    dsply 'Excellent score!';
  else;
    dsply 'Good effort!';
  endif;
  
  dsply '';
  dsply 'Demo complete!';
  
  return;
end-proc;
