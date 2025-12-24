#include <stdio.h>
#include <stdlib.h>
#include "ast.h"
#include "codegen.h"

extern int yyparse();
extern FILE* yyin;
extern ASTNode* root;
extern char* main_proc_name;

void print_usage(const char* program_name) {
    fprintf(stderr, "Usage: %s [input_file] [-o output_file]\n", program_name);
    fprintf(stderr, "  If no input file is specified, reads from stdin\n");
    fprintf(stderr, "  If no output file is specified, writes to stdout\n");
}

int main(int argc, char* argv[]) {
    FILE* input = stdin;
    FILE* output = stdout;
    char* input_file = NULL;
    char* output_file = NULL;
    
    /* Parse command line arguments */
    for (int i = 1; i < argc; i++) {
        if (strcmp(argv[i], "-o") == 0) {
            if (i + 1 < argc) {
                output_file = argv[++i];
            } else {
                fprintf(stderr, "Error: -o requires an argument\n");
                print_usage(argv[0]);
                return 1;
            }
        } else if (strcmp(argv[i], "-h") == 0 || strcmp(argv[i], "--help") == 0) {
            print_usage(argv[0]);
            return 0;
        } else if (argv[i][0] != '-') {
            input_file = argv[i];
        } else {
            fprintf(stderr, "Error: Unknown option %s\n", argv[i]);
            print_usage(argv[0]);
            return 1;
        }
    }
    
    /* Open input file */
    if (input_file) {
        input = fopen(input_file, "r");
        if (!input) {
            fprintf(stderr, "Error: Cannot open input file '%s'\n", input_file);
            return 1;
        }
        yyin = input;
    }
    
    /* Parse the input */
    if (yyparse() != 0) {
        fprintf(stderr, "Parse failed\n");
        if (input_file) fclose(input);
        return 1;
    }
    
    if (!root) {
        fprintf(stderr, "Error: No AST generated\n");
        if (input_file) fclose(input);
        return 1;
    }
    
    /* Open output file */
    if (output_file) {
        output = fopen(output_file, "w");
        if (!output) {
            fprintf(stderr, "Error: Cannot open output file '%s'\n", output_file);
            if (input_file) fclose(input);
            free_ast(root);
            return 1;
        }
    }
    
    /* Generate code */
    CodeGenContext ctx;
    codegen_init(&ctx, output);
    ctx.main_proc_name = main_proc_name;
    codegen_program(&ctx, root);
    
    /* Cleanup */
    if (input_file) fclose(input);
    if (output_file) fclose(output);
    free_ast(root);
    
    return 0;
}
