%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "ast.h"

extern int yylex();
extern int yyparse();
extern FILE* yyin;
extern int line_num;
extern int col_num;

void yyerror(const char* s);

ASTNode* root = NULL;
char* main_proc_name = NULL;
%}

%union {
    int int_val;
    double float_val;
    char* str_val;
    ASTNode* node;
    TypeInfo* type_info;
    Operator op;
}

/* Tokens */
%token <str_val> IDENTIFIER STRING_LITERAL DATE_LITERAL TIME_LITERAL TIMESTAMP_LITERAL
%token <int_val> INTEGER_LITERAL
%token <float_val> DECIMAL_LITERAL

/* Keywords - Control */
%token CTL_OPT

/* Keywords - Declarations */
%token DCL_S DCL_C DCL_F DCL_DS DCL_PR DCL_PI DCL_PROC END_PROC END_DS END_PR END_PI

/* Keywords - Data Types */
%token CHAR VARCHAR INT UNS PACKED ZONED BINDEC IND DATE TIME TIMESTAMP POINTER
%token LIKE LIKEDS LIKEFILE DIM CONST INZ STATIC EXTPROC EXPORT IMPORT VALUE NOOPT QUALIFIED

/* Keywords - Control Flow */
%token IF ELSE ELSEIF ENDIF FOR ENDFOR DOW DOU ENDDO
%token SELECT WHEN OTHER ENDSL ITER LEAVE

/* Keywords - Operations */
%token EVAL RETURN CALLP CLEAR RESET DSPLY

/* Keywords - I/O */
%token CHAIN READ READE READP READPE WRITE UPDATE DELETE SETLL SETGT OPEN CLOSE

/* Built-in Functions */
%token BIF_TRIM BIF_TRIMR BIF_TRIML BIF_SUBST BIF_LEN BIF_SIZE BIF_ELEM
%token BIF_ABS BIF_ADDR BIF_CHAR BIF_DATE BIF_TIME BIF_TIMESTAMP
%token BIF_FOUND BIF_EOF BIF_EQUAL BIF_ERROR BIF_SCAN BIF_REPLACE BIF_XLATE
%token BIF_INT BIF_DEC BIF_FLOAT BIF_EDITC BIF_EDITW BIF_STR BIF_PARMS
%token BIF_OCCUR BIF_OPEN
%token BIF_SCANRPL BIF_CHECK BIF_CHECKR BIF_SPLIT
%token BIF_DECH BIF_DECPOS BIF_INTH BIF_SQRT BIF_REM BIF_DIV BIF_EDITFLT BIF_UNS BIF_UNSH
%token BIF_YEARS BIF_MONTHS BIF_DAYS BIF_HOURS BIF_MINUTES BIF_SECONDS BIF_MSECONDS
%token BIF_DIFF BIF_SUBDUR BIF_ADDDUR
%token BIF_LOOKUP BIF_LOOKUPLT BIF_LOOKUPLE BIF_LOOKUPGT BIF_LOOKUPGE BIF_SUBARR BIF_SORTARR
%token BIF_GRAPH BIF_UCS2 BIF_HEX BIF_BITAND BIF_BITOR BIF_BITXOR BIF_BITNOT
%token BIF_STATUS BIF_RECORD
%token BIF_ALLOC BIF_REALLOC BIF_DEALLOC BIF_PARMNUM BIF_PARSER
%token BIF_DTAARA BIF_NULLIND BIF_FIELDS BIF_LIST
%token BIF_XML BIF_DATA
%token BIF_KDS BIF_OMITTED BIF_RANGE BIF_PADDR BIF_PROC

/* Operators */
%token PLUS MINUS MULT DIV POWER ASSIGN
%token EQ NE LT LE GT GE
%token AND OR NOT

/* Delimiters */
%token LPAREN RPAREN COLON SEMICOLON COMMA DOT

/* Constants */
%token CONSTANT_ON CONSTANT_OFF CONSTANT_BLANK CONSTANT_BLANKS
%token CONSTANT_ZERO CONSTANT_ZEROS CONSTANT_NULL CONSTANT_HIVAL CONSTANT_LOVAL
%token CONSTANT_ALL NOPASS OMIT BY TO DOWNTO

/* Non-terminals */
%type <node> program statement_list ctl_opt_list statement declaration
%type <node> ctl_opt_stmt dcl_s_stmt dcl_c_stmt dcl_f_stmt dcl_ds_stmt ds_field_list ds_field dcl_proc_stmt procedure_body
%type <node> if_stmt for_stmt dow_stmt dou_stmt select_stmt when_clause_list when_clause
%type <node> eval_stmt return_stmt callp_stmt
%type <node> expression primary_expr binary_expr unary_expr function_call
%type <node> argument_list parameter_list parameter
%type <node> dsply_stmt
%type <node> iter_stmt leave_stmt
%type <node> file_io_stmt open_stmt close_stmt read_stmt write_stmt chain_stmt
%type <type_info> type_spec
%type <int_val> data_type

/* Operator precedence */
%left OR
%left AND
%left NOT
%left EQ NE
%left LT LE GT GE
%left PLUS MINUS
%left MULT DIV
%right POWER
%right UMINUS

%%

program:
    ctl_opt_list statement_list {
        root = create_node(NODE_PROGRAM);
        /* Combine ctl_opt_list and statement_list */
        int total = $1->data.list.count + $2->data.list.count;
        root->data.list.items = (ASTNode**)malloc(sizeof(ASTNode*) * total);
        root->data.list.capacity = total;
        root->data.list.count = 0;
        
        /* Add CTL-OPT statements first */
        for (int i = 0; i < $1->data.list.count; i++) {
            root->data.list.items[root->data.list.count++] = $1->data.list.items[i];
        }
        /* Then add other statements */
        for (int i = 0; i < $2->data.list.count; i++) {
            root->data.list.items[root->data.list.count++] = $2->data.list.items[i];
        }
        $$ = root;
    }
    | statement_list {
        root = create_node(NODE_PROGRAM);
        root->data.list.items = $1->data.list.items;
        root->data.list.count = $1->data.list.count;
        root->data.list.capacity = $1->data.list.capacity;
        $$ = root;
    }
    ;

