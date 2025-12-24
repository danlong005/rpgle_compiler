%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <ctype.h>
#include "ast.h"

int line_num = 1;
int col_num = 1;

/* Forward declaration - will be defined by bison */
#ifndef YY_TYPEDEF_YY_SCANNER_T
#define YY_TYPEDEF_YY_SCANNER_T
typedef void* yyscan_t;
#endif

void count_newlines() {
    for (int i = 0; i < yyleng; i++) {
        if (yytext[i] == '\n') {
            line_num++;
            col_num = 1;
        }
    }
}

char* normalize_identifier(const char* str) {
    char* result = strdup(str);
    for (int i = 0; result[i]; i++) {
        result[i] = tolower(result[i]);
    }
    return result;
}

/* Include after our definitions */
#include "rpgle.tab.h"
%}

%option noyywrap
%option case-insensitive

DIGIT       [0-9]
LETTER      [a-zA-Z]
ALPHANUM    [a-zA-Z0-9_]
IDENTIFIER  {LETTER}{ALPHANUM}*
INTEGER     {DIGIT}+
DECIMAL     {DIGIT}+\.{DIGIT}+
STRING      '([^'\n]|'')*'
DATE_LIT    [dD]'[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]'
TIME_LIT    [tT]'[0-9][0-9]:[0-9][0-9]:[0-9][0-9]'
TIMESTAMP_LIT [zZ]'[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]-[0-9][0-9]\.[0-9][0-9]\.[0-9][0-9]\.[0-9][0-9][0-9][0-9][0-9][0-9]'

%%

    /* Free Format Directive */
"**FREE"                { /* Free format marker - ignore */ }
"**free"                { /* Free format marker - ignore */ }

    /* Comments */
"//".*                  { /* Single-line comment */ }
"/*"([^*]|\*+[^*/])*\*+"/" { count_newlines(); /* Multi-line comment */ }

    /* Control Options */
"CTL-OPT"               { return CTL_OPT; }

    /* Declaration Keywords */
"DCL-S"                 { return DCL_S; }
"DCL-C"                 { return DCL_C; }
"DCL-F"                 { return DCL_F; }
"DCL-DS"                { return DCL_DS; }
"DCL-PR"                { return DCL_PR; }
"DCL-PI"                { return DCL_PI; }
"DCL-PROC"              { return DCL_PROC; }
"END-PROC"              { return END_PROC; }
"END-DS"                { return END_DS; }
"END-PR"                { return END_PR; }
"END-PI"                { return END_PI; }

    /* Data Types */
"CHAR"                  { return CHAR; }
"VARCHAR"               { return VARCHAR; }
"INT"                   { return INT; }
"UNS"                   { return UNS; }
"PACKED"                { return PACKED; }
"ZONED"                 { return ZONED; }
"BINDEC"                { return BINDEC; }
"IND"                   { return IND; }
"DATE"                  { return DATE; }
"TIME"                  { return TIME; }
"TIMESTAMP"             { return TIMESTAMP; }
"POINTER"               { return POINTER; }
"LIKE"                  { return LIKE; }
"LIKEDS"                { return LIKEDS; }
"LIKEFILE"              { return LIKEFILE; }
"DIM"                   { return DIM; }
"CONST"                 { return CONST; }
"INZ"                   { return INZ; }
"QUALIFIED"             { return QUALIFIED; }
"LIKEDS"                { return LIKEDS; }
"STATIC"                { return STATIC; }
"EXTPROC"               { return EXTPROC; }
"EXPORT"                { return EXPORT; }
"IMPORT"                { return IMPORT; }
"VALUE"                 { return VALUE; }
"NOOPT"                 { return NOOPT; }

    /* Control Flow */
"IF"                    { return IF; }
"ELSE"                  { return ELSE; }
"ELSEIF"                { return ELSEIF; }
"ENDIF"                 { return ENDIF; }
"FOR"                   { return FOR; }
"ENDFOR"                { return ENDFOR; }
"DOW"                   { return DOW; }
"DOU"                   { return DOU; }
"ENDDO"                 { return ENDDO; }
"SELECT"                { return SELECT; }
"WHEN"                  { return WHEN; }
"OTHER"                 { return OTHER; }
"ENDSL"                 { return ENDSL; }
"ITER"                  { return ITER; }
"LEAVE"                 { return LEAVE; }

    /* Operations */
