
	/*** Deklaration section ***/
    
%{

	/* C-Code copied to  y.tab.c */

	/* Code to include */
#include <string.h>
#include <stdio.h>
#include <stdlib.h>

#include "lab.h"
#include "stack.h"

	/* extermal functions */
extern int yylex();
extern int yyparse();
extern int yyerror(const char *msg);
extern void printsymbtab();
extern void printmcode();

	/* struct for id-list used in deklarations ond so on. */
struct _idlist {
	char name[MAXIDLENGTH];
	struct _idlist *next;
};
typedef struct _idlist *IDLIST;
#define IDNULL (IDLIST) NULL

	/* struct for a namespace scope, keeping track of what's necessary */
struct _scope {

	SYMBOL symbtabl;
	int offset;

};
typedef struct _scope *SCOPE;

	/* Function declarations for the id-list */
IDLIST makeIDlist( void );
IDLIST insertIDlist( IDLIST dl, char *name );
IDLIST concatIDlist( IDLIST dl1, IDLIST dl2 );
char * topIDlist( IDLIST dl );
IDLIST popIDlist( IDLIST dl );
void printIDlist( IDLIST dl );

	/* Function heads for scope, stack, and symbol handling */
SYMBOL newSymb( char *name, int type, int class );
void newScope( void );
void downScope( char * id );
void destroyTrashStack(void);

	/* !!! Global variables !!! */
extern SYMBOL symbtab;	/* The current symbol table, from table.c ! */
STACK scopeStack;		/* The earlier scopes */
STACK trashStack;		/* scopes to remove */



%}

	/* Declarations of tokens */
	/* %token <name> */
	/* %start <name> */
	/* %left and others */

	/* union for the different yylval values */
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
%token <name> FLOATSY
%token <name> PROGSY
%token <name> READSY
%token <name> THENSY
%token <name> WHILESY
%token <name> WRITESY
%token <name> REPEATSY
%token <name> UNTILSY

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
%token <name> FLOATCONST

%token OTHERSY

	/* Special Tokens */
%type <val> Mark1
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
				IDENT 
				{
					/* Make new symbol, and scope, and send command Fstart. */
					newScope();
					newSymb( $2, INTEGER, FUNC );
					emit( FSTART, lookup($2), SNULL, 0 );
				}
				SEMI 
				dekllist 
				fndekllist 
				compstat 
				PERIOD  
				{  
					/* Send stop command, and step down a scope */
					emit( HALT, SNULL, SNULL, 0 );
					emit( FEND, lookup($2), SNULL, 0 );

					downScope( $2 );
					newSymb( $2, INTEGER, FUNC );				
				}
			;

dekllist    :   dekllist dekl		{/* Taken care of in dekl */}
            |   dekl				{/* Taken care of in dekl */}
            ;

dekl        :   type idlist SEMI										
			{  
				/* Get ID-List, and make new symbols with correct type */
				int typeval = $1; 
				IDLIST dl = $2;
				while( dl != IDNULL ){ 
					newSymb( topIDlist(dl), typeval, VAR ); 
					dl = popIDlist(dl);

				}  
			}
            ;

type        :   INTSY													
			{ 	
				/* Currently only INTEGER type, but this way more could be added */
				$<val>$ = INTEGER;	
			}
			|	FLOATSY
			{
				/* Testing other type */
				$<val>$ = FLOAT;
			}
            ;

idlist      :   idlist COMMA IDENT										
			{ 
				/* Continue the idlist with the new id appended */
				IDLIST dl = makeIDlist(); 
				dl = insertIDlist( dl, $3 );
				dl = concatIDlist( $1, dl );
				$$ = dl;  
			}
            |   IDENT													
            { 
            	/* Start a new idlist containing IDENT */
            	IDLIST dl = makeIDlist(); 
            	dl = insertIDlist( dl, $1 ); 
            	$<identlist>$ = dl;  
            }
            ;


fndekllist  :   fndekllist fndekl			{/* Taken care of in fndekl */}
            |   							{/* Can be empty */}
            ;


fndekl      :   {  
					newScope();
				}
				fnhead 
				{
					/* Fnhead has added function symbol to the new scope */
					emit( FSTART, lookup($2), SNULL, 0 );
				}
				dekllist 
				fndekllist 
				compstat
				SEMI
				{  
					/* Output end command and change scope, allow symbol for function there aswell */
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
					/* Make a new symbol and return the name */
					newSymb( $2, $7, FUNC );
					strcpy( $$, $2 );
				}
            ;


