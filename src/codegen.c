#include "codegen.h"
#include <string.h>
#include <ctype.h>

/* Helper function to convert RPGLE string (single quotes) to C string (double quotes) */
char* rpgle_string_to_c(const char* rpgle_str) {
    if (!rpgle_str) return NULL;
    
    size_t len = strlen(rpgle_str);
    if (len < 2) return strdup(rpgle_str);
    
    /* Check if it starts and ends with single quotes */
    if (rpgle_str[0] == '\'' && rpgle_str[len-1] == '\'') {
        char* result = (char*)malloc(len + 1);
        result[0] = '"';  /* Replace leading single quote with double quote */
        
        /* Copy middle part, handling escaped single quotes */
        size_t j = 1;
        for (size_t i = 1; i < len - 1; i++) {
            if (rpgle_str[i] == '\'' && i + 1 < len - 1 && rpgle_str[i+1] == '\'') {
                /* Double single quote - keep as single quote in C string */
                result[j++] = '\'';
                i++;  /* Skip the second quote */
            } else if (rpgle_str[i] == '"') {
                /* Escape double quotes for C */
                result[j++] = '\\';
                result[j++] = '"';
            } else {
                result[j++] = rpgle_str[i];
            }
        }
        
        result[j++] = '"';  /* Replace trailing single quote with double quote */
        result[j] = '\0';
        return result;
    }
    
    return strdup(rpgle_str);
}

void codegen_init(CodeGenContext* ctx, FILE* output) {
    ctx->output = output;
    ctx->indent_level = 0;
    ctx->temp_var_counter = 0;
    ctx->label_counter = 0;
    ctx->main_proc_name = NULL;
    ctx->symbol_table = NULL;
    ctx->ds_table = NULL;
}

void add_symbol(CodeGenContext* ctx, const char* name, int dim) {
    SymbolTableEntry* entry = (SymbolTableEntry*)malloc(sizeof(SymbolTableEntry));
    entry->name = strdup(name);
    entry->dim = dim;
    entry->next = ctx->symbol_table;
    ctx->symbol_table = entry;
}

int get_array_dim(CodeGenContext* ctx, const char* name) {
    SymbolTableEntry* entry = ctx->symbol_table;
    while (entry) {
        if (strcmp(entry->name, name) == 0) {
            return entry->dim;
        }
        entry = entry->next;
    }
    return 0;  /* Not found or not an array */
}

void free_symbol_table(CodeGenContext* ctx) {
    SymbolTableEntry* entry = ctx->symbol_table;
    while (entry) {
        SymbolTableEntry* next = entry->next;
        free(entry->name);
        free(entry);
        entry = next;
    }
    ctx->symbol_table = NULL;
}

void add_ds_symbol(CodeGenContext* ctx, const char* name, ASTNode* fields, int is_qualified) {
    DSSymbolEntry* entry = (DSSymbolEntry*)malloc(sizeof(DSSymbolEntry));
    entry->name = strdup(name);
    entry->fields = fields;
    entry->is_qualified = is_qualified;
    entry->next = ctx->ds_table;
    ctx->ds_table = entry;
}

ASTNode* get_ds_fields(CodeGenContext* ctx, const char* name) {
    DSSymbolEntry* entry = ctx->ds_table;
    while (entry) {
        if (strcmp(entry->name, name) == 0) {
            return entry->fields;
        }
        entry = entry->next;
    }
    return NULL;  /* Not found */
}

void codegen_indent(CodeGenContext* ctx) {
    for (int i = 0; i < ctx->indent_level; i++) {
        fprintf(ctx->output, "    ");
    }
}

char* codegen_type_to_c(TypeInfo* type_info) {
    if (!type_info) return "void";
    
    switch (type_info->type) {
        case TYPE_CHAR:
        case TYPE_VARCHAR:
            return "char*";
        case TYPE_INT:
            if (type_info->length <= 3) return "char";
            if (type_info->length <= 5) return "short";
            if (type_info->length <= 10) return "int";
            return "long long";
        case TYPE_UNS:
            if (type_info->length <= 3) return "unsigned char";
            if (type_info->length <= 5) return "unsigned short";
            if (type_info->length <= 10) return "unsigned int";
            return "unsigned long long";
        case TYPE_PACKED:
        case TYPE_ZONED:
        case TYPE_BINDEC:
            return "double";
        case TYPE_IND:
            return "int";
        case TYPE_POINTER:
            return "void*";
        case TYPE_DATE:
            return "char";  /* Will be used as char[11] for YYYY-MM-DD\0 */
        case TYPE_TIME:
            return "char";  /* Will be used as char[9] for HH:MM:SS\0 */
        case TYPE_TIMESTAMP:
            return "char";  /* Will be used as char[27] for full timestamp */
        default:
            return "int";
    }
}

int generate_temp_var(CodeGenContext* ctx) {
    return ctx->temp_var_counter++;
}

int generate_label(CodeGenContext* ctx) {
    return ctx->label_counter++;
}

