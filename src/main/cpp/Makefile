ARCH=i686-w64-mingw32-
CXX= $(ARCH)g++
CXXFLAGS= -O2 -Wall -I/cygdrive/c/lua/lua-5.2.4/src
LDFLAGS= -L/cygdrive/c/lua/lua-5.2.4/src
LIBS= -llua52

RM= rm -f

TISCOMP_T=tiscomp.exe
TISCOMP_O=tiscomp.o

all: $(TISCOMP_T)

$(TISCOMP_T): $(TISCOMP_O)
	$(CXX) -o $@ $(LDFLAGS) $(TISCOMP_O) $(LIBS)

clean:
	$(RM) $(TISCOMP_T) $(TISCOMP_O)

depend:
	@$(CXX) $(CFLAGS) -MM *.cpp

.PHONY: all clean depend

tiscomp.o: tiscomp.cpp
