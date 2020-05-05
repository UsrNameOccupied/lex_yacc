package main

import (
	"fmt"
)

func isSyntaxOk() (bool, []string) {
	defer func() {
		if err := recover(); err != nil {
			fmt.Println(err)
			// return false, nil
		}
	}()

	// newCalcLexer为用户自定义的lex接口
	lex := newCalcLexer([]byte("(msg HAS \"dfg dfg\")AND(msg HAS             \"\"dfg dfg\"\")OR"))
	// 指定的{prefix}
	dslParse(lex)

	fmt.Printf("tokens = %+v\n", lex.getTokens())

	return true, lex.getTokens()
}

func main() {
	ok, tokens := isSyntaxOk()
	fmt.Printf("%t %+v\n", ok, tokens)
}