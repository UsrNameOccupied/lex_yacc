#!/bin/bash
flex --prefix=yy --header-file=lexer.h -o lexer.c lexer.l
goyacc -o parser.go -p "dsl" parser.y
go build -i -x