void codegen_expression(CodeGenContext* ctx, ASTNode* node) {
    if (!node) return;
    
    switch (node->type) {
        case NODE_INTEGER:
            fprintf(ctx->output, "%d", node->data.int_value);
            break;
            
        case NODE_DECIMAL:
            fprintf(ctx->output, "%f", node->data.float_value);
            break;
            
        case NODE_STRING:
            {
                const char* str_val = node->data.string_value;
                /* Check if it's a date/time/timestamp literal */
                if ((str_val[0] == 'd' || str_val[0] == 'D' ||
                     str_val[0] == 't' || str_val[0] == 'T' ||
                     str_val[0] == 'z' || str_val[0] == 'Z') && 
                    strlen(str_val) > 1 && str_val[1] == '\'') {
                    /* Convert d'YYYY-MM-DD' to "YYYY-MM-DD" */
                    char* c_str = rpgle_string_to_c(str_val + 1);
                    fprintf(ctx->output, "%s", c_str);
                    free(c_str);
                } else {
                    char* c_str = rpgle_string_to_c(str_val);
                    fprintf(ctx->output, "%s", c_str);
                    free(c_str);
                }
            }
            break;
            
        case NODE_IDENTIFIER:
            fprintf(ctx->output, "%s", node->data.identifier.name);
            break;
            
        case NODE_ARRAY_SUBSCRIPT:
            /* Check if this is a DS array field access (array_name contains dot) */
            if (strchr(node->data.array_subscript.array_name, '.')) {
                /* Format: ds.field where ds is an array */
                /* Split into array name and field name */
                char* dot_pos = strchr(node->data.array_subscript.array_name, '.');
                int array_name_len = dot_pos - node->data.array_subscript.array_name;
                char* array_name = strndup(node->data.array_subscript.array_name, array_name_len);
                char* field_name = strdup(dot_pos + 1);
                
                /* Generate: arrayname[(index)-1].fieldname */
                fprintf(ctx->output, "%s[(", array_name);
                codegen_expression(ctx, node->data.array_subscript.index);
                fprintf(ctx->output, ")-1].%s", field_name);
                
                free(array_name);
                free(field_name);
            } else {
                /* Regular array subscript - RPGLE uses 1-based indexing, C uses 0-based */
                fprintf(ctx->output, "%s[(", node->data.array_subscript.array_name);
                codegen_expression(ctx, node->data.array_subscript.index);
                fprintf(ctx->output, ")-1]");
            }
            break;
            
        case NODE_BINARY_OP:
            fprintf(ctx->output, "(");
            codegen_expression(ctx, node->data.binary_op.left);
            
            switch (node->data.binary_op.op) {
                case OP_ADD:  fprintf(ctx->output, " + "); break;
                case OP_SUB:  fprintf(ctx->output, " - "); break;
                case OP_MULT: fprintf(ctx->output, " * "); break;
                case OP_DIV:  fprintf(ctx->output, " / "); break;
                case OP_EQ:   fprintf(ctx->output, " == "); break;
                case OP_NE:   fprintf(ctx->output, " != "); break;
                case OP_LT:   fprintf(ctx->output, " < "); break;
                case OP_LE:   fprintf(ctx->output, " <= "); break;
                case OP_GT:   fprintf(ctx->output, " > "); break;
                case OP_GE:   fprintf(ctx->output, " >= "); break;
                case OP_AND:  fprintf(ctx->output, " && "); break;
                case OP_OR:   fprintf(ctx->output, " || "); break;
                default: fprintf(ctx->output, " ? "); break;
            }
            
            codegen_expression(ctx, node->data.binary_op.right);
            fprintf(ctx->output, ")");
            break;
            
        case NODE_UNARY_OP:
            if (node->data.unary_op.op == OP_NOT) {
                fprintf(ctx->output, "!");
            } else if (node->data.unary_op.op == OP_SUB) {
                fprintf(ctx->output, "-");
            }
            fprintf(ctx->output, "(");
            codegen_expression(ctx, node->data.unary_op.operand);
            fprintf(ctx->output, ")");
            break;
            
        case NODE_FUNCTION_CALL: {
            /* Special handling for BIFs that need custom code generation */
            const char* func_name = node->data.function_call.name;
            ASTNode* args = node->data.function_call.arguments;
            
            /* Date/Time BIFs */
            if (strcmp(func_name, "date") == 0) {
                if (args && args->type == NODE_PARAMETER_LIST && args->data.list.count > 0) {
                    codegen_expression(ctx, args->data.list.items[0]);
                } else if (args && args->type != NODE_PARAMETER_LIST) {
                    codegen_expression(ctx, args);
                } else {
                    fprintf(ctx->output, "get_current_date()");
                }
            } else if (strcmp(func_name, "time") == 0) {
                if (args && args->type == NODE_PARAMETER_LIST && args->data.list.count > 0) {
                    codegen_expression(ctx, args->data.list.items[0]);
                } else if (args && args->type != NODE_PARAMETER_LIST) {
                    codegen_expression(ctx, args);
                } else {
                    fprintf(ctx->output, "get_current_time()");
                }
            } else if (strcmp(func_name, "timestamp") == 0) {
                if (args && args->type == NODE_PARAMETER_LIST && args->data.list.count > 0) {
                    codegen_expression(ctx, args->data.list.items[0]);
                } else if (args && args->type != NODE_PARAMETER_LIST) {
                    codegen_expression(ctx, args);
                } else {
                    fprintf(ctx->output, "get_current_timestamp()");
                }
            }
            /* Numeric BIFs */
            else if (strcmp(func_name, "abs") == 0) {
                fprintf(ctx->output, "abs(");
                if (args && args->type == NODE_PARAMETER_LIST && args->data.list.count > 0) {
                    codegen_expression(ctx, args->data.list.items[0]);
                } else if (args && args->type != NODE_PARAMETER_LIST) {
                    codegen_expression(ctx, args);
                }
                fprintf(ctx->output, ")");
            } else if (strcmp(func_name, "float") == 0) {
                fprintf(ctx->output, "(double)(");
                if (args && args->type == NODE_PARAMETER_LIST && args->data.list.count > 0) {
                    codegen_expression(ctx, args->data.list.items[0]);
                } else if (args && args->type != NODE_PARAMETER_LIST) {
                    codegen_expression(ctx, args);
                }
                fprintf(ctx->output, ")");
            } else if (strcmp(func_name, "int") == 0) {
                fprintf(ctx->output, "(int)(");
                if (args && args->type == NODE_PARAMETER_LIST && args->data.list.count > 0) {
                    codegen_expression(ctx, args->data.list.items[0]);
                } else if (args && args->type != NODE_PARAMETER_LIST) {
                    codegen_expression(ctx, args);
                }
                fprintf(ctx->output, ")");
            }
            /* String BIFs - map to runtime functions */
            else if (strcmp(func_name, "trimr") == 0 ||
                     strcmp(func_name, "triml") == 0 ||
                     strcmp(func_name, "trim") == 0 ||
                     strcmp(func_name, "len") == 0 ||
                     strcmp(func_name, "size") == 0 ||
                     strcmp(func_name, "char") == 0 ||
                     strcmp(func_name, "addr") == 0 ||
                     strcmp(func_name, "occur") == 0) {
                /* These BIFs take a single argument */
                if (strcmp(func_name, "char") == 0) {
                    fprintf(ctx->output, "rpgle_char(");
                } else {
                    fprintf(ctx->output, "%s(", func_name);
                }
                if (args && args->type == NODE_PARAMETER_LIST && args->data.list.count > 0) {
                    codegen_expression(ctx, args->data.list.items[0]);
                } else if (args && args->type != NODE_PARAMETER_LIST) {
                    codegen_expression(ctx, args);
                }
                fprintf(ctx->output, ")");
            } else if (strcmp(func_name, "elem") == 0) {
                /* Special handling for %ELEM - look up array dimension */
                int dim = 0;
                if (args && args->type == NODE_PARAMETER_LIST && args->data.list.count > 0) {
                    ASTNode* arg = args->data.list.items[0];
                    if (arg->type == NODE_IDENTIFIER) {
                        dim = get_array_dim(ctx, arg->data.identifier.name);
                    }
                } else if (args && args->type == NODE_IDENTIFIER) {
                    dim = get_array_dim(ctx, args->data.identifier.name);
                }
                fprintf(ctx->output, "%d", dim);  /* Emit dimension as constant */
            } else if (strcmp(func_name, "scan") == 0 ||
                       strcmp(func_name, "replace") == 0 ||
                       strcmp(func_name, "xlate") == 0 ||
                       strcmp(func_name, "subst") == 0 ||
                       strcmp(func_name, "str") == 0 ||
                       strcmp(func_name, "dec") == 0 ||
                       strcmp(func_name, "editc") == 0 ||
                       strcmp(func_name, "editw") == 0) {
                /* These BIFs take multiple arguments via colon separator */
                if (strcmp(func_name, "str") == 0) {
                    fprintf(ctx->output, "str_func(");
                } else {
                    fprintf(ctx->output, "%s(", func_name);
                }
                if (args && args->type == NODE_PARAMETER_LIST) {
                    for (int i = 0; i < args->data.list.count; i++) {
                        if (i > 0) fprintf(ctx->output, ", ");
                        codegen_expression(ctx, args->data.list.items[i]);
                    }
                }
                fprintf(ctx->output, ")");
            }
            /* I/O Status BIFs */
            else if (strcmp(func_name, "found") == 0 ||
                     strcmp(func_name, "equal") == 0 ||
                     strcmp(func_name, "error") == 0 ||
                     strcmp(func_name, "parms") == 0) {
                fprintf(ctx->output, "%s()", func_name);
            } else if (strcmp(func_name, "eof") == 0) {
                /* eof() requires a filename parameter - generate direct EOF flag access */
                if (args && args->type == NODE_PARAMETER_LIST && args->data.list.count > 0) {
                    ASTNode* fileArg = args->data.list.items[0];
                    if (fileArg->type == NODE_IDENTIFIER) {
                        /* Generate direct access to the file-specific EOF flag */
                        fprintf(ctx->output, "_rpgle_eof_%s", fileArg->data.identifier.name);
                    } else {
                        fprintf(ctx->output, "eof(");
                        codegen_expression(ctx, fileArg);
                        fprintf(ctx->output, ")");
                    }
                } else if (args && args->type != NODE_PARAMETER_LIST) {
                    if (args->type == NODE_IDENTIFIER) {
                        fprintf(ctx->output, "_rpgle_eof_%s", args->data.identifier.name);
                    } else {
                        fprintf(ctx->output, "eof(");
                        codegen_expression(ctx, args);
                        fprintf(ctx->output, ")");
                    }
                }
            } else if (strcmp(func_name, "open") == 0) {
                fprintf(ctx->output, "open_func(");
                if (args && args->type == NODE_PARAMETER_LIST && args->data.list.count > 0) {
                    codegen_expression(ctx, args->data.list.items[0]);
                } else if (args && args->type != NODE_PARAMETER_LIST) {
                    codegen_expression(ctx, args);
                }
                fprintf(ctx->output, ")");
            }
            /* Additional String BIFs */
            else if (strcmp(func_name, "scanrpl") == 0 || strcmp(func_name, "check") == 0 ||
                     strcmp(func_name, "checkr") == 0 || strcmp(func_name, "split") == 0) {
                fprintf(ctx->output, "%s(", func_name);
                if (args && args->type == NODE_PARAMETER_LIST) {
                    for (int i = 0; i < args->data.list.count; i++) {
                        if (i > 0) fprintf(ctx->output, ", ");
                        codegen_expression(ctx, args->data.list.items[i]);
                    }
                }
                fprintf(ctx->output, ")");
            }
            /* Additional Numeric BIFs */
            else if (strcmp(func_name, "dech") == 0 || strcmp(func_name, "decpos") == 0 ||
                     strcmp(func_name, "inth") == 0 || strcmp(func_name, "sqrt") == 0 ||
                     strcmp(func_name, "rem") == 0 || strcmp(func_name, "editflt") == 0 ||
                     strcmp(func_name, "uns") == 0 || strcmp(func_name, "unsh") == 0) {
                if (strcmp(func_name, "sqrt") == 0) {
                    fprintf(ctx->output, "sqrt_func(");
                } else {
                    fprintf(ctx->output, "%s(", func_name);
                }
                if (args && args->type == NODE_PARAMETER_LIST) {
                    for (int i = 0; i < args->data.list.count; i++) {
                        if (i > 0) fprintf(ctx->output, ", ");
                        codegen_expression(ctx, args->data.list.items[i]);
                    }
                } else if (args && args->type != NODE_PARAMETER_LIST) {
                    codegen_expression(ctx, args);
                }
                fprintf(ctx->output, ")");
            } else if (strcmp(func_name, "div_func") == 0) {
                fprintf(ctx->output, "div_func(");
                if (args && args->type == NODE_PARAMETER_LIST) {
                    for (int i = 0; i < args->data.list.count; i++) {
                        if (i > 0) fprintf(ctx->output, ", ");
                        codegen_expression(ctx, args->data.list.items[i]);
                    }
                }
                fprintf(ctx->output, ")");
            }
            /* Date/Time extraction BIFs */
            else if (strcmp(func_name, "years") == 0 || strcmp(func_name, "months") == 0 ||
                     strcmp(func_name, "days") == 0 || strcmp(func_name, "hours") == 0 ||
                     strcmp(func_name, "minutes") == 0 || strcmp(func_name, "seconds") == 0 ||
                     strcmp(func_name, "mseconds") == 0) {
                fprintf(ctx->output, "%s(", func_name);
                if (args && args->type == NODE_PARAMETER_LIST && args->data.list.count > 0) {
                    codegen_expression(ctx, args->data.list.items[0]);
                } else if (args && args->type != NODE_PARAMETER_LIST) {
                    codegen_expression(ctx, args);
                }
                fprintf(ctx->output, ")");
            } else if (strcmp(func_name, "diff") == 0 || strcmp(func_name, "subdur") == 0 ||
                       strcmp(func_name, "adddur") == 0) {
                fprintf(ctx->output, "%s(", func_name);
                if (args && args->type == NODE_PARAMETER_LIST) {
                    for (int i = 0; i < args->data.list.count; i++) {
                        if (i > 0) fprintf(ctx->output, ", ");
                        codegen_expression(ctx, args->data.list.items[i]);
                    }
                }
                fprintf(ctx->output, ")");
            }
            /* Array BIFs */
            else if (strcmp(func_name, "lookup") == 0 || strcmp(func_name, "lookuplt") == 0 ||
                     strcmp(func_name, "lookuple") == 0 || strcmp(func_name, "lookupgt") == 0 ||
                     strcmp(func_name, "lookupge") == 0 || strcmp(func_name, "subarr") == 0 ||
                     strcmp(func_name, "sortarr") == 0) {
                fprintf(ctx->output, "%s(", func_name);
                if (args && args->type == NODE_PARAMETER_LIST) {
                    for (int i = 0; i < args->data.list.count; i++) {
                        if (i > 0) fprintf(ctx->output, ", ");
                        codegen_expression(ctx, args->data.list.items[i]);
                    }
                }
                fprintf(ctx->output, ")");
            }
            /* Conversion/Bit BIFs */
            else if (strcmp(func_name, "graph") == 0 || strcmp(func_name, "ucs2") == 0 ||
                     strcmp(func_name, "hex") == 0 || strcmp(func_name, "bitnot") == 0) {
                fprintf(ctx->output, "%s(", func_name);
                if (args && args->type == NODE_PARAMETER_LIST && args->data.list.count > 0) {
                    codegen_expression(ctx, args->data.list.items[0]);
                } else if (args && args->type != NODE_PARAMETER_LIST) {
                    codegen_expression(ctx, args);
                }
                fprintf(ctx->output, ")");
            } else if (strcmp(func_name, "bitand") == 0 || strcmp(func_name, "bitor") == 0 ||
                       strcmp(func_name, "bitxor") == 0) {
                fprintf(ctx->output, "%s(", func_name);
                if (args && args->type == NODE_PARAMETER_LIST) {
                    for (int i = 0; i < args->data.list.count; i++) {
                        if (i > 0) fprintf(ctx->output, ", ");
                        codegen_expression(ctx, args->data.list.items[i]);
                    }
                }
                fprintf(ctx->output, ")");
            }
            /* I/O BIFs */
            else if (strcmp(func_name, "status") == 0 || strcmp(func_name, "record") == 0) {
                fprintf(ctx->output, "%s()", func_name);
            }
            /* Memory/System BIFs */
            else if (strcmp(func_name, "alloc") == 0 || strcmp(func_name, "dealloc") == 0 ||
                     strcmp(func_name, "nullind") == 0 || strcmp(func_name, "fields") == 0 ||
                     strcmp(func_name, "paddr") == 0) {
                fprintf(ctx->output, "%s(", func_name);
                if (args && args->type == NODE_PARAMETER_LIST && args->data.list.count > 0) {
                    codegen_expression(ctx, args->data.list.items[0]);
                } else if (args && args->type != NODE_PARAMETER_LIST) {
                    codegen_expression(ctx, args);
                }
                fprintf(ctx->output, ")");
            } else if (strcmp(func_name, "realloc") == 0) {
                fprintf(ctx->output, "rpgle_realloc(");
                if (args && args->type == NODE_PARAMETER_LIST) {
                    for (int i = 0; i < args->data.list.count; i++) {
                        if (i > 0) fprintf(ctx->output, ", ");
                        codegen_expression(ctx, args->data.list.items[i]);
                    }
                }
                fprintf(ctx->output, ")");
            } else if (strcmp(func_name, "parmnum") == 0 || strcmp(func_name, "omitted") == 0 ||
                       strcmp(func_name, "proc") == 0) {
                fprintf(ctx->output, "%s()", func_name);
            } else if (strcmp(func_name, "parser") == 0 || strcmp(func_name, "dtaara") == 0 ||
                       strcmp(func_name, "list") == 0 || strcmp(func_name, "xml") == 0 ||
                       strcmp(func_name, "data") == 0 || strcmp(func_name, "kds") == 0 ||
                       strcmp(func_name, "range") == 0) {
                fprintf(ctx->output, "%s(", func_name);
                if (args && args->type == NODE_PARAMETER_LIST) {
                    for (int i = 0; i < args->data.list.count; i++) {
                        if (i > 0) fprintf(ctx->output, ", ");
                        codegen_expression(ctx, args->data.list.items[i]);
                    }
                }
                fprintf(ctx->output, ")");
            }
            /* Default: regular function call */
            else {
                fprintf(ctx->output, "%s(", func_name);
                if (args && args->type == NODE_PARAMETER_LIST) {
                    for (int i = 0; i < args->data.list.count; i++) {
                        if (i > 0) fprintf(ctx->output, ", ");
                        codegen_expression(ctx, args->data.list.items[i]);
                    }
                }
                fprintf(ctx->output, ")");
            }
            break;
        }
            
        default:
            break;
    }
}

