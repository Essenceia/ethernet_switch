BIN_NAME=test
DEFAULT_ETH=enp2s0
SRC=$(wildcard *.c) $(wildcard *.h)

.PHONY: build clean trace run


build: ${SRC}
	gcc -o ${BIN_NAME} ${SRC}

#debug network socket/connection failures
trace: build 
	strace ${BIN_NAME} ${ARGS}

run: build
	sudo ./${BIN_NAME} ${DEFAULT_ETH}
 
clean:
	rm -f ./${BIN_NAME}
	rm -f ./vgcore*