ctl_opt_list:
    ctl_opt_stmt {
        $$ = create_list_node(NODE_STATEMENT_LIST);
        add_to_list($$, $1);
    }
    | ctl_opt_list ctl_opt_stmt {
        add_to_list($1, $2);
        $$ = $1;
    }
    ;

statement_list:
    /* empty */ {
        $$ = create_list_node(NODE_STATEMENT_LIST);
    }
    | statement_list statement {
        if ($2) {
            add_to_list($1, $2);
        }
        $$ = $1;
    }
    ;

statement:
    declaration { $$ = $1; }
    | dcl_proc_stmt { $$ = $1; }
    | if_stmt { $$ = $1; }
    | for_stmt { $$ = $1; }
    | dow_stmt { $$ = $1; }
    | dou_stmt { $$ = $1; }
    | select_stmt { $$ = $1; }
    | eval_stmt { $$ = $1; }
    | return_stmt { $$ = $1; }
    | callp_stmt { $$ = $1; }
    | dsply_stmt { $$ = $1; }
    | iter_stmt { $$ = $1; }
    | leave_stmt { $$ = $1; }
    | file_io_stmt { $$ = $1; }
    | SEMICOLON { $$ = NULL; }
    ;

ctl_opt_stmt:
    CTL_OPT IDENTIFIER SEMICOLON {
        ASTNode* node = create_node(NODE_CTL_OPT);
        node->data.ctl_opt.options = (char**)malloc(sizeof(char*));
        node->data.ctl_opt.options[0] = $2;
        node->data.ctl_opt.count = 1;
        $$ = node;
    }
    | CTL_OPT IDENTIFIER LPAREN IDENTIFIER RPAREN SEMICOLON {
        ASTNode* node = create_node(NODE_CTL_OPT);
        node->data.ctl_opt.options = (char**)malloc(sizeof(char*));
        node->data.ctl_opt.options[0] = $2;
        node->data.ctl_opt.count = 1;
        /* Check if this is MAIN option */
        if (strcasecmp($2, "MAIN") == 0) {
            main_proc_name = strdup($4);
        }
        free($4);
        $$ = node;
    }
    | CTL_OPT IDENTIFIER LPAREN MULT IDENTIFIER RPAREN SEMICOLON {
        ASTNode* node = create_node(NODE_CTL_OPT);
        node->data.ctl_opt.options = (char**)malloc(sizeof(char*));
        node->data.ctl_opt.options[0] = $2;
        node->data.ctl_opt.count = 1;
        free($5);
        $$ = node;
    }
    | CTL_OPT IDENTIFIER LPAREN expression RPAREN SEMICOLON {
        ASTNode* node = create_node(NODE_CTL_OPT);
        node->data.ctl_opt.options = (char**)malloc(sizeof(char*));
        node->data.ctl_opt.options[0] = $2;
        node->data.ctl_opt.count = 1;
        $$ = node;
    }
    | CTL_OPT IDENTIFIER LPAREN MULT IDENTIFIER RPAREN IDENTIFIER LPAREN IDENTIFIER RPAREN SEMICOLON {
        ASTNode* node = create_node(NODE_CTL_OPT);
        node->data.ctl_opt.options = (char**)malloc(sizeof(char*));
        node->data.ctl_opt.options[0] = $2;
        node->data.ctl_opt.count = 1;
        /* Check if second option is MAIN */
        if (strcasecmp($7, "MAIN") == 0) {
            main_proc_name = strdup($9);
        }
        free($5);
        free($9);
        $$ = node;
    }
    | CTL_OPT IDENTIFIER IDENTIFIER LPAREN IDENTIFIER RPAREN SEMICOLON {
        ASTNode* node = create_node(NODE_CTL_OPT);
        node->data.ctl_opt.options = (char**)malloc(sizeof(char*));
        node->data.ctl_opt.options[0] = $2;
        node->data.ctl_opt.count = 1;
        /* Check if second option is MAIN */
        if (strcasecmp($3, "MAIN") == 0) {
            main_proc_name = strdup($5);
        }
        free($5);
        $$ = node;
    }
    ;

declaration:
    dcl_s_stmt { $$ = $1; }
    | dcl_c_stmt { $$ = $1; }
    | dcl_f_stmt { $$ = $1; }
    | dcl_ds_stmt { $$ = $1; }
    ;

dcl_s_stmt:
    DCL_S IDENTIFIER type_spec SEMICOLON {
        $$ = create_declaration_node($2, $3, NULL, 0);
        free($2);
    }
    | DCL_S IDENTIFIER type_spec INZ LPAREN expression RPAREN SEMICOLON {
        $$ = create_declaration_node($2, $3, $6, 0);
        free($2);
    }
    | DCL_S IDENTIFIER type_spec DIM LPAREN INTEGER_LITERAL RPAREN SEMICOLON {
        $3->dim = $6;
        $$ = create_declaration_node($2, $3, NULL, 0);
        free($2);
    }
    | DCL_S IDENTIFIER type_spec DIM LPAREN INTEGER_LITERAL RPAREN INZ LPAREN expression RPAREN SEMICOLON {
        $3->dim = $6;
        $$ = create_declaration_node($2, $3, $10, 0);
        free($2);
    }
    ;

dcl_c_stmt:
    DCL_C IDENTIFIER CONST LPAREN expression RPAREN SEMICOLON {
        TypeInfo* ti = create_type_info(TYPE_UNKNOWN, 0, 0);
        $$ = create_declaration_node($2, ti, $5, 1);
        $$->type = NODE_DCL_C;
        free($2);
    }
    ;

