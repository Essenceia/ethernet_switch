BIN_NAME=test
SRC=$(wildcard *.cpp) $(wildcard *.hpp)

.PHONY: build clean 

build: ${SRC}
	g++ -std=c++23 -o ${BIN_NAME} ${SRC}

test: ${BIN_NAME}
	${BIN_NAME} 

clean:
	rm -f ./${BIN_NAME}
