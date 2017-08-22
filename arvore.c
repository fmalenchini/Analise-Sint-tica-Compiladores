#include "arvore.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "def.tab.h"

/* recursive drawing of the syntax tree */
void expNode (noTipo *p);
noTipo* noAux;

static int indent_level = 0;

int ex (noTipo *p) 
{
    //int rte, rtm;
    expNode (p);
    //AnaliseSemantica(p);
    return 0;
}

void* xmalloc(size_t t) {
    void* p = malloc(t);

    if(!p) {
        //yyerror("sem memoria");
        printf("sem memoria\n");
        exit(0);
    }

    return p;
}

void* xrealloc(void* m, size_t t) {
    void* p = realloc(m, t);

    if(!p) {
        //yyerror("sem memoria");
        printf("sem memoria\n");
        exit(0);
    }

    return p;
}

void* xcalloc(size_t n, size_t t) {
    void* p = calloc(n, t);

    if(!p) {
        //yyerror("sem memoria");
        printf("sem memoria\n");
        exit(0);
    }

    return p;
}


void expNode (noTipo *p)
{
    int i;
    if (!p) return;
    noNaoTerminais teste;
    switch(p->tipo) {
        case tipoConst: fprintf (yyout,"[%s] ", p->con.valor); break;
        case tipoId: fprintf (yyout,"[%s]",p->id.i); break;
        case tipoNaoTerminal: 
        	switch(p->naoTerm.terminais){			
        	case Program: fprintf(yyout,"[program "); teste = p->naoTerm.terminais; break;
        	case DecVar: fprintf(yyout,"[decvar ");teste = p->naoTerm.terminais;  break;
        	case DecFunc: fprintf(yyout,"[decfunc "); teste = p->naoTerm.terminais; break;
        	case ParamList: fprintf(yyout,"[paramlist ");teste = p->naoTerm.terminais;  break;
        	case Block: fprintf(yyout,"[Block ");teste = p->naoTerm.terminais;  break;
        	case Stmt: fprintf(yyout,"[Stmt ");teste = p->naoTerm.terminais;  break;
        	case FuncCall: fprintf(yyout,"[funccall ");teste = p->naoTerm.terminais;  break;
        	case ArgList: fprintf(yyout,"[arglist ");teste = p->naoTerm.terminais;  break;
        	case Expr:/* fprintf(yyout,"[Expr ");*/ teste = p->naoTerm.terminais; break;
        	case BinOp: fprintf(yyout,"[BinOp ");teste = p->naoTerm.terminais;  break;  
        	case UnOp: fprintf(yyout,"[UnOp ");teste = p->naoTerm.terminais;  break;
        	case Type: /*fprintf(yyout,"[type "); */teste = p->naoTerm.terminais; break; 
        	case Assign:  fprintf(yyout,"[assign "); teste = p->naoTerm.terminais; break;
        	case Return: fprintf(yyout,"[return ");teste = p->naoTerm.terminais;  break;
        	case expTPLUS: fprintf(yyout,"[+ ");teste = p->naoTerm.terminais;  break;
        	case expTMINUS: fprintf(yyout,"[- ");teste = p->naoTerm.terminais;  break;
        	case expTTIMES: fprintf(yyout,"[* "); teste = p->naoTerm.terminais; break;
        	case expTDIV: fprintf(yyout,"[/ "); teste = p->naoTerm.terminais; break;
        	case expTLT: fprintf(yyout,"[< "); teste = p->naoTerm.terminais; break;
        	case expTGT: fprintf(yyout,"[> ");  teste = p->naoTerm.terminais; break;
        	case expTEQ: fprintf(yyout,"[== ");  teste = p->naoTerm.terminais; break;
        	case expTNEQ: fprintf(yyout,"[!= ");  teste = p->naoTerm.terminais; break;
        	case expTLTEQ: fprintf(yyout,"[<= ");  teste = p->naoTerm.terminais; break;
        	case expTGTEQ: fprintf(yyout,"[>= ");  teste = p->naoTerm.terminais; break;
        	case expTAND: fprintf(yyout,"[&& "); teste = p->naoTerm.terminais; break;
        	case expTOR: fprintf(yyout,"[|| "); teste = p->naoTerm.terminais; break;
        	case expTMINUS2: fprintf(yyout,"[- "); teste = p->naoTerm.terminais; break;
        	case expTNOT: fprintf(yyout,"[! "); teste = p->naoTerm.terminais; break;
        	case While: fprintf(yyout,"[while "); teste = p->naoTerm.terminais; break;
        	case If: fprintf(yyout,"[if "); teste = p->naoTerm.terminais; break;
        	case Break: fprintf(yyout,"[break ");  teste = p->naoTerm.terminais; break;
        	case Continue: fprintf(yyout,"[continue ");  teste = p->naoTerm.terminais; break;
         	case Else: /*fprintf(yyout,"[else ");*/  teste = p->naoTerm.terminais; break;
        	case BlockAux: /*fprintf(yyout,"[BlockAux");*/ teste = p->naoTerm.terminais; break;
        }
        for(i =0; i< p->naoTerm.numFilhos; i++){
                  expNode(p->naoTerm.filhos[i]);  
        }
        if(teste != BlockAux && teste != Else && teste != Expr && teste != Type)
         fprintf(yyout,"]");	 
        break;   
        case tipoOperador:             	
            switch(p->opr.oper){
               	case T_DEF:      fprintf(yyout, "[T_DEF def] ");    break;  
	 			case T_VOID: break;  
			   	case T_VIRG:    /* fprintf(yyout, "[T_VIRG ,] ");*/    break; 
            }
            for (i = 0; i < p->opr.nops; i++) {
               expNode (p->opr.op[i]); 				   	   		        
            }
        break; 
    }
}


