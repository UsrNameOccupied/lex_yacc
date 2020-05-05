package main

/*
#include "const.h"
#include "lexer.h"

struct YaccExtra {
    void *scanner;
};
*/
import "C"

import (
	"errors"
	"log"
)

type calcLex struct {
	yylineno int
	yytext   string
	lastErr  error
	// 使用独立的空间
	extra *C.struct_YaccExtra
	tokens []string
}

func (p *calcLex) getTokens() []string {
	return 	p.tokens
}

func newCalcLexer(data []byte) *calcLex {
	p := &calcLex {
		extra: &C.struct_YaccExtra{},
		tokens: make([]string, 0),
	}

	C.yylex_init((*C.yyscan_t)(&p.extra.scanner))

	cnt := len(data)

	C.yy_scan_bytes(
		(*C.char)(C.CBytes(data)),
		C.int(cnt),
		(C.yyscan_t)(p.extra.scanner),
	)

	return p
}

// The parser calls this method to get each new token. This
// implementation returns operators and NUM.
func (p *calcLex) Lex(yylval *dslSymType) int {
	p.lastErr = nil

	var tok = C.yylex((C.yyscan_t)(p.extra.scanner))

	p.yylineno = int(C.yyget_lineno((C.yyscan_t)(p.extra.scanner)))
	p.yytext = C.GoString(C.yyget_text((C.yyscan_t)(p.extra.scanner)))

	log.Printf("lex: token = %d, yytext = %q, yylineno = %d", tok, p.yytext, p.yylineno)

	yylval.id = p.yytext

	// 完成cflex到goyacc的转换
	switch tok {
		case C.MATCH:
			p.tokens = append(p.tokens, p.yytext)
			return MATCH
		case C.LVAL:
			p.tokens = append(p.tokens, p.yytext)
			return LVAL
		case C.RVAL:
			p.tokens = append(p.tokens, p.yytext)
			return RVAL
		case C.LP:
			p.tokens = append(p.tokens, p.yytext)
			return LP
		case C.RP:
			p.tokens = append(p.tokens, p.yytext)
			return RP
		case C.BOOL:
			p.tokens = append(p.tokens, p.yytext)
			return BOOL
		case C.UNKNOW:
			p.tokens = append(p.tokens, p.yytext)
			return UNKNOW
	}

	C.yylex_destroy((C.yyscan_t)(p.extra.scanner));

	return 0
}

// The parser calls this method on a parse error.
func (p *calcLex) Error(s string) {
	p.lastErr = errors.New("yacc: " + s)
	if err := p.lastErr; err != nil {
		log.Println(err)
	}

	panic(p.lastErr)
}