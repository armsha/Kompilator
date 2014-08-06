
#include <stdio.h>
#include <stdlib.h>

#define NKEYS           14

struct key {
	char *keyw;        /*definitions of all keywords and their*/
	int symb;          /*symbols*/
} keytab[NKEYS]={
	"a", 1,
	"b", 2,
	"c", 3,
	"d", 4,
	"e", 5,
	"f", 6,
	"g", 7,
	"h", 8,
	"i", 9,
	"j", 10,
	"k", 11,
    "m", 13,
	"n", 14,
	"w", 12
};

/*search - binary search after string "word" in "tab" */
int search (char *word, struct key *tab, int n)
{
	int low, high,mid,cond;
	low = 0;
	high = n;
	while (low <= high) {
		mid = (low+high) / 2;
		if ((cond=strcmp(word,tab[mid].keyw)) < 0)
			high = mid - 1;
		else if (cond > 0)
			low = mid+1;
		else
			return (mid);
	}  /* position for "word" in "tab" */
	return (-1);          /* not found */
}

int main(void){

	struct key res;
	printf("%d", search( "a", keytab, NKEYS ));
	res = keytab[search( "a", keytab, NKEYS )];
	printf( " s  %s %d \n", res.keyw, res.symb );
	res = keytab[search( "b", keytab, NKEYS )];
	printf( " s  %s %d \n", res.keyw, res.symb );
	res = keytab[search( "w", keytab, NKEYS )];
	printf( " s  %s %d \n", res.keyw, res.symb );
	res = keytab[search( "m", keytab, NKEYS )];
	printf( " s m  %s %d \n", res.keyw, res.symb );
	res = keytab[search( "n", keytab, NKEYS )];
	printf( " s n  %s %d \n", res.keyw, res.symb );
	res = keytab[search( "a", keytab, NKEYS )];
	printf( " s  %s %d \n", res.keyw, res.symb );
	res = keytab[search( "b", keytab, NKEYS )];
	printf( " s  %s %d \n", res.keyw, res.symb );
	res = keytab[search( "c", keytab, NKEYS )];
	printf( " s  %s %d \n", res.keyw, res.symb );
	res = keytab[search( "d", keytab, NKEYS )];
	printf( " s  %s %d \n", res.keyw, res.symb );
	res = keytab[search( "e", keytab, NKEYS )];
	printf( " s  %s %d \n", res.keyw, res.symb );
	res = keytab[search( "f", keytab, NKEYS )];
	printf( " s  %s %d \n", res.keyw, res.symb );
	res = keytab[search( "g", keytab, NKEYS )];
	printf( " s  %s %d \n", res.keyw, res.symb );
	res = keytab[search( "h", keytab, NKEYS )];
	printf( " s  %s %d \n", res.keyw, res.symb );
	res = keytab[search( "i", keytab, NKEYS )];
	printf( " s  %s %d \n", res.keyw, res.symb );
	res = keytab[search( "j", keytab, NKEYS )];
	printf( " s  %s %d \n", res.keyw, res.symb );
	res = keytab[search( "k", keytab, NKEYS )];
	printf( " s  %s %d \n", res.keyw, res.symb );
	res = keytab[search( "w", keytab, NKEYS )];
	printf( " s  %s %d \n", res.keyw, res.symb );
	res = keytab[search( "m", keytab, NKEYS )];
	printf( " s  %s %d \n", res.keyw, res.symb );
	res = keytab[search( "n", keytab, NKEYS )];
	printf( " s  %s %d \n", res.keyw, res.symb );

}