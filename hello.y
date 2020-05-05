%{
  #include <stdio.h>
  #define YYDEBUG 1
  #define YYSTYPE_IS_DECLARED 1
  #define BUFF_LEN 1024
  typedef char* YYSTYPE;
  char namespace[BUFF_LEN] = { 0 }; 
  char interface[BUFF_LEN] = { 0 }; 
  char class_name[BUFF_LEN] = { 0 };
  char functions[BUFF_LEN * 10] = { 0 };
  void write_to_result(char* msg_buff);
  int rex_str_replace(char* src, char* dest, char* pattern, char* rl_string);
%}

%token EQUAL_SIGN R_BRACKET L_BRACKET RESTRICT_WORD SEMICOLON KEY_WORD_TYPE COMMA L_R_BRACKET R_R_BRACKET
%token KEY_WORD_DECOR STL_STRUCT TEMPLATE_PATTERN NUMBER IDENTIFIER ENUM STRUCT MODULE INTERFACE PARAM_OUT

%%

// module
module_declare_stmt: MODULE IDENTIFIER L_BRACKET var_declare_stmts enum_declare_stmt struct_declare_stmt interface_declare_stmt R_BRACKET SEMICOLON { 
                       printf("module %s declare found.\n", $2);
                       snprintf(namespace, sizeof(namespace), "\nusing namespace %s;\n", $2);
                       write_to_result(namespace);
                       char new_functions[BUFF_LEN * 10] = { 0 };
                       snprintf(class_name, sizeof(class_name), "%sImp", interface);
                       rex_str_replace(functions, new_functions, "TO_BE_REPLACE_BY_IMP", class_name);
                       write_to_result(new_functions);
                     }
                     ;
// interface
interface_declare_stmt: INTERFACE IDENTIFIER L_BRACKET func_declare_stmts R_BRACKET SEMICOLON { 
                         printf("interface %s declare found.\n", $2);
                         snprintf(interface, sizeof(interface), "%s", $2);
                     }
                     ;

func_declare_stmts: func_declare_stmt
                    | func_declare_stmts func_declare_stmt
                    ;

func_declare_stmt: identifier_type_stmt IDENTIFIER L_R_BRACKET identifier_type_stmt IDENTIFIER COMMA PARAM_OUT identifier_type_stmt IDENTIFIER R_R_BRACKET SEMICOLON { 
                     printf("function %s declare found.\n", $2);
                     snprintf(functions + strlen(functions), sizeof(functions) - strlen(functions), "\n%s %s_test(TO_BE_REPLACE_BY_IMP* ptr) {", $1, $2);
                     snprintf(functions + strlen(functions), sizeof(functions) - strlen(functions), "\n  %s %s;", $4, $5);
                     snprintf(functions + strlen(functions), sizeof(functions) - strlen(functions), "\n  %s %s;", $8, $9);
                     snprintf(functions + strlen(functions), sizeof(functions) - strlen(functions), "\n  %s ret = ptr->%s(%s, %s);", $1, $2, $5, $9);
                     snprintf(functions + strlen(functions), sizeof(functions) - strlen(functions), "\n  assert(ret == 0);");
                     snprintf(functions + strlen(functions), sizeof(functions) - strlen(functions), "\n}\n");
                   }
                   ;

// struct
struct_declare_stmt: STRUCT IDENTIFIER L_BRACKET struct_field_declare_stmts R_BRACKET SEMICOLON { printf("struct %s declare found.\n", $2); }
                     ;

struct_field_declare_stmts: struct_field_declare_stmt
                  | struct_field_declare_stmts struct_field_declare_stmt
                  ;

struct_field_declare_stmt: NUMBER RESTRICT_WORD var_declare_stmt
                  ;
                  
var_declare_stmts: var_declare_stmt
                  | var_declare_stmts var_declare_stmt
                  ;

var_declare_stmt: identifier_type_stmt IDENTIFIER SEMICOLON
                 |identifier_type_stmt IDENTIFIER EQUAL_SIGN NUMBER SEMICOLON
                 |identifier_type_stmt IDENTIFIER EQUAL_SIGN IDENTIFIER SEMICOLON
                  ;

// IDENTIFIER（自定义类型）
identifier_type_stmt: KEY_WORD_TYPE
              |IDENTIFIER
              |STL_STRUCT TEMPLATE_PATTERN
              |KEY_WORD_DECOR KEY_WORD_TYPE
              |KEY_WORD_DECOR IDENTIFIER
              |KEY_WORD_DECOR STL_STRUCT TEMPLATE_PATTERN
              ;

// enum
enum_declare_stmt: ENUM IDENTIFIER L_BRACKET enum_field_declare_stmts R_BRACKET SEMICOLON { printf("enum %s declare found.\n", $2); }
                   ;
                     
enum_field_declare_stmts: enum_field_declare_stmt
                     | enum_field_declare_stmts enum_field_declare_stmt
                     ;

enum_field_declare_stmt: IDENTIFIER EQUAL_SIGN NUMBER COMMA
                     | IDENTIFIER EQUAL_SIGN NUMBER 
                     ;
         
%%
