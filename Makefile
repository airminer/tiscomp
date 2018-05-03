ARCH=
CXX=$(ARCH)g++
CXXFLAGS= -g -O2 -Wall -I/cygdrive/c/lua/lua-5.2.4/src
LDFLAGS= -L/cygdrive/c/lua/lua-5.2.4/src
LIBS= -llua
MAIN=src/main/cpp
BISON=bison
FLEX=flex

RM= rm -f
SED= sed

TISCOMP_T=$(MAIN)/tiscomp.exe
TISCOMP_O=$(MAIN)/tiscomp.o $(MAIN)/puzzle.o $(MAIN)/save.tab.o $(MAIN)/save.yy.o $(MAIN)/save.o $(MAIN)/fpga.o $(MAIN)/software.o

all: $(TISCOMP_T)

$(TISCOMP_T): $(TISCOMP_O)
	$(CXX) -o $@ $(CXXFLAGS) $(LDFLAGS) $(TISCOMP_O) $(LIBS)

$(MAIN)/savetest.exe: $(MAIN)/savetest.o $(MAIN)/save.tab.o $(MAIN)/save.yy.o $(MAIN)/save.o
	$(CXX) -o $@ $(CXXFLAGS) $(LDFLAGS) $(MAIN)/savetest.o $(MAIN)/save.tab.o $(MAIN)/save.yy.o $(MAIN)/save.o

$(MAIN)/tisprog.exe: $(MAIN)/tisprog.o $(MAIN)/tisvm.o $(MAIN)/node.o
	$(CXX) -o $@ $(CXXFLAGS) $(LDFLAGS) $(MAIN)/tisprog.o $(MAIN)/tisvm.o $(MAIN)/node.o

clean:
	$(RM) $(TISCOMP_T) $(TISCOMP_O) $(MAIN)/save.tab.cpp $(MAIN)/save.tab.h $(MAIN)/save.yy.cpp \
        $(MAIN)/save.o $(MAIN)/save.yy.o $(MAIN)/save.tab.o $(MAIN)/savetest.o $(MAIN)/savetest.exe

%.o: %.cpp
	$(CXX) -o $@ $(CPPFLAGS) $(CXXFLAGS) -c $*.cpp

%.tab.cpp %.tab.h: %.y
	$(BISON) -o $*.tab.cpp --defines=$*.tab.h $*.y

%.yy.cpp: %.l
	 $(FLEX) -o $@ $*.l

.PHONY: all clean depend

.PRECIOUS: %.tab.cpp %.yy.cpp

.SUFFIXES:

$(MAIN)/tiscomp.o $(MAIN)/fpga.o $(MAIN)/software.o : $(MAIN)/puzzle.hpp $(MAIN)/node.hpp $(MAIN)/backend.hpp
$(MAIN)/puzzle.o : $(MAIN)/puzzle.hpp
$(MAIN)/save.yy.o : $(MAIN)/save.tab.h $(MAIN)/save.hpp
$(MAIN)/save.tab.o  $(MAIN)/save.o : $(MAIN)/save.hpp

$(MAIN)/tisprog.o $(MAIN)/tisvm.o : $(MAIN)/tisvm.hpp $(MAIN)/node.hpp
$(MAIN)/node.o : $(MAIN)/node.hpp
