ARCH=
CXX=$(ARCH)g++
CXXFLAGS= -g -O2 -Wall -I/cygdrive/c/lua/lua-5.2.4/src
LDFLAGS= -L/cygdrive/c/lua/lua-5.2.4/src
LIBS= -llua52
MAIN=src/main/cpp
BISON=bison
FLEX=flex

RM= rm -f
SED= sed

TISCOMP_T=$(MAIN)/tiscomp.exe
TISCOMP_O=$(MAIN)/tiscomp.o $(MAIN)/puzzle.o $(MAIN)/save.tab.o $(MAIN)/save.yy.o $(MAIN)/save.o $(MAIN)/fpga.o $(MAIN)/software.o $(MAIN)/refimpl.o

all: $(TISCOMP_T)

$(TISCOMP_T): $(TISCOMP_O)
	$(CXX) -o $@ $(CXXFLAGS) $(LDFLAGS) $(TISCOMP_O) $(LIBS)

$(MAIN)/savetest.exe: $(MAIN)/savetest.o $(MAIN)/save.tab.o $(MAIN)/save.yy.o $(MAIN)/save.o
	$(CXX) -o $@ $(CXXFLAGS) $(LDFLAGS) $(MAIN)/savetest.o $(MAIN)/save.tab.o $(MAIN)/save.yy.o $(MAIN)/save.o

$(MAIN)/tisprog.exe: $(MAIN)/tisprog.o $(MAIN)/tisvm.o $(MAIN)/node.o
	$(CXX) -o $@ $(CXXFLAGS) $(LDFLAGS) $(MAIN)/tisprog.o $(MAIN)/tisvm.o $(MAIN)/node.o

cleanoutput:
	$(RM) in[0-3].txt out[0-3].txt prog.txt len.txt refimpl.sys refimpl.tis save.txt slen.txt stack.txt streams.txt test.lua \
        $(MAIN)/tisprog.cpp

clean: cleanoutput
	$(RM) $(TISCOMP_T) $(TISCOMP_O) $(MAIN)/save.tab.cpp $(MAIN)/save.tab.h $(MAIN)/save.yy.cpp \
        $(MAIN)/savetest.o $(MAIN)/savetest.exe \
		$(MAIN)/tisprog.o $(MAIN)/tisprog.exe $(MAIN)/tisvm.o $(MAIN)/node.o \

%.o: %.cpp
	$(CXX) -o $@ $(CPPFLAGS) $(CXXFLAGS) -c $*.cpp

%.tab.cpp %.tab.h: %.y
	$(BISON) -o $*.tab.cpp --defines=$*.tab.h $*.y

%.yy.cpp: %.l
	 $(FLEX) -o $@ $*.l

.PHONY: all cleanoutput clean

.PRECIOUS: %.tab.cpp %.yy.cpp

.SUFFIXES:

$(MAIN)/tiscomp.o $(MAIN)/fpga.o $(MAIN)/software.o $(MAIN)/refimpl.o : $(MAIN)/puzzle.hpp $(MAIN)/node.hpp $(MAIN)/backend.hpp
$(MAIN)/puzzle.o : $(MAIN)/puzzle.hpp
$(MAIN)/save.yy.o : $(MAIN)/save.tab.h $(MAIN)/save.hpp
$(MAIN)/save.tab.o  $(MAIN)/save.o : $(MAIN)/save.hpp

$(MAIN)/tisprog.o $(MAIN)/tisvm.o : $(MAIN)/tisvm.hpp $(MAIN)/node.hpp
$(MAIN)/node.o : $(MAIN)/node.hpp
