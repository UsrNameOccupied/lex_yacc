%{
  #include "y.tab.c"
  #include <stdio.h>
  #include <stdlib.h>
  #include <assert.h>
  #include <string.h>
  #include <regex.h>
  #include <errno.h>
  int yydebug = 0;
  FILE* result;
  extern FILE* yyin;
  extern int errno;
%}

space                       [ \t]*
equal_sign                  "="
semicolon                   ";"
left_bracket                "{"
right_bracket               "}"
l_round_bracket             "("
r_round_bracket             ")"
line_break                  "\n"
char                        [A-Za-z|_]
number                      [0-9]
empty_line                  ^\n|^[ \t]+\n
comment                     \/(\*)(.*\n)*\*\/|\/\/[ \t]*.*|\/(\*).*\*\/
key_word_type               ("int"|"unsigned int"|"unsigned long"|"long"|"float")
stl_struct                  ("vector"|"map"|"set")
param_out                   "out"
template_pattern            "<".*">"
key_word_decorate           ("const"|"static")
restrict_word               ("optional"|"required")
identifier                  {char}*(({number}?)({char}?))*

%%
{empty_line}                { }
{space}                     { }
{line_break}                { }
","                         { yylval = strdup(yytext); return COMMA; }
{equal_sign}                { yylval = strdup(yytext); return EQUAL_SIGN;  }
{key_word_type}             { yylval = strdup(yytext); return KEY_WORD_TYPE; }
{key_word_decorate}         { yylval = strdup(yytext); return KEY_WORD_DECOR;  }
{restrict_word}             { yylval = strdup(yytext); return RESTRICT_WORD;  }
{semicolon}                 { yylval = strdup(yytext); return SEMICOLON;  }
{right_bracket}             { yylval = strdup(yytext); return R_BRACKET;  }
{left_bracket}              { yylval = strdup(yytext); return L_BRACKET;  }
{l_round_bracket}           { yylval = strdup(yytext); return L_R_BRACKET;  }
{r_round_bracket}           { yylval = strdup(yytext); return R_R_BRACKET;  }
{stl_struct}                { yylval = strdup(yytext); return STL_STRUCT;  }
{param_out}                 { yylval = strdup(yytext); return PARAM_OUT;  }
{template_pattern}          { yylval = strdup(yytext); return TEMPLATE_PATTERN;  }
{comment}                   { }
"enum"                      { yylval = strdup(yytext); return ENUM; }
"struct"                    { yylval = strdup(yytext); return STRUCT; }
"module"                    { yylval = strdup(yytext); return MODULE; }
"interface"                 { yylval = strdup(yytext); return INTERFACE; }
{number}*                   { yylval = strdup(yytext); return NUMBER; }
{identifier}                { yylval = strdup(yytext); return IDENTIFIER; }
%%

void yyerror(const char* s) {
    fprintf(stderr, "%s\n", s);
}

int main(int argc, char* argv[]) {
  if(argc < 2) {
    printf("%s\n", "please input jce file path.");
    exit(-1);
  }

  yyin = fopen(argv[1], "r+");

  if(yyin == NULL) {
    printf("%s\n", strerror(errno));
    exit(-1);
  }

  regex_t reg;
  regmatch_t match;
  char result_file_name[BUFF_LEN] = { 0 };
  char msg_buff[BUFF_LEN] = { 0 };
  int ret = regcomp(&reg, "\.txt", REG_EXTENDED);
  
  if(ret != 0) {
    regerror(ret, &reg, msg_buff, sizeof(msg_buff));
    printf("%s\n", msg_buff);
    regfree(&reg);
    exit(1);
  }
  
  ret = regexec(&reg, argv[1], 1, &match, 0);
  if (ret != 0) {  
    regerror(ret, &reg, msg_buff, sizeof(msg_buff));
    printf("%d: %s\n", ret, msg_buff);
    regfree(&reg);
    exit(1);
  }

  strncpy(result_file_name, argv[1], match.rm_so);
  
  regfree(&reg);
  
  if (yydebug) {
    printf("%s\n", result_file_name);
  }

  snprintf(msg_buff, sizeof(msg_buff), "%s.td.h", result_file_name);
  
  result = fopen(msg_buff, "w+");

  if(result == NULL) {
    printf("%s\n", strerror(errno));
    exit(-1);
  }
  
  snprintf(msg_buff, sizeof(msg_buff), "#include \"%s.text.h\"\n#include <assert.h>\n", result_file_name);
  write_to_result(msg_buff);
  
  yyparse();
  // yylex();
  
  fclose(yyin);
  fclose(result);

  return 0;
}

void write_to_result(char* msg_buff) {
  if(fwrite(msg_buff, 1, strlen(msg_buff), result) != strlen(msg_buff)) {
    printf("%s\n", strerror(errno));
    exit(-1);
  }
}

int rex_str_replace(char* src, char* dest, char* pattern, char* rl_string) {
  int ret;
  regex_t reg;
  char msg_buff[BUFF_LEN] = { 0 };

  assert(src != NULL);
  assert(dest != NULL);
  assert(rl_string != NULL);
  
  regmatch_t match;
  ret = regcomp(&reg, pattern, REG_EXTENDED | REG_NEWLINE);
  
  if(ret != 0) {
    regerror(ret, &reg, msg_buff, sizeof(msg_buff));
    printf("%s\n", msg_buff);
    regfree(&reg);
    return ret;
  }
  
  int pos = 0;

  do {
    ret = regexec(&reg, src + pos, 1, &match, 0);
    if (ret != 0) {  
      regerror(ret, &reg, msg_buff, sizeof(msg_buff));
 
      if (yydebug) {
        printf("%d: %s\n", ret, msg_buff);
      }

      snprintf(dest + strlen(dest), 1024 * 10 - strlen(dest), "%s", src + pos);
      regfree(&reg);
      return 0;
    } else {
      if (yydebug) {
        printf("%s\n", src + pos + match.rm_so);
      }
      strncpy(dest + strlen(dest), src + pos, match.rm_so);
      strncpy(dest + strlen(dest), rl_string, strlen(rl_string));
      pos += match.rm_eo;
    }
  } while(pos < strlen(src));
  
  regfree(&reg);
  
  return 0;
}

int yywrap() {
  return 1;
}