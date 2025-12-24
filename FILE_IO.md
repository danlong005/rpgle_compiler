# File I/O Implementation

## Overview

The RPGLE compiler now supports file input/output operations for reading and writing text files using the standard `DCL-F` (Declare File) statement.

## Supported Operations

### DCL-F - Declare a File
```rpgle
DCL-F filename;
```
Declares a file variable. Files are automatically managed as FILE* pointers in the generated C code.

**Example:**
```rpgle
DCL-F myfile;
DCL-F datafile;
```

### OPEN - Open a File
```rpgle
OPEN file_variable;
```
Opens a file for reading and writing. If the file doesn't exist, it will be created.

**Example:**
```rpgle
DCL-S myfile POINTER;
OPEN myfile;  // Opens myfile.txt
```

### CLOSE - Close a File
```rpgle
CLOSE file_variable;
```
Closes an open file and releases resources.

**Example:**
```rpgle
CLOSE myfile;
```

### WRITE - Write to a File
```rpgle
WRITE file_variable;               // Write blank line
WRITE file_variable data_var;      // Write data from variable
WRITE file_variable data_structure; // Write entire DS as a record
```
Writes data to the file followed by a newline. When writing a data structure, the entire structure is written as a single binary record.

**Example:**
```rpgle
DCL-S line CHAR(50);
line = 'Hello, World!';
WRITE myfile line;

// Write data structure
DCL-DS employee QUALIFIED;
    name CHAR(30);
    id INT(10);
END-DS;
employee.name = 'John Smith';
employee.id = 1001;
WRITE myfile employee;  // Writes the entire structure as one record
```

### READ - Read from a File
```rpgle
READ file_variable;                 // Read and discard line
READ file_variable data_var;        // Read line into variable
READ file_variable data_structure;  // Read record into DS
```
Reads a line from the file. When reading into a data structure, the entire record buffer is read and copied into the structure.

**Example:**
```rpgle
DCL-S line CHAR(100);
READ myfile line;
DSPLY line;

// Read into data structure
DCL-DS employee QUALIFIED;
    name CHAR(30);
    id INT(10);
END-DS;
READ myfile employee;  // Reads record buffer into structure
// Now employee.name and employee.id contain the data
```

### CHAIN - Keyed Read (Simplified)
```rpgle
CHAIN key_value file_variable;
CHAIN key_value file_variable data_var;
```
Performs a keyed read operation (currently implemented as a simple rewind and read).

**Example:**
```rpgle
CHAIN 1 myfile line;
```

## File Variable Declaration

File variables must be declared using `DCL-F`:

```rpgle
DCL-F myfile;
DCL-F datafile;
```

File variables are automatically generated as global `FILE*` pointers in the C code.

## Complete Example

### Simple String I/O
```rpgle
**free
CTL-OPT DFTACTGRP(*NO) MAIN(fileExample);

DCL-F datafile;
DCL-S line CHAR(100);

DCL-PROC fileExample;
    // Open file for writing
    OPEN datafile;
    
    // Write data
    line = 'First record';
    WRITE datafile line;
    
    line = 'Second record';
    WRITE datafile line;
    
    // Close and reopen
    CLOSE datafile;
    OPEN datafile;
    
    // Read data
    READ datafile line;
    DSPLY line;  // Displays: First record
    
    READ datafile line;
    DSPLY line;  // Displays: Second record
    
    CLOSE datafile;
    RETURN;
END-PROC;
```

### Data Structure I/O
```rpgle
**FREE
DCL-F EMPFILE;

DCL-DS employee QUALIFIED;
    name CHAR(30);
    id INT(10);
    dept CHAR(10);
    salary PACKED(9:2);
END-DS;

DCL-PROC processEmployees;
    // Write employee records
    OPEN EMPFILE;
    
    employee.name = 'John Smith';
    employee.id = 1001;
    employee.dept = 'Sales';
    employee.salary = 75000.00;
    WRITE EMPFILE employee;
    
    employee.name = 'Jane Doe';
    employee.id = 1002;
    employee.dept = 'IT';
    employee.salary = 85000.00;
    WRITE EMPFILE employee;
    
    CLOSE EMPFILE;
    
    // Read employee records back
    OPEN EMPFILE;
    READ EMPFILE employee;
    DOW NOT %EOF();
        // Process employee data
        // employee.name, employee.id, employee.dept, employee.salary
        READ EMPFILE employee;
    ENDDO;
    CLOSE EMPFILE;
    RETURN;
END-PROC;

CTL-OPT MAIN(processEmployees);
```

## Implementation Details

### File Naming Convention
Files are automatically named based on the file variable name with `.txt` extension:
- Variable `myfile` → creates/opens `myfile.txt`
- Variable `datafile` → creates/opens `datafile.txt`

### C Code Generation

**OPEN generates:**
```c
file_var = fopen("file_var.txt", "r+");
if (!file_var) file_var = fopen("file_var.txt", "w+");
```

**CLOSE generates:**
```c
if (file_var) { fclose(file_var); file_var = NULL; }
```

**WRITE (string) generates:**
```c
if (file_var) fprintf(file_var, "%s\n", data_var);
```

**WRITE (data structure) generates:**
```c
if (file_var) {
    char _rpgle_buffer[4096];
    memcpy(_rpgle_buffer, &data_structure, sizeof(data_structure));
    fwrite(_rpgle_buffer, sizeof(data_structure), 1, file_var);
    fputc('\n', file_var);
}
```

**READ (string) generates:**
```c
if (file_var && fgets(data_var, sizeof(data_var), file_var)) {
    data_var[strcspn(data_var, "\n")] = 0;
}
```

**READ (data structure) generates:**
```c
{ char _rpgle_buffer[4096];
  if (file_var && fgets(_rpgle_buffer, sizeof(_rpgle_buffer), file_var)) {
      _rpgle_buffer[strcspn(_rpgle_buffer, "\n")] = 0;
      memcpy(&data_structure, _rpgle_buffer, sizeof(data_structure));
      _rpgle_eof = 0;
  } else {
      _rpgle_eof = 1;
  }
}
```

## Limitations

1. **Text files only** - Binary file operations are not supported
2. **Sequential access** - Files are read/written sequentially
3. **No record locking** - Concurrent access is not managed
4. **Simple CHAIN** - Keyed access is simplified (not full database functionality)
5. **Fixed buffer sizes** - String variables must be large enough for file data

## Error Handling

Currently, file operations perform basic null checks but don't set error indicators. The following BIFs can be used for status checking (placeholders):
- `%EOF()` - End of file indicator
- `%ERROR()` - Error indicator
- `%OPEN(filename)` - File open status

## Future Enhancements

Planned improvements:
- Database file support (DCL-F)
- Record-level access
- Keyed file operations
- File positioning (SETLL, SETGT)
- Update and delete operations
- Error indicator support

## Testing

Example test program: `examples/simple_file_io.rpgle`

Run the test:
```bash
./bin/rpglec examples/simple_file_io.rpgle -o test/simple_file_io.c
gcc -o test/simple_file_io test/simple_file_io.c -lm
./test/simple_file_io
```

The program creates `datafile.txt` with three lines and then reads them back.