dcl_f_stmt:
    DCL_F IDENTIFIER SEMICOLON {
        ASTNode* node = create_node(NODE_DCL_S);
        node->data.declaration.name = $2;
        node->data.declaration.type_info = NULL;
        node->data.declaration.initializer = NULL;
        node->data.declaration.is_const = 0;
        node->data.declaration.is_static = 0;
        node->data.declaration.is_file = 1;
        $$ = node;
    }
    | DCL_F IDENTIFIER IDENTIFIER SEMICOLON {
        ASTNode* node = create_node(NODE_DCL_S);
        node->data.declaration.name = $2;
        node->data.declaration.type_info = NULL;
        node->data.declaration.initializer = NULL;
        node->data.declaration.is_const = 0;
        node->data.declaration.is_static = 0;
        node->data.declaration.is_file = 1;
        free($3);  /* File type/options */
        $$ = node;
    }
    ;

dcl_ds_stmt:
    DCL_DS IDENTIFIER SEMICOLON ds_field_list END_DS SEMICOLON {
        ASTNode* node = create_node(NODE_DCL_DS);
        node->data.data_structure.name = $2;
        node->data.data_structure.fields = $4;
        node->data.data_structure.is_qualified = 0;
        node->data.data_structure.base_ds_name = NULL;
        node->data.data_structure.dim = 0;
        $$ = node;
    }
    | DCL_DS IDENTIFIER QUALIFIED SEMICOLON ds_field_list END_DS SEMICOLON {
        ASTNode* node = create_node(NODE_DCL_DS);
        node->data.data_structure.name = $2;
        node->data.data_structure.fields = $5;
        node->data.data_structure.is_qualified = 1;
        node->data.data_structure.base_ds_name = NULL;
        node->data.data_structure.dim = 0;
        $$ = node;
    }
    | DCL_DS IDENTIFIER LIKEDS LPAREN IDENTIFIER RPAREN SEMICOLON {
        ASTNode* node = create_node(NODE_DCL_DS);
        node->data.data_structure.name = $2;
        node->data.data_structure.fields = NULL;
        node->data.data_structure.is_qualified = 1;  /* LIKEDS implies qualified */
        node->data.data_structure.base_ds_name = $5;
        node->data.data_structure.dim = 0;
        $$ = node;
    }
    | DCL_DS IDENTIFIER LIKEDS LPAREN IDENTIFIER RPAREN DIM LPAREN INTEGER_LITERAL RPAREN SEMICOLON {
        ASTNode* node = create_node(NODE_DCL_DS);
        node->data.data_structure.name = $2;
        node->data.data_structure.fields = NULL;
        node->data.data_structure.is_qualified = 1;  /* LIKEDS implies qualified */
        node->data.data_structure.base_ds_name = $5;
        node->data.data_structure.dim = $9;
        $$ = node;
    }
    | DCL_DS IDENTIFIER QUALIFIED DIM LPAREN INTEGER_LITERAL RPAREN SEMICOLON ds_field_list END_DS SEMICOLON {
        ASTNode* node = create_node(NODE_DCL_DS);
        node->data.data_structure.name = $2;
        node->data.data_structure.fields = $9;
        node->data.data_structure.is_qualified = 1;
        node->data.data_structure.base_ds_name = NULL;
        node->data.data_structure.dim = $6;
        $$ = node;
    }
    ;

ds_field_list:
    /* empty */ {
        $$ = create_list_node(NODE_FIELD_LIST);
    }
    | ds_field_list ds_field {
        if ($2) {
            add_to_list($1, $2);
        }
        $$ = $1;
    }
    ;

ds_field:
    IDENTIFIER type_spec SEMICOLON {
        $$ = create_declaration_node($1, $2, NULL, 0);
        free($1);
    }
    | IDENTIFIER type_spec INZ LPAREN expression RPAREN SEMICOLON {
        $$ = create_declaration_node($1, $2, $5, 0);
        free($1);
    }
    ;

dcl_proc_stmt:
    DCL_PROC IDENTIFIER SEMICOLON procedure_body END_PROC SEMICOLON {
        $$ = create_procedure_node($2, NULL, $4, NULL);
        free($2);
    }
    | DCL_PROC IDENTIFIER SEMICOLON procedure_body END_PROC IDENTIFIER SEMICOLON {
        $$ = create_procedure_node($2, NULL, $4, NULL);
        free($2);
        free($6);
    }
    ;

procedure_body:
    statement_list {
        $$ = $1;
    }
    ;

parameter_list:
    /* empty */ {
        $$ = create_list_node(NODE_PARAMETER_LIST);
    }
    | parameter {
        ASTNode* list = create_list_node(NODE_PARAMETER_LIST);
        add_to_list(list, $1);
        $$ = list;
    }
    | parameter_list SEMICOLON parameter {
        add_to_list($1, $3);
        $$ = $1;
    }
    ;

parameter:
    IDENTIFIER type_spec {
        $$ = create_declaration_node($1, $2, NULL, 0);
        free($1);
    }
    ;