void codegen_statement(CodeGenContext* ctx, ASTNode* node) {
    if (!node) return;
    
    switch (node->type) {
        case NODE_DCL_S:
        case NODE_DCL_C: {
            /* Check if this is a file declaration (DCL-F) */
            if (node->data.declaration.is_file) {
                /* Already output as global, skip */
                break;
            }
            
            codegen_indent(ctx);
            
            /* Check if it's an array */
            int is_array = (node->data.declaration.type_info->dim > 0);
            
            /* Add to symbol table */
            add_symbol(ctx, node->data.declaration.name, node->data.declaration.type_info->dim);
            
            /* Special handling for CHAR, VARCHAR, and date/time types */
            if (node->data.declaration.type_info->type == TYPE_CHAR ||
                node->data.declaration.type_info->type == TYPE_VARCHAR ||
                node->data.declaration.type_info->type == TYPE_DATE ||
                node->data.declaration.type_info->type == TYPE_TIME ||
                node->data.declaration.type_info->type == TYPE_TIMESTAMP) {
                /* Generate as char array, not char pointer */
                if (is_array) {
                    fprintf(ctx->output, "char %s[%d][%d]", 
                            node->data.declaration.name,
                            node->data.declaration.type_info->dim,
                            node->data.declaration.type_info->length + 1);
                } else {
                    fprintf(ctx->output, "char %s[%d]", 
                            node->data.declaration.name,
                            node->data.declaration.type_info->length + 1);
                }
                
                if (node->data.declaration.initializer) {
                    /* For date/time literals, convert format */
                    if (node->data.declaration.initializer->type == NODE_STRING) {
                        char* str_val = node->data.declaration.initializer->data.string_value;
                        /* Check if it's a date/time/timestamp literal */
                        if ((str_val[0] == 'd' || str_val[0] == 'D' ||
                             str_val[0] == 't' || str_val[0] == 'T' ||
                             str_val[0] == 'z' || str_val[0] == 'Z') && str_val[1] == '\'') {
                            /* Convert d'YYYY-MM-DD' to "YYYY-MM-DD" */
                            char* c_str = rpgle_string_to_c(str_val + 1);
                            fprintf(ctx->output, " = %s", c_str);
                            free(c_str);
                        } else {
                            fprintf(ctx->output, " = ");
                            codegen_expression(ctx, node->data.declaration.initializer);
                        }
                    } else {
                        fprintf(ctx->output, " = ");
                        codegen_expression(ctx, node->data.declaration.initializer);
                    }
                }
            } else {
                char* c_type = codegen_type_to_c(node->data.declaration.type_info);
                
                if (is_array) {
                    fprintf(ctx->output, "%s %s[%d]", 
                            c_type, 
                            node->data.declaration.name,
                            node->data.declaration.type_info->dim);
                } else {
                    fprintf(ctx->output, "%s %s", c_type, node->data.declaration.name);
                }
                
                if (node->data.declaration.initializer) {
                    fprintf(ctx->output, " = ");
                    codegen_expression(ctx, node->data.declaration.initializer);
                }
            }
            
            fprintf(ctx->output, ";\n");
            break;
        }
        
        case NODE_DCL_DS: {
            /* Handle LIKEDS - get fields from base DS */
            ASTNode* fields = node->data.data_structure.fields;
            if (node->data.data_structure.base_ds_name) {
                fields = get_ds_fields(ctx, node->data.data_structure.base_ds_name);
                if (!fields) {
                    fprintf(stderr, "Error: LIKEDS references undefined data structure '%s'\n", 
                            node->data.data_structure.base_ds_name);
                    break;
                }
            }
            
            /* Store DS definition for LIKEDS references */
            if (fields && !node->data.data_structure.base_ds_name) {
                add_ds_symbol(ctx, node->data.data_structure.name, fields, 
                             node->data.data_structure.is_qualified);
            }
            
            if (node->data.data_structure.is_qualified || node->data.data_structure.base_ds_name) {
                /* QUALIFIED or LIKEDS data structure - generate as struct */
                codegen_indent(ctx);
                
                /* Generate struct typedef */
                fprintf(ctx->output, "struct {\n");
                ctx->indent_level++;
                
                /* Generate fields */
                if (fields) {
                    for (int i = 0; i < fields->data.list.count; i++) {
                        ASTNode* field = fields->data.list.items[i];
                        codegen_indent(ctx);
                        
                        /* Generate field declaration */
                        if (field->data.declaration.type_info->type == TYPE_CHAR ||
                            field->data.declaration.type_info->type == TYPE_VARCHAR) {
                            fprintf(ctx->output, "char %s[%d];\n",
                                    field->data.declaration.name,
                                    field->data.declaration.type_info->length + 1);
                        } else if (field->data.declaration.type_info->type == TYPE_DATE) {
                            fprintf(ctx->output, "char %s[11];\n", field->data.declaration.name);
                        } else if (field->data.declaration.type_info->type == TYPE_TIME) {
                            fprintf(ctx->output, "char %s[9];\n", field->data.declaration.name);
                        } else if (field->data.declaration.type_info->type == TYPE_TIMESTAMP) {
                            fprintf(ctx->output, "char %s[27];\n", field->data.declaration.name);
                        } else {
                            char* c_type = codegen_type_to_c(field->data.declaration.type_info);
                            fprintf(ctx->output, "%s %s;\n", c_type, field->data.declaration.name);
                        }
                    }
                }
                
                ctx->indent_level--;
                codegen_indent(ctx);
                
                /* Handle array of DS */
                if (node->data.data_structure.dim > 0) {
                    fprintf(ctx->output, "} %s[%d]", 
                            node->data.data_structure.name, 
                            node->data.data_structure.dim);
                } else {
                    fprintf(ctx->output, "} %s", node->data.data_structure.name);
                }
                
                /* Initialize fields if needed */
                if (fields && node->data.data_structure.dim == 0) {
                    int has_init = 0;
                    for (int i = 0; i < fields->data.list.count; i++) {
                        ASTNode* field = fields->data.list.items[i];
                        if (field->data.declaration.initializer) {
                            has_init = 1;
                            break;
                        }
                    }
                    
                    if (has_init) {
                        fprintf(ctx->output, " = {\n");
                        ctx->indent_level++;
                        for (int i = 0; i < fields->data.list.count; i++) {
                            ASTNode* field = fields->data.list.items[i];
                            codegen_indent(ctx);
                            if (field->data.declaration.initializer) {
                                fprintf(ctx->output, ".");
                                fprintf(ctx->output, "%s = ", field->data.declaration.name);
                                codegen_expression(ctx, field->data.declaration.initializer);
                            } else {
                                fprintf(ctx->output, ".%s = 0", field->data.declaration.name);
                            }
                            if (i < fields->data.list.count - 1) {
                                fprintf(ctx->output, ",");
                            }
                            fprintf(ctx->output, "\n");
                        }
                        ctx->indent_level--;
                        codegen_indent(ctx);
                        fprintf(ctx->output, "}");
                    }
                }
                
                fprintf(ctx->output, ";\n");
            } else {
                /* Non-qualified data structure - generate fields as separate global variables */
                if (fields) {
                    for (int i = 0; i < fields->data.list.count; i++) {
                        ASTNode* field = fields->data.list.items[i];
                        codegen_indent(ctx);
                        
                        /* Generate field as global variable */
                        if (field->data.declaration.type_info->type == TYPE_CHAR ||
                            field->data.declaration.type_info->type == TYPE_VARCHAR) {
                            fprintf(ctx->output, "char %s[%d]",
                                    field->data.declaration.name,
                                    field->data.declaration.type_info->length + 1);
                        } else if (field->data.declaration.type_info->type == TYPE_DATE) {
                            fprintf(ctx->output, "char %s[11]", field->data.declaration.name);
                        } else if (field->data.declaration.type_info->type == TYPE_TIME) {
                            fprintf(ctx->output, "char %s[9]", field->data.declaration.name);
                        } else if (field->data.declaration.type_info->type == TYPE_TIMESTAMP) {
                            fprintf(ctx->output, "char %s[27]", field->data.declaration.name);
                        } else {
                            char* c_type = codegen_type_to_c(field->data.declaration.type_info);
                            fprintf(ctx->output, "%s %s", c_type, field->data.declaration.name);
                        }
                        
                        /* Add initializer if present */
                        if (field->data.declaration.initializer) {
                            fprintf(ctx->output, " = ");
                            codegen_expression(ctx, field->data.declaration.initializer);
                        }
                        
                        fprintf(ctx->output, ";\n");
                    }
                }
            }
            break;
        }
        
        case NODE_EVAL: {
            codegen_indent(ctx);
            /* Check if right side is a string-returning BIF call */
            if (node->data.binary_op.right && 
                node->data.binary_op.right->type == NODE_FUNCTION_CALL) {
                const char* func_name = node->data.binary_op.right->data.function_call.name;
                /* These BIFs return char* and need strcpy for assignment to char arrays */
                if (strcmp(func_name, "date") == 0 ||
                    strcmp(func_name, "time") == 0 ||
                    strcmp(func_name, "timestamp") == 0 ||
                    strcmp(func_name, "trim") == 0 ||
                    strcmp(func_name, "trimr") == 0 ||
                    strcmp(func_name, "triml") == 0 ||
                    strcmp(func_name, "subst") == 0 ||
                    strcmp(func_name, "replace") == 0 ||
                    strcmp(func_name, "xlate") == 0 ||
                    strcmp(func_name, "editc") == 0 ||
                    strcmp(func_name, "editw") == 0 ||
                    strcmp(func_name, "char") == 0 ||
                    strcmp(func_name, "str") == 0 ||
                    strcmp(func_name, "scanrpl") == 0 ||
                    strcmp(func_name, "split") == 0 ||
                    strcmp(func_name, "editflt") == 0 ||
                    strcmp(func_name, "subdur") == 0 ||
                    strcmp(func_name, "adddur") == 0 ||
                    strcmp(func_name, "graph") == 0 ||
                    strcmp(func_name, "ucs2") == 0 ||
                    strcmp(func_name, "hex") == 0 ||
                    strcmp(func_name, "dtaara") == 0 ||
                    strcmp(func_name, "fields") == 0 ||
                    strcmp(func_name, "list") == 0 ||
                    strcmp(func_name, "xml") == 0 ||
                    strcmp(func_name, "data") == 0 ||
                    strcmp(func_name, "proc") == 0) {
                    /* Use strcpy for string assignments */
                    fprintf(ctx->output, "strcpy(");
                    codegen_expression(ctx, node->data.binary_op.left);
                    fprintf(ctx->output, ", ");
                    codegen_expression(ctx, node->data.binary_op.right);
                    fprintf(ctx->output, ")");
                } else {
                    /* Regular assignment */
                    codegen_expression(ctx, node->data.binary_op.left);
                    fprintf(ctx->output, " = ");
                    codegen_expression(ctx, node->data.binary_op.right);
                }
            } else if (node->data.binary_op.right && 
                       node->data.binary_op.right->type == NODE_STRING) {
                /* String literal assignment */
                fprintf(ctx->output, "strcpy(");
                codegen_expression(ctx, node->data.binary_op.left);
                fprintf(ctx->output, ", ");
                codegen_expression(ctx, node->data.binary_op.right);
                fprintf(ctx->output, ")");
            } else {
                codegen_expression(ctx, node->data.binary_op.left);
                fprintf(ctx->output, " = ");
                codegen_expression(ctx, node->data.binary_op.right);
            }
            fprintf(ctx->output, ";\n");
            break;
        }
        
        case NODE_IF: {
            codegen_indent(ctx);
            fprintf(ctx->output, "if (");
            codegen_expression(ctx, node->data.if_stmt.condition);
            fprintf(ctx->output, ") {\n");
            
            ctx->indent_level++;
            if (node->data.if_stmt.then_branch) {
                for (int i = 0; i < node->data.if_stmt.then_branch->data.list.count; i++) {
                    codegen_statement(ctx, node->data.if_stmt.then_branch->data.list.items[i]);
                }
            }
            ctx->indent_level--;
            
            if (node->data.if_stmt.else_branch) {
                codegen_indent(ctx);
                fprintf(ctx->output, "} else {\n");
                ctx->indent_level++;
                
                if (node->data.if_stmt.else_branch->type == NODE_IF) {
                    /* ELSEIF case */
                    codegen_statement(ctx, node->data.if_stmt.else_branch);
                } else {
                    /* ELSE case */
                    for (int i = 0; i < node->data.if_stmt.else_branch->data.list.count; i++) {
                        codegen_statement(ctx, node->data.if_stmt.else_branch->data.list.items[i]);
                    }
                }
                ctx->indent_level--;
            }
            
            codegen_indent(ctx);
            fprintf(ctx->output, "}\n");
            break;
        }
        
        case NODE_FOR: {
            codegen_indent(ctx);
            fprintf(ctx->output, "for (%s = ", node->data.for_loop.var);
            codegen_expression(ctx, node->data.for_loop.start);
            fprintf(ctx->output, "; %s %s ", 
                    node->data.for_loop.var,
                    node->data.for_loop.is_downto ? ">=" : "<=");
            codegen_expression(ctx, node->data.for_loop.end);
            fprintf(ctx->output, "; %s %s ", 
                    node->data.for_loop.var,
                    node->data.for_loop.is_downto ? "-=" : "+=");
            
            if (node->data.for_loop.step) {
                codegen_expression(ctx, node->data.for_loop.step);
            } else {
                fprintf(ctx->output, "1");
            }
            
            fprintf(ctx->output, ") {\n");
            
            ctx->indent_level++;
            if (node->data.for_loop.body) {
                for (int i = 0; i < node->data.for_loop.body->data.list.count; i++) {
                    codegen_statement(ctx, node->data.for_loop.body->data.list.items[i]);
                }
            }
            ctx->indent_level--;
            
            codegen_indent(ctx);
            fprintf(ctx->output, "}\n");
            break;
        }
        
        case NODE_DOW:
        case NODE_DOU: {
            codegen_indent(ctx);
            
            if (node->data.while_loop.is_post_test) {
                /* DOU - do-until */
                fprintf(ctx->output, "do {\n");
                ctx->indent_level++;
                
                if (node->data.while_loop.body) {
                    for (int i = 0; i < node->data.while_loop.body->data.list.count; i++) {
                        codegen_statement(ctx, node->data.while_loop.body->data.list.items[i]);
                    }
                }
                
                ctx->indent_level--;
                codegen_indent(ctx);
                fprintf(ctx->output, "} while (!(");
                codegen_expression(ctx, node->data.while_loop.condition);
                fprintf(ctx->output, "));\n");
            } else {
                /* DOW - do-while */
                fprintf(ctx->output, "while (");
                codegen_expression(ctx, node->data.while_loop.condition);
                fprintf(ctx->output, ") {\n");
                
                ctx->indent_level++;
                if (node->data.while_loop.body) {
                    for (int i = 0; i < node->data.while_loop.body->data.list.count; i++) {
                        codegen_statement(ctx, node->data.while_loop.body->data.list.items[i]);
                    }
                }
                ctx->indent_level--;
                
                codegen_indent(ctx);
                fprintf(ctx->output, "}\n");
            }
            break;
        }
        
        case NODE_SELECT: {
            /* Convert to if-else chain */
            ASTNode* when_list = node->data.select_stmt.when_clauses;
            if (when_list && when_list->data.list.count > 0) {
                for (int i = 0; i < when_list->data.list.count; i++) {
                    ASTNode* when = when_list->data.list.items[i];
                    codegen_indent(ctx);
                    
                    if (i == 0) {
                        fprintf(ctx->output, "if (");
                    } else {
                        fprintf(ctx->output, "} else if (");
                    }
                    
                    codegen_expression(ctx, when->data.when_clause.condition);
                    fprintf(ctx->output, ") {\n");
                    
                    ctx->indent_level++;
                    if (when->data.when_clause.statements) {
                        for (int j = 0; j < when->data.when_clause.statements->data.list.count; j++) {
                            codegen_statement(ctx, when->data.when_clause.statements->data.list.items[j]);
                        }
                    }
                    ctx->indent_level--;
                }
                
                if (node->data.select_stmt.other_clause) {
                    codegen_indent(ctx);
                    fprintf(ctx->output, "} else {\n");
                    ctx->indent_level++;
                    
                    for (int i = 0; i < node->data.select_stmt.other_clause->data.list.count; i++) {
                        codegen_statement(ctx, node->data.select_stmt.other_clause->data.list.items[i]);
                    }
                    
                    ctx->indent_level--;
                }
                
                codegen_indent(ctx);
                fprintf(ctx->output, "}\n");
            }
            break;
        }
        
        case NODE_RETURN: {
            codegen_indent(ctx);
            fprintf(ctx->output, "return");
            if (node->data.return_stmt.value) {
                fprintf(ctx->output, " ");
                codegen_expression(ctx, node->data.return_stmt.value);
            }
            fprintf(ctx->output, ";\n");
            break;
        }
        
        case NODE_CALLP: {
            codegen_indent(ctx);
            fprintf(ctx->output, "%s(", node->data.function_call.name);
            if (node->data.function_call.arguments) {
                ASTNode* args = node->data.function_call.arguments;
                for (int i = 0; i < args->data.list.count; i++) {
                    if (i > 0) fprintf(ctx->output, ", ");
                    codegen_expression(ctx, args->data.list.items[i]);
                }
            }
            fprintf(ctx->output, ");\n");
            break;
        }
        
        case NODE_DSPLY: {
            codegen_indent(ctx);
            
            /* For DSPLY, we output the value directly */
            if (node->data.dsply.message) {
                ASTNode* msg = node->data.dsply.message;
                
                if (msg->type == NODE_STRING) {
                    /* String literal */
                    char* c_str = rpgle_string_to_c(msg->data.string_value);
                    fprintf(ctx->output, "printf(\"%%s\\n\", %s);\n", c_str);
                    free(c_str);
                } else if (msg->type == NODE_INTEGER) {
                    /* Integer constant */
                    fprintf(ctx->output, "printf(\"%%d\\n\", %d);\n", msg->data.int_value);
                } else if (msg->type == NODE_DECIMAL) {
                    /* Decimal constant */
                    fprintf(ctx->output, "printf(\"%%f\\n\", %f);\n", msg->data.float_value);
                } else if (msg->type == NODE_IDENTIFIER) {
                    /* Try to determine if it's a string or number using _Generic */
                    fprintf(ctx->output, "printf(_Generic((%s),\n", msg->data.identifier.name);
                    fprintf(ctx->output, "        char*: \"%%s\\n\",\n");
                    fprintf(ctx->output, "        int: \"%%d\\n\",\n");
                    fprintf(ctx->output, "        double: \"%%f\\n\",\n");
                    fprintf(ctx->output, "        default: \"%%p\\n\"\n");
                    fprintf(ctx->output, "    ), %s);\n", msg->data.identifier.name);
                } else {
                    /* For complex expressions, evaluate and print as int */
                    fprintf(ctx->output, "printf(\"%%d\\n\", ");
                    codegen_expression(ctx, msg);
                    fprintf(ctx->output, ");\n");
                }
            } else {
                fprintf(ctx->output, "printf(\"\\n\");\n");
            }
            break;
        }
        
        case NODE_ITER: {
            codegen_indent(ctx);
            fprintf(ctx->output, "continue;\n");
            break;
        }
        
        case NODE_LEAVE: {
            codegen_indent(ctx);
            fprintf(ctx->output, "break;\n");
            break;
        }
        
        case NODE_OPEN: {
            codegen_indent(ctx);
            const char* file_var = node->data.file_io.file_name;
            fprintf(ctx->output, "%s = fopen(\"%s.txt\", \"r+\");\n", file_var, file_var);
            fprintf(ctx->output, "    if (!%s) %s = fopen(\"%s.txt\", \"w+\");\n", 
                    file_var, file_var, file_var);
            break;
        }
        
        case NODE_CLOSE: {
            codegen_indent(ctx);
            const char* file_var = node->data.file_io.file_name;
            fprintf(ctx->output, "if (%s) { fclose(%s); %s = NULL; }\n", 
                    file_var, file_var, file_var);
            break;
        }
        
        case NODE_READ: {
            codegen_indent(ctx);
            const char* file_var = node->data.file_io.file_name;
            const char* record_var = node->data.file_io.record_var;
            
            if (record_var) {
                /* Try to get DS fields for formatted input */
                ASTNode* fields = get_ds_fields(ctx, record_var);
                
                fprintf(ctx->output, "{ char _rpgle_buffer[4096]; \n");
                fprintf(ctx->output, "    if (%s && fgets(_rpgle_buffer, sizeof(_rpgle_buffer), %s)) {\n",
                        file_var, file_var);
                fprintf(ctx->output, "        _rpgle_buffer[strcspn(_rpgle_buffer, \"\\n\")] = 0;\n");
                
                if (fields && (fields->type == NODE_FIELD_LIST || fields->type == NODE_STATEMENT_LIST)) {
                    /* Parse colon-delimited fields */
                    fprintf(ctx->output, "        /* Parse colon-delimited fields */\n");
                    fprintf(ctx->output, "        char* _token = strtok(_rpgle_buffer, \":\");\n");
                    
                    for (int i = 0; i < fields->data.list.count; i++) {
                        ASTNode* field = fields->data.list.items[i];
                        const char* field_name = field->data.declaration.name;
                        int field_type = field->data.declaration.type_info->type;
                        
                        fprintf(ctx->output, "        if (_token) {\n");
                        
                        if (field_type == TYPE_CHAR || field_type == TYPE_VARCHAR) {
                            fprintf(ctx->output, "            strncpy(%s.%s, _token, sizeof(%s.%s) - 1);\n",
                                    record_var, field_name, record_var, field_name);
                            fprintf(ctx->output, "            %s.%s[sizeof(%s.%s) - 1] = 0;\n",
                                    record_var, field_name, record_var, field_name);
                        } else if (field_type == TYPE_INT) {
                            fprintf(ctx->output, "            %s.%s = atoi(_token);\n",
                                    record_var, field_name);
                        } else if (field_type == TYPE_PACKED || field_type == TYPE_ZONED) {
                            fprintf(ctx->output, "            %s.%s = atof(_token);\n",
                                    record_var, field_name);
                        } else {
                            /* Default: treat as integer */
                            fprintf(ctx->output, "            %s.%s = atoi(_token);\n",
                                    record_var, field_name);
                        }
                        
                        fprintf(ctx->output, "            _token = strtok(NULL, \":\");\n");
                        fprintf(ctx->output, "        }\n");
                    }
                } else {
                    /* Fallback: read as byte values */
                    fprintf(ctx->output, "        unsigned char* _p = (unsigned char*)&%s;\n", record_var);
                    fprintf(ctx->output, "        int _sz = sizeof(%s);\n", record_var);
                    fprintf(ctx->output, "        char* _token = strtok(_rpgle_buffer, \".:, \");\n");
                    fprintf(ctx->output, "        int _idx = 0;\n");
                    fprintf(ctx->output, "        while (_token && _idx < _sz) {\n");
                    fprintf(ctx->output, "            _p[_idx++] = (unsigned char)atoi(_token);\n");
                    fprintf(ctx->output, "            _token = strtok(NULL, \".:, \");\n");
                    fprintf(ctx->output, "        }\n");
                }
                
                fprintf(ctx->output, "        _rpgle_eof_%s = 0;\n", file_var);
                fprintf(ctx->output, "    } else {\n");
                fprintf(ctx->output, "        _rpgle_eof_%s = 1;\n", file_var);
                fprintf(ctx->output, "    }\n");
                fprintf(ctx->output, "}\n");
            } else {
                /* Just advance file pointer */
                fprintf(ctx->output, "{ char _line[1024]; if (%s) fgets(_line, sizeof(_line), %s); }\n",
                        file_var, file_var);
            }
            break;
        }
        
        case NODE_WRITE: {
            codegen_indent(ctx);
            const char* file_var = node->data.file_io.file_name;
            const char* record_var = node->data.file_io.record_var;
            
            if (record_var) {
                /* Try to get DS fields for formatted output */
                ASTNode* fields = get_ds_fields(ctx, record_var);
                
                fprintf(ctx->output, "if (%s) {\n", file_var);
                
                if (fields && (fields->type == NODE_FIELD_LIST || fields->type == NODE_STATEMENT_LIST)) {
                    /* Write each field separated by colons */
                    fprintf(ctx->output, "        /* Write fields as colon-delimited values */\n");
                    for (int i = 0; i < fields->data.list.count; i++) {
                        ASTNode* field = fields->data.list.items[i];
                        if (i > 0) {
                            fprintf(ctx->output, "        fputc(':', %s);\n", file_var);
                        }
                        
                        const char* field_name = field->data.declaration.name;
                        int field_type = field->data.declaration.type_info->type;
                        
                        if (field_type == TYPE_CHAR || field_type == TYPE_VARCHAR) {
                            fprintf(ctx->output, "        fprintf(%s, \"%%s\", %s.%s);\n",
                                    file_var, record_var, field_name);
                        } else if (field_type == TYPE_INT) {
                            fprintf(ctx->output, "        fprintf(%s, \"%%d\", %s.%s);\n",
                                    file_var, record_var, field_name);
                        } else if (field_type == TYPE_PACKED || field_type == TYPE_ZONED) {
                            fprintf(ctx->output, "        fprintf(%s, \"%%.2f\", %s.%s);\n",
                                    file_var, record_var, field_name);
                        } else {
                            /* Default: treat as integer */
                            fprintf(ctx->output, "        fprintf(%s, \"%%d\", %s.%s);\n",
                                    file_var, record_var, field_name);
                        }
                    }
                } else {
                    /* Fallback: write as byte values if no DS fields found */
                    fprintf(ctx->output, "        unsigned char* _p = (unsigned char*)&%s;\n", record_var);
                    fprintf(ctx->output, "        int _sz = sizeof(%s);\n", record_var);
                    fprintf(ctx->output, "        for (int _i = 0; _i < _sz; _i += 4) {\n");
                    fprintf(ctx->output, "            if (_i > 0) fputc(':', %s);\n", file_var);
                    fprintf(ctx->output, "            int _end = (_i + 4 < _sz) ? _i + 4 : _sz;\n");
                    fprintf(ctx->output, "            for (int _j = _i; _j < _end; _j++) {\n");
                    fprintf(ctx->output, "                if (_j > _i) fputc('.', %s);\n", file_var);
                    fprintf(ctx->output, "                fprintf(%s, \"%%d\", _p[_j]);\n", file_var);
                    fprintf(ctx->output, "            }\n");
                    fprintf(ctx->output, "        }\n");
                }
                
                fprintf(ctx->output, "        fputc('\\n', %s);\n", file_var);
                fprintf(ctx->output, "    }\n");
            } else {
                fprintf(ctx->output, "if (%s) fprintf(%s, \"\\n\");\n",
                        file_var, file_var);
            }
            break;
        }
        
        case NODE_CHAIN: {
            codegen_indent(ctx);
            const char* file_var = node->data.file_io.file_name;
            const char* record_var = node->data.file_io.record_var;
            
            /* CHAIN is a keyed read - simplified implementation */
            fprintf(ctx->output, "/* CHAIN to %s with key ", file_var);
            codegen_expression(ctx, node->data.file_io.key);
            fprintf(ctx->output, " */\n");
            
            codegen_indent(ctx);
            fprintf(ctx->output, "if (%s) {\n", file_var);
            fprintf(ctx->output, "        rewind(%s);\n", file_var);
            if (record_var) {
                fprintf(ctx->output, "        while (fgets(%s, sizeof(%s), %s)) {\n",
                        record_var, record_var, file_var);
                fprintf(ctx->output, "            %s[strcspn(%s, \"\\n\")] = 0;\n",
                        record_var, record_var);
                fprintf(ctx->output, "            break;\n");
                fprintf(ctx->output, "        }\n");
            }
            fprintf(ctx->output, "    }\n");
            break;
        }
        
        case NODE_DCL_PROC: {
            /* Check if this is the Main procedure */
            const char* proc_name = node->data.procedure.name;
            if (strcasecmp(proc_name, "main") == 0) {
                /* Rename to avoid conflict with C main() */
                ctx->main_proc_name = strdup("rpgle_Main");
                proc_name = "rpgle_Main";
            }
            
            codegen_indent(ctx);
            char* ret_type = codegen_type_to_c(node->data.procedure.return_type);
            fprintf(ctx->output, "%s %s(", ret_type, proc_name);
            
            /* Parameters */
            if (node->data.procedure.parameters && 
                node->data.procedure.parameters->data.list.count > 0) {
                ASTNode* params = node->data.procedure.parameters;
                for (int i = 0; i < params->data.list.count; i++) {
                    if (i > 0) fprintf(ctx->output, ", ");
                    ASTNode* param = params->data.list.items[i];
                    char* param_type = codegen_type_to_c(param->data.declaration.type_info);
                    fprintf(ctx->output, "%s %s", param_type, param->data.declaration.name);
                }
            } else {
                fprintf(ctx->output, "void");
            }
            
            fprintf(ctx->output, ") {\n");
            
            ctx->indent_level++;
            if (node->data.procedure.body) {
                for (int i = 0; i < node->data.procedure.body->data.list.count; i++) {
                    codegen_statement(ctx, node->data.procedure.body->data.list.items[i]);
                }
            }
            ctx->indent_level--;
            
            codegen_indent(ctx);
            fprintf(ctx->output, "}\n\n");
            break;
        }
        
        case NODE_STATEMENT_LIST: {
            for (int i = 0; i < node->data.list.count; i++) {
                codegen_statement(ctx, node->data.list.items[i]);
            }
            break;
        }
        
        default:
            break;
    }
}

