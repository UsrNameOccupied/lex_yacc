###0、说明
flex开启线程安全，build.sh可一键编译，lexer.c lexer.h parser.go为自动生成的文件。
###1、安装goyacc
下载https://github.com/golang/tools/tree/master/cmd/goyacc，go build
###2、flex文件编译
flex --prefix=yy --header-file=lexer.h -o lexer.c lexer.l
###3、yacc文件编译
goyacc -o parser.go -p "dsl" parser.y
###4、编译
go build -i -x