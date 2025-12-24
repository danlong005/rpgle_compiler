# RPGLE Free Format Compiler

A compiler for IBM i v7r5 compatible RPGLE (RPG IV) free format code that translates RPGLE programs to C code. Built using Flex and Yacc/Bison.

## Features

This compiler supports the following RPGLE free format features:

**Note:** The compiler is fully case-insensitive, matching IBM i RPGLE behavior. Keywords and identifiers can be written in any case (e.g., `DCL-S`, `Dcl-S`, `dcl-s` are all equivalent).

### Control Options
- `CTL-OPT` - Program control options
- `MAIN(procedureName)` - Specify the main entry point procedure (required)

### Declarations
- `DCL-S` - Declare standalone variables
- `DCL-C` - Declare constants
- `DCL-PROC` / `END-PROC` - Define procedures
- `DCL-PR` / `END-PR` - Procedure prototypes
- `DCL-PI` / `END-PI` - Procedure interfaces
- `DCL-DS` / `END-DS` - Data structures
- `DIM` - Array dimension specification

### Data Types
- `CHAR` - Character strings
- `VARCHAR` - Variable-length character strings
- `INT` - Integer numbers
- `UNS` - Unsigned integers
- `PACKED` - Packed decimal
- `ZONED` - Zoned decimal
- `BINDEC` - Binary decimal
- `IND` - Indicator (boolean)
- `DATE`, `TIME`, `TIMESTAMP` - Date/time types with literal support
  - DATE literals: `d'YYYY-MM-DD'` (e.g., `d'2025-12-23'`)
  - TIME literals: `t'HH:MM:SS'` (e.g., `t'14:30:00'`)
  - TIMESTAMP literals: `z'YYYY-MM-DD-HH.MM.SS.mmmmmm'` (e.g., `z'2025-12-23-14.30.00.000000'`)
- `POINTER` - Pointer types

### Control Flow
- `IF` / `ELSEIF` / `ELSE` / `ENDIF`
- `FOR` / `ENDFOR` - For loops with `TO`, `DOWNTO`, `BY`
- `DOW` / `ENDDO` - Do while loops
- `DOU` / `ENDDO` - Do until loops
- `SELECT` / `WHEN` / `OTHER` / `ENDSL` - Select statements
- `ITER` - Continue loop
- `LEAVE` - Break from loop

### Operations
- `EVAL` - Evaluate expression (optional keyword)
- `RETURN` - Return from procedure
- `CALLP` - Call procedure
- `DSPLY` - Display message or variable value
- Assignment operators: `=`
- Arithmetic operators: `+`, `-`, `*`, `/`, `**`
- Comparison operators: `==`, `<>`, `<`, `<=`, `>`, `>=`
- Logical operators: `AND`, `OR`, `NOT`

### Built-in Functions
- **100+ BIFs** compatible with IBM RPGLE v7.5 - see [BIFS.md](BIFS.md) for complete list
- String functions: `%TRIM`, `%TRIMR`, `%TRIML`, `%SUBST`, `%REPLACE`, `%SCAN`, `%XLATE`, `%SCANRPL`, `%CHECK`, `%CHECKR`
- Conversion functions: `%CHAR`, `%INT`, `%DEC`, `%FLOAT`, `%UNS`, `%GRAPH`, `%HEX`
- Date/time functions: `%DATE`, `%TIME`, `%TIMESTAMP`, `%YEARS`, `%MONTHS`, `%DAYS`, `%HOURS`, `%MINUTES`, `%SECONDS`
- Array functions: `%ELEM` (returns array dimension)
- Math functions: `%ABS`, `%SQRT`, `%REM`, `%DIV`
- Bitwise functions: `%BITAND`, `%BITOR`, `%BITXOR`, `%BITNOT`
- Utility functions: `%LEN`, `%SIZE`, `%ADDR`, `%PARMS`
- I/O status: `%FOUND`, `%EOF`, `%EQUAL`, `%ERROR`, `%OPEN`, `%STATUS`, `%RECORD`

## Requirements

- GCC (C compiler)
- Flex (lexical analyzer generator)
- Bison/Yacc (parser generator)
- Make

### Installation on Linux/Unix

```bash
# Debian/Ubuntu
sudo apt-get install gcc flex bison make

# Fedora/RHEL
sudo dnf install gcc flex bison make

# macOS (with Homebrew)
brew install gcc flex bison make
```

## Building the Compiler

```bash
# Build the compiler
make

# Clean build artifacts
make clean

# Run tests
make test
```

The compiler executable will be created at `bin/rpglec`.

## Usage

```bash
# Compile RPGLE file to C
./bin/rpglec input.rpgle -o output.c

# Read from stdin, write to stdout
./bin/rpglec < input.rpgle > output.c

# Display help
./bin/rpglec --help
```

### Example Workflow

```bash
# 1. Compile RPGLE to C
./bin/rpglec examples/hello.rpgle -o hello.c

# 2. Compile the generated C code
gcc hello.c -o hello -lm

# 3. Run the executable
./hello
```

## Example Programs

The `examples/` directory contains several example RPGLE programs:

