#ifndef AST_H
#define AST_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* AST Node Types */
typedef enum {
    /* Program structure */
    NODE_PROGRAM,
    NODE_CTL_OPT,
    NODE_DECLARATION,
    NODE_PROCEDURE,
    
    /* Declarations */
    NODE_DCL_S,      /* Standalone variable */
    NODE_DCL_C,      /* Constant */
    NODE_DCL_DS,     /* Data structure */
    NODE_DCL_PR,     /* Prototype */
    NODE_DCL_PI,     /* Procedure interface */
    NODE_DCL_PROC,   /* Procedure */
    
    /* Statements */
    NODE_IF,
    NODE_FOR,
    NODE_DOW,
    NODE_DOU,
    NODE_SELECT,
    NODE_WHEN,
    NODE_EVAL,
    NODE_RETURN,
    NODE_CALLP,
    NODE_CLEAR,
    NODE_RESET,
    NODE_DSPLY,
    
    /* I/O Operations */
    NODE_CHAIN,
    NODE_READ,
    NODE_WRITE,
    NODE_UPDATE,
    NODE_DELETE,
    NODE_OPEN,
    NODE_CLOSE,
    
    /* Expressions */
    NODE_BINARY_OP,
    NODE_UNARY_OP,
    NODE_FUNCTION_CALL,
    NODE_IDENTIFIER,
    NODE_ARRAY_SUBSCRIPT,
    NODE_INTEGER,
    NODE_DECIMAL,
    NODE_STRING,
    NODE_CONSTANT,
    
    /* Lists */
    NODE_STATEMENT_LIST,
    NODE_PARAMETER_LIST,
    NODE_FIELD_LIST,
    
    /* Control flow modifiers (added last to avoid shifting other values) */
    NODE_ITER,
    NODE_LEAVE
} NodeType;

/* Data Types */
typedef enum {
    TYPE_CHAR,
    TYPE_VARCHAR,
    TYPE_INT,
    TYPE_UNS,
    TYPE_PACKED,
    TYPE_ZONED,
    TYPE_BINDEC,
    TYPE_IND,
    TYPE_DATE,
    TYPE_TIME,
    TYPE_TIMESTAMP,
    TYPE_POINTER,
    TYPE_UNKNOWN
} DataType;

/* Operators */
typedef enum {
    OP_ADD,
    OP_SUB,
    OP_MULT,
    OP_DIV,
    OP_POWER,
    OP_EQ,
    OP_NE,
    OP_LT,
    OP_LE,
    OP_GT,
    OP_GE,
    OP_AND,
    OP_OR,
    OP_NOT
} Operator;

/* Type Information */
typedef struct {
    DataType type;
    int length;
    int decimals;
    int dim;  /* Array dimension */
    char* like_field;  /* For LIKE keyword */
} TypeInfo;

/* AST Node */
typedef struct ASTNode {
    NodeType type;
    union {
        /* Literals */
        int int_value;
        double float_value;
        char* string_value;
        
        /* Identifier */
        struct {
            char* name;
        } identifier;
        
        /* Variable declaration */
        struct {
            char* name;
            TypeInfo* type_info;
            struct ASTNode* initializer;
            int is_const;
            int is_static;
            int is_file;
        } declaration;
        
        /* Data structure */
        struct {
            char* name;
            struct ASTNode* fields;
            int is_qualified;
            char* base_ds_name;  /* For LIKEDS */
            int dim;             /* For DIM (array of DS) */
        } data_structure;
        
        /* Procedure */
        struct {
            char* name;
            struct ASTNode* parameters;
            struct ASTNode* body;
            TypeInfo* return_type;
            int is_export;
        } procedure;
        
        /* Binary operation */
        struct {
            Operator op;
            struct ASTNode* left;
            struct ASTNode* right;
        } binary_op;
        
        /* Unary operation */
        struct {
            Operator op;
            struct ASTNode* operand;
        } unary_op;
        
        /* Function call */
        struct {
            char* name;
            struct ASTNode* arguments;
        } function_call;
        
        /* Array subscript */
        struct {
            char* array_name;
            struct ASTNode* index;
        } array_subscript;
        
        /* If statement */
        struct {
            struct ASTNode* condition;
            struct ASTNode* then_branch;
            struct ASTNode* else_branch;
        } if_stmt;
        
        /* For loop */
        struct {
            char* var;
            struct ASTNode* start;
            struct ASTNode* end;
            struct ASTNode* step;
            struct ASTNode* body;
            int is_downto;
        } for_loop;
        
        /* While/Do-While loop */
        struct {
            struct ASTNode* condition;
            struct ASTNode* body;
            int is_post_test;  /* DOU vs DOW */
        } while_loop;
        
        /* Select statement */
        struct {
            struct ASTNode* when_clauses;
            struct ASTNode* other_clause;
        } select_stmt;
        
        /* When clause */
        struct {
            struct ASTNode* condition;
            struct ASTNode* statements;
        } when_clause;
        
        /* Return statement */
        struct {
            struct ASTNode* value;
        } return_stmt;
        
        /* Display statement */
        struct {
            struct ASTNode* message;
            struct ASTNode* variable;
        } dsply;
        
        /* File I/O operations */
        struct {
            char* file_name;
            char* record_var;
            struct ASTNode* key;
        } file_io;
        
        /* Control options */
        struct {
            char** options;
            int count;
        } ctl_opt;
        
        /* List */
        struct {
            struct ASTNode** items;
            int count;
            int capacity;
        } list;
    } data;
    
    int line;
    int column;
} ASTNode;

/* Function prototypes */
ASTNode* create_node(NodeType type);
ASTNode* create_integer_node(int value);
ASTNode* create_float_node(double value);
ASTNode* create_string_node(char* value);
ASTNode* create_identifier_node(char* name);
ASTNode* create_binary_op_node(Operator op, ASTNode* left, ASTNode* right);
ASTNode* create_unary_op_node(Operator op, ASTNode* operand);
ASTNode* create_function_call_node(char* name, ASTNode* args);
ASTNode* create_if_node(ASTNode* condition, ASTNode* then_branch, ASTNode* else_branch);
ASTNode* create_for_node(char* var, ASTNode* start, ASTNode* end, ASTNode* step, ASTNode* body, int is_downto);
ASTNode* create_while_node(ASTNode* condition, ASTNode* body, int is_post_test);
ASTNode* create_declaration_node(char* name, TypeInfo* type_info, ASTNode* initializer, int is_const);
ASTNode* create_procedure_node(char* name, ASTNode* params, ASTNode* body, TypeInfo* return_type);
ASTNode* create_return_node(ASTNode* value);
ASTNode* create_list_node(NodeType type);
void add_to_list(ASTNode* list, ASTNode* item);
void free_ast(ASTNode* node);
TypeInfo* create_type_info(DataType type, int length, int decimals);

#endif /* AST_H */
