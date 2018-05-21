%{
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <stdarg.h>

#include "ast.h"

extern FILE *yyin; //reads from file(s) instead of keyboard

void delNode(makeType *p);
makeType *operation(int myOperator, int nodeNum, ...); //variadic function - ellipsis
makeType *identifier(int i);
makeType *constant(int value);
int ex(makeType *p);
int yylex(void);

void yyerror(char *s);
int vars[26]; 
%}

%union {
    int makeInt; 
    char makeChar; 
    makeType *myType; 
};

%token <makeInt> INTEGER
%token <makeChar> VARIABLE
%token WHILE 
%token IF 
%token PRINT 
%token WORDCOUNTER
%token PRINTFILE
%token INT
%nonassoc IFX
%nonassoc ELSE

%left GE LE EQ NE '>' '<'
%left '+' '-'
%left '*' '/'
%nonassoc UMINUS

%type <myType> statement expression statements_bucket 

%%

program:
        function                { exit(0); }
        ;

function:
          function statement { ex($2); delNode($2); }
        | 
        ;

statement:
          ';'                            	{ $$ = operation(';', 2, NULL, NULL); }
        | expression ';'                        { $$ = $1; }
        | PRINT '(' expression ')' ';'          { $$ = operation(PRINT, 1, $3); }
	| WORDCOUNTER '(' expression ')'  	{ $$ = operation(WORDCOUNTER,1,$3); }
	| PRINTFILE '(' expression ')' ';'	{ $$ = operation(PRINTFILE,1,$3);}
        | INT VARIABLE '=' expression ';'       { $$ = operation('=', 2, identifier($2), $4); }
        | WHILE '(' expression ')' '{' statement '}' { 
		$$ = operation(WHILE, 2, $3, $6); 
	}
        | IF '(' expression ')''{' statement %prec IFX '}'{ 
		$$ = operation(IF, 2, $3, $6); 
	}
        | IF '(' expression ')' '{' statement '}' ELSE '{' statement '}' { 
		$$ = operation(IF, 3, $3, $6, $10); 
	}
        | '{' statements_bucket '}'              { $$ = $2; }
        ;

statements_bucket:
          statement 			{ $$ = $1; }
        | statements_bucket statement 	{ $$ = operation(';', 2, $1, $2); }
        ;

expression:
          INTEGER               		{ $$ = constant($1); }
        | VARIABLE              		{ $$ = identifier($1); 	}
        | '-' expression %prec UMINUS 		{ $$ = operation(UMINUS, 1, $2);  }
        | expression '+' expression         	{ $$ = operation('+', 2, $1, $3); }
        | expression '-' expression         	{ $$ = operation('-', 2, $1, $3); }
        | expression '*' expression         	{ $$ = operation('*', 2, $1, $3); }
        | expression '/' expression         	{ $$ = operation('/', 2, $1, $3); }
        | expression '<' expression         	{ $$ = operation('<', 2, $1, $3); }
        | expression '>' expression         	{ $$ = operation('>', 2, $1, $3); }
        | expression GE expression          	{ $$ = operation(GE, 2, $1, $3); }
        | expression LE expression          	{ $$ = operation(LE, 2, $1, $3); }
        | expression NE expression          	{ $$ = operation(NE, 2, $1, $3); }
        | expression EQ expression          	{ $$ = operation(EQ, 2, $1, $3); }
        | '(' expression ')'          		{ $$ = $2; }
        ;

%%

/* The implementation of the "tree", aftet checking the syntax
it creates a node for each valid command */

makeType *constant(int value) {
    makeType *p;

    if ((p = malloc(sizeof(makeType))) == NULL)
        yyerror("Could not allocate memory");

    p->type = typeCon;
    p->constant.value = value;

    return p;
}

makeType *identifier(int i) {
    makeType *p;

    if ((p = malloc(sizeof(makeType))) == NULL)
        yyerror("Could not allocate memory");

    p->type = typeId;
    p->identifier.i = i;

    return p;
}

makeType *operation(int myOperator, int nodeNum, ...) {
    va_list ap;
    makeType *p;
    int i;

    if ((p = malloc(sizeof(makeType) + (nodeNum-1) * sizeof(makeType *))) == NULL)
        yyerror("Could not allocate memory");

    p->type = typeOpr;
    p->operation.myOperator = myOperator;
    p->operation.nodeNum = nodeNum;
    va_start(ap, nodeNum);
    for (i = 0; i < nodeNum; i++)
        p->operation.myOperand[i] = va_arg(ap, makeType*);
    va_end(ap);
    return p;
}

void delNode(makeType *p) {
    int i;

    if (!p) return;
    if (p->type == typeOpr) {
        for (i = 0; i < p->operation.nodeNum; i++)
            delNode(p->operation.myOperand[i]);
    }
    //delete(p);
    free(p);
}

void yyerror(char *msg) {
    fprintf(stdout, "%s\n", msg);
}

int main(int argc, char *argv[]) {
	

	FILE *sourceCode = fopen(argv[1], "r");

	if(!sourceCode) {
		printf("Could not open file\n");
		printf("\n");
		printf("Enter an example as a parameter\n");
		printf("For example: ./danise examples/exam1.txt\n");
		return -1;
	}
	yyin = sourceCode;
	do {
		yyparse();
	} while(!feof(yyin));

    return 0;
}
