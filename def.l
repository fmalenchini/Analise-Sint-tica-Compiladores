  /* ESPECIFICACAO LÉXICA LINGUAGEM DEF
	VIVIANE PEREIRA E FLORENCIA MELLENCHINI 2016.2 */ 
	
/*%option noyywrap yylineno*/
%{
#include <stdlib.h>
#include "arvore.h"
#include "def.tab.h"
int line_num = 1;
%}

numero		[0-9]+
nome        [_a-zA-Z][_a-zA-Z0-9]*
whitespace  [\r\n\t]*
comment     "/*".*"*/"|"//".*
%%
"def"        { return T_DEF;}
"if"         { return T_IF; }
"else"       { return T_ELSE;}
"while"      { return T_WHILE;}
"return"     { return T_RETURN; }
"break"      { return T_BREAK;}
"continue"   { return T_CONTINUE;}
"int"        { return T_INT;}
"void"       { return T_VOID;}

{numero}     { yylval.val = strdup(yytext); return T_NUM; }
{nome}       { yylval.string = strdup(yytext); return T_NOME;}

"("           { return T_OPENPAR; }
"{"           { return T_OPENCHAVE; }
"["           { return T_OPENCOCHETE; } 
"]"           { return T_CLOSECOCHETE; }
"}"           { return T_CLOSECHAVE; }
")"           { return T_CLOSEPAR; }
","			  { return T_VIRG; }
";"           { return T_PONTOVIRG; }
"="           { return T_EQUAL; }
"+"           { return T_SOMA; }
"-"           { return T_SUB; }
"*"           { return T_MULT; }
"/"           { return T_DIV; }
"<"           { return T_LT; }
">"           { return T_GT; }
"<="          { return T_LTEQ; }
">="          { return T_GTEQ; }
"=="          { return T_IGUALIGUAL; }
"!="          { return T_DIF; }
"&&"          { return T_AND; }
"||"          { return T_OR; }
"!"           { return T_NAOIGUAL; }

{comment} {/* ignora  */}
[ \t] { /* ignore whitespace */ }
\n			{++line_num;}
\n\n			{line_num=line_num+2;}
\n\n\n			{line_num=line_num+3;}
\n\n\n\n		{line_num=line_num+4;}
\n\n\n\n\n		{line_num=line_num+5;}
. { printf("Erro lexico %c  nao reconhecido linha %d\n", *yytext,line_num); }

%%
int yywrap(void){
	return 1;
}