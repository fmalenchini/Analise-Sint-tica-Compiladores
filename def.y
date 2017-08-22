 /* ESPECIFICACAO SINTÁTICA E SEMÂNTICA LINGUAGEM  DEF
	VIVIANE PEREIRA E FLORENCIA MALLENCHINI 2016.2 */ 
%{
#include <stdlib.h>
#include <stdio.h>
#include "arvore.h"
#define YYDEBUG 1
//#include "tabSimb.h"
#include <stdarg.h>
#include <string.h>

noTipo **noAux;
noTipo *raiz;
extern int line_num;
nodeLista* listaNomeVar;
nodeLista* listaNomeFunc;
int erromain = 0;

/* prototipos */
noTipo *opr(int oper,noTipo ** pai, int nops, ...);
noTipo *id(const char i[50]);                
noTipo *con(const char num[50]);
noTipo *naoTerm(int t,noTipo ** pai, int nFilhos, ...) ;
void addFilhoNaoTerm(noTipo ** pai, noTipo *filho);

void freeNode(noTipo *p);
int ex(noTipo *p);
extern const char *yytext;
void yyerror(char *s);
int sym[26];   



/* FUNCÇÕES PARA ANÁLISE SINTÁTICA */
nodeLista* criaLista();
void insere(nodeLista *LISTA, const char pPai[50], const char pNomeVariavel[50], const char pTipo, const char pValor[50], int pLinha);
void percorreLista(nodeLista *LISTA);
void iniciaLista(nodeLista *LISTA);
int vazia(nodeLista *LISTA);
%}

%union {
	const char * val;
	const char *string;
	noTipo *nPtr;
}
 /* TOKENS */
%start input

%token T_DEF
%token T_IF
%token T_ELSE
%token T_WHILE	
%token T_RETURN
%token T_BREAK
%token T_CONTINUE
%token T_INT
%token T_VOID

%token <val> T_NUM
%token <string> T_NOME

%token T_OPENPAR
%token T_OPENCHAVE
%token T_OPENCOCHETE
%token T_CLOSEPAR
%token T_CLOSECHAVE
%token T_CLOSECOCHETE		
%token T_VIRG
%token T_PONTOVIRG
%token T_EQUAL

%token T_SOMA
%token T_SUB
%token T_MULT
%token T_DIV
%token T_LT
%token T_GT
%token T_LTEQ
%token T_GTEQ
%token T_IGUALIGUAL
%token T_DIF
%token T_AND
%token T_OR
%token T_NAOIGUAL 
       

%left T_OR
%left T_AND
%left T_IGUALIGUAL T_DIF T_LTEQ T_GTEQ T_LT T_GT
%left T_SUB T_SOMA
%left T_MULT T_DIV
%left T_NAOIGUAL
%left UNARY_OPERATOR

%type <nPtr> Program DecVar DecVarOp ParamList DecFunc ArgListExpOp  DeclList 
%type <nPtr> DecFuncoP ParamListOp Block DecVarLoop_Block StmLoop_Block Declaration StmtElse_Op
%type <nPtr> Stmt returnOp_Stmt FuncCall ArgListOp ArgList 
%type <nPtr> Expr TypeFunc TypeVar Assign //Return 

%% /* Gramatica def */

input: Program  { raiz = $1;  verificaMain(); ex(raiz);}
;

Program: DeclList 
;

DeclList:  Declaration DeclList {
									if($1 != NULL)	
									{
									   $$ = naoTerm(Program,&$$,1,$1);
                                       
									}
									// aproveitando a recursao, vai add os filhos de $2 como filhos de $$ tambem
									if($2 != NULL)
									{
									  int i;
                                      for ( i = 0; i < $2->naoTerm.numFilhos ; ++i )
                                      {
                                           addFilhoNaoTerm(&$$, $2->naoTerm.filhos[i]);
                                      }
                                    }
                                } |  {$$ = NULL;} 
