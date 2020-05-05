%{
 
package main

import (
        "fmt"
)

%}

// SymType，源文件中的表现为{prefix}SymType
%union {
	value int
	id    string
}

/* declare tokens*/
%token LVAL
%token RVAL
%token MATCH
%token LP
%token RP
%token BOOL
%token UNKNOW
 
%%
start   : conds
        ;

conds   : expr
        | conds expr
        ;

expr    : LP LVAL MATCH RVAL RP BOOL {fmt.Printf("expr: token info: %+v\n", $1)}
        | LP LVAL MATCH RVAL RP {fmt.Printf("expr: token info: %+v\n", $1)}
        ;
;
%%