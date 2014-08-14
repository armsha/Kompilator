#include <stdio.h>
#include <stdlib.h>
#include "lab.h"

void tblerror(char *);

struct _mcode mcodetab[MAXCODE]; /* save intermediate code in mcodetab */
int nextquad, offsetnow, currentlevel;

int tempcount = 0;
struct _symbol tempvars[6] =    	/* temporary variables */
{
	{"temp0" ,0, TEMP, 0, 0, 0, SNULL},
	{"temp1" ,0, TEMP, 0, 0, 0, SNULL},
	{"temp2" ,0, TEMP, 0, 0, 0, SNULL},
	{"temp3" ,0, TEMP, 0, 0, 0, SNULL},
	{"temp4" ,0, TEMP, 0, 0, 0, SNULL},
	{"temp5" ,0, TEMP, 0, 0, 0, SNULL}
};

SYMBOL symbtab = SNULL;

/* SYMBOL TABLE ROUTINES  */

/* insert - insert new identifier in symbol table */
SYMBOL insert(char *name, int type, int class)
{
	SYMBOL r;
	r = symbtab;
	while (r != SNULL)
		if (strcmp(r->id, name) == 0) {
			if (class != CONST){
				printf("%s: ", name);
				tblerror("identifier multiply declared");
			}
			return(r);
		} else
			r = r->nextsym;
	if ((r = (SYMBOL)malloc(sizeof(struct _symbol))) == SNULL) {
		fprintf(stderr, "insert: memory allocation error\n");
		exit(1);
	}
	strcpy(r->id, name);
	r->type = type;
	r->class = class;
	r->level = currentlevel;
	r->offset = offsetnow;
	r->nextsym = symbtab;
	symbtab = r;
	return(r);
}

/* destroy - remove all elements from symbtab */
void SYMBTABdestroy()
{
	SYMBOL temp;
	if( symbtab == SNULL ) return;

	temp=symbtab;
	while(symbtab->nextsym!=SNULL)
	{

		symbtab=symbtab->nextsym;
		free(temp);
		temp=symbtab;

	}

	free(symbtab);
	symbtab=SNULL;

}

/* lookup - search for name in symbol table */
SYMBOL lookup(char *s)
{
	SYMBOL sp;
	for (sp = symbtab; sp != SNULL; sp = sp->nextsym)
		if (strcmp(sp->id, s) == 0)
			return(sp);

	printf("%s: ", s);
	tblerror("identifier not declared");    /* id not found */
	return(insert(s, NOTYPE, UNDEF));
}


/* ROUTINES FOR GENERATING AND MANIPULATING INTERMEDIATE CODE */

SYMBOL emit(int op, SYMBOL a1, SYMBOL a2, int jmp)
{
	SYMBOL p;
	if (a1 != SNULL)
		if (a1->class == TEMP)
			tempcount--;
	if (a2 != SNULL)
		if(a2->class == TEMP)
			tempcount--;
	if (tempcount >= 6) {
		fprintf(stderr, "gen: run out of space for temp.vars.\n");
		exit(1);
	}
	if (op < EQ || op == CALL) {		/* Use temporary variable */
		p = tempvars + tempcount;
		p->offset = tempcount++;   /* Offset for temp.vars.=tempno */
	}
	else
		p = SNULL;
	mcodetab[nextquad].operation = op;
	mcodetab[nextquad].arg1 = a1;
	mcodetab[nextquad].arg2 = a2;
	mcodetab[nextquad++].target = jmp;
	return(p);
}


QUADLIST merge(QUADLIST l1, QUADLIST l2)
{
	QUADLIST qp;
	if (l1 == QNULL)
		return(l2);
	else { 
		qp = l1;
		while (qp->nxt != QNULL) 
			qp = qp->nxt;
		qp->nxt = l2;
		return(l1);
	}
}

QUADLIST makelist(int quad)
{
	QUADLIST q;
	if (quad == -1)
		return(QNULL);
	else {
		if ((q = (QUADLIST)malloc(sizeof(struct _quadlist))) == QNULL) {
                	fprintf(stderr, "makelist: memory allocation error\n");
			exit(1);
		}
		q->adr = quad;
		q->nxt = QNULL;
		return(q);
	}
}

void QUADLISTdestroy( QUADLIST l ){
	QUADLIST tmp;
	if (l != QNULL)
	do {
		tmp = l->nxt;
		free( l );
		l= tmp;
	} while (l != QNULL);
}

void backpatch(QUADLIST l, int a)
{

	QUADLIST tmp;
	tmp = l;

	if (l != QNULL)
		do {
			mcodetab[l->adr].target = a;
			l= l->nxt;
		} while (l != QNULL);

	QUADLISTdestroy(tmp);

}

void printQList( QUADLIST l, const char *s ){
	if (l != QNULL)
		do {
			printf( "%s: %d\n", s, l->adr);
			l= l->nxt;
		} while (l != QNULL);
}

/* OUTPUT ROUTINES */

char *typ[5]  = {
     "", "INTEGER", "FLOAT  ", "", "NOTYPE " };

char *cl[7]   = {
     "", "VAR  ", "FUNC ", "PAR  ", "CONST", "TEMP ", "UNDEF"  };

char *op[100] = {
     "", "PLUS", "MINUS", "OROP", "TIMES", "PARTS", "", "", "", "",
     "", "", "", "", "", "", "", "", "EQ", "NE",
     "LE", "LT", "GE", "GT", "ASS", "WRITE", "READ", "GOTO", "", "",
     "", "", "PARAM", "CALL", "RETURN", "", "", "", "", "",
     "", "", "", "", "", "", "", "", "", "",
     "", "", "", "", "", "", "", "", "", "",
     "", "", "", "", "", "", "", "", "", "",
     "", "", "", "", "", "", "", "", "", "",
     "", "", "", "", "", "", "", "", "", "",
     "", "", "", "", "", "", "", "FSTART", "FEND", "HALT"  };

FILE *ptree;	/* file for output */

void printsymbtab(void)
{
	SYMBOL sp;
	for (sp = symbtab; sp != SNULL; sp = sp->nextsym){
		fprintf(ptree, "%-9.9stype %s class %s offset%3d level%3d\n",
		sp->id, typ[sp->type], cl[sp->class], sp->offset, sp->level);
	}


}

void printmcode(void)
{
	int n;
	fprintf(ptree,"\n");
	for (n = 0; n < nextquad; n++)
		fprintf(ptree, "%4d:\t%s\t%s\t%s\t%4d\n",
				n, op[mcodetab[n].operation],
				mcodetab[n].arg1 != 0 ? mcodetab[n].arg1->id : "",
				mcodetab[n].arg2 != 0 ? mcodetab[n].arg2->id : "",
				mcodetab[n].target);
}

void tblerror(char *s)
{
	printf("%s\n", s);
}
