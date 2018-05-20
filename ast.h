extern int vars[26];

typedef enum { 
	typeCon, typeId, typeOpr 
} nodeEnum;

typedef struct {
    int value; 
} conNodeType;

typedef struct {
    int i; 
} idNodeType;

typedef struct {
    int myOperator; 
    int nodeNum; 
    struct nodeTypeTag *myOperand[1];
} oprNodeType;

typedef struct nodeTypeTag {
    nodeEnum type; 

    union {
        conNodeType constant; 
        idNodeType identifier; 
        oprNodeType operation;
    };
} makeType;


