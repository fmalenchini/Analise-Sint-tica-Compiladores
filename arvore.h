#include <stdio.h>
#include <stdlib.h>

FILE *yyin;
FILE *yyout;
FILE *out;

typedef enum { tipoConst, tipoId, tipoOperador, tipoNaoTerminal } noEnum;
typedef enum { Program, DecVar, DecFunc, ParamList, Block, Stmt, FuncCall, 
ArgList, Expr, BinOp, UnOp, Type,Assign,Return,expTPLUS,expTMINUS,expTMINUS2,
expTDIV,expTTIMES,expTLT, expTGT, expTEQ, expTNEQ, expTLTEQ, expTGTEQ, expTAND,
expTOR, expTNOT, While, If, Break, Continue, Else, BlockAux} noNaoTerminais;

/* contantes */
typedef struct {
    char  valor[50];                    /* value of constant */
} constanteNoTipo;

/* identificadores */
typedef struct {
    char  i[50];                      /* subscript to sym array */
} idNoTipo;

/* operadores */
typedef struct {
    int oper;                   /* operator */
    int nops;                   /* number of operands */
    struct nodeTypeTag *op[1];	/* operands, extended at runtime */
    struct nodeTypeTag *pai;
} oprNoTipo;

/* nao terminais */
typedef struct {
    noNaoTerminais terminais;
	 int numFilhos;                   
    struct nodeTypeTag *filhos[1];
    struct nodeTypeTag *pai;
    /* number of operands */
    } naoTerminal;


typedef struct nodeTypeTag {
    noEnum tipo;             /* type of node */

    union {
        constanteNoTipo con;        /* constants */
        idNoTipo id;          /* identifiers */
        oprNoTipo opr;    		    /* operators */
        naoTerminal naoTerm;
    };
} noTipo;

extern int sym[26];

//ESTRUTURA PARA TABELA DE SIMBOLOS

struct NodeLista{
	int linha; //numero da linha
	char tipo[6];  //tipo void ou int
	char pai[50]; //nome da funcao ou trcho que chamou
	char tipoVar; // se eh Local (L) ou  global (G)
	char nomeVar[50]; //nome da variavel
	char valor[50]; //valor da variavel
	struct NodeLista *prox;
}; 
typedef struct NodeLista nodeLista;


/** @brief Wrapper para malloc com verificação de erro
 */
void* xmalloc(size_t t);

/** @brief Wrapper para realloc com verificação de erro
 */
void* xrealloc(void* p, size_t t);

/** @brief Wrapper para calloc com verificação de erro
 */
void* xcalloc(size_t n, size_t t);