type_spec:
    data_type LPAREN INTEGER_LITERAL RPAREN {
        $$ = create_type_info($1, $3, 0);
    }
    | data_type LPAREN INTEGER_LITERAL COLON INTEGER_LITERAL RPAREN {
        $$ = create_type_info($1, $3, $5);
    }
    | CHAR LPAREN INTEGER_LITERAL RPAREN {
        $$ = create_type_info(TYPE_CHAR, $3, 0);
    }
    | VARCHAR LPAREN INTEGER_LITERAL RPAREN {
        $$ = create_type_info(TYPE_VARCHAR, $3, 0);
    }
    | INT LPAREN INTEGER_LITERAL RPAREN {
        $$ = create_type_info(TYPE_INT, $3, 0);
    }
    | PACKED LPAREN INTEGER_LITERAL COLON INTEGER_LITERAL RPAREN {
        $$ = create_type_info(TYPE_PACKED, $3, $5);
    }
    | ZONED LPAREN INTEGER_LITERAL COLON INTEGER_LITERAL RPAREN {
        $$ = create_type_info(TYPE_ZONED, $3, $5);
    }
    | IND {
        $$ = create_type_info(TYPE_IND, 1, 0);
    }
    | POINTER {
        $$ = create_type_info(TYPE_POINTER, 0, 0);
    }
    | DATE {
        $$ = create_type_info(TYPE_DATE, 10, 0);
    }
    | TIME {
        $$ = create_type_info(TYPE_TIME, 8, 0);
    }
    | TIMESTAMP {
        $$ = create_type_info(TYPE_TIMESTAMP, 26, 0);
    }
    ;

data_type:
    CHAR { $$ = TYPE_CHAR; }
    | VARCHAR { $$ = TYPE_VARCHAR; }
    | INT { $$ = TYPE_INT; }
    | UNS { $$ = TYPE_UNS; }
    | PACKED { $$ = TYPE_PACKED; }
    | ZONED { $$ = TYPE_ZONED; }
    | BINDEC { $$ = TYPE_BINDEC; }
    | IND { $$ = TYPE_IND; }
    | DATE { $$ = TYPE_DATE; }
    | TIME { $$ = TYPE_TIME; }
    | TIMESTAMP { $$ = TYPE_TIMESTAMP; }
    | POINTER { $$ = TYPE_POINTER; }
    ;

if_stmt:
    IF expression SEMICOLON statement_list ENDIF SEMICOLON {
        $$ = create_if_node($2, $4, NULL);
    }
    | IF expression SEMICOLON statement_list ELSE SEMICOLON statement_list ENDIF SEMICOLON {
        $$ = create_if_node($2, $4, $7);
    }
    | IF expression SEMICOLON statement_list ELSEIF expression SEMICOLON statement_list ENDIF SEMICOLON {
        ASTNode* elseif = create_if_node($6, $8, NULL);
        $$ = create_if_node($2, $4, elseif);
    }
    ;

for_stmt:
    FOR IDENTIFIER ASSIGN expression TO expression SEMICOLON statement_list ENDFOR SEMICOLON {
        $$ = create_for_node($2, $4, $6, NULL, $8, 0);
        free($2);
    }
    | FOR IDENTIFIER ASSIGN expression TO expression BY expression SEMICOLON statement_list ENDFOR SEMICOLON {
        $$ = create_for_node($2, $4, $6, $8, $10, 0);
        free($2);
    }
    | FOR IDENTIFIER ASSIGN expression DOWNTO expression SEMICOLON statement_list ENDFOR SEMICOLON {
        $$ = create_for_node($2, $4, $6, NULL, $8, 1);
        free($2);
    }
    | FOR IDENTIFIER ASSIGN expression DOWNTO expression BY expression SEMICOLON statement_list ENDFOR SEMICOLON {
        $$ = create_for_node($2, $4, $6, $8, $10, 1);
        free($2);
    }
    ;

dow_stmt:
    DOW expression SEMICOLON statement_list ENDDO SEMICOLON {
        $$ = create_while_node($2, $4, 0);
    }
    ;

dou_stmt:
    DOU expression SEMICOLON statement_list ENDDO SEMICOLON {
        $$ = create_while_node($2, $4, 1);
    }
    ;

select_stmt:
    SELECT SEMICOLON when_clause_list ENDSL SEMICOLON {
        ASTNode* node = create_node(NODE_SELECT);
        node->data.select_stmt.when_clauses = $3;
        node->data.select_stmt.other_clause = NULL;
        $$ = node;
    }
    | SELECT SEMICOLON when_clause_list OTHER SEMICOLON statement_list ENDSL SEMICOLON {
        ASTNode* node = create_node(NODE_SELECT);
        node->data.select_stmt.when_clauses = $3;
        node->data.select_stmt.other_clause = $6;
        $$ = node;
    }
    ;

when_clause_list:
    when_clause {
        ASTNode* list = create_list_node(NODE_STATEMENT_LIST);
        add_to_list(list, $1);
        $$ = list;
    }
    | when_clause_list when_clause {
        add_to_list($1, $2);
        $$ = $1;
    }
    ;

when_clause:
    WHEN expression SEMICOLON statement_list {
        ASTNode* node = create_node(NODE_WHEN);
        node->data.when_clause.condition = $2;
        node->data.when_clause.statements = $4;
        $$ = node;
    }
    ;

eval_stmt:
    IDENTIFIER ASSIGN expression SEMICOLON {
        ASTNode* node = create_node(NODE_EVAL);
        node->data.binary_op.op = OP_ADD;  /* Just a placeholder */
        node->data.binary_op.left = create_identifier_node($1);
        node->data.binary_op.right = $3;
        free($1);
        $$ = node;
    }
    | IDENTIFIER DOT IDENTIFIER ASSIGN expression SEMICOLON {
        /* Qualified data structure field assignment: ds.field = value */
        ASTNode* node = create_node(NODE_EVAL);
        node->data.binary_op.op = OP_ADD;
        char* qualified_name = malloc(strlen($1) + strlen($3) + 2);
        sprintf(qualified_name, "%s.%s", $1, $3);
        node->data.binary_op.left = create_identifier_node(qualified_name);
        node->data.binary_op.right = $5;
        free(qualified_name);
        free($1);
        free($3);
        $$ = node;
    }
    | IDENTIFIER LPAREN expression RPAREN ASSIGN expression SEMICOLON {
        /* Array subscript assignment */
        ASTNode* node = create_node(NODE_EVAL);
        ASTNode* subscript = create_node(NODE_ARRAY_SUBSCRIPT);
        subscript->data.array_subscript.array_name = $1;
        subscript->data.array_subscript.index = $3;
        node->data.binary_op.left = subscript;
        node->data.binary_op.right = $6;
        $$ = node;
    }
    | IDENTIFIER LPAREN expression RPAREN DOT IDENTIFIER ASSIGN expression SEMICOLON {
        /* DS array field assignment: ds(i).field = value */
        ASTNode* node = create_node(NODE_EVAL);
        ASTNode* subscript = create_node(NODE_ARRAY_SUBSCRIPT);
        /* Store as ds.field in array_name, will be parsed in codegen */
        subscript->data.array_subscript.array_name = malloc(strlen($1) + strlen($6) + 2);
        sprintf(subscript->data.array_subscript.array_name, "%s.%s", $1, $6);
        subscript->data.array_subscript.index = $3;
        node->data.binary_op.left = subscript;
        node->data.binary_op.right = $8;
        free($1);
        free($6);
        $$ = node;
    }
    | EVAL IDENTIFIER ASSIGN expression SEMICOLON {
        ASTNode* node = create_node(NODE_EVAL);
        node->data.binary_op.left = create_identifier_node($2);
        node->data.binary_op.right = $4;
        free($2);
        $$ = node;
    }
    | EVAL IDENTIFIER LPAREN expression RPAREN ASSIGN expression SEMICOLON {
        /* EVAL with array subscript assignment */
        ASTNode* node = create_node(NODE_EVAL);
        ASTNode* subscript = create_node(NODE_ARRAY_SUBSCRIPT);
        subscript->data.array_subscript.array_name = $2;
        subscript->data.array_subscript.index = $4;
        node->data.binary_op.left = subscript;
        node->data.binary_op.right = $7;
        $$ = node;
    }
    ;

return_stmt:
    RETURN expression SEMICOLON {
        $$ = create_return_node($2);
    }
    | RETURN SEMICOLON {
        $$ = create_return_node(NULL);
    }
    ;

callp_stmt:
    CALLP IDENTIFIER LPAREN argument_list RPAREN SEMICOLON {
        $$ = create_function_call_node($2, $4);
        $$->type = NODE_CALLP;
        free($2);
    }
    | IDENTIFIER LPAREN argument_list RPAREN SEMICOLON {
        $$ = create_function_call_node($1, $3);
        $$->type = NODE_CALLP;
        free($1);
    }
    ;

dsply_stmt:
    DSPLY expression SEMICOLON {
        ASTNode* node = create_node(NODE_DSPLY);
        node->data.dsply.message = $2;
        node->data.dsply.variable = NULL;
        $$ = node;
    }
    | DSPLY IDENTIFIER expression SEMICOLON {
        ASTNode* node = create_node(NODE_DSPLY);
        node->data.dsply.message = $3;
        node->data.dsply.variable = create_identifier_node($2);
        free($2);
        $$ = node;
    }
    ;

iter_stmt:
    ITER SEMICOLON {
        $$ = create_node(NODE_ITER);
    }
    ;

leave_stmt:
    LEAVE SEMICOLON {
        $$ = create_node(NODE_LEAVE);
    }
    ;

file_io_stmt:
    open_stmt { $$ = $1; }
    | close_stmt { $$ = $1; }
    | read_stmt { $$ = $1; }
    | write_stmt { $$ = $1; }
    | chain_stmt { $$ = $1; }
    ;

open_stmt:
    OPEN IDENTIFIER SEMICOLON {
        ASTNode* node = create_node(NODE_OPEN);
        node->data.file_io.file_name = $2;
        node->data.file_io.record_var = NULL;
        node->data.file_io.key = NULL;
        $$ = node;
    }
    ;

close_stmt:
    CLOSE IDENTIFIER SEMICOLON {
        ASTNode* node = create_node(NODE_CLOSE);
        node->data.file_io.file_name = $2;
        node->data.file_io.record_var = NULL;
        node->data.file_io.key = NULL;
        $$ = node;
    }
    ;

read_stmt:
    READ IDENTIFIER SEMICOLON {
        ASTNode* node = create_node(NODE_READ);
        node->data.file_io.file_name = $2;
        node->data.file_io.record_var = NULL;
        node->data.file_io.key = NULL;
        $$ = node;
    }
    | READ IDENTIFIER IDENTIFIER SEMICOLON {
        ASTNode* node = create_node(NODE_READ);
        node->data.file_io.file_name = $2;
        node->data.file_io.record_var = $3;
        node->data.file_io.key = NULL;
        $$ = node;
    }
    ;

write_stmt:
    WRITE IDENTIFIER SEMICOLON {
        ASTNode* node = create_node(NODE_WRITE);
        node->data.file_io.file_name = $2;
        node->data.file_io.record_var = NULL;
        node->data.file_io.key = NULL;
        $$ = node;
    }
    | WRITE IDENTIFIER IDENTIFIER SEMICOLON {
        ASTNode* node = create_node(NODE_WRITE);
        node->data.file_io.file_name = $2;
        node->data.file_io.record_var = $3;
        node->data.file_io.key = NULL;
        $$ = node;
    }
    ;

chain_stmt:
    CHAIN expression IDENTIFIER SEMICOLON {
        ASTNode* node = create_node(NODE_CHAIN);
        node->data.file_io.file_name = $3;
        node->data.file_io.record_var = NULL;
        node->data.file_io.key = $2;
        $$ = node;
    }
    | CHAIN expression IDENTIFIER IDENTIFIER SEMICOLON {
        ASTNode* node = create_node(NODE_CHAIN);
        node->data.file_io.file_name = $3;
        node->data.file_io.record_var = $4;
        node->data.file_io.key = $2;
        $$ = node;
    }
    ;

