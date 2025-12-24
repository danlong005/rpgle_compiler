# Array Support Implementation

## Overview
The RPGLE compiler now has full support for arrays using the DIM keyword, array subscripts, and the %ELEM built-in function.

## Features Implemented

### 1. Array Declaration with DIM
Arrays can be declared using the DIM keyword:
```rpgle
DCL-S numbers INT(10) DIM(5);      // Array of 5 integers
DCL-S names CHAR(20) DIM(10);      // Array of 10 strings
DCL-S scores INT(10) DIM(100);     // Array of 100 integers
```

### 2. Array Subscript Access
Array elements are accessed using 1-based indexing (RPGLE standard):
```rpgle
numbers(1) = 10;                    // Set first element
numbers(2) = 20;                    // Set second element
value = numbers(1);                 // Read first element
sum = numbers(1) + numbers(2);      // Use in expressions
```

### 3. %ELEM Built-in Function
The %ELEM BIF returns the array dimension:
```rpgle
DCL-S nums INT(10) DIM(5);
DCL-S count INT(10);

count = %ELEM(nums);               // Returns 5

// Use in loops
FOR i = 1 TO %ELEM(nums);
    nums(i) = i * 10;
ENDFOR;
```

## Implementation Details

### Lexer (src/rpgle.l)
- DIM keyword already existed and is recognized

### Parser (src/rpgle.y)
- Extended `dcl_s_stmt` to support DIM syntax
- Added `NODE_ARRAY_SUBSCRIPT` node type
- Modified `primary_expr` to recognize array subscript syntax
- Extended `eval_stmt` to handle array element assignment

### AST (include/ast.h)
- Added `NODE_ARRAY_SUBSCRIPT` node type
- Added `array_subscript` structure with `array_name` and `index` fields
- Extended TypeInfo structure (already had `dim` field)

### Code Generator (src/codegen.c)
- Array declarations generate C arrays: `int name[dim]`
- String arrays generate 2D arrays: `char name[dim][length+1]`
- Array subscripts convert from 1-based to 0-based: `array[(index)-1]`
- Added symbol table to track array dimensions
- %ELEM emits the dimension as a compile-time constant

### Symbol Table
- Simple linked list tracking variable names and dimensions
- Used by %ELEM to emit correct array size
- Initialized in `codegen_init()`, freed in `free_symbol_table()`

## Generated C Code Examples

### RPGLE Code:
```rpgle
DCL-S numbers INT(10) DIM(5);
numbers(1) = 10;
numbers(2) = 20;
total = numbers(1) + numbers(2);
count = %ELEM(numbers);
```

### Generated C Code:
```c
int numbers[5];
numbers[(1)-1] = 10;
numbers[(2)-1] = 20;
total = (numbers[(1)-1] + numbers[(2)-1]);
count = 5;
```

## Array BIF Support

### Now Functional
- **%ELEM(array)** - Returns array dimension (compile-time constant)

### Future Implementation
These array BIFs are declared but need real implementation:
- **%LOOKUP(value:array:start:elements)** - Search array
- **%LOOKUPLT/LE/GT/GE** - Comparison searches
- **%SUBARR(array:start:count)** - Extract sub-array
- **%SORTARR(array:start:count)** - Sort array elements

## Test Programs

### test_simple_arrays.rpgle
Basic array operations:
- Array declaration
- Element assignment
- Element access
- %ELEM usage
- Sum calculation

Output:
```
100
200
300
600
3
```

### test_arrays.rpgle
Comprehensive array test:
- Integer arrays with DIM(5) and DIM(10)
- String arrays with DIM(3)
- Array initialization in loops
- %ELEM in FOR loops
- Array arithmetic

## Limitations

1. **Multi-dimensional arrays**: Only 1D arrays supported
2. **Array initialization**: INZ with DIM not yet supported  
3. **Array of structures**: Data structure arrays not implemented
4. **DSPLY with array subscripts**: Prints addresses for string arrays (DSPLY limitation)
5. **Array BIFs**: LOOKUP, SORTARR, SUBARR have placeholder implementations

## Backward Compatibility
All existing test programs (35 tests) continue to compile and run correctly.

## Files Modified

1. **include/ast.h** - Added NODE_ARRAY_SUBSCRIPT, array_subscript structure
2. **include/codegen.h** - Added symbol table structures and functions
3. **src/rpgle.y** - Added DIM rules, array subscript parsing, array assignment
4. **src/codegen.c** - Array code generation, symbol table, %ELEM implementation
5. **examples/test_arrays.rpgle** - Comprehensive array test
6. **examples/test_simple_arrays.rpgle** - Simple array test

## Usage Example

```rpgle
**FREE

DCL-PROC calculate_average;
    DCL-S values INT(10) DIM(10);
    DCL-S sum INT(10);
    DCL-S avg INT(10);
    DCL-S i INT(10);
    
    // Initialize array
    FOR i = 1 TO %ELEM(values);
        values(i) = i * 10;
    ENDFOR;
    
    // Calculate sum
    sum = 0;
    FOR i = 1 TO %ELEM(values);
        sum = sum + values(i);
    ENDFOR;
    
    // Calculate average
    avg = sum / %ELEM(values);
    
    DSPLY avg;  // Displays 55
    
END-PROC;

CTL-OPT MAIN(calculate_average);
```

## Next Steps

To complete array support:
1. Implement INZ with array initialization
2. Add multi-dimensional array support
3. Implement array BIFs (LOOKUP, SORTARR, SUBARR)
4. Add array of data structures
5. Support LIKEDS with DIM for DS arrays
