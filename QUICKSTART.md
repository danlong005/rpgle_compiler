# Quick Start Guide - RPGLE Free Format Compiler

## Building and Testing in 5 Minutes

### 1. Build the Compiler

```bash
cd /home/dlong/Source/repos/rpgle_compiler
make
```

You should see output indicating successful compilation. The compiler binary will be at `bin/rpglec`.

### 2. Create Your First RPGLE Program

Create a file named `test.rpgle`:

```rpgle
**free
// My first RPGLE program
CTL-OPT MAIN(sayHello);

DCL-S name CHAR(20);
DCL-S greeting CHAR(50);
DCL-S i INT(10);

DCL-PROC sayHello;
    greeting = 'Hello';
    
    FOR i = 1 TO 5;
        // Loop iteration
    ENDFOR;
    
    RETURN;
END-PROC;
```

### 3. Compile RPGLE to C

```bash
./bin/rpglec test.rpgle -o test.c
```

### 4. Compile and Run the Generated C Code

```bash
gcc test.c -o test -lm
./test
```

## What Can You Do?

### Case Insensitivity

RPGLE is case insensitive, just like on IBM i. You can write keywords in any case:

```rpgle
**free
CTL-OPT MAIN(MyProc);
// or
ctl-opt main(MyProc);
// or
Ctl-Opt Main(MyProc);

DCL-S counter INT(10);
// or
dcl-s counter int(10);

IF x > 10;
// or
if x > 10;
```

### Variables and Data Types

```rpgle
**free
DCL-S counter INT(10);
DCL-S name CHAR(50);
DCL-S price PACKED(7:2);
DCL-S isValid IND;
```

### Control Flow

```rpgle
**free
// IF statement
IF counter > 10;
    counter = 0;
ELSE;
    counter = counter + 1;
ENDIF;

// FOR loop
FOR i = 1 TO 100 BY 2;
    sum = sum + i;
ENDFOR;

// DOWNTO loop
FOR i = 10 DOWNTO 1;
    // Countdown
ENDFOR;

// DOW (while) loop
DOW counter < 100;
    counter = counter + 1;
ENDDO;

// DOU (do-until) loop
DOU done == *ON;
    // Process
ENDDO;

// SELECT statement
SELECT;
    WHEN score >= 90;
        grade = 'A';
    WHEN score >= 80;
        grade = 'B';
    OTHER;
        grade = 'F';
ENDSL;
```

### Procedures

```rpgle
**free
DCL-PROC calculateTotal;
    total = price * quantity;
    RETURN;
END-PROC;
```

### Expressions

```rpgle
**free
result = a + b * c;           // Arithmetic
result = (a + b) / (c - d);   // Parentheses
isValid = x > 10 AND y < 20;  // Logical
```

## Common Workflow

1. **Write RPGLE code** in free format (no fixed columns!)
2. **Compile to C**: `./bin/rpglec input.rpgle -o output.c`
3. **Compile C to executable**: `gcc output.c -o program -lm`
4. **Run**: `./program`

## Tips

- **All free format programs must start with `**free` on line 1**
- **Must declare the main procedure on CTL-OPT line: `CTL-OPT MAIN(procedureName);`**
- **RPGLE is case insensitive** - keywords and identifiers can be in any case
- Comments use `//` for single line
- All statements end with `;`
- Variables must be declared before use with `DCL-S`
- Procedures are defined with `DCL-PROC` / `END-PROC`
- Use `*ON` and `*OFF` for boolean values
- String literals use single quotes: `'Hello'`

## Example Workflow

```bash
# 1. Write your RPGLE program
cat > myprogram.rpgle << 'EOF'
**free
CTL-OPT MAIN(processData);

DCL-S x INT(10);
DCL-S y INT(10);

DCL-PROC processData;
    x = 10;
    y = 20;
    
    IF x < y;
        x = x + 1;
    ENDIF;
    
    RETURN;
END-PROC;
EOF

# 2. Compile RPGLE to C
./bin/rpglec myprogram.rpgle -o myprogram.c

# 3. Compile C to executable
gcc myprogram.c -o myprogram -lm

# 4. Success!
echo "Program compiled successfully!"
```

## Next Steps

- Check out the `examples/` directory for more examples
- Read the full README.md for complete feature list
- Experiment with different RPGLE constructs
- Report issues or contribute improvements!