expression:
    primary_expr { $$ = $1; }
    | binary_expr { $$ = $1; }
    | unary_expr { $$ = $1; }
    | function_call { $$ = $1; }
    ;

primary_expr:
    IDENTIFIER LPAREN expression RPAREN {
        /* Array subscript access */
        ASTNode* node = create_node(NODE_ARRAY_SUBSCRIPT);
        node->data.array_subscript.array_name = $1;
        node->data.array_subscript.index = $3;
        $$ = node;
    }
    | IDENTIFIER DOT IDENTIFIER {
        /* Qualified data structure field access: ds.field */
        char* qualified_name = malloc(strlen($1) + strlen($3) + 2);
        sprintf(qualified_name, "%s.%s", $1, $3);
        $$ = create_identifier_node(qualified_name);
        free(qualified_name);
        free($1);
        free($3);
    }
    | IDENTIFIER LPAREN expression RPAREN DOT IDENTIFIER {
        /* Array of DS with field access: ds(i).field */
        /* Create a special node type to handle this */
        ASTNode* node = create_node(NODE_IDENTIFIER);
        /* Store the array name, subscript, and field name */
        /* Format will be: arrayname[(index)-1].fieldname in C */
        node->data.identifier.name = malloc(strlen($1) + strlen($6) + 50);
        /* We'll mark this for special handling with a prefix */
        sprintf(node->data.identifier.name, "__DSARRAY__%s__FIELD__%s__IDX__", $1, $6);
        /* Store the index expression as a child (we'll need to update identifier structure) */
        /* For now, we'll handle this in a simpler way in codegen */
        /* Just concatenate: ds[idx-1].field will be built in codegen_expression */
        free(node->data.identifier.name);
        free(node);
        /* Better approach: create array subscript node with field suffix */
        ASTNode* subscript = create_node(NODE_ARRAY_SUBSCRIPT);
        subscript->data.array_subscript.array_name = malloc(strlen($1) + strlen($6) + 2);
        sprintf(subscript->data.array_subscript.array_name, "%s.%s", $1, $6);
        subscript->data.array_subscript.index = $3;
        $$ = subscript;
        free($1);
        free($6);
    }
    | IDENTIFIER {
        $$ = create_identifier_node($1);
        free($1);
    }
    | INTEGER_LITERAL {
        $$ = create_integer_node($1);
    }
    | DECIMAL_LITERAL {
        $$ = create_float_node($1);
    }
    | STRING_LITERAL {
        $$ = create_string_node($1);
        free($1);
    }
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
    | CONSTANT_ON {
        $$ = create_integer_node(1);
    }
    | CONSTANT_OFF {
        $$ = create_integer_node(0);
    }
    | CONSTANT_BLANKS {
        $$ = create_string_node("' '");
    }
    | CONSTANT_ZEROS {
        $$ = create_integer_node(0);
    }
    | LPAREN expression RPAREN {
        $$ = $2;
    }
    ;

binary_expr:
    expression PLUS expression {
        $$ = create_binary_op_node(OP_ADD, $1, $3);
    }
    | expression MINUS expression {
        $$ = create_binary_op_node(OP_SUB, $1, $3);
    }
    | expression MULT expression {
        $$ = create_binary_op_node(OP_MULT, $1, $3);
    }
    | expression DIV expression {
        $$ = create_binary_op_node(OP_DIV, $1, $3);
    }
    | expression POWER expression {
        $$ = create_binary_op_node(OP_POWER, $1, $3);
    }
    | expression EQ expression {
        $$ = create_binary_op_node(OP_EQ, $1, $3);
    }
    | expression ASSIGN expression {
        /* In RPGLE, = is equality in expression context */
        $$ = create_binary_op_node(OP_EQ, $1, $3);
    }
    | expression NE expression {
        $$ = create_binary_op_node(OP_NE, $1, $3);
    }
    | expression LT expression {
        $$ = create_binary_op_node(OP_LT, $1, $3);
    }
    | expression LE expression {
        $$ = create_binary_op_node(OP_LE, $1, $3);
    }
    | expression GT expression {
        $$ = create_binary_op_node(OP_GT, $1, $3);
    }
    | expression GE expression {
        $$ = create_binary_op_node(OP_GE, $1, $3);
    }
    | expression AND expression {
        $$ = create_binary_op_node(OP_AND, $1, $3);
    }
    | expression OR expression {
        $$ = create_binary_op_node(OP_OR, $1, $3);
    }
    ;

unary_expr:
    MINUS expression %prec UMINUS {
        $$ = create_unary_op_node(OP_SUB, $2);
    }
    | NOT expression {
        $$ = create_unary_op_node(OP_NOT, $2);
    }
    ;

