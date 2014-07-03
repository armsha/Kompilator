
	/*** Deklaration section ***/
    
%{
	/* C-Code copied to  y.tab.c */
#include <string.h>
#include <stdio.h>
#include <stdlib.h>

#include "lab.h"
#include "stack.h"

extern int yylex();
extern int yyparse();
extern int yyerror(const char *msg);
extern void printsymbtab();
extern void printmcode();

struct _idlist {
	char name[MAXIDLENGTH];
	struct _idlist *next;
};
typedef struct _idlist *IDLIST;
#define IDNULL (IDLIST) NULL

struct _scope {

	SYMBOL symbtabl;
	int offset;

};
typedef struct _scope *SCOPE;


IDLIST makeIDlist( void );
IDLIST insertIDlist( IDLIST dl, char *name );
IDLIST concatIDlist( IDLIST dl1, IDLIST dl2 );
char * topIDlist( IDLIST dl );
IDLIST popIDlist( IDLIST dl );
void printIDlist( IDLIST dl );

SYMBOL newSymb( char *name, int type, int class );
void newScope( void );
void downScope( char * id );

extern SYMBOL symbtab;
STACK scopeStack;



%}

	/* Declarations of tokens */
	/* %token <name> */
	/* %start <name> */
	/* %left and others */

%union {
	
	int val;
	char name[MAXIDLENGTH];
	struct _idlist *identlist;
	struct _expression express;
	struct _stack *stack;
	QUADLIST nextlist;
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

	/* Special Tokens */
%type <val> Mark1
%type <val> Mark2
%type <nextlist> Ntok

	/* Type defs */
%type <express> aexp
%type <express> expr
%type <val> type
%type <identlist> idlist
%type <name> fname
%type <name> fnhead
%type <stack> exprlist
%type <nextlist> stat
%type <nextlist> compstat
%type <nextlist> statlist


%%
	    
	/*** Translation Rules ***/

	/* <left side>  :  <alt 1> {semantic action 1}   */
	/*              | ...                           */
	/*              | <alt n> {semantic action n}   */
	/*              ;                               */
	    
	/* $$ is the left side value; $i is the value of i'th symbol */
	/* Actions can be interplaced with symbols. */


prog 	    :   PROGSY 
				{  
					newScope();
				}
				IDENT 
				{
					newSymb( $3, INTEGER, FUNC );
					emit( FSTART, lookup($3), SNULL, 0 );
				}
				SEMI 
				dekllist 
				fndekllist 
				compstat 
				PERIOD  
				{  
					emit( HALT, SNULL, SNULL, 0 );
					emit( FEND, lookup($3), SNULL, 0 );

					downScope( $3 );
					newSymb( $3, INTEGER, FUNC );				
				}
			;

dekllist    :   dekllist dekl											{/*EMPTY*/}
            |   dekl													{/*EMPTY*/}
            ;

dekl        :   type idlist SEMI										
			{  
				int typeval = $1; 
				IDLIST dl = $2;
				while( dl != IDNULL ){ 
					newSymb( topIDlist(dl), typeval, VAR ); 
					dl = popIDlist(dl);

				}  
			}
            ;

type        :   INTSY													{ $<val>$ = INTEGER; }
            ;

idlist      :   idlist COMMA IDENT										
			{ 
				IDLIST dl = makeIDlist(); 
				dl = insertIDlist( dl, $3 );
				dl = concatIDlist( $1, dl );
				$$ = dl;  
			}
            |   IDENT													
            { 
            	IDLIST dl = makeIDlist(); 
            	dl = insertIDlist( dl, $1 ); 
            	$<identlist>$ = dl;  
            }
            ;


fndekllist  :   fndekllist fndekl										{/*EMPTY*/}
            |   														{/*EMPTY*/}
            ;


fndekl      :   {  
					newScope();
				}
				fnhead 
				{
					emit( FSTART, lookup($2), SNULL, 0 );
				}
				dekllist 
				fndekllist 
				compstat
				SEMI
				{  
					SYMBOL s;
					emit( FEND, lookup($2), SNULL, 0 ); 
					s = lookup( $2 );
					downScope( $2 );
					newSymb( s->id, s->type, FUNC );
				}
            ;


fnhead      :   FUNCSY 
				fname 
				LPAREN 
				parlist 
				RPAREN 
				COLON 
				type 
				SEMI
				{
					newSymb( $2, $7, FUNC ); /* Return? */
					/* Chack where to put scope, and names */
					/* Are all the dekllists... same things ? */
					strcpy( $$, $2 );
				}
            ;


parlist     :   dekllist												{/*EMPTY*/}
            |   														{/*EMPTY*/}
            ;


fname       :   IDENT													
				{ strcpy( $$, $1 ); }
            ;

Mark1		:	{
					$$ = nextquad;
				}
			;
Mark2		:	{
					$$ = nextquad;
				}
			;
Ntok		:	{
					$$ = makelist(nextquad);
            		emit( GOTO, SNULL, SNULL, -1);
            	
				}	
			;

compstat    :   BEGINSY 
				statlist
				Mark1
				ENDSY									
				{ 
					backpatch($2, $3);
					$$ = $2; 
				}
            ;


statlist    :   statlist Mark1 stat											
				{ /* $$ = merge( $1, $2 ); ??? */
					backpatch( $1, $2 );
					$$ = $3;
				}
            |   stat													
            	{ $$ = $1; }
            ;


stat        :   compstat												
				{
					$$ = $1;
				}
            |   IFSY expr THENSY Mark1 stat Ntok
            	ELSESY Mark2 stat						
            	{
            		QUADLIST q;
            		backpatch( $2.truelist, $4 );
            		backpatch( $2.falselist, $8 );
            		q = merge( $5, $6 );
            		q = merge( q, $9 );
            		$$ = q;
            	}
            |   WHILESY Mark1 expr DOSY Mark2 stat									
            	{
            		backpatch( $6, $2 );
            		backpatch( $3.truelist, $5 );
            		$$ = $3.falselist;
            		emit( GOTO, SNULL, SNULL, $2 );
            	}
            |   WRITESY LPAREN exprlist RPAREN SEMI						
            	{
            		STACK s, t;
            		t = STACKempty();
            		s = $3;
            		while( !STACKisEmpty(s) ){
            			t = STACKpush( t, STACKtop(s) );
            			s = STACKpop( s, NULL );
            		}

            		while( !STACKisEmpty(t) ){
            			emit( WRITE, STACKtop(t), SNULL, 0 );
            			t = STACKpop( t, NULL );
            		}

            		STACKdestroy( s, NULL );
            		STACKdestroy( t, NULL );


            		$$ = QNULL;
            		/* $$ = makelist( nextquad ); */ 
            	}
            |   READSY LPAREN idlist RPAREN SEMI						
            	{ 
            		IDLIST dl = $3; 
            		while( dl != IDNULL ){  
            			emit( READ, lookup(dl->name), SNULL, 0 );
            			dl = popIDlist(dl); 
            		}


            		$$ = QNULL;
            		/* $$ = makelist( nextquad ); */ 
            	}
            |   IDENT ASSIGN expr SEMI									
            	{ 
            		SYMBOL s = lookup( $1 );
            		if( s->class == FUNC ){
            			emit( RETURN, $3.place, SNULL, 0 ); /* Maybe goto? */
            		}else{
            			emit( ASS, lookup($1), $3.place, 0 ); 
            		}


            		$$ = QNULL;
            		/* $$ = makelist( nextquad ); */ 
            	}
           // |   fname ASSIGN expr SEMI									
            //	{
            		/*RETURN*/
            		/* Beware; Both fname and IDENT same, and stuff */

            //	}
            /*|	REPEATSY stat UNTILSY expr SEMI 						{EMPTY}  */
            ;


exprlist    :   exprlist COMMA expr										
				{ 
					/*Maybe List and return? */
					$$ = STACKpush( $$, $3.place ); 
				}
            |   expr													
            	{ 
            		STACK s = STACKempty();
            		s = STACKpush( s, $1.place );
            		$$ = s;
            	}
            ;


expr        :   aexp RELOP aexp											
				{
					$$.truelist  = makelist(nextquad);
					$$.place = emit( $2, $1.place, $3.place, -1 );
					$$.falselist = makelist(nextquad);

					emit( GOTO, SNULL, SNULL, -1 );

				}
            |   aexp													
            	{
					$$.place = $1.place; 
            		$$.truelist  = $1.truelist;
					$$.falselist = $1.falselist;
            	}
            ;


aexp        :   aexp ADDOP aexp											
            	{
            		$$.place = emit($2, $1.place, $3.place, 0);
            	}										
            |   aexp MULOP aexp											
            	{
            		$$.place = emit($2, $1.place, $3.place, 0);
            	}
            |   fname LPAREN arglist RPAREN																		
            	{
            		$$.place = emit( CALL, lookup($1), SNULL, 0 );
            	}
            |   LPAREN expr RPAREN																				
            	{
            		$$.place = $2.place;
            		$$.truelist = $2.truelist;
            		$$.falselist = $2.falselist;
            	}
            |   IDENT																							
            	{
            		$$.place = lookup($1);

            	}
            |   INTCONST												
            	{ 
            		$$.place = newSymb( $1, INTEGER, CONST ); 

            	}
            ;



arglist     :   exprlist												
				{ 	/* Actually emit param here? */
					STACK s,t;
            		s = $1;
            		t = STACKempty();
            		while( !STACKisEmpty(s) ){
            			t = STACKpush( t, STACKtop(s) );
            			s = STACKpop( s, NULL );
            		}
            		while( !STACKisEmpty(t) ){
            			emit( PARAM, STACKtop( t ), SNULL, 0 );
            			t = STACKpop( t, NULL );
            		}

            		STACKdestroy( s, NULL ); 
            		STACKdestroy( t, NULL ); 
				}
            |   { /* No Params to emit! */ }
            ;



	    
%%
	   
	/*** C help routines, copied to y.tab.h ***/

	/* The followin routines are needed in this part of the file */
	/* yyerror()	*/
	/* main()	*/


SYMBOL newSymb( char *name, int type, int class ){

	SYMBOL s;
	s = insert( name, type, class );
	offsetnow++;
	return s;
}

void newScope(){

	/* Make new scope frame */
	SCOPE s;
	if( ( s = (SCOPE)malloc( sizeof( struct _scope ) ) ) == (SCOPE)NULL ){
		perror("Error while mallocating scope frame");
		exit(1);
	}

	/* Configure frame */
	s->symbtabl = symbtab;
	s->offset = offsetnow;

	/* Push current frame to stack */
	scopeStack = STACKpush( scopeStack, s );  

	/* Prepare clean slate for next frame */
	currentlevel++; 
	offsetnow = 0;
	symbtab = SNULL;

}

void downScope( char *id ){

	SCOPE s;

	/* Output this scope */
	fprintf( ptree, "\n%s:\n", id );
	printsymbtab(); 

	/* Remove this scope */
	/*destroy();
	 Beware mcode printing using symbols */

	/* Reinstate the previous scope */
	s = STACKtop( scopeStack ); 
	symbtab = s->symbtabl;
	offsetnow = s->offset;

	/* Destroy scope and continue */
	scopeStack = STACKpop( scopeStack, NULL );
	free( s );
	currentlevel--; 

}

IDLIST makeIDlist( void ){
	return IDNULL;

}

IDLIST insertIDlist( IDLIST dl, char *name ){
	
	IDLIST new;

	if ( (new = (IDLIST)malloc(sizeof(struct _idlist))) == IDNULL ){
		fprintf( stderr, "IDLIST: Memory Allocation FAILURE!\n");
		exit(1);
	}
	
	strcpy( new->name, name );
	new->next = dl;

	return new;

}

IDLIST concatIDlist( IDLIST dl1, IDLIST dl2 ){
	
	IDLIST tmp, last; 
	last = IDNULL;
	for( tmp = dl1; tmp != IDNULL; tmp = tmp->next ){

		last = tmp;
	}

	if( last != IDNULL ){
		last->next = dl2;
	}else{
		return dl2;
	}

	return dl1;

}


char * topIDlist( IDLIST dl ){
	
	return dl->name;

}

IDLIST popIDlist( IDLIST dl ){
	
	IDLIST n = dl->next;
	free(dl);
	return n;

}


void printIDlist( IDLIST dl ){
	
	while( dl != IDNULL ){ 
		printf("\niddek %s", topIDlist(dl));
		dl = dl->next;
	}

}

int yyerror(const char *msg)
{
	fprintf(stderr, "Error: %s\n", msg);
	return 0;
}



int main(int argc, char **argv)
{
	scopeStack = STACKempty();
	ptree = stdout;
	yyparse();
	printf( "\n\n");
	/* printsymbtab(); */
	printmcode();
	destroy();
	STACKdestroy(scopeStack,NULL);
	return 0;
}
