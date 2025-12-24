#ifndef CODEGEN_H
#define CODEGEN_H

#include "ast.h"
#include <stdio.h>

/* Symbol table for tracking array information */
typedef struct SymbolTableEntry {
    char* name;
    int dim;  /* Array dimension, 0 if not an array */
    struct SymbolTableEntry* next;
} SymbolTableEntry;

/* Data structure symbol table for LIKEDS */
typedef struct DSSymbolEntry {
    char* name;
    ASTNode* fields;  /* List of field declarations */
    int is_qualified;
    struct DSSymbolEntry* next;
} DSSymbolEntry;

typedef struct {
    FILE* output;
    int indent_level;
    int temp_var_counter;
    int label_counter;
    char* main_proc_name;
    SymbolTableEntry* symbol_table;
    DSSymbolEntry* ds_table;
} CodeGenContext;

void codegen_init(CodeGenContext* ctx, FILE* output);
void codegen_program(CodeGenContext* ctx, ASTNode* node);
void codegen_statement(CodeGenContext* ctx, ASTNode* node);
void codegen_expression(CodeGenContext* ctx, ASTNode* node);
void codegen_indent(CodeGenContext* ctx);
char* codegen_type_to_c(TypeInfo* type_info);
int generate_temp_var(CodeGenContext* ctx);
int generate_label(CodeGenContext* ctx);
void add_symbol(CodeGenContext* ctx, const char* name, int dim);
int get_array_dim(CodeGenContext* ctx, const char* name);
void free_symbol_table(CodeGenContext* ctx);
void add_ds_symbol(CodeGenContext* ctx, const char* name, ASTNode* fields, int is_qualified);
ASTNode* get_ds_fields(CodeGenContext* ctx, const char* name);

#endif /* CODEGEN_H */