"EVAL"                  { return EVAL; }
"RETURN"                { return RETURN; }
"CALLP"                 { return CALLP; }
"CLEAR"                 { return CLEAR; }
"RESET"                 { return RESET; }
"DSPLY"                 { return DSPLY; }

    /* I/O Operations */
"CHAIN"                 { return CHAIN; }
"READ"                  { return READ; }
"READE"                 { return READE; }
"READP"                 { return READP; }
"READPE"                { return READPE; }
"WRITE"                 { return WRITE; }
"UPDATE"                { return UPDATE; }
"DELETE"                { return DELETE; }
"SETLL"                 { return SETLL; }
"SETGT"                 { return SETGT; }
"OPEN"                  { return OPEN; }
"CLOSE"                 { return CLOSE; }

    /* Built-in Functions */
"%TRIM"                 { return BIF_TRIM; }
"%TRIMR"                { return BIF_TRIMR; }
"%TRIML"                { return BIF_TRIML; }
"%SUBST"                { return BIF_SUBST; }
"%LEN"                  { return BIF_LEN; }
"%SIZE"                 { return BIF_SIZE; }
"%ELEM"                 { return BIF_ELEM; }
"%ABS"                  { return BIF_ABS; }
"%ADDR"                 { return BIF_ADDR; }
"%CHAR"                 { return BIF_CHAR; }
"%DATE"                 { return BIF_DATE; }
"%TIME"                 { return BIF_TIME; }
"%TIMESTAMP"            { return BIF_TIMESTAMP; }
"%FOUND"                { return BIF_FOUND; }
"%EOF"                  { return BIF_EOF; }
"%EQUAL"                { return BIF_EQUAL; }
"%ERROR"                { return BIF_ERROR; }
"%SCAN"                 { return BIF_SCAN; }
"%REPLACE"              { return BIF_REPLACE; }
"%XLATE"                { return BIF_XLATE; }
"%INT"                  { return BIF_INT; }
"%DEC"                  { return BIF_DEC; }
"%FLOAT"                { return BIF_FLOAT; }
"%EDITC"                { return BIF_EDITC; }
"%EDITW"                { return BIF_EDITW; }
"%STR"                  { return BIF_STR; }
"%PARMS"                { return BIF_PARMS; }
"%OCCUR"                { return BIF_OCCUR; }
"%OPEN"                 { return BIF_OPEN; }

    /* Additional String BIFs */
"%SCANRPL"              { return BIF_SCANRPL; }
"%CHECK"                { return BIF_CHECK; }
"%CHECKR"               { return BIF_CHECKR; }
"%SPLIT"                { return BIF_SPLIT; }

    /* Additional Numeric BIFs */
"%DECH"                 { return BIF_DECH; }
"%DECPOS"               { return BIF_DECPOS; }
"%INTH"                 { return BIF_INTH; }
"%SQRT"                 { return BIF_SQRT; }
"%REM"                  { return BIF_REM; }
"%DIV"                  { return BIF_DIV; }
"%EDITFLT"              { return BIF_EDITFLT; }
"%UNS"                  { return BIF_UNS; }
"%UNSH"                 { return BIF_UNSH; }

    /* Date/Time BIFs */
"%YEARS"                { return BIF_YEARS; }
"%MONTHS"               { return BIF_MONTHS; }
"%DAYS"                 { return BIF_DAYS; }
"%HOURS"                { return BIF_HOURS; }
"%MINUTES"              { return BIF_MINUTES; }
"%SECONDS"              { return BIF_SECONDS; }
"%MSECONDS"             { return BIF_MSECONDS; }
"%DIFF"                 { return BIF_DIFF; }
"%SUBDUR"               { return BIF_SUBDUR; }
"%ADDDUR"               { return BIF_ADDDUR; }

    /* Array BIFs */
"%LOOKUP"               { return BIF_LOOKUP; }
"%LOOKUPLT"             { return BIF_LOOKUPLT; }
"%LOOKUPLE"             { return BIF_LOOKUPLE; }
"%LOOKUPGT"             { return BIF_LOOKUPGT; }
"%LOOKUPGE"             { return BIF_LOOKUPGE; }
"%SUBARR"               { return BIF_SUBARR; }
"%SORTARR"              { return BIF_SORTARR; }

    /* Conversion/Bit BIFs */
