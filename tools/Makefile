BIN_NAME=test
SRC=$(wildcard *.c) $(wildcard *.h)

.PHONY: build clean trace


build: ${SRC}
	gcc -o ${BIN_NAME} ${SRC}

#debug network socket/connection failures
trace: build 
	strace ${BIN_NAME} ${ARGS}

clean:
	rm -f ./${BIN_NAME}
	rm -f ./vgcore*