parlist     :   dekllist												
				{ /* Taken care of in dekllist */ }
            |   														
            	{/*EMPTY*/}
            ;


fname       :   IDENT													
				{ /* Just get the name */ strcpy( $$, $1 ); }
            ;

Mark1		:	{
					/* Marker for next code-row returned as val */
					$$ = nextquad;
				}
			;
Ntok		:	{
					/* Return a nextlist for a returned goto-row */
					$$ = makelist(nextquad);
            		emit( GOTO, SNULL, SNULL, -1);
            	
				}	
			;

compstat    :   BEGINSY 
				statlist
				Mark1
				ENDSY									
				{ 
					/* Make sure we continue from the correct spot */
					backpatch($2, $3);
					$$ = $2; 
				}
            ;


statlist    :   statlist Mark1 stat											
				{ 
					/* Make sure the first part continues with the second */
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
            	ELSESY Mark1 stat						
            	{
            		/* Have false and true options continue from the correct points 
            			Also make sure they continue correctly, using a merged nextlist */
            		QUADLIST q;
            		backpatch( $2.truelist, $4 );
            		backpatch( $2.falselist, $8 );
            		q = merge( $5, $6 );
            		q = merge( q, $9 );
            		$$ = q;
            	}
            |   WHILESY Mark1 expr DOSY Mark1 stat									
            	{
            		/* Have the code jump back and continue according to expr */
            		backpatch( $6, $2 );
            		backpatch( $3.truelist, $5 );
            		$$ = $3.falselist;
            		emit( GOTO, SNULL, SNULL, $2 );
            	}
            |   WRITESY LPAREN exprlist RPAREN SEMI						
            	{

            		/* Make a list of expressions to print, reverse and output it */

            		STACK s, t;
            		t = STACKempty();
            		s = $3;
            		while( !STACKisEmpty(s) ){
            			t = STACKpush( t, STACKtop(s) );
            			s = STACKpop( s, NULL );
            		}
            		/* reversed order emits */
            		while( !STACKisEmpty(t) ){
            			emit( WRITE, STACKtop(t), SNULL, 0 );
            			t = STACKpop( t, NULL );
            		}

            		STACKdestroy( s, NULL );
            		STACKdestroy( t, NULL );


            		$$ = QNULL;

            	}
            |   READSY LPAREN idlist RPAREN SEMI						
            	{ 

            		/* Output commands for each id in the idlist */

            		IDLIST dl = $3; 
            		while( dl != IDNULL ){  
            			emit( READ, lookup(dl->name), SNULL, 0 );
            			dl = popIDlist(dl); 
            		}


            		$$ = QNULL;

            	}
            |   IDENT ASSIGN expr SEMI									
            	{ 

            		/* Also fname, handeled via symbol class */
            		SYMBOL s = lookup( $1 );
            		if( s->class == FUNC ){
            			emit( RETURN, $3.place, SNULL, 0 ); 
            		}else{
            			emit( ASS, lookup($1), $3.place, 0 ); 
            		}

            		$$ = QNULL;

            	}
            |	REPEATSY Mark1 stat UNTILSY Mark1 expr SEMI 						
            	{
            		/* Added rule, making sure the expression leads to the correct place */

            		backpatch( $6.falselist, $2 );
            		backpatch( $3, $5 );

            		$$ = $6.truelist;
            	}  
            ;


exprlist    :   exprlist COMMA expr										
				{ 
					/* Add an expr to the stack */
					$$ = STACKpush( $1, $3.place ); 
				}
            |   expr													
            	{ 
            		/* Start a new stack with one element */
            		STACK s = STACKempty();
            		s = STACKpush( s, $1.place );
            		$$ = s;
            	}
            ;


expr        :   aexp RELOP aexp											
				{

					/* Make true/false-list and make goto according to operator result */
					$$.truelist  = makelist(nextquad);
					$$.place = emit( $2, $1.place, $3.place, -1 );
					$$.falselist = makelist(nextquad);

					emit( GOTO, SNULL, SNULL, -1 );

				}
            |   aexp													
            	{
            		/* Accept the aexp values */
					$$.place = $1.place; 
            		$$.truelist  = $1.truelist;
					$$.falselist = $1.falselist;
            	}
            ;


aexp        :   aexp ADDOP aexp											
            	{
            		/* Output command */
            		$$.place = emit($2, $1.place, $3.place, 0);
            	}										
            |   aexp MULOP aexp											
            	{
            		/* Output command */
            		$$.place = emit($2, $1.place, $3.place, 0);
            	}
            |   fname LPAREN arglist RPAREN																		
            	{
            		/* Output command, calling the function, arglist takes care of params */
            		$$.place = emit( CALL, lookup($1), SNULL, 0 );
            	}
            |   LPAREN expr RPAREN																				
            	{
            		/* Return the expression */
            		$$.place = $2.place;
            		$$.truelist = $2.truelist;
            		$$.falselist = $2.falselist;
            	}
            |   IDENT																							
            	{

            		/* Lookup the id */
            		$$.place = lookup($1);

            	}
            |   INTCONST												
            	{ 

            		/* Make new const symvol */
            		$$.place = newSymb( $1, INTEGER, CONST ); 

            	}
            |   FLOATCONST												
            	{ 

            		/* Make new const symvol */
            		$$.place = newSymb( $1, FLOAT, CONST ); 

            	}
            ;



arglist     :   exprlist												
				{ 	

					/* Collect all the expressions in a stack, 
						emmiting them as params in revere (correct) order */
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


/* Take care of adding a new symbol and all related tasks */
SYMBOL newSymb( char *name, int type, int class ){

	SYMBOL s;
	s = insert( name, type, class );

	if ( class != CONST && class != FUNC )
		offsetnow++;

	return s;
}

/* Make a new scope, with old pushed to scopeStack
 * As when making a new function */
void newScope(){

	/* Make new scope frame */
	SCOPE s;
	/*SYMBOL symb;*/

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

	/* GO WITH FULL DECLARATION INSTEAD! Insert old symbols still visible */ 
	/*symb = s->symbtabl;
	while( symb != SNULL ){
		insert( symb->id, symb->type, symb->class );
		symb = symb->nextsym;
	}*/

}

/* Take down and pick up the old stack from scopeStack,
 * Also push the used one for removal at thrashStack */
void downScope( char *id ){

	SCOPE s;
	/*SYMBOL symb;*/

	/* GO WITH FULL DECLARATION INSTEAD!  Remove earlier, still visible scope entries */
	/*symb = s->symbtabl;
	while( symb != SNULL ){
		if( symb->level != currentlevel )
			symb->
		symb = symb->nextsym;
	}*/

	/* Output this scope */
	fprintf( ptree, "\n%s:\n", id );
	printsymbtab(); 

	/* Remove this scope */
	/*SYMBTABdestroy(); */
	trashStack = STACKpush( trashStack, symbtab ); 
	/* Beware mcode printing using symbols */

	/* Reinstate the previous scope */
	s = STACKtop( scopeStack ); 
	symbtab = s->symbtabl;
	offsetnow = s->offset;

	/* Destroy scope and continue */
	scopeStack = STACKpop( scopeStack, free );
	currentlevel--; 

}

/* Go through and destroy all scopes in the trashStack */
void destroyTrashStack(void){

	SYMBTABdestroy();
	while( !STACKisEmpty( trashStack ) ){
		symbtab = STACKtop( trashStack );
		trashStack = STACKpop( trashStack, NULL );
		SYMBTABdestroy();
	}
	STACKdestroy(trashStack,NULL);

}

/* make a new IDList */
IDLIST makeIDlist( void ){
	return IDNULL;

}

/* Insert a id to a idlist, that's returned */
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

/* Concatenate two Id-lists, the result returned */
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

/* Get the id stored in the top of a idlist */
char * topIDlist( IDLIST dl ){
	
	return dl->name;

}

/* Pop an element of the idlist */
IDLIST popIDlist( IDLIST dl ){
	
	IDLIST n = dl->next;
	free(dl);
	return n;

}

/* Print an entire idlist */
void printIDlist( IDLIST dl ){
	
	while( dl != IDNULL ){ 
		printf("\niddek %s", topIDlist(dl));
		dl = dl->next;
	}

}

/* Print during error */
int yyerror(const char *msg)
{
	fprintf(stderr, "Error: %s\n", msg);
	return 0;
}



int main(int argc, char **argv)
{

	/* initialize global variables */
	scopeStack = STACKempty();
	trashStack = STACKempty();

	ptree = stdout; /* Print to stdout */

	/* Perform parse, also printing symbtabs */
	yyparse();

	fprintf( ptree, "\nMain Scope:\n" );
	printsymbtab(); 

	/* Print the mcodetab */
	printf( "\n");
	printmcode();
	
	/* Free allocated memory */
	destroyTrashStack();
	STACKdestroy(scopeStack,NULL);
	
	return 0;
}
