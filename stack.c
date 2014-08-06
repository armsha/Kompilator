
/*
 *	General stack data-structure
 *	Handling void *, with possible memory freeing support.
 *	Providing common interface, implemented via singly linked list.
 *
 */

#include "stack.h"

/* Remove top element from stack, the resulting stack returned
 * If memhandler given, it will be used on the value stored */
STACK STACKpop( STACK s, memhandler mhf )
{

	STACK rest;
	rest = s->next;

	if(  mhf != (memhandler)NULL  )
		mhf( s->val );
	free( s );

	return rest;

}

/* Push the value given on the stack
 * resulting stak returned */
STACK STACKpush( STACK s, void *v )
{

	STACK n;
	n = STACKempty();
	n->next = s;
	n->val = v;
	return n;

}

/* Get the value at the top of the stack. */
void *STACKtop( STACK s )
{

	return s->val;

}


/* Make an empty stack */
STACK STACKempty( void )
{

	STACK s;
	if( ( s = (STACK)malloc( sizeof( struct _stack ) ) ) == STNULL ){
		perror("Error when mallocating stack");
		exit(1);
	}
	s->next = STNULL;
	s->val = NULL;

	return s;

}


/* Check whether the given stack is empty */
bool STACKisEmpty( STACK s )
{

	return s->next == STNULL;

}

/* Destroy the given stack, poping each element using mhf */
void STACKdestroy( STACK s, memhandler mhf )
{

	while( ! STACKisEmpty( s ) ){
		s = STACKpop(s,mhf);
	}
	free( s );

}
