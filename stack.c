
#include "stack.h"

STACK STACKpop( STACK s, memhandler mhf )
{

	STACK rest;
	rest = s->next;

	if(  mhf != (memhandler)NULL  )
		mhf( s->val );
	free( s );

	return rest;

}

STACK STACKpush( STACK s, void *v )
{

	STACK n;
	n = STACKempty();
	n->next = s;
	n->val = v;
	return n;

}

void *STACKtop( STACK s )
{

	return s->val;

}


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


bool STACKisEmpty( STACK s )
{

	return s->next == STNULL;

}


void STACKdestroy( STACK s, memhandler mhf )
{

	while( ! STACKisEmpty( s ) ){
		s = STACKpop(s,mhf);
	}
	free( s );

}
