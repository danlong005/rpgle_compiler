# DATE, TIME, and TIMESTAMP Data Type Implementation

## Overview

The DATE, TIME, and TIMESTAMP data types have been successfully implemented in the RPGLE free format compiler. These types are used to store and manipulate date and time values in RPGLE programs.

## Supported Types

### DATE
- **Format**: YYYY-MM-DD
- **Storage**: char[11] (10 chars + null terminator)
- **Literal syntax**: `d'YYYY-MM-DD'`
- **Example**: `dcl-s birthDate date inz(d'1990-05-15');`

### TIME
- **Format**: HH:MM:SS
- **Storage**: char[9] (8 chars + null terminator)
- **Literal syntax**: `t'HH:MM:SS'`
- **Example**: `dcl-s startTime time inz(t'08:00:00');`

### TIMESTAMP
- **Format**: YYYY-MM-DD-HH.MM.SS.mmmmmm
- **Storage**: char[27] (26 chars + null terminator)
- **Literal syntax**: `z'YYYY-MM-DD-HH.MM.SS.mmmmmm'`
- **Example**: `dcl-s recordTs timestamp inz(z'2025-12-23-14.30.00.000000');`

## Implementation Details

### Lexer (rpgle.l)
Added three new literal patterns for date/time values:

```lex
DATE_LIT    [dD]'[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]'
TIME_LIT    [tT]'[0-9][0-9]:[0-9][0-9]:[0-9][0-9]'
TIMESTAMP_LIT [zZ]'[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]-[0-9][0-9]\.[0-9][0-9]\.[0-9][0-9]\.[0-9][0-9][0-9][0-9][0-9][0-9]'
```

**Important**: These patterns are placed BEFORE the STRING pattern in the lexer rules to ensure they are matched first.

Added corresponding token returns:
```c
{DATE_LIT}              { yylval.str_val = strdup(yytext); return DATE_LITERAL; }
{TIME_LIT}              { yylval.str_val = strdup(yytext); return TIME_LITERAL; }
{TIMESTAMP_LIT}         { yylval.str_val = strdup(yytext); return TIMESTAMP_LITERAL; }
```

### Parser (rpgle.y)

1. **Token declarations**:
```yacc
%token <str_val> IDENTIFIER STRING_LITERAL DATE_LITERAL TIME_LITERAL TIMESTAMP_LITERAL
```

2. **Type specifications** - Added standalone type rules:
```yacc
| DATE {
    $$ = create_type_info(TYPE_DATE, 10, 0);
}
| TIME {
    $$ = create_type_info(TYPE_TIME, 8, 0);
}
| TIMESTAMP {
    $$ = create_type_info(TYPE_TIMESTAMP, 26, 0);
}
```

3. **Primary expressions** - Added literal support:
```yacc
| DATE_LITERAL {
    $$ = create_string_node($1);
    free($1);
}
| TIME_LITERAL {
    $$ = create_string_node($1);
    free($1);
}
| TIMESTAMP_LITERAL {
    $$ = create_string_node($1);
    free($1);
}
```

### Code Generator (codegen.c)

1. **Type conversion** - Updated to use char arrays:
```c
case TYPE_DATE:
    return "char";  /* Will be used as char[11] for YYYY-MM-DD\0 */
case TYPE_TIME:
    return "char";  /* Will be used as char[9] for HH:MM:SS\0 */
case TYPE_TIMESTAMP:
    return "char";  /* Will be used as char[27] for full timestamp */
```

2. **Variable declarations** - Special handling for date/time types:
```c
if (node->data.declaration.type_info->type == TYPE_CHAR ||
    node->data.declaration.type_info->type == TYPE_VARCHAR ||
    node->data.declaration.type_info->type == TYPE_DATE ||
    node->data.declaration.type_info->type == TYPE_TIME ||
    node->data.declaration.type_info->type == TYPE_TIMESTAMP) {
    /* Generate as char array, not char pointer */
    fprintf(ctx->output, "char %s[%d]", 
            node->data.declaration.name,
            node->data.declaration.type_info->length + 1);
```

3. **Literal initialization** - Converts date literals to C strings:
```c
/* Check if it's a date/time/timestamp literal */
if ((str_val[0] == 'd' || str_val[0] == 'D' ||
     str_val[0] == 't' || str_val[0] == 'T' ||
     str_val[0] == 'z' || str_val[0] == 'Z') && str_val[1] == '\'') {
    /* Convert d'YYYY-MM-DD' to "YYYY-MM-DD" */
    char* c_str = rpgle_string_to_c(str_val + 1);
    fprintf(ctx->output, " = %s", c_str);
    free(c_str);
}
```

