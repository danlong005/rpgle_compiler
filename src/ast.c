#include "ast.h"

ASTNode* create_node(NodeType type) {
    ASTNode* node = (ASTNode*)malloc(sizeof(ASTNode));
    if (!node) {
        fprintf(stderr, "Error: Memory allocation failed\n");
        exit(1);
    }
    memset(node, 0, sizeof(ASTNode));
    node->type = type;
    return node;
}

ASTNode* create_integer_node(int value) {
    ASTNode* node = create_node(NODE_INTEGER);
    node->data.int_value = value;
    return node;
}

ASTNode* create_float_node(double value) {
    ASTNode* node = create_node(NODE_DECIMAL);
    node->data.float_value = value;
    return node;
}

ASTNode* create_string_node(char* value) {
    ASTNode* node = create_node(NODE_STRING);
    node->data.string_value = strdup(value);
    return node;
}

ASTNode* create_identifier_node(char* name) {
    ASTNode* node = create_node(NODE_IDENTIFIER);
    node->data.identifier.name = strdup(name);
    return node;
}

ASTNode* create_binary_op_node(Operator op, ASTNode* left, ASTNode* right) {
    ASTNode* node = create_node(NODE_BINARY_OP);
    node->data.binary_op.op = op;
    node->data.binary_op.left = left;
    node->data.binary_op.right = right;
    return node;
}

ASTNode* create_unary_op_node(Operator op, ASTNode* operand) {
    ASTNode* node = create_node(NODE_UNARY_OP);
    node->data.unary_op.op = op;
    node->data.unary_op.operand = operand;
    return node;
}

ASTNode* create_function_call_node(char* name, ASTNode* args) {
    ASTNode* node = create_node(NODE_FUNCTION_CALL);
    node->data.function_call.name = strdup(name);
    node->data.function_call.arguments = args;
    return node;
}

ASTNode* create_if_node(ASTNode* condition, ASTNode* then_branch, ASTNode* else_branch) {
    ASTNode* node = create_node(NODE_IF);
    node->data.if_stmt.condition = condition;
    node->data.if_stmt.then_branch = then_branch;
    node->data.if_stmt.else_branch = else_branch;
    return node;
}

ASTNode* create_for_node(char* var, ASTNode* start, ASTNode* end, ASTNode* step, ASTNode* body, int is_downto) {
    ASTNode* node = create_node(NODE_FOR);
    node->data.for_loop.var = strdup(var);
    node->data.for_loop.start = start;
    node->data.for_loop.end = end;
    node->data.for_loop.step = step;
    node->data.for_loop.body = body;
    node->data.for_loop.is_downto = is_downto;
    return node;
}

ASTNode* create_while_node(ASTNode* condition, ASTNode* body, int is_post_test) {
    ASTNode* node = create_node(NODE_DOW);
    node->data.while_loop.condition = condition;
    node->data.while_loop.body = body;
    node->data.while_loop.is_post_test = is_post_test;
    return node;
}

ASTNode* create_declaration_node(char* name, TypeInfo* type_info, ASTNode* initializer, int is_const) {
    ASTNode* node = create_node(NODE_DCL_S);
    node->data.declaration.name = strdup(name);
    node->data.declaration.type_info = type_info;
    node->data.declaration.initializer = initializer;
    node->data.declaration.is_const = is_const;
    return node;
}

ASTNode* create_procedure_node(char* name, ASTNode* params, ASTNode* body, TypeInfo* return_type) {
    ASTNode* node = create_node(NODE_DCL_PROC);
    node->data.procedure.name = strdup(name);
    node->data.procedure.parameters = params;
    node->data.procedure.body = body;
    node->data.procedure.return_type = return_type;
    return node;
}

ASTNode* create_return_node(ASTNode* value) {
    ASTNode* node = create_node(NODE_RETURN);
    node->data.return_stmt.value = value;
    return node;
}

ASTNode* create_list_node(NodeType type) {
    ASTNode* node = create_node(type);
    node->data.list.items = NULL;
    node->data.list.count = 0;
    node->data.list.capacity = 0;
    return node;
}

void add_to_list(ASTNode* list, ASTNode* item) {
    if (!list || !item) return;
    
    if (list->data.list.count >= list->data.list.capacity) {
        int new_capacity = list->data.list.capacity == 0 ? 8 : list->data.list.capacity * 2;
        ASTNode** new_items = (ASTNode**)realloc(list->data.list.items, 
                                                   new_capacity * sizeof(ASTNode*));
        if (!new_items) {
            fprintf(stderr, "Error: Memory allocation failed\n");
            exit(1);
        }
        list->data.list.items = new_items;
        list->data.list.capacity = new_capacity;
    }
    
    list->data.list.items[list->data.list.count++] = item;
}

void free_ast(ASTNode* node) {
    if (!node) return;
    
    /* Free based on node type */
    switch (node->type) {
        case NODE_STRING:
            free(node->data.string_value);
            break;
        case NODE_IDENTIFIER:
            free(node->data.identifier.name);
            break;
        case NODE_DCL_S:
        case NODE_DCL_C:
            free(node->data.declaration.name);
            free(node->data.declaration.type_info);
            free_ast(node->data.declaration.initializer);
            break;
        case NODE_DCL_PROC:
            free(node->data.procedure.name);
            free(node->data.procedure.return_type);
            free_ast(node->data.procedure.parameters);
            free_ast(node->data.procedure.body);
            break;
        case NODE_BINARY_OP:
            free_ast(node->data.binary_op.left);
            free_ast(node->data.binary_op.right);
            break;
        case NODE_UNARY_OP:
            free_ast(node->data.unary_op.operand);
            break;
        case NODE_FUNCTION_CALL:
            free(node->data.function_call.name);
            free_ast(node->data.function_call.arguments);
            break;
        case NODE_IF:
            free_ast(node->data.if_stmt.condition);
            free_ast(node->data.if_stmt.then_branch);
            free_ast(node->data.if_stmt.else_branch);
            break;
        case NODE_FOR:
            free(node->data.for_loop.var);
            free_ast(node->data.for_loop.start);
            free_ast(node->data.for_loop.end);
            free_ast(node->data.for_loop.step);
            free_ast(node->data.for_loop.body);
            break;
        case NODE_DOW:
        case NODE_DOU:
            free_ast(node->data.while_loop.condition);
            free_ast(node->data.while_loop.body);
            break;
        case NODE_RETURN:
            free_ast(node->data.return_stmt.value);
            break;
        case NODE_STATEMENT_LIST:
        case NODE_PARAMETER_LIST:
        case NODE_FIELD_LIST:
            for (int i = 0; i < node->data.list.count; i++) {
                free_ast(node->data.list.items[i]);
            }
            free(node->data.list.items);
            break;
        default:
            break;
    }
    
    free(node);
}

TypeInfo* create_type_info(DataType type, int length, int decimals) {
    TypeInfo* info = (TypeInfo*)malloc(sizeof(TypeInfo));
    if (!info) {
        fprintf(stderr, "Error: Memory allocation failed\n");
        exit(1);
    }
    info->type = type;
    info->length = length;
    info->decimals = decimals;
    info->dim = 0;
    info->like_field = NULL;
    return info;
}
