**free
// Test program to verify DSPLY keyword functionality
// This program tests DSPLY with various data types and contexts
ctl-opt main(TestDsplyKeyword);

dcl-proc TestDsplyKeyword;
  dcl-s counter int(10) inz(0);
  dcl-s total int(10) inz(0);
  dcl-s average int(10);
  
  dsply '========================================';
  dsply 'RPGLE DSPLY Keyword Test Suite';
  dsply '========================================';
  dsply '';
  
  // Test 1: String literals
  dsply 'Test 1: String Literals';
  dsply 'DSPLY works with string constants!';
  dsply '';
  
  // Test 2: Integer variables
  dsply 'Test 2: Integer Variables';
  counter = 42;
  dsply counter;
  dsply '';
  
  // Test 3: DSPLY in loops
  dsply 'Test 3: DSPLY in FOR Loop';
  for counter = 1 to 5;
    dsply counter;
  endfor;
  dsply '';
  
  // Test 4: DSPLY in conditionals
  dsply 'Test 4: DSPLY in IF/ELSE';
  counter = 100;
  if counter > 50;
    dsply 'Counter is greater than 50';
    dsply counter;
  else;
    dsply 'Counter is 50 or less';
  endif;
  dsply '';
  
  // Test 5: DSPLY with expressions
  dsply 'Test 5: DSPLY with Calculated Values';
  total = 15 + 25;
  dsply total;
  
  average = total / 2;
  dsply average;
  dsply '';
  
  // Test 6: DSPLY in SELECT
  dsply 'Test 6: DSPLY in SELECT';
  select;
    when counter == 100;
      dsply 'Counter equals 100';
    when counter > 100;
      dsply 'Counter is greater than 100';
    other;
      dsply 'Counter is less than 100';
  endsl;
  dsply '';
  
  dsply 'All tests completed successfully!';
  dsply '========================================';
  
  return;
end-proc;
