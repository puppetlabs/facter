# Base compiler flags: debug and c++0x (maybe c++11 later?)
CCFLAGS = -std=c++0x -g

UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Darwin)
  # because Darwin has two c++ libs and this one works better
  # need to investigate this more
  CCFLAGS += --stdlib=libc++
  CCFLAGS += -Wno-tautological-constant-out-of-range-compare
endif

all: cfacter libcfacter.so

cfacter: cfacter.cc cfacterlib.cc cfacterimpl.cc cfacterlib.h cfacterimpl.h
	g++ ${CCFLAGS} -o cfacter cfacter.cc cfacterlib.cc cfacterimpl.cc -I C

cfacterlib.o: cfacterlib.cc cfacterlib.h cfacterimpl.h
	g++ ${CCFLAGS} -fPIC -c -o $@ cfacterlib.cc -I .

cfacterimpl.o: cfacterimpl.cc cfacterimpl.h
	g++ ${CCFLAGS} -fPIC -c -o $@ cfacterimpl.cc -I .

libcfacter.so: cfacterlib.o cfacterimpl.o
	g++ ${CCFLAGS} -o $@ $^ -fPIC -shared

install: libcfacter.so
	-cp libcfacter.so $(HOME)/lib

clean:
	-rm cfacterlib.o cfacterimpl.o cfacterlib.so cfacter 2> /dev/null

missing:
	-$(shell facter    | grep "=>" | cut -f1 -d' ' | sort > /tmp/facter.txt)
	-$(shell ./cfacter | grep "=>" | cut -f1 -d' ' | sort > /tmp/cfacter.txt)
	-@$(shell diff /tmp/facter.txt /tmp/cfacter.txt > /tmp/facterdiff.txt | true)
	-@cat /tmp/facterdiff.txt
	-@rm /tmp/facter.txt /tmp/cfacter.txt /tmp/facterdiff.txt