;

Declaration: DecVar | DecFunc 
;

DecVar: TypeVar T_NOME DecVarOp T_PONTOVIRG { $$ = naoTerm(DecVar,&$$,2,id($2),$3); } 
;

DecVarOp: T_EQUAL Expr  { $$ = opr(T_EQUAL, &$$, 1, $2); }  | { $$ = NULL;}
;

DecFunc: T_DEF TypeFunc T_NOME T_OPENPAR DecFuncoP T_CLOSEPAR Block {if(strcmp($3, "main")==0) erromain = 1; $$ = naoTerm(DecFunc,&$$,3,id($3),$5,$7); }
;

DecFuncoP: ParamList | {$$ = naoTerm(ParamList,&$$,1,NULL);}
;

ParamList: TypeVar T_NOME ParamListOp { $$ = naoTerm(ParamList,&$$,2,id($2),$3);  }
;

ParamListOp: T_VIRG TypeVar T_NOME ParamListOp  { $$ = opr(T_VIRG, &$$,2, id($3),$4); } | { $$ = NULL;} 
;

Block: T_OPENCHAVE DecVarLoop_Block StmLoop_Block T_CLOSECHAVE { $$ = naoTerm(Block,&$$,2,$2,$3); noAux = &$$; }
;

DecVarLoop_Block: DecVar DecVarLoop_Block {
                                              $$ = naoTerm(BlockAux,&$$,1,$1);
                                            // aproveitando a recursao, vai add os filhos de $2 como filhos de $$ tambem
                                             if($2 != NULL)
                                             {
                                               int i;
                                               for ( i = 0; i < $2->naoTerm.numFilhos ; ++i )
                                               {
                                                  addFilhoNaoTerm(&$$, $2->naoTerm.filhos[i]); 
                                                }
                                            }
                                        } | { $$ = NULL; } 
;

StmLoop_Block: Stmt StmLoop_Block  {
	                                 $$ = naoTerm(BlockAux,&$$,1,$1);
	                                 // aproveitando a recursao, vai add os filhos de $2 como filhos de $$ tambem
                                    if($2 != NULL)
                                    {
                                       int i;
                                       for ( i = 0; i < $2->naoTerm.numFilhos ; ++i )
                                       {
                                            addFilhoNaoTerm(&$$, $2->naoTerm.filhos[i]); 
                                       }
                                    }
                                    }  |  { $$ = NULL; } 
;

Stmt:  Assign T_PONTOVIRG 
      | FuncCall T_PONTOVIRG 
      | T_IF T_OPENPAR Expr T_CLOSEPAR Block StmtElse_Op { $$ = naoTerm(If,&$$,3,$3,$5,$6); } 
	  | T_WHILE T_OPENPAR Expr T_CLOSEPAR Block { $$ =  naoTerm(While,&$$,2,$3,$5); } 
	  | T_RETURN returnOp_Stmt T_PONTOVIRG { $$ = naoTerm(Return,&$$,1,$2); }
	  | T_BREAK T_PONTOVIRG { $$ = naoTerm(Break,&$$,1, NULL); }
	  | T_CONTINUE T_PONTOVIRG { $$ = naoTerm(Continue,&$$,1, NULL); }
;

/*Return: 
;*/

Assign : T_NOME T_EQUAL Expr { $$ = naoTerm(Assign,&$$,2,id($1),$3);}
;

returnOp_Stmt: Expr  | { $$ = NULL; }
; 

StmtElse_Op: T_ELSE Block { $$ = naoTerm(Else,&$$,1,$2); }   | { $$ = NULL; }
;

FuncCall: T_NOME T_OPENPAR ArgListOp T_CLOSEPAR { $$ = naoTerm(FuncCall,&$$,2,id($1),$3); }
;

ArgListOp: ArgList | { $$ = naoTerm(ArgList,&$$,1,NULL); } 
; 

