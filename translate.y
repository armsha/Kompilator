
    /*** Deklaration section ***/
    
%{
    /* C-Code copied to  y.tab.c */
%}

    /* Declarations of tokens */
    /* %token <name> */
    /* %start <name> */
    /* %left and others */
    
%%
    
    /*** Translation Rules ***/
    
    /* <left side>  : <alt 1> {semantic action 1}   */
    /*              | ...                           */
    /*              | <alt n> {semantic action n}   */
    /*              ;                               */
    
    /* $$ is the left side value; $i is the value of i'th symbol */
    
%%
    
    /*** C help routines, cppied to y.tab.h ***/
    
