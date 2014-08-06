
#ifndef __STACK
#define __STACK

#include <stdlib.h>
#include <stdbool.h>
#include <stdio.h>

/* Simple stack type using single links */
struct _stack 
{
	
	void *val;
	struct _stack *next;

};

typedef struct _stack *STACK; 


typedef void (*memhandler)(void *);
#define STNULL (STACK)NULL


STACK STACKpop( STACK s, memhandler mhf );
STACK STACKpush( STACK s, void *val );
void *STACKtop( STACK s );
STACK STACKempty( void );
bool STACKisEmpty( STACK s );
void STACKdestroy( STACK s, memhandler mhf );

#endif