- `hello.rpgle` - Basic hello world with variables and loops
- `control_flow.rpgle` - IF/ELSE statements
- `loops.rpgle` - FOR, DOW, and DOU loops
- `select.rpgle` - SELECT statement demonstration
- `expressions.rpgle` - Arithmetic and logical expressions
- `dsply_demo.rpgle` - DSPLY (display) operation examples
- `test_arrays.rpgle` - Array declaration and manipulation
- `test_simple_arrays.rpgle` - Simple array operations with %ELEM
- `test_data_structures.rpgle` - Qualified and non-qualified data structures
- `test_complex_ds.rpgle` - Complex data structures with various types
- `test_ds_array.rpgle` - Arrays of data structures with LIKEDS
- `test_ds_array_inline.rpgle` - Inline data structure array definition
- `test_ds_array_complete.rpgle` - Complete DS array test with LIKEDS and DIM
- `test_bif_*.rpgle` - Built-in function tests (string, numeric, date/time, etc.)
- `test_date_*.rpgle` - Date/time literal and BIF tests
- `test_file_*.rpgle` - File I/O operation tests

### Array Example

```rpgle
**FREE

DCL-PROC calculate_total;
    DCL-S numbers INT(10) DIM(5);
    DCL-S total INT(10);
    DCL-S i INT(10);
    
    // Initialize array
    numbers(1) = 10;
    numbers(2) = 20;
    numbers(3) = 30;
    numbers(4) = 40;
    numbers(5) = 50;
    
    // Calculate sum using %ELEM
    total = 0;
    FOR i = 1 TO %ELEM(numbers);
        total = total + numbers(i);
    ENDFOR;
    
    DSPLY total;  // Displays: 150
    
END-PROC;

CTL-OPT MAIN(calculate_total);
```

### Data Structure Example

```rpgle
**FREE

// Qualified data structure
DCL-DS employee QUALIFIED;
    name CHAR(50);
    id INT(10);
    salary PACKED(9:2);
    hireDate DATE;
END-DS;

DCL-PROC processEmployee;
    employee.name = 'John Smith';
    employee.id = 12345;
    employee.salary = 75000.00;
    employee.hireDate = d'2020-01-15';
    
    DSPLY employee.name;
    DSPLY employee.id;
END-PROC;

CTL-OPT MAIN(processEmployee);
```

See [DATA_STRUCTURES.md](DATA_STRUCTURES.md) for complete documentation.

### File I/O Example

```rpgle
**FREE

DCL-F MYFILE;

DCL-PROC readFile;
    DCL-S line CHAR(100);
    
    OPEN MYFILE;
    READ MYFILE line;
    DOW NOT %EOF;
        DSPLY line;
        READ MYFILE line;
    ENDDO;
    CLOSE MYFILE;
END-PROC;

CTL-OPT MAIN(readFile);
```

See [FILE_IO.md](FILE_IO.md) for complete documentation.

All example programs start with `**free` on the first line, which is the standard marker for free-format RPGLE programs. All programs must also specify a MAIN procedure using `ctl-opt main(procedureName);`.

## Project Structure

```
rpgle_compiler/
├── src/
│   ├── rpgle.l          # Flex lexer specification
│   ├── rpgle.y          # Yacc/Bison parser specification
│   ├── ast.c            # Abstract Syntax Tree implementation
│   ├── codegen.c        # C code generation
│   └── main.c           # Main compiler driver
├── include/
│   ├── ast.h            # AST header
│   └── codegen.h        # Code generator header
├── examples/            # Example RPGLE programs
├── Makefile            # Build configuration
└── README.md           # This file
```

## Limitations

This is a free format RPGLE compiler focusing on modern RPGLE syntax. It does **NOT** support:

- Fixed format (column-based) RPG code
- Legacy RPG/400 syntax
- External program calls with full IBM i semantics
- Service programs and binding directories (partial support)
- ILE-specific features beyond basic procedures
- Multi-dimensional arrays (only 1D arrays supported)
- Nested data structures
- Data structure overlay (POS keyword)
- Some advanced BIFs have placeholder implementations (see [BIFS.md](BIFS.md) for details)

## Generated C Code

The compiler generates standard C code that:
- Includes standard C headers (stdio.h, stdlib.h, string.h, math.h)
- Implements RPGLE procedures as C functions
- Converts RPGLE data types to appropriate C types
- Provides runtime helper functions for built-in operations
- Can be compiled with any standard C compiler

## Development

To extend the compiler:

1. **Add new tokens**: Edit [src/rpgle.l](src/rpgle.l)
2. **Add new grammar rules**: Edit [src/rpgle.y](src/rpgle.y)
3. **Add new AST node types**: Edit [include/ast.h](include/ast.h) and [src/ast.c](src/ast.c)
4. **Add code generation**: Edit [src/codegen.c](src/codegen.c)

## License

This compiler is provided as-is for educational and development purposes.

## Contributing

Contributions are welcome! Areas for improvement:
- More built-in function implementations
- Data structure support
- File I/O operations
- Error messages and diagnostics
- Optimization passes
- Better type checking
- Symbol table enhancements

## References

- IBM i v7r5 RPGLE Reference: https://www.ibm.com/docs/en/i/7.5
- Free Format RPGLE: https://www.ibm.com/docs/en/i/7.5?topic=rpg-free-form-specifications
