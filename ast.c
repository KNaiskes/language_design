#include <stdio.h>
#include <string.h>
#include "ast.h"
#include "grammar.tab.h"

void readFromFile();
void printFile();

int ex(makeType *p) {
    if (!p) return 0;
    switch(p->type) {
    case typeCon:       return p->constant.value;
    case typeId:        return vars[p->identifier.i];
    case typeOpr:
        switch(p->operation.myOperator) {
        case WHILE:     while(ex(p->operation.myOperand[0])) ex(p->operation.myOperand[1]); return 0;
        case IF:        if (ex(p->operation.myOperand[0]))
                            ex(p->operation.myOperand[1]);
                        else if (p->operation.nodeNum > 2)
                            ex(p->operation.myOperand[2]);
                        return 0;
        case PRINT:     printf("%d\n", ex(p->operation.myOperand[0])); return 0;
	case WORDCOUNTER:  if(ex(p->operation.myOperand[0]) == 1) {
				readFromFile();
				return 0;
			}
	case PRINTFILE: if(ex(p->operation.myOperand[0]) == 1){
				printFile();
				return 0;
			}
        case ';':       ex(p->operation.myOperand[0]); return ex(p->operation.myOperand[1]);
        case '=':       return vars[p->operation.myOperand[0]->identifier.i] = ex(p->operation.myOperand[1]);
        case UMINUS:    return -ex(p->operation.myOperand[0]);
        case '+':       return ex(p->operation.myOperand[0]) + ex(p->operation.myOperand[1]);
        case '-':       return ex(p->operation.myOperand[0]) - ex(p->operation.myOperand[1]);
        case '*':       return ex(p->operation.myOperand[0]) * ex(p->operation.myOperand[1]);
        case '/':       return ex(p->operation.myOperand[0]) / ex(p->operation.myOperand[1]);
        case '<':       return ex(p->operation.myOperand[0]) < ex(p->operation.myOperand[1]);
        case '>':       return ex(p->operation.myOperand[0]) > ex(p->operation.myOperand[1]);
        case GE:        return ex(p->operation.myOperand[0]) >= ex(p->operation.myOperand[1]);
        case LE:        return ex(p->operation.myOperand[0]) <= ex(p->operation.myOperand[1]);
        case NE:        return ex(p->operation.myOperand[0]) != ex(p->operation.myOperand[1]);
        case EQ:        return ex(p->operation.myOperand[0]) == ex(p->operation.myOperand[1]);
        }
    }
    return 0;
}

void readFromFile() {
	
    FILE* file;

    char ch;
    int characters, words, lines;

    file = fopen("examples/test.txt", "r");

    if(file){

    	characters = words = lines = 0;
    	while ((ch = fgetc(file)) != EOF)
    	{
    	    characters++;

    	    if (ch == '\n' || ch == '\0'){
    	        lines++;
    	    }

    	    if (ch == ' ' || ch == '\t' || ch == '\n' || ch == '\0'){
    	        words++;
    	    }
    	}

    	if (characters > 0){
    	    words++;
    	    lines++;
    	}

    	printf("\n");
    	printf("Total characters = %d\n", characters - 1);
    	printf("Total words      = %d\n", words - 1);
    	printf("Total lines      = %d\n", lines - 1);


    	fclose(file);
    }
    else{
	    printf("File examples/test.txt, does not exist\n");
    }
}

void printFile() {

	int c;
	FILE *file;
	file = fopen("examples/test.txt", "r");
	printf("----Text from file ----\n");
	if(file){
		while((c = getc(file)) != EOF){
			putchar(c);
		}
		fclose(file);
		printf("----End of file----\n");
	}
	else { 
		printf("File test.txt, does not exist\n");
	}
}