/* Helper function to recursively find and output all DCL-F declarations */
static void output_file_declarations_recursive(FILE* output, ASTNode* n) {
    if (!n) return;
    if ((n->type == NODE_DCL_S || n->type == NODE_DCL_C) && n->data.declaration.is_file) {
        fprintf(output, "FILE* %s = NULL;\n", n->data.declaration.name);
        fprintf(output, "int _rpgle_eof_%s = 0;\n", n->data.declaration.name);
    } else if (n->type == NODE_STATEMENT_LIST || n->type == NODE_PROGRAM) {
        for (int j = 0; j < n->data.list.count; j++) {
            output_file_declarations_recursive(output, n->data.list.items[j]);
        }
    } else if (n->type == NODE_DCL_PROC && n->data.procedure.body) {
        output_file_declarations_recursive(output, n->data.procedure.body);
    }
}

void codegen_program(CodeGenContext* ctx, ASTNode* node) {
    if (!node) return;
    
    /* Generate standard C headers */
    fprintf(ctx->output, "/* Generated by RPGLE Compiler */\n");
    fprintf(ctx->output, "#include <stdio.h>\n");
    fprintf(ctx->output, "#include <stdlib.h>\n");
    fprintf(ctx->output, "#include <string.h>\n");
    fprintf(ctx->output, "#include <math.h>\n");
    fprintf(ctx->output, "#include <time.h>\n\n");
    
    /* Generate RPGLE runtime helper functions */
    fprintf(ctx->output, "/* RPGLE Runtime Functions */\n");
    
    /* String functions */
    fprintf(ctx->output, "char* trim(char* str) {\n");
    fprintf(ctx->output, "    char* end;\n");
    fprintf(ctx->output, "    while(*str == ' ') str++;\n");
    fprintf(ctx->output, "    if(*str == 0) return str;\n");
    fprintf(ctx->output, "    end = str + strlen(str) - 1;\n");
    fprintf(ctx->output, "    while(end > str && *end == ' ') end--;\n");
    fprintf(ctx->output, "    *(end+1) = 0;\n");
    fprintf(ctx->output, "    return str;\n");
    fprintf(ctx->output, "}\n\n");
    
    fprintf(ctx->output, "char* trimr(char* str) {\n");
    fprintf(ctx->output, "    char* end = str + strlen(str) - 1;\n");
    fprintf(ctx->output, "    while(end > str && *end == ' ') end--;\n");
    fprintf(ctx->output, "    *(end+1) = 0;\n");
    fprintf(ctx->output, "    return str;\n");
    fprintf(ctx->output, "}\n\n");
    
    fprintf(ctx->output, "char* triml(char* str) {\n");
    fprintf(ctx->output, "    while(*str == ' ') str++;\n");
    fprintf(ctx->output, "    return str;\n");
    fprintf(ctx->output, "}\n\n");
    
    fprintf(ctx->output, "int scan(char* search, char* str, int start) {\n");
    fprintf(ctx->output, "    if (start < 1) start = 1;\n");
    fprintf(ctx->output, "    char* found = strstr(str + start - 1, search);\n");
    fprintf(ctx->output, "    if (found) return (found - str) + 1;\n");
    fprintf(ctx->output, "    return 0;\n");
    fprintf(ctx->output, "}\n\n");
    
    fprintf(ctx->output, "char* subst(char* str, int start, int len) {\n");
    fprintf(ctx->output, "    static char result[1024];\n");
    fprintf(ctx->output, "    if (start < 1) start = 1;\n");
    fprintf(ctx->output, "    int slen = strlen(str);\n");
    fprintf(ctx->output, "    if (start > slen) return \"\";\n");
    fprintf(ctx->output, "    if (len > slen - start + 1) len = slen - start + 1;\n");
    fprintf(ctx->output, "    strncpy(result, str + start - 1, len);\n");
    fprintf(ctx->output, "    result[len] = 0;\n");
    fprintf(ctx->output, "    return result;\n");
    fprintf(ctx->output, "}\n\n");
    
    fprintf(ctx->output, "char* replace(char* repl, char* src, int start, int len) {\n");
    fprintf(ctx->output, "    static char result[1024];\n");
    fprintf(ctx->output, "    if (start < 1) start = 1;\n");
    fprintf(ctx->output, "    strncpy(result, src, start - 1);\n");
    fprintf(ctx->output, "    result[start - 1] = 0;\n");
    fprintf(ctx->output, "    strcat(result, repl);\n");
    fprintf(ctx->output, "    if (start + len - 1 < strlen(src)) {\n");
    fprintf(ctx->output, "        strcat(result, src + start + len - 1);\n");
    fprintf(ctx->output, "    }\n");
    fprintf(ctx->output, "    return result;\n");
    fprintf(ctx->output, "}\n\n");
    
    fprintf(ctx->output, "char* xlate(char* from, char* to, char* str, int start) {\n");
    fprintf(ctx->output, "    static char result[1024];\n");
    fprintf(ctx->output, "    if (start < 1) start = 1;\n");
    fprintf(ctx->output, "    strcpy(result, str);\n");
    fprintf(ctx->output, "    for (int i = start - 1; result[i]; i++) {\n");
    fprintf(ctx->output, "        char* pos = strchr(from, result[i]);\n");
    fprintf(ctx->output, "        if (pos) result[i] = to[pos - from];\n");
    fprintf(ctx->output, "    }\n");
    fprintf(ctx->output, "    return result;\n");
    fprintf(ctx->output, "}\n\n");
    
    fprintf(ctx->output, "char* editc(double num, char* code, char* currency) {\n");
    fprintf(ctx->output, "    static char result[256];\n");
    fprintf(ctx->output, "    sprintf(result, \"%%.2f\", num);\n");
    fprintf(ctx->output, "    return result;\n");
    fprintf(ctx->output, "}\n\n");
    
    fprintf(ctx->output, "char* editw(double num, char* editword) {\n");
    fprintf(ctx->output, "    static char result[256];\n");
    fprintf(ctx->output, "    sprintf(result, \"%%.2f\", num);\n");
    fprintf(ctx->output, "    return result;\n");
    fprintf(ctx->output, "}\n\n");
    
    fprintf(ctx->output, "double dec(double num, int digits, int decimals) {\n");
    fprintf(ctx->output, "    return num;\n");
    fprintf(ctx->output, "}\n\n");
    
    fprintf(ctx->output, "char* rpgle_char(int num) {\n");
    fprintf(ctx->output, "    static char result[32];\n");
    fprintf(ctx->output, "    sprintf(result, \"%%d\", num);\n");
    fprintf(ctx->output, "    return result;\n");
    fprintf(ctx->output, "}\n\n");
    
    fprintf(ctx->output, "char* str_func(void* ptr, int len) {\n");
    fprintf(ctx->output, "    static char result[1024];\n");
    fprintf(ctx->output, "    if (len > 0) {\n");
    fprintf(ctx->output, "        strncpy(result, (char*)ptr, len);\n");
    fprintf(ctx->output, "        result[len] = 0;\n");
    fprintf(ctx->output, "    } else {\n");
    fprintf(ctx->output, "        strcpy(result, (char*)ptr);\n");
    fprintf(ctx->output, "    }\n");
    fprintf(ctx->output, "    return result;\n");
    fprintf(ctx->output, "}\n\n");
    
    fprintf(ctx->output, "int len(char* str) {\n");
    fprintf(ctx->output, "    return strlen(str);\n");
    fprintf(ctx->output, "}\n\n");
    
    /* I/O status indicators */
    fprintf(ctx->output, "int _rpgle_found = 0;\n");
    fprintf(ctx->output, "int _rpgle_equal = 0;\n");
    fprintf(ctx->output, "int _rpgle_error = 0;\n");
    fprintf(ctx->output, "int _rpgle_open = 0;\n\n");
    
    fprintf(ctx->output, "int found(void) { return _rpgle_found; }\n");
    fprintf(ctx->output, "int error(void) { return _rpgle_error; }\n");
    fprintf(ctx->output, "int open_func(char* file) { return _rpgle_open; }\n\n");
    
    /* EOF function - returns file-specific EOF flag */
    fprintf(ctx->output, "int eof(char* filename) {\n");
    fprintf(ctx->output, "    /* File-specific EOF flags are declared with file variables */\n");
    fprintf(ctx->output, "    /* This function is handled specially in code generation */\n");
    fprintf(ctx->output, "    return 0;\n");
    fprintf(ctx->output, "}\n\n");
    
    fprintf(ctx->output, "void* addr(void* var) { return var; }\n");
    fprintf(ctx->output, "int elem(void* arr) { return 1; }\n");
    fprintf(ctx->output, "int parms(void) { return 0; }\n");
    fprintf(ctx->output, "int occur(void* ds) { return 1; }\n\n");
    
    /* Date/Time functions */
    fprintf(ctx->output, "char* get_current_date(void) {\n");
    fprintf(ctx->output, "    static char date_buf[11];\n");
    fprintf(ctx->output, "    time_t now = time(NULL);\n");
    fprintf(ctx->output, "    struct tm* t = localtime(&now);\n");
    fprintf(ctx->output, "    strftime(date_buf, sizeof(date_buf), \"%%Y-%%m-%%d\", t);\n");
    fprintf(ctx->output, "    return date_buf;\n");
    fprintf(ctx->output, "}\n\n");
    
    fprintf(ctx->output, "char* get_current_time(void) {\n");
    fprintf(ctx->output, "    static char time_buf[9];\n");
    fprintf(ctx->output, "    time_t now = time(NULL);\n");
    fprintf(ctx->output, "    struct tm* t = localtime(&now);\n");
    fprintf(ctx->output, "    strftime(time_buf, sizeof(time_buf), \"%%H:%%M:%%S\", t);\n");
    fprintf(ctx->output, "    return time_buf;\n");
    fprintf(ctx->output, "}\n\n");
    
    fprintf(ctx->output, "char* get_current_timestamp(void) {\n");
    fprintf(ctx->output, "    static char timestamp_buf[27];\n");
    fprintf(ctx->output, "    time_t now = time(NULL);\n");
    fprintf(ctx->output, "    struct tm* t = localtime(&now);\n");
    fprintf(ctx->output, "    strftime(timestamp_buf, sizeof(timestamp_buf), \"%%Y-%%m-%%d-%%H.%%M.%%S.000000\", t);\n");
    fprintf(ctx->output, "    return timestamp_buf;\n");
    fprintf(ctx->output, "}\n\n");
    
    /* Additional String BIFs */
    fprintf(ctx->output, "char* scanrpl(char* search, char* repl, char* src, int start) {\n");
    fprintf(ctx->output, "    static char result[1024];\n");
    fprintf(ctx->output, "    strcpy(result, src);\n");
    fprintf(ctx->output, "    char* found = strstr(result + start - 1, search);\n");
    fprintf(ctx->output, "    if (found) {\n");
    fprintf(ctx->output, "        int pos = found - result;\n");
    fprintf(ctx->output, "        strcpy(result + pos, repl);\n");
    fprintf(ctx->output, "        strcat(result, src + pos + strlen(search));\n");
    fprintf(ctx->output, "    }\n");
    fprintf(ctx->output, "    return result;\n");
    fprintf(ctx->output, "}\n\n");
    
    fprintf(ctx->output, "int check(char* cmp, char* base, int start) {\n");
    fprintf(ctx->output, "    if (start < 1) start = 1;\n");
    fprintf(ctx->output, "    for (int i = start - 1; base[i]; i++) {\n");
    fprintf(ctx->output, "        if (!strchr(cmp, base[i])) return i + 1;\n");
    fprintf(ctx->output, "    }\n");
    fprintf(ctx->output, "    return 0;\n");
    fprintf(ctx->output, "}\n\n");
    
    fprintf(ctx->output, "int checkr(char* cmp, char* base, int start) {\n");
    fprintf(ctx->output, "    int len = strlen(base);\n");
    fprintf(ctx->output, "    if (start < 1) start = len;\n");
    fprintf(ctx->output, "    for (int i = start - 1; i >= 0; i--) {\n");
    fprintf(ctx->output, "        if (!strchr(cmp, base[i])) return i + 1;\n");
    fprintf(ctx->output, "    }\n");
    fprintf(ctx->output, "    return 0;\n");
    fprintf(ctx->output, "}\n\n");
    
    fprintf(ctx->output, "char* split(char* str, char* sep) {\n");
    fprintf(ctx->output, "    static char result[1024];\n");
    fprintf(ctx->output, "    char* token = strtok(str, sep);\n");
    fprintf(ctx->output, "    if (token) strcpy(result, token);\n");
    fprintf(ctx->output, "    else result[0] = 0;\n");
    fprintf(ctx->output, "    return result;\n");
    fprintf(ctx->output, "}\n\n");
    
    /* Additional Numeric BIFs */
    fprintf(ctx->output, "double dech(double num, int digits, int decimals) {\n");
    fprintf(ctx->output, "    return num;\n");
    fprintf(ctx->output, "}\n\n");
    
    fprintf(ctx->output, "int decpos(double num) {\n");
    fprintf(ctx->output, "    char str[64];\n");
    fprintf(ctx->output, "    sprintf(str, \"%%f\", num);\n");
    fprintf(ctx->output, "    char* dot = strchr(str, '.');\n");
    fprintf(ctx->output, "    if (!dot) return 0;\n");
    fprintf(ctx->output, "    int pos = strlen(dot) - 1;\n");
    fprintf(ctx->output, "    while (pos > 0 && dot[pos] == '0') pos--;\n");
    fprintf(ctx->output, "    return pos;\n");
    fprintf(ctx->output, "}\n\n");
    
    fprintf(ctx->output, "int inth(int num) {\n");
    fprintf(ctx->output, "    return num;\n");
    fprintf(ctx->output, "}\n\n");
    
    fprintf(ctx->output, "double sqrt_func(double num) {\n");
    fprintf(ctx->output, "    return sqrt(num);\n");
    fprintf(ctx->output, "}\n\n");
    
    fprintf(ctx->output, "int rem(int dividend, int divisor) {\n");
    fprintf(ctx->output, "    return dividend %% divisor;\n");
    fprintf(ctx->output, "}\n\n");
    
    fprintf(ctx->output, "int div_func(int dividend, int divisor) {\n");
    fprintf(ctx->output, "    return dividend / divisor;\n");
    fprintf(ctx->output, "}\n\n");
    
    fprintf(ctx->output, "char* editflt(double num) {\n");
    fprintf(ctx->output, "    static char result[64];\n");
    fprintf(ctx->output, "    sprintf(result, \"%%e\", num);\n");
    fprintf(ctx->output, "    return result;\n");
    fprintf(ctx->output, "}\n\n");
    
    fprintf(ctx->output, "unsigned int uns(int num) {\n");
    fprintf(ctx->output, "    return (unsigned int)num;\n");
    fprintf(ctx->output, "}\n\n");
    
    fprintf(ctx->output, "unsigned short unsh(int num) {\n");
    fprintf(ctx->output, "    return (unsigned short)num;\n");
    fprintf(ctx->output, "}\n\n");
    
    /* Date/Time extraction BIFs */
    fprintf(ctx->output, "int years(char* date) {\n");
    fprintf(ctx->output, "    int y, m, d;\n");
    fprintf(ctx->output, "    sscanf(date, \"%%d-%%d-%%d\", &y, &m, &d);\n");
    fprintf(ctx->output, "    return y;\n");
    fprintf(ctx->output, "}\n\n");
    
    fprintf(ctx->output, "int months(char* date) {\n");
    fprintf(ctx->output, "    int y, m, d;\n");
    fprintf(ctx->output, "    sscanf(date, \"%%d-%%d-%%d\", &y, &m, &d);\n");
    fprintf(ctx->output, "    return m;\n");
    fprintf(ctx->output, "}\n\n");
    
    fprintf(ctx->output, "int days(char* date) {\n");
    fprintf(ctx->output, "    int y, m, d;\n");
    fprintf(ctx->output, "    sscanf(date, \"%%d-%%d-%%d\", &y, &m, &d);\n");
    fprintf(ctx->output, "    return d;\n");
    fprintf(ctx->output, "}\n\n");
    
    fprintf(ctx->output, "int hours(char* time) {\n");
    fprintf(ctx->output, "    int h, m, s;\n");
    fprintf(ctx->output, "    sscanf(time, \"%%d:%%d:%%d\", &h, &m, &s);\n");
    fprintf(ctx->output, "    return h;\n");
    fprintf(ctx->output, "}\n\n");
    
    fprintf(ctx->output, "int minutes(char* time) {\n");
    fprintf(ctx->output, "    int h, m, s;\n");
    fprintf(ctx->output, "    sscanf(time, \"%%d:%%d:%%d\", &h, &m, &s);\n");
    fprintf(ctx->output, "    return m;\n");
    fprintf(ctx->output, "}\n\n");
    
    fprintf(ctx->output, "int seconds(char* time) {\n");
    fprintf(ctx->output, "    int h, m, s;\n");
    fprintf(ctx->output, "    sscanf(time, \"%%d:%%d:%%d\", &h, &m, &s);\n");
    fprintf(ctx->output, "    return s;\n");
    fprintf(ctx->output, "}\n\n");
    
    fprintf(ctx->output, "int mseconds(char* timestamp) {\n");
    fprintf(ctx->output, "    return 0; /* Placeholder */\n");
    fprintf(ctx->output, "}\n\n");
    
    fprintf(ctx->output, "int diff(char* date1, char* date2, int durcode) {\n");
    fprintf(ctx->output, "    return 0; /* Placeholder - needs date math */\n");
    fprintf(ctx->output, "}\n\n");
    
    fprintf(ctx->output, "char* subdur(char* date, int duration, int durcode) {\n");
    fprintf(ctx->output, "    static char result[27];\n");
    fprintf(ctx->output, "    strcpy(result, date);\n");
    fprintf(ctx->output, "    return result; /* Placeholder */\n");
    fprintf(ctx->output, "}\n\n");
    
    fprintf(ctx->output, "char* adddur(char* date, int duration, int durcode) {\n");
    fprintf(ctx->output, "    static char result[27];\n");
    fprintf(ctx->output, "    strcpy(result, date);\n");
    fprintf(ctx->output, "    return result; /* Placeholder */\n");
    fprintf(ctx->output, "}\n\n");
    
    /* Array BIFs */
    fprintf(ctx->output, "int lookup(void* search, void* arr, int start, int elems) {\n");
    fprintf(ctx->output, "    return 0; /* Placeholder - requires array support */\n");
    fprintf(ctx->output, "}\n\n");
    
    fprintf(ctx->output, "int lookuplt(void* search, void* arr, int start, int elems) {\n");
    fprintf(ctx->output, "    return 0; /* Placeholder */\n");
    fprintf(ctx->output, "}\n\n");
    
    fprintf(ctx->output, "int lookuple(void* search, void* arr, int start, int elems) {\n");
    fprintf(ctx->output, "    return 0; /* Placeholder */\n");
    fprintf(ctx->output, "}\n\n");
    
    fprintf(ctx->output, "int lookupgt(void* search, void* arr, int start, int elems) {\n");
    fprintf(ctx->output, "    return 0; /* Placeholder */\n");
    fprintf(ctx->output, "}\n\n");
    
    fprintf(ctx->output, "int lookupge(void* search, void* arr, int start, int elems) {\n");
    fprintf(ctx->output, "    return 0; /* Placeholder */\n");
    fprintf(ctx->output, "}\n\n");
    
    fprintf(ctx->output, "void* subarr(void* arr, int start, int count) {\n");
    fprintf(ctx->output, "    return NULL; /* Placeholder */\n");
    fprintf(ctx->output, "}\n\n");
    
    fprintf(ctx->output, "void sortarr(void* arr, int start, int count) {\n");
    fprintf(ctx->output, "    /* Placeholder - requires array support */\n");
    fprintf(ctx->output, "}\n\n");
    
    /* Conversion/Bit BIFs */
    fprintf(ctx->output, "char* graph(char* str) {\n");
    fprintf(ctx->output, "    static char result[1024];\n");
    fprintf(ctx->output, "    strcpy(result, str);\n");
    fprintf(ctx->output, "    return result; /* Placeholder */\n");
    fprintf(ctx->output, "}\n\n");
    
    fprintf(ctx->output, "char* ucs2(char* str) {\n");
    fprintf(ctx->output, "    static char result[2048];\n");
    fprintf(ctx->output, "    strcpy(result, str);\n");
    fprintf(ctx->output, "    return result; /* Placeholder */\n");
    fprintf(ctx->output, "}\n\n");
    
    fprintf(ctx->output, "char* hex(void* data) {\n");
    fprintf(ctx->output, "    static char result[1024];\n");
    fprintf(ctx->output, "    sprintf(result, \"%%p\", data);\n");
    fprintf(ctx->output, "    return result;\n");
    fprintf(ctx->output, "}\n\n");
    
    fprintf(ctx->output, "int bitand(int a, int b) {\n");
    fprintf(ctx->output, "    return a & b;\n");
    fprintf(ctx->output, "}\n\n");
    
    fprintf(ctx->output, "int bitor(int a, int b) {\n");
    fprintf(ctx->output, "    return a | b;\n");
    fprintf(ctx->output, "}\n\n");
    
    fprintf(ctx->output, "int bitxor(int a, int b) {\n");
    fprintf(ctx->output, "    return a ^ b;\n");
    fprintf(ctx->output, "}\n\n");
    
    fprintf(ctx->output, "int bitnot(int a) {\n");
    fprintf(ctx->output, "    return ~a;\n");
    fprintf(ctx->output, "}\n\n");
    
    /* I/O BIFs */
    fprintf(ctx->output, "int status(void) { return 0; }\n");
    fprintf(ctx->output, "int record(void) { return 0; }\n\n");
    
    /* Memory/System BIFs */
    fprintf(ctx->output, "void* alloc(int size) {\n");
    fprintf(ctx->output, "    return malloc(size);\n");
    fprintf(ctx->output, "}\n\n");
    
    fprintf(ctx->output, "void* rpgle_realloc(void* ptr, int size) {\n");
    fprintf(ctx->output, "    return realloc(ptr, size);\n");
    fprintf(ctx->output, "}\n\n");
    
    fprintf(ctx->output, "void dealloc(void* ptr) {\n");
    fprintf(ctx->output, "    free(ptr);\n");
    fprintf(ctx->output, "}\n\n");
    
    fprintf(ctx->output, "int parmnum(void) { return 0; }\n\n");
    
    fprintf(ctx->output, "void* parser(char* xml, char* opts) {\n");
    fprintf(ctx->output, "    return NULL; /* Placeholder */\n");
    fprintf(ctx->output, "}\n\n");
    
    /* Data Area BIF */
    fprintf(ctx->output, "char* dtaara(char* name, char* value) {\n");
    fprintf(ctx->output, "    static char result[1024];\n");
    fprintf(ctx->output, "    strcpy(result, value ? value : \"\");\n");
    fprintf(ctx->output, "    return result; /* Placeholder */\n");
    fprintf(ctx->output, "}\n\n");
    
    /* Data Structure BIFs */
    fprintf(ctx->output, "int nullind(void* field) {\n");
    fprintf(ctx->output, "    return 0; /* Placeholder */\n");
    fprintf(ctx->output, "}\n\n");
    
    fprintf(ctx->output, "char* fields(void* ds) {\n");
    fprintf(ctx->output, "    static char result[1024];\n");
    fprintf(ctx->output, "    result[0] = 0;\n");
    fprintf(ctx->output, "    return result; /* Placeholder */\n");
    fprintf(ctx->output, "}\n\n");
    
    fprintf(ctx->output, "char* list(char* str) {\n");
    fprintf(ctx->output, "    static char result[1024];\n");
    fprintf(ctx->output, "    strcpy(result, str);\n");
    fprintf(ctx->output, "    return result; /* Placeholder */\n");
    fprintf(ctx->output, "}\n\n");
    
    /* XML/JSON BIFs */
    fprintf(ctx->output, "char* xml(char* data, char* opts) {\n");
    fprintf(ctx->output, "    static char result[4096];\n");
    fprintf(ctx->output, "    strcpy(result, data);\n");
    fprintf(ctx->output, "    return result; /* Placeholder */\n");
    fprintf(ctx->output, "}\n\n");
    
    fprintf(ctx->output, "char* data(void* parser) {\n");
    fprintf(ctx->output, "    static char result[4096];\n");
    fprintf(ctx->output, "    result[0] = 0;\n");
    fprintf(ctx->output, "    return result; /* Placeholder */\n");
    fprintf(ctx->output, "}\n\n");
    
    /* Miscellaneous BIFs */
    fprintf(ctx->output, "void* kds(void* ds, int keys) {\n");
    fprintf(ctx->output, "    return ds; /* Placeholder */\n");
    fprintf(ctx->output, "}\n\n");
    
    fprintf(ctx->output, "int omitted(void) { return 0; }\n");
    fprintf(ctx->output, "int range(int val, int low, int high) { return (val >= low && val <= high); }\n");
    fprintf(ctx->output, "void* paddr(void* proc) { return proc; }\n");
    fprintf(ctx->output, "char* proc(void) { static char name[] = \"unknown\"; return name; }\n\n");
    
    /* First pass: Generate all file declarations (DCL-F) globally */
    if (node->type == NODE_PROGRAM) {
        output_file_declarations_recursive(ctx->output, node);
        fprintf(ctx->output, "\n");
    }
    
    /* Second pass: Generate global variables and procedures */
    if (node->type == NODE_PROGRAM) {
        for (int i = 0; i < node->data.list.count; i++) {
            codegen_statement(ctx, node->data.list.items[i]);
        }
    }
    
    /* Generate main function */
    fprintf(ctx->output, "int main(int argc, char* argv[]) {\n");
    if (ctx->main_proc_name) {
        fprintf(ctx->output, "    %s();\n", ctx->main_proc_name);
    }
    fprintf(ctx->output, "    return 0;\n");
    fprintf(ctx->output, "}\n");
}
