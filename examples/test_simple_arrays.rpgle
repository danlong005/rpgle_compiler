**FREE

// Simple array test with manual output

DCL-PROC test_simple_arrays;
    DCL-S nums INT(10) DIM(3);
    DCL-S sum INT(10);
    
    nums(1) = 100;
    nums(2) = 200;
    nums(3) = 300;
    
    sum = nums(1) + nums(2) + nums(3);
    
    DSPLY nums(1);
    DSPLY nums(2);
    DSPLY nums(3);
    DSPLY sum;
    DSPLY %ELEM(nums);
    
END-PROC;
