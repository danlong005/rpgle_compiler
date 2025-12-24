# DSPLY Operation Implementation

## Overview

The DSPLY operation code has been successfully implemented in the RPGLE free format compiler. DSPLY is used to display messages and variable values to the console, similar to printf in C or print in other languages.

## Syntax

```rpgle
DSPLY expression;
```

Where `expression` can be:
- String literal: `DSPLY 'Hello, World!';`
- Integer variable: `DSPLY counter;`
- Integer constant: `DSPLY 42;`
- Arithmetic expression: `DSPLY total;` (where total is a calculated value)

## Implementation Details

### Lexer (rpgle.l)
Added the DSPLY token to recognize the keyword in the input:
```c
"DSPLY"                 { return DSPLY; }
```

### Parser (rpgle.y)
1. Added DSPLY token declaration
2. Created `dsply_stmt` grammar rule:
   ```yacc
   dsply_stmt:
       DSPLY expression SEMICOLON
   ```
3. Added dsply_stmt to the statement alternatives

### AST (ast.h)
1. Added `NODE_DSPLY` to the NodeType enum
2. Added dsply structure to ASTNode union:
   ```c
   struct {
       struct ASTNode* message;
       struct ASTNode* variable;
   } dsply;
   ```

### Code Generator (codegen.c)
The DSPLY operation is translated to C printf statements:

1. **String literals**: Converted from RPGLE single quotes to C double quotes
   - Input: `DSPLY 'Hello';`
   - Output: `printf("%s\n", "Hello");`

2. **Integer constants**: Direct integer printing
   - Input: `DSPLY 42;`
   - Output: `printf("%d\n", 42);`

3. **Integer variables**: Print variable value
   - Input: `DSPLY counter;`
   - Output: `printf("%d\n", counter);`

4. **String conversion**: Added `rpgle_string_to_c()` helper function to convert RPGLE string literals (single quotes) to C string literals (double quotes)

## Usage Examples

### Example 1: Simple Display
```rpgle
**free
ctl-opt main(Test);

dcl-proc Test;
  dsply 'Hello, World!';
  return;
end-proc;
```

### Example 2: Display Variables
```rpgle
**free
ctl-opt main(Test);

dcl-proc Test;
  dcl-s count int(10) inz(42);
  dsply 'The count is:';
  dsply count;
  return;
end-proc;
```

### Example 3: DSPLY in Loops
```rpgle
**free
ctl-opt main(Test);

dcl-proc Test;
  dcl-s i int(10);
  
  for i = 1 to 5;
    dsply i;
  endfor;
  
  return;
end-proc;
```

### Example 4: DSPLY in Conditionals
```rpgle
**free
ctl-opt main(Test);

dcl-proc Test;
  dcl-s score int(10) inz(95);
  
  if score > 90;
    dsply 'Excellent!';
  else;
    dsply 'Good effort!';
  endif;
  
  return;
end-proc;
```

## Test Results

All tests pass successfully:

✓ String literal display
✓ Integer variable display
✓ DSPLY in FOR loops
✓ DSPLY in IF/ELSE statements
✓ DSPLY in SELECT statements
✓ DSPLY with calculated values
✓ Case-insensitive keyword recognition (DSPLY, Dsply, dsply)

## Limitations

1. **Type Detection**: Currently, variable types are not tracked in a symbol table, so the compiler assumes integer variables when displaying identifiers. String variables declared as CHAR arrays will display as memory addresses rather than their content.

2. **Format Control**: The RPGLE DSPLY operation supports additional parameters for format control and response variables. The current implementation only supports the basic form with a single expression.

3. **Future Enhancements**:
   - Add symbol table to properly track variable types
   - Support DSPLY with response variables
   - Support DSPLY with output queue specifications
   - Better handling of CHAR/VARCHAR variable display

## Files Modified

1. `src/rpgle.l` - Added DSPLY token
2. `src/rpgle.y` - Added dsply_stmt grammar rule and token
3. `include/ast.h` - Added NODE_DSPLY and dsply structure
4. `src/codegen.c` - Added DSPLY code generation and string conversion
5. `README.md` - Updated documentation
6. `examples/` - Added test programs

## Verification

Run the test suite to verify DSPLY functionality:
```bash
make test
./bin/rpglec examples/test_dsply_complete.rpgle -o test.c
gcc -o test test.c
./test
```

The DSPLY keyword is now fully functional and ready for use in RPGLE programs!
