%option reentrant

%{

#include <stdio.h>
#include "const.h"

#define YYSTYPE char*
#define YYDEBUG 1
#define YYSTYPE_IS_DECLARED 1

extern YYSTYPE yylval;
int yydebug = 0;

%}

%%

"EQ"                        { return MATCH;}
"NE"                        { return MATCH;}
"HAS"                       { return MATCH;}
"AND"                       { return BOOL;}
"OR"                        { return BOOL;}
\"\"([^\"]*)\"\"            { return RVAL;}
\"([^\"]*)\"                { return RVAL;}
[a-zA-Z][0-9a-zA-Z_]*       { return LVAL;}
"("                         { return LP;}
")"                         { return RP;}
" "                         {}
"\t"                        {}
.                           { return UNKNOW;}

%%

/* 这个函数是必须的，用于多文件，默认返回1，代表没有更多文件需要处理 */
int yywrap(yyscan_t yyscanner) {
    return 1;
}