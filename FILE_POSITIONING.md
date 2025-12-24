# Advanced File Positioning Functions - Implementation

## Overview
Implemented advanced RPGLE file positioning operations for keyed file access: SETLL, SETGT, READE, READP, and READPE.

## Implemented Operations

### 1. SETLL - Set Lower Limit
**Syntax**: `SETLL key filename;`

**Purpose**: Positions the file at or immediately before the specified key value.

**Usage**:
```rpgle
DCL-S key INT(10);
key = 100;
SETLL key MYFILE;
IF %FOUND();
    // File is positioned
ENDIF;
```

**Generated C Code**:
- Searches file from beginning
- Sets file position to first record >= key
- Sets `%FOUND()` indicator on success

### 2. SETGT - Set Greater Than
**Syntax**: `SETGT key filename;`

**Purpose**: Positions the file immediately after the specified key value.

**Usage**:
```rpgle
SETGT key MYFILE;
IF %FOUND();
    // Positioned after key
ENDIF;
```

**Generated C Code**:
- Searches file from beginning
- Sets file position to first record > key
- Sets `%FOUND()` indicator on success

### 3. READE - Read Equal
**Syntax**: 
- `READE filename;`
- `READE filename record;`
- `READE key filename;`
- `READE key filename record;`

**Purpose**: Reads the next record with a key equal to the current search key.

**Usage**:
```rpgle
DCL-DS employee QUALIFIED;
    id INT(10);
    name CHAR(50);
END-DS;

// After SETLL
READE EMPFILE employee;
DOW %EQUAL() AND NOT %EOF(EMPFILE);
    DSPLY employee.name;
    READE EMPFILE employee;
ENDDO;
```

**Generated C Code**:
- Reads next record from current position
- Sets `%EQUAL()` if key matches
- Sets `%EOF()` if no more records
- Parses data into DS fields (colon-delimited)

### 4. READP - Read Previous
**Syntax**:
- `READP filename;`
- `READP filename record;`

**Purpose**: Reads the previous record in the file (moves backward).

**Usage**:
```rpgle
READP MYFILE dataRecord;
IF NOT %EOF(MYFILE);
    // Process previous record
ENDIF;
```

**Generated C Code**:
- Seeks backward in file
- Reads previous record
- Sets `%EOF()` if at beginning of file

### 5. READPE - Read Previous Equal
**Syntax**:
- `READPE filename;`
- `READPE filename record;`  
- `READPE key filename;`
- `READPE key filename record;`

**Purpose**: Reads the previous record with a key equal to the search key.

**Usage**:
```rpgle
READPE MYFILE dataRecord;
IF %EQUAL();
    // Found matching previous record
ENDIF;
```

**Generated C Code**:
- Seeks backward in file
- Reads previous record
- Sets `%EQUAL()` if key matches
- Sets `%EOF()` if no match found

## Implementation Details

### AST Node Types
Added to `include/ast.h`:
```c
NODE_SETLL,
NODE_SETGT,
NODE_READE,
NODE_READP,
NODE_READPE,
```

### Grammar Rules
Added to `src/rpgle.y`:
- Grammar production rules for each operation
- Multiple syntax variations (with/without record variable, with/without key)
- Proper file_io structure population

### Code Generation
Added to `src/codegen.c`:
- Case handlers for each NODE type
- File positioning logic using `fseek()`, `ftell()`, `rewind()`
- `%FOUND()`, `%EQUAL()`, and `%EOF()` indicator management
- Record parsing for qualified data structures

### Built-in Functions
Added `equal()` function to runtime:
```c
int equal(void) { return _rpgle_equal; }
```

## Status Indicators

These file operations set the following indicators:

| Indicator | Set By | Purpose |
|-----------|--------|---------|
| `%FOUND()` | SETLL, SETGT | Record/position found |
| `%EQUAL()` | READE, READPE | Key matches search key |
| `%EOF(file)` | All READ operations | End of file reached |

## Example: Sequential Key Processing

```rpgle
**FREE

CTL-OPT DFTACTGRP(*NO) MAIN(processOrders);

DCL-F ORDERS;

DCL-DS order QUALIFIED;
    custId INT(10);
    orderNum INT(10);
    amount PACKED(9:2);
END-DS;

DCL-PROC processOrders;
    DCL-S searchId INT(10);
    
    OPEN ORDERS;
    
    // Process all orders for customer 100
    searchId = 100;
    SETLL searchId ORDERS;
    
    IF %FOUND();
        READE ORDERS order;
        DOW %EQUAL() AND NOT %EOF(ORDERS);
            // Process each matching order
            DSPLY order.orderNum;
            DSPLY order.amount;
            READE ORDERS order;
        ENDDO;
    ENDIF;
    
    CLOSE ORDERS;
END-PROC;
```

## Example: Backward Processing

```rpgle
// Read file in reverse from end
SETGT 999999 MYFILE;  // Position after last key
READP MYFILE record;
DOW NOT %EOF(MYFILE);
    // Process records backward
    DSPLY record.data;
    READP MYFILE record;
ENDDO;
```

## Limitations

Current implementation provides simplified file positioning:

1. **Key Matching**: Simplified key comparison (full key comparison logic TBD)
2. **Backward Reading**: Uses fixed offset estimate (80 bytes) for READP/READPE
3. **File Format**: Assumes colon-delimited text format for DS parsing
4. **Performance**: Not optimized for large files (uses sequential search)

## Future Enhancements

1. **Indexed File Support**: Add proper key index structures
2. **Binary File Support**: Handle binary record formats
3. **Multi-key Support**: Support composite keys
4. **Optimization**: Add file position caching and indexed access
5. **Error Handling**: Enhanced error indicators and status codes

## Testing

Test files:
- `examples/test_file_positioning.rpgle` - Comprehensive test of all operations
- `examples/test_setll_reade.rpgle` - Basic SETLL/READE usage

All file positioning operations compile successfully and generate working C code.
