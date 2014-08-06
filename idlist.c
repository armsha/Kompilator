
#ifndef __IDLIST
#define __IDLIST

struct _idlist {
	char *name;
	struct _idlist *next;
};
typedef struct _idlist *IDLIST;
#define IDNULL (IDLIST) NULL
IDLIST makeIDlist( void );
IDLIST insertIDlist( IDLIST dl, char *name );
IDLIST concatIDlist( IDLIST dl1, IDLIST dl2 );
char * topIDlist( IDLIST dl );
IDLIST popDEKlist( IDLIST dl );




IDLIST makeIDlist( void ){
	return IDNULL;

}

IDLIST insertIDlist( IDLIST dl, char *name ){
	IDLIST new;

	if ( (new = (IDLIST)malloc(sizeof(struct _idlist))) == IDNULL ){
		fprintf( stderr, "IDLIST: Memory Allocation FAILURE!\n");
		exit(1);
	}

	new->name = name;
	new->next = dl;

	return new;

}

IDLIST concatIDlist( IDLIST dl1, IDLIST dl2 ){
	
	IDLIST tmp, last; 
	for( tmp = dl1; tmp != IDNULL; tmp = tmp->next ){

		last = tmp;
	}
	last->next = dl2;

	return dl1;

}


char * topIDlist( IDLIST dl ){
	
	return dl->name;

}

IDLIST popDEKlist( IDLIST dl ){
	
	free(dl);
	return dl->next;

}

#endif