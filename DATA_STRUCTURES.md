# Data Structures in RPGLE

## Overview

Data structures (DS) in RPGLE group related fields together, similar to C structs. They can be either qualified (accessed with dot notation) or non-qualified (fields are global).

## Syntax

### Qualified Data Structures

```rpgle
DCL-DS employee QUALIFIED;
    name CHAR(50);
    id INT(10);
    salary INT(10);
END-DS;

// Access fields with dot notation
employee.name = 'John Smith';
employee.id = 12345;
```

### Non-Qualified Data Structures

```rpgle
DCL-DS point;
    x INT(10);
    y INT(10);
END-DS;

// Fields are accessed directly without DS name
x = 10;
y = 20;
```

## C Code Generation

### Qualified DS → C Struct

A qualified data structure is generated as a C struct:

```rpgle
DCL-DS employee QUALIFIED;
    name CHAR(50);
    id INT(10);
    salary INT(10);
END-DS;
```

Generates:

```c
struct {
    char name[51];
    int id;
    int salary;
} employee;
```

Access: `employee.name`, `employee.id`, `employee.salary`

### Non-Qualified DS → Separate Variables

A non-qualified data structure generates individual global variables:

```rpgle
DCL-DS point;
    x INT(10);
    y INT(10);
END-DS;
```

Generates:

```c
int x;
int y;
```

Access: `x`, `y`

## Field Types

Data structure fields support all standard RPGLE types:

- `CHAR(n)` - Character strings
- `VARCHAR(n)` - Variable-length character strings
- `INT(n)` - Integer numbers
- `PACKED(p:d)` - Packed decimal
- `ZONED(p:d)` - Zoned decimal
- `DATE` - Date values
- `TIME` - Time values
- `TIMESTAMP` - Timestamp values
- `IND` - Indicators (boolean)

## Examples

### Employee Record

```rpgle
DCL-DS employee QUALIFIED;
    firstName CHAR(30);
    lastName CHAR(30);
    employeeId INT(10);
    salary PACKED(9:2);
    hireDate DATE;
END-DS;

DCL-PROC processEmployee;
    employee.firstName = 'John';
    employee.lastName = 'Smith';
    employee.employeeId = 12345;
    employee.salary = 75000.00;
    employee.hireDate = d'2020-01-15';
    
    DSPLY ('Employee: ' + employee.firstName + ' ' + employee.lastName);
    DSPLY ('ID: ' + %CHAR(employee.employeeId));
END-PROC;
```

### Coordinates (Non-Qualified)

```rpgle
DCL-DS coordinates;
    x INT(10);
    y INT(10);
    z INT(10);
END-DS;

DCL-PROC setPosition;
    x = 100;
    y = 200;
    z = 50;
    
    DSPLY ('Position: (' + %CHAR(x) + ',' + %CHAR(y) + ',' + %CHAR(z) + ')');
END-PROC;
```

## When to Use Qualified vs Non-Qualified

### Use QUALIFIED when:

- You want explicit namespacing to avoid field name conflicts
- The data structure represents a cohesive entity (like an employee or customer)
- You may have multiple instances of the same structure type
- You want clearer, more readable code

### Use Non-Qualified when:

- You have a small number of global variables
- Field names are unique and won't conflict
- You're working with legacy code that doesn't use qualification
- You want shorter field references

## Best Practices

1. **Prefer QUALIFIED** - It makes code more maintainable and avoids naming conflicts
2. **Use meaningful names** - Both for DS names and field names
3. **Group related fields** - Put fields that logically belong together in the same DS
4. **Document complex structures** - Add comments explaining the purpose of each field
5. **Initialize fields** - Always initialize fields to known values when possible

## Limitations

Current implementation limitations:

- No nested data structures yet
- No data structure overlay (POS keyword)
- No data structure initialization in declaration (INZ on DS level)

## Data Structure Arrays

You can create arrays of data structures using either LIKEDS or inline definition with DIM.

### Using LIKEDS with DIM

```rpgle
// Define base data structure
DCL-DS employee QUALIFIED;
    name CHAR(50);
    id INT(10);
    salary PACKED(9:2);
END-DS;

// Create array using LIKEDS
DCL-DS employees LIKEDS(employee) DIM(10);

// Access array elements
employees(1).name = 'John Smith';
employees(1).id = 1001;
employees(2).salary = 75000.00;
```

Generates:

```c
struct {
    char name[51];
    int id;
    double salary;
} employee;

struct {
    char name[51];
    int id;
    double salary;
} employees[10];

strcpy(employees[0].name, "John Smith");
employees[0].id = 1001;
employees[1].salary = 75000.00;
```

### Inline Definition with DIM

```rpgle
DCL-DS coordinates QUALIFIED DIM(5);
    x INT(10);
    y INT(10);
    z INT(10);
END-DS;

coordinates(1).x = 100;
coordinates(1).y = 200;
```

Generates:

```c
struct {
    int x;
    int y;
    int z;
} coordinates[5];

coordinates[0].x = 100;
coordinates[0].y = 200;
```

### Complete Example

```rpgle
**FREE

// Base person structure
DCL-DS person QUALIFIED;
    firstName CHAR(20);
    lastName CHAR(20);
    age INT(10);
END-DS;

// Array of people using LIKEDS
DCL-DS people LIKEDS(person) DIM(3);

DCL-PROC processPeople;
    DCL-S i INT(10);
    DCL-S totalAge INT(10);
    
    // Initialize
    people(1).firstName = 'John';
    people(1).lastName = 'Smith';
    people(1).age = 30;
    
    people(2).firstName = 'Jane';
    people(2).lastName = 'Doe';
    people(2).age = 28;
    
    people(3).firstName = 'Bob';
    people(3).lastName = 'Johnson';
    people(3).age = 35;
    
    // Calculate total age
    totalAge = 0;
    FOR i = 1 TO 3;
        totalAge = totalAge + people(i).age;
    ENDFOR;
    
    DSPLY totalAge;  // Should display 93
END-PROC;

CTL-OPT MAIN(processPeople);
```

## Limitations

```rpgle
**FREE

// Qualified employee data structure
DCL-DS employee QUALIFIED;
    name CHAR(50);
    id INT(10);
    salary INT(10);
END-DS;

// Non-qualified point data structure
DCL-DS point;
    x INT(10);
    y INT(10);
END-DS;

DCL-PROC testDataStructures;
    // Set employee data
    employee.name = 'John Smith';
    employee.id = 12345;
    employee.salary = 75000;
    
    // Display employee info
    DSPLY 'Employee Name:';
    DSPLY employee.name;
    DSPLY 'Employee ID:';
    DSPLY employee.id;
    DSPLY 'Employee Salary:';
    DSPLY employee.salary;
    
    // Set point coordinates
    x = 10;
    y = 20;
    
    // Display point info
    DSPLY 'Point X:';
    DSPLY x;
    DSPLY 'Point Y:';
    DSPLY y;
END-PROC;
```

## See Also

- [Array Implementation](ARRAY_IMPLEMENTATION.md)
- [File I/O](FILE_IO.md)
- [RPGLE Grammar](RPGLE_GRAMMAR.ebnf)
