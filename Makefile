ARCH=i686-w64-mingw32-
CXX=$(ARCH)g++
CXXFLAGS= -O2 -Wall -I/cygdrive/c/lua/lua-5.2.4/src
LDFLAGS= -L/cygdrive/c/lua/lua-5.2.4/src
LIBS= -llua52
MAIN=src/main/cpp
BISON=bison
FLEX=flex

RM= rm -f
SED= sed

TISCOMP_T=$(MAIN)/tiscomp.exe
TISCOMP_O=$(MAIN)/tiscomp.o

all: $(TISCOMP_T)

$(TISCOMP_T): $(TISCOMP_O)
	$(CXX) -o $@ $(LDFLAGS) $(TISCOMP_O) $(LIBS)

$(MAIN)/savetest.exe: $(MAIN)/savetest.o $(MAIN)/save.tab.o $(MAIN)/save.yy.o
	$(CXX) -o $@ $(MAIN)/savetest.o $(MAIN)/save.tab.o $(MAIN)/save.yy.o

clean:
	$(RM) $(TISCOMP_T) $(TISCOMP_O) $(MAIN)/save.tab.cpp $(MAIN)/save.tab.h $(MAIN)/save.yy.cpp

%.o: %.cpp
	$(CXX) -o $@ $(CPPFLAGS) $(CXXFLAGS) -c $*.cpp

%.tab.cpp %.tab.h: %.y
	$(BISON) -o $*.tab.cpp --defines=$*.tab.h $*.y

%.yy.cpp: %.l
	 $(FLEX) -o $@ $*.l

.PHONY: all clean depend

.PRECIOUS: %.tab.cpp %.yy.cpp

.SUFFIXES:

$(MAIN)/save.yy.o : $(MAIN)/save.tab.h