"%GRAPH"                { return BIF_GRAPH; }
"%UCS2"                 { return BIF_UCS2; }
"%HEX"                  { return BIF_HEX; }
"%BITAND"               { return BIF_BITAND; }
"%BITOR"                { return BIF_BITOR; }
"%BITXOR"               { return BIF_BITXOR; }
"%BITNOT"               { return BIF_BITNOT; }

    /* I/O BIFs */
"%STATUS"               { return BIF_STATUS; }
"%RECORD"               { return BIF_RECORD; }

    /* Memory/System BIFs */
"%ALLOC"                { return BIF_ALLOC; }
"%REALLOC"              { return BIF_REALLOC; }
"%DEALLOC"              { return BIF_DEALLOC; }
"%PARMNUM"              { return BIF_PARMNUM; }
"%PARSER"               { return BIF_PARSER; }

    /* Data Area BIF */
"%DTAARA"               { return BIF_DTAARA; }

    /* Data Structure BIFs */
"%NULLIND"              { return BIF_NULLIND; }
"%FIELDS"               { return BIF_FIELDS; }
"%LIST"                 { return BIF_LIST; }

    /* XML/JSON BIFs */
"%XML"                  { return BIF_XML; }
"%DATA"                 { return BIF_DATA; }

    /* Miscellaneous BIFs */
"%KDS"                  { return BIF_KDS; }
"%OMITTED"              { return BIF_OMITTED; }
"%RANGE"                { return BIF_RANGE; }
"%PADDR"                { return BIF_PADDR; }
"%PROC"                 { return BIF_PROC; }

    /* Operators */
"+"                     { return PLUS; }
"-"                     { return MINUS; }
"*"                     { return MULT; }
"/"                     { return DIV; }
"**"                    { return POWER; }
"="                     { return ASSIGN; }
"=="                    { return EQ; }
"<>"                    { return NE; }
"<"                     { return LT; }
"<="                    { return LE; }
">"                     { return GT; }
">="                    { return GE; }
"AND"                   { return AND; }
"OR"                    { return OR; }
"NOT"                   { return NOT; }

    /* Delimiters */
"("                     { return LPAREN; }
")"                     { return RPAREN; }
":"                     { return COLON; }
";"                     { return SEMICOLON; }
","                     { return COMMA; }
"."                     { return DOT; }

    /* Special Keywords */
"*ON"                   { return CONSTANT_ON; }
"*OFF"                  { return CONSTANT_OFF; }
"*BLANK"                { return CONSTANT_BLANK; }
"*BLANKS"               { return CONSTANT_BLANKS; }
"*ZERO"                 { return CONSTANT_ZERO; }
"*ZEROS"                { return CONSTANT_ZEROS; }
"*NULL"                 { return CONSTANT_NULL; }
"*HIVAL"                { return CONSTANT_HIVAL; }
"*LOVAL"                { return CONSTANT_LOVAL; }
"*ALL"                  { return CONSTANT_ALL; }
"*NOPASS"               { return NOPASS; }
"*OMIT"                 { return OMIT; }
"BY"                    { return BY; }
"TO"                    { return TO; }
"DOWNTO"                { return DOWNTO; }

    /* Literals and Identifiers */
{DATE_LIT}              { yylval.str_val = strdup(yytext); return DATE_LITERAL; }
{TIME_LIT}              { yylval.str_val = strdup(yytext); return TIME_LITERAL; }
{TIMESTAMP_LIT}         { yylval.str_val = strdup(yytext); return TIMESTAMP_LITERAL; }
{INTEGER}               { yylval.int_val = atoi(yytext); return INTEGER_LITERAL; }
{DECIMAL}               { yylval.float_val = atof(yytext); return DECIMAL_LITERAL; }
{STRING}                { 
                            yylval.str_val = strdup(yytext); 
                            return STRING_LITERAL; 
                        }
{IDENTIFIER}            { 
                            yylval.str_val = normalize_identifier(yytext); 
                            return IDENTIFIER; 
                        }

    /* Whitespace */
[ \t]+                  { col_num += yyleng; }
\n                      { line_num++; col_num = 1; }
\r\n                    { line_num++; col_num = 1; }

    /* Unknown character */
.                       { 
                            fprintf(stderr, "Unknown character: %s at line %d, col %d\n", 
                                    yytext, line_num, col_num); 
                            return yytext[0];
                        }

%%