function_call:
    BIF_TRIM LPAREN expression RPAREN {
        $$ = create_function_call_node("trim", $3);
    }
    | BIF_TRIMR LPAREN expression RPAREN {
        $$ = create_function_call_node("trimr", $3);
    }
    | BIF_TRIML LPAREN expression RPAREN {
        $$ = create_function_call_node("triml", $3);
    }
    | BIF_SUBST LPAREN argument_list RPAREN {
        $$ = create_function_call_node("subst", $3);
    }
    | BIF_SCAN LPAREN argument_list RPAREN {
        $$ = create_function_call_node("scan", $3);
    }
    | BIF_REPLACE LPAREN argument_list RPAREN {
        $$ = create_function_call_node("replace", $3);
    }
    | BIF_XLATE LPAREN argument_list RPAREN {
        $$ = create_function_call_node("xlate", $3);
    }
    | BIF_LEN LPAREN expression RPAREN {
        $$ = create_function_call_node("len", $3);
    }
    | BIF_SIZE LPAREN expression RPAREN {
        $$ = create_function_call_node("size", $3);
    }
    | BIF_ABS LPAREN expression RPAREN {
        $$ = create_function_call_node("abs", $3);
    }
    | BIF_CHAR LPAREN expression RPAREN {
        $$ = create_function_call_node("char", $3);
    }
    | BIF_INT LPAREN expression RPAREN {
        $$ = create_function_call_node("int", $3);
    }
    | BIF_DEC LPAREN argument_list RPAREN {
        $$ = create_function_call_node("dec", $3);
    }
    | BIF_FLOAT LPAREN expression RPAREN {
        $$ = create_function_call_node("float", $3);
    }
    | BIF_EDITC LPAREN argument_list RPAREN {
        $$ = create_function_call_node("editc", $3);
    }
    | BIF_EDITW LPAREN argument_list RPAREN {
        $$ = create_function_call_node("editw", $3);
    }
    | BIF_DATE LPAREN RPAREN {
        ASTNode* empty = create_list_node(NODE_PARAMETER_LIST);
        $$ = create_function_call_node("date", empty);
    }
    | BIF_DATE LPAREN expression RPAREN {
        $$ = create_function_call_node("date", $3);
    }
    | BIF_TIME LPAREN RPAREN {
        ASTNode* empty = create_list_node(NODE_PARAMETER_LIST);
        $$ = create_function_call_node("time", empty);
    }
    | BIF_TIME LPAREN expression RPAREN {
        $$ = create_function_call_node("time", $3);
    }
    | BIF_TIMESTAMP LPAREN RPAREN {
        ASTNode* empty = create_list_node(NODE_PARAMETER_LIST);
        $$ = create_function_call_node("timestamp", empty);
    }
    | BIF_TIMESTAMP LPAREN expression RPAREN {
        $$ = create_function_call_node("timestamp", $3);
    }
    | BIF_ADDR LPAREN expression RPAREN {
        $$ = create_function_call_node("addr", $3);
    }
    | BIF_ELEM LPAREN expression RPAREN {
        $$ = create_function_call_node("elem", $3);
    }
    | BIF_STR LPAREN argument_list RPAREN {
        $$ = create_function_call_node("str", $3);
    }
    | BIF_PARMS LPAREN RPAREN {
        ASTNode* empty = create_list_node(NODE_PARAMETER_LIST);
        $$ = create_function_call_node("parms", empty);
    }
    | BIF_OCCUR LPAREN expression RPAREN {
        $$ = create_function_call_node("occur", $3);
    }
    | BIF_FOUND LPAREN RPAREN {
        ASTNode* empty = create_list_node(NODE_PARAMETER_LIST);
        $$ = create_function_call_node("found", empty);
    }
    | BIF_EOF LPAREN IDENTIFIER RPAREN {
        ASTNode* args = create_list_node(NODE_PARAMETER_LIST);
        add_to_list(args, create_identifier_node($3));
        $$ = create_function_call_node("eof", args);
        free($3);
    }
    | BIF_EQUAL LPAREN RPAREN {
        ASTNode* empty = create_list_node(NODE_PARAMETER_LIST);
        $$ = create_function_call_node("equal", empty);
    }
    | BIF_ERROR LPAREN RPAREN {
        ASTNode* empty = create_list_node(NODE_PARAMETER_LIST);
        $$ = create_function_call_node("error", empty);
    }
    | BIF_OPEN LPAREN expression RPAREN {
        $$ = create_function_call_node("open", $3);
    }
    /* Additional String BIFs */
    | BIF_SCANRPL LPAREN argument_list RPAREN {
        $$ = create_function_call_node("scanrpl", $3);
    }
    | BIF_CHECK LPAREN argument_list RPAREN {
        $$ = create_function_call_node("check", $3);
    }
    | BIF_CHECKR LPAREN argument_list RPAREN {
        $$ = create_function_call_node("checkr", $3);
    }
    | BIF_SPLIT LPAREN argument_list RPAREN {
        $$ = create_function_call_node("split", $3);
    }
    /* Additional Numeric BIFs */
    | BIF_DECH LPAREN argument_list RPAREN {
        $$ = create_function_call_node("dech", $3);
    }
    | BIF_DECPOS LPAREN expression RPAREN {
        $$ = create_function_call_node("decpos", $3);
    }
    | BIF_INTH LPAREN expression RPAREN {
        $$ = create_function_call_node("inth", $3);
    }
    | BIF_SQRT LPAREN expression RPAREN {
        $$ = create_function_call_node("sqrt", $3);
    }
    | BIF_REM LPAREN argument_list RPAREN {
        $$ = create_function_call_node("rem", $3);
    }
    | BIF_DIV LPAREN argument_list RPAREN {
        $$ = create_function_call_node("div_func", $3);
    }
    | BIF_EDITFLT LPAREN expression RPAREN {
        $$ = create_function_call_node("editflt", $3);
    }
    | BIF_UNS LPAREN expression RPAREN {
        $$ = create_function_call_node("uns", $3);
    }
    | BIF_UNSH LPAREN expression RPAREN {
        $$ = create_function_call_node("unsh", $3);
    }
    /* Date/Time BIFs */
    | BIF_YEARS LPAREN expression RPAREN {
        $$ = create_function_call_node("years", $3);
    }
    | BIF_MONTHS LPAREN expression RPAREN {
        $$ = create_function_call_node("months", $3);
    }
    | BIF_DAYS LPAREN expression RPAREN {
        $$ = create_function_call_node("days", $3);
    }
    | BIF_HOURS LPAREN expression RPAREN {
        $$ = create_function_call_node("hours", $3);
    }
    | BIF_MINUTES LPAREN expression RPAREN {
        $$ = create_function_call_node("minutes", $3);
    }
    | BIF_SECONDS LPAREN expression RPAREN {
        $$ = create_function_call_node("seconds", $3);
    }
    | BIF_MSECONDS LPAREN expression RPAREN {
        $$ = create_function_call_node("mseconds", $3);
    }
    | BIF_DIFF LPAREN argument_list RPAREN {
        $$ = create_function_call_node("diff", $3);
    }
    | BIF_SUBDUR LPAREN argument_list RPAREN {
        $$ = create_function_call_node("subdur", $3);
    }
    | BIF_ADDDUR LPAREN argument_list RPAREN {
        $$ = create_function_call_node("adddur", $3);
    }
    /* Array BIFs */
    | BIF_LOOKUP LPAREN argument_list RPAREN {
        $$ = create_function_call_node("lookup", $3);
    }
    | BIF_LOOKUPLT LPAREN argument_list RPAREN {
        $$ = create_function_call_node("lookuplt", $3);
    }
    | BIF_LOOKUPLE LPAREN argument_list RPAREN {
        $$ = create_function_call_node("lookuple", $3);
    }
    | BIF_LOOKUPGT LPAREN argument_list RPAREN {
        $$ = create_function_call_node("lookupgt", $3);
    }
    | BIF_LOOKUPGE LPAREN argument_list RPAREN {
        $$ = create_function_call_node("lookupge", $3);
    }
    | BIF_SUBARR LPAREN argument_list RPAREN {
        $$ = create_function_call_node("subarr", $3);
    }
    | BIF_SORTARR LPAREN argument_list RPAREN {
        $$ = create_function_call_node("sortarr", $3);
    }
    /* Conversion/Bit BIFs */
    | BIF_GRAPH LPAREN expression RPAREN {
        $$ = create_function_call_node("graph", $3);
    }
    | BIF_UCS2 LPAREN expression RPAREN {
        $$ = create_function_call_node("ucs2", $3);
    }
    | BIF_HEX LPAREN expression RPAREN {
        $$ = create_function_call_node("hex", $3);
    }
    | BIF_BITAND LPAREN argument_list RPAREN {
        $$ = create_function_call_node("bitand", $3);
    }
    | BIF_BITOR LPAREN argument_list RPAREN {
        $$ = create_function_call_node("bitor", $3);
    }
    | BIF_BITXOR LPAREN argument_list RPAREN {
        $$ = create_function_call_node("bitxor", $3);
    }
    | BIF_BITNOT LPAREN expression RPAREN {
        $$ = create_function_call_node("bitnot", $3);
    }
    /* I/O BIFs */
    | BIF_STATUS LPAREN RPAREN {
        ASTNode* empty = create_list_node(NODE_PARAMETER_LIST);
        $$ = create_function_call_node("status", empty);
    }
    | BIF_RECORD LPAREN RPAREN {
        ASTNode* empty = create_list_node(NODE_PARAMETER_LIST);
        $$ = create_function_call_node("record", empty);
    }
    /* Memory/System BIFs */
    | BIF_ALLOC LPAREN expression RPAREN {
        $$ = create_function_call_node("alloc", $3);
    }
    | BIF_REALLOC LPAREN argument_list RPAREN {
        $$ = create_function_call_node("realloc", $3);
    }
    | BIF_DEALLOC LPAREN expression RPAREN {
        $$ = create_function_call_node("dealloc", $3);
    }
    | BIF_PARMNUM LPAREN RPAREN {
        ASTNode* empty = create_list_node(NODE_PARAMETER_LIST);
        $$ = create_function_call_node("parmnum", empty);
    }
    | BIF_PARSER LPAREN argument_list RPAREN {
        $$ = create_function_call_node("parser", $3);
    }
    /* Data Area BIF */
    | BIF_DTAARA LPAREN argument_list RPAREN {
        $$ = create_function_call_node("dtaara", $3);
    }
    /* Data Structure BIFs */
    | BIF_NULLIND LPAREN expression RPAREN {
        $$ = create_function_call_node("nullind", $3);
    }
    | BIF_FIELDS LPAREN expression RPAREN {
        $$ = create_function_call_node("fields", $3);
    }
    | BIF_LIST LPAREN argument_list RPAREN {
        $$ = create_function_call_node("list", $3);
    }
    /* XML/JSON BIFs */
    | BIF_XML LPAREN argument_list RPAREN {
        $$ = create_function_call_node("xml", $3);
    }
    | BIF_DATA LPAREN argument_list RPAREN {
        $$ = create_function_call_node("data", $3);
    }
    /* Miscellaneous BIFs */
    | BIF_KDS LPAREN argument_list RPAREN {
        $$ = create_function_call_node("kds", $3);
    }
    | BIF_OMITTED LPAREN RPAREN {
        ASTNode* empty = create_list_node(NODE_PARAMETER_LIST);
        $$ = create_function_call_node("omitted", empty);
    }
    | BIF_RANGE LPAREN argument_list RPAREN {
        $$ = create_function_call_node("range", $3);
    }
    | BIF_PADDR LPAREN expression RPAREN {
        $$ = create_function_call_node("paddr", $3);
    }
    | BIF_PROC LPAREN RPAREN {
        ASTNode* empty = create_list_node(NODE_PARAMETER_LIST);
        $$ = create_function_call_node("proc", empty);
    }
    | IDENTIFIER LPAREN argument_list RPAREN {
        $$ = create_function_call_node($1, $3);
        free($1);
    }
    ;

argument_list:
    /* empty */ {
        $$ = create_list_node(NODE_PARAMETER_LIST);
    }
    | expression {
        ASTNode* list = create_list_node(NODE_PARAMETER_LIST);
        add_to_list(list, $1);
        $$ = list;
    }
    | argument_list COLON expression {
        add_to_list($1, $3);
        $$ = $1;
    }
    ;

%%

void yyerror(const char* s) {
    fprintf(stderr, "Parse error at line %d, column %d: %s\n", line_num, col_num, s);
}