ArgList: Expr ArgListExpOp { $$ = naoTerm(ArgList,&$$,2,$1,$2); }
;

ArgListExpOp: T_VIRG Expr ArgListExpOp { $$ = opr(T_VIRG, &$$, 2, $2,$3); } | { $$ = NULL;}
;

Expr :Expr T_SOMA Expr 			{$$ = naoTerm(expTPLUS,&$$,2,$1,$3);}
	|Expr T_SUB Expr 			{$$ = naoTerm(expTMINUS,&$$,2,$1,$3);}
	|Expr T_MULT Expr		    {$$ = naoTerm(expTTIMES,&$$,2,$1,$3);}
	|Expr T_DIV Expr			{$$ = naoTerm(expTDIV,&$$,2,$1,$3);}
	|Expr T_LT Expr				{$$ = naoTerm(expTLT,&$$,2,$1,$3);}
	|Expr T_GT Expr				{$$ = naoTerm(expTGT,&$$,2,$1,$3);}
	|Expr T_IGUALIGUAL Expr		{$$ = naoTerm(expTEQ,&$$,2,$1,$3);}
	|Expr T_DIF Expr			{$$ = naoTerm(expTNEQ,&$$,2,$1,$3);}
	|Expr T_LTEQ Expr			{$$ = naoTerm(expTLTEQ,&$$,2,$1,$3);}
	|Expr T_GTEQ Expr			{$$ = naoTerm(expTGTEQ,&$$,2,$1,$3);}
	|Expr T_AND Expr			{$$ = naoTerm(expTAND,&$$,2,$1,$3);}
	|Expr T_OR Expr				{$$ = naoTerm(expTOR,&$$,2,$1,$3);}
	| T_SUB %prec UNARY_OPERATOR Expr {$$ = naoTerm(expTMINUS2,&$$,1,$2);}
	| T_NAOIGUAL Expr			{$$ = naoTerm(expTNOT,&$$,1,$2);}
	| T_NUM					    {$$ = con($1); }
	| T_NOME					{$$ = id($1); }
    | FuncCall			| T_OPENPAR Expr T_CLOSEPAR		{ $$ = naoTerm(Expr,&$$,1,$2);}	

	; 

TypeFunc:  T_INT { $$ = naoTerm(Type, &$$,1,opr(T_INT, &$$,1, NULL)); }
      | T_VOID { $$ = naoTerm(Type,&$$,1, opr(T_VOID, &$$,1, NULL));}
     
TypeVar:  T_INT { $$ = naoTerm(Type, &$$,1,opr(T_INT, &$$,1, NULL)); }
      | T_VOID { yyerror("Tipo Incorreto"); } 
        
;
%%



/*TABELA DA SIMBOLOS*/
void iniciaLista(nodeLista *LISTA)
{
	LISTA->prox = NULL;
}

int vazia(nodeLista *LISTA)
{
	if(LISTA->prox == NULL)
		return 1;
	else
		return 0;
}
nodeLista* criaLista()
{
	nodeLista *LISTA = (nodeLista *) malloc(sizeof(nodeLista));
	if(!LISTA){
		printf("Sem memoria disponivel!\n");
		exit(1);
	}
	iniciaLista(LISTA);
	return LISTA;
}

void insere(nodeLista *LISTA, const char pPai[50], const char pNomeVariavel[50], const char pTipo, const char pValor[50], int pLinha)
{
	nodeLista *novo=(nodeLista *) malloc(sizeof(nodeLista));
	if(!novo){
		printf("Sem memoria disponivel!\n");
		exit(1);
	}
	novo->linha = pLinha;
    strcpy(novo->pai, pPai);
    novo->tipoVar = pTipo;
    strcpy(novo->nomeVar, pNomeVariavel);
    strcpy(novo->valor,pValor);
	novo->prox = NULL;
	
	if(vazia(LISTA))
		LISTA->prox=novo;
	else{
		nodeLista *tmp = LISTA->prox;
		
		while(tmp->prox != NULL)
			tmp = tmp->prox;
		
		tmp->prox = novo;
	}
}