## Usage Examples

### Basic DATE Declaration
```rpgle
**free
ctl-opt main(DateExample);

dcl-proc DateExample;
  dcl-s today date;
  dcl-s birthdate date inz(d'1990-05-15');
  dcl-s hiredate date inz(d'2020-01-01');
  
  return;
end-proc;
```

### All Date/Time Types
```rpgle
**free
ctl-opt main(DateTimeExample);

dcl-proc DateTimeExample;
  dcl-s mydate date inz(d'2025-12-23');
  dcl-s mytime time inz(t'14:30:00');
  dcl-s mytimestamp timestamp inz(z'2025-12-23-14.30.00.000000');
  
  return;
end-proc;
```

### Practical Application
```rpgle
**free
ctl-opt main(OrderSystem);

dcl-proc OrderSystem;
  dcl-s orderDate date inz(d'2025-01-15');
  dcl-s shipDate date inz(d'2025-01-20');
  dcl-s startTime time inz(t'08:00:00');
  dcl-s endTime time inz(t'17:00:00');
  dcl-s recordTs timestamp inz(z'2025-12-23-10.30.45.123456');
  
  dsply 'Order Date: 2025-01-15';
  dsply 'Ship Date: 2025-01-20';
  
  return;
end-proc;
```

## Generated C Code

### RPGLE Input:
```rpgle
dcl-s mydate date inz(d'2025-12-23');
dcl-s mytime time inz(t'14:30:00');
dcl-s mytimestamp timestamp inz(z'2025-12-23-14.30.00.000000');
```

### Generated C Output:
```c
char mydate[11] = "2025-12-23";
char mytime[9] = "14:30:00";
char mytimestamp[27] = "2025-12-23-14.30.00.000000";
```

## Test Results

All date/time type tests pass successfully:

✅ DATE type declaration
✅ TIME type declaration
✅ TIMESTAMP type declaration
✅ DATE literal initialization (d'YYYY-MM-DD')
✅ TIME literal initialization (t'HH:MM:SS')
✅ TIMESTAMP literal initialization (z'...')
✅ String initialization for date types
✅ Uninitialized date/time variables
✅ Case-insensitive literal prefixes (d/D, t/T, z/Z)
✅ Integration with existing features (DSPLY, procedures)

## Limitations

1. **No Date Arithmetic**: The current implementation treats dates as strings. Date arithmetic operations (adding days, calculating differences) are not yet implemented.

2. **No Format Validation**: The lexer accepts any string that matches the pattern. Invalid dates like `d'2025-13-45'` will be accepted at compile time.

3. **No Built-in Functions**: Date manipulation functions like `%DATE()`, `%DIFF()`, `%DAYS()` are not yet implemented.

4. **String Storage**: Dates are stored as character arrays in C, not as structured date types or timestamps.

## Future Enhancements

Potential improvements for date/time support:

1. **Date Arithmetic**:
   - Add support for date addition/subtraction
   - Implement duration data types
   
2. **Built-in Functions**:
   - `%DATE()` - Convert to date
   - `%TIME()` - Convert to time
   - `%TIMESTAMP()` - Convert to timestamp
   - `%DIFF()` - Calculate date difference
   - `%DAYS()`, `%MONTHS()`, `%YEARS()` - Date components
   
3. **Format Support**:
   - Multiple date format options (*ISO, *USA, *EUR, etc.)
   - Format conversion functions
   
4. **Validation**:
   - Compile-time date literal validation
   - Range checking for date components

## Files Modified

1. **src/rpgle.l** - Added date/time literal patterns and tokens
2. **src/rpgle.y** - Added DATE/TIME/TIMESTAMP to type_spec and primary_expr
3. **src/codegen.c** - Updated type conversion and declaration generation
4. **README.md** - Updated documentation with date literal syntax
5. **examples/** - Added test programs:
   - test_date_basic.rpgle
   - test_date_time.rpgle
   - test_date_demo.rpgle
   - test_date_simple.rpgle
   - test_date_string_init.rpgle

## Verification

Run the test suite to verify date/time functionality:

```bash
make test
./bin/rpglec examples/test_date_demo.rpgle -o test.c
gcc -o test test.c
./test
```

The DATE, TIME, and TIMESTAMP data types are now fully functional and ready for use in RPGLE programs!
