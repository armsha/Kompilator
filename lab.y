
	/*** Deklaration section ***/
    
%{
	/* C-Code copied to  y.tab.c */
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include "lab.h"

extern int yylex();
extern int yyparse();
extern int yyerror(const char *msg);
%}

	/* Declarations of tokens */
	/* %token <name> */
	/* %start <name> */
	/* %left and others */

%union {
	
	int val;
	char name[MAXIDLENGTH];
}

	/* Tokens:  */

%start prog

%token <name> BEGINSY
%token <name> DOSY
%token <name> ELSESY
%token <name> ENDSY
%token <name> FUNCSY
%token <name> IFSY
%token <name> INTSY
%token <name> PROGSY
%token <name> READSY
%token <name> THENSY
%token <name> WHILESY
%token <name> WRITESY

%token <name> IDENT
 
%token PERIOD
%token SEMI
%token COMMA
%token ASSIGN
%token LPAREN
%token RPAREN
%token COLON

%left <val> RELOP /* nonasoc ? for not A<B<C ? or right */
%left <val> ADDOP
%left <val> MULOP

%token <name> INTCONST /* Type for this, both val and name ? name else error ? */

%token OTHERSY


%%
	    
	/*** Translation Rules ***/

	/* <left side>  :  <alt 1> {semantic action 1}   */
	/*              | ...                           */
	/*              | <alt n> {semantic action n}   */
	/*              ;                               */
	    
	/* $$ is the left side value; $i is the value of i'th symbol */
	/* Actions can be interplaced with symbols. */


prog 	    :   PROGSY IDENT SEMI dekllist fndekllist compstat PERIOD 	{printf("\n\n%s %s %d", $1, $2, $<val>4);}
dekllist    :   dekllist dekl											{/*EMPTY*/}
            |   dekl													{/*EMPTY*/}
dekl        :   type idlist SEMI										{/*EMPTY*/}
type        :   INTSY													{/*EMPTY*/}
idlist      :   idlist COMMA IDENT										{/*EMPTY*/}
            |   IDENT													{/*EMPTY*/}
fndekllist  :   fndekllist fndekl										{/*EMPTY*/}
            |   														{/*EMPTY*/}
fndekl      :   fnhead dekllist fndekllist compstat SEMI				{/*EMPTY*/}
fnhead      :   FUNCSY fname LPAREN parlist RPAREN COLON type SEMI	{/*EMPTY*/}
parlist     :   dekllist												{/*EMPTY*/}
            |   														{/*EMPTY*/}
fname       :   IDENT													{/*EMPTY*/}
compstat    :   BEGINSY statlist ENDSY									{/*EMPTY*/}
statlist    :   statlist stat											{/*EMPTY*/}
            |   stat													{/*EMPTY*/}
stat        :   compstat												{/*EMPTY*/}
            |   IFSY expr THENSY stat ELSESY stat						{/*EMPTY*/}
            |   WHILESY expr DOSY stat									{/*EMPTY*/}
            |   WRITESY LPAREN exprlist RPAREN SEMI						{/*EMPTY*/}
            |   READSY LPAREN idlist RPAREN SEMI						{/*EMPTY*/}
            |   IDENT ASSIGN expr SEMI									{/*EMPTY*/}
            |   fname ASSIGN expr SEMI									{/*EMPTY*/}
            /*|	REPEATSY stat UNTILSY expr SEMI 						{EMPTY}  */
exprlist    :   exprlist COMMA expr										{/*EMPTY*/}
            |   expr													{/*EMPTY*/}
expr        :   aexp RELOP aexp											{/*EMPTY*/}
            |   aexp													{/*EMPTY*/}
aexp        :   aexp ADDOP aexp											{/*EMPTY*/}
            |   aexp MULOP aexp											{/*EMPTY*/}
            |   fname LPAREN arglist RPAREN								{/*EMPTY*/}
            |   LPAREN expr RPAREN										{/*EMPTY*/}
            |   IDENT													{/*EMPTY*/}
            |   INTCONST												{/*EMPTY*/}
arglist     :   exprlist												{/*EMPTY*/}
            |   														{/*EMPTY*/}



	    
%%
	   
	/*** C help routines, copied to y.tab.h ***/

	/* The followin routines are needed in this part of the file */
	/* yyerror()	*/
	/* main()	*/



int yyerror(const char *msg)
{
	fprintf(stderr, "Error: %s\n", msg);
	return 0;
}



int main(int argc, char **argv)
{
	yyparse();
	return 0;
}