void percorreLista(nodeLista *LISTA)
{
	if(vazia(LISTA)){
		printf("Lista vazia!\n\n");
		return ;
	}
	
	nodeLista *tmp;
	tmp = LISTA->prox;
	
	while( tmp != NULL){
		//printf("%5d", tmp->num);
		tmp = tmp->prox;
	}
	printf("\n\n");
}
/*END TABELA DE SIMBOLOS*/

noTipo *con(const char num[50]) {
    noTipo *p;

    /* allocate node */
    if ((p = (noTipo *) xmalloc(sizeof(noTipo))) == NULL)
        yyerror("out of memory");
    /* copy information */
    p->tipo = tipoConst;
   strcpy(p->con.valor,num);
   // p->con.valor = num;

    return p;
}

noTipo *id(const char i[50]) {
    noTipo *p;

    /* allocate node */
    if ((p = (noTipo *) xmalloc(sizeof(noTipo))) == NULL)
        yyerror("out of memory");

    /* copy information */
    p->tipo = tipoId;
	strcpy(p->id.i,i);
	
    return p;
}

 noTipo *naoTerm(int t, noTipo** pai, int nFilhos, ...) {
	va_list f;
    noTipo *p;
	int i;
    /* allocate node */
    if ((p = (noTipo *) xmalloc(sizeof(noTipo) + (nFilhos-1) * sizeof(noTipo *))) == NULL)
        yyerror("out of memory");

    /* copy information */
    p->tipo = tipoNaoTerminal;
	p->naoTerm.terminais = t;
	p->naoTerm.numFilhos = nFilhos;
	p->naoTerm.pai = (*pai);
	
	va_start(f, nFilhos);
    for (i = 0; i < nFilhos; i++)
        p->naoTerm.filhos[i] = va_arg(f, noTipo*);
    va_end(f);
    return p;
}

void addFilhoNaoTerm(noTipo ** pai, noTipo *filho)
{
	int numFilhos = (*pai)->naoTerm.numFilhos;

	if ( ( (*pai) = (noTipo*) xrealloc((*pai), sizeof(noTipo) + (numFilhos) * sizeof(noTipo *)) ) == NULL )
        yyerror("out of memory");

    (*pai)->naoTerm.filhos[numFilhos] = filho;

    (*pai)->naoTerm.numFilhos = ++numFilhos;
}

noTipo *opr(int oper, noTipo ** pai,int nops, ...) {
    va_list ap;
    noTipo *p;
    int i;

    /* allocate node, extending op array */
    if ((p = (noTipo *)  xmalloc(sizeof(noTipo) + (nops-1) * sizeof(noTipo *))) == NULL)
        yyerror("out of memory");

    /* copy information */
    p->tipo = tipoOperador;
    p->opr.oper = oper;
    p->opr.nops = nops;
    p->opr.pai = (*pai);
    
	va_start(ap, nops);
    for (i = 0; i < nops; i++)
        p->opr.op[i] = va_arg(ap, noTipo*);
    va_end(ap);
    return p;
}

verificaMain()
{
  if (erromain == 0)
   yyerror("Programa sem main");
}

void yyerror(char *s)
{
	printf("Error: %s linha: %d \n", s,line_num);	
	exit(1);
}

int main(int argc, char **argv)
{

	++argv, --argc; /* pular o nome do programa */
	if(argc == 0)
	{
		yyin = stdin;
		yyout = stdout;
	}
	else if(argc == 1)
	{
		yyin = fopen(argv[0], "r" );
		yyout = stdout;
	}
	else if(argc == 2){
		yyin = fopen(argv[0], "r" );
	    yyout = fopen(argv[1], "a+");		
	}	
	
  //criaPilha();
	yyparse();
	return 0;	
}