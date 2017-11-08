ARCH=i686-w64-mingw32-
CXX= $(ARCH)g++
CXXFLAGS= -O2 -Wall -I/cygdrive/c/lua/lua-5.2.4/src
LDFLAGS= -L/cygdrive/c/lua/lua-5.2.4/src
LIBS= -llua52
MAIN=src/main/cpp

RM= rm -f
SED= sed

TISCOMP_T=$(MAIN)/tiscomp.exe
TISCOMP_O=$(MAIN)/tiscomp.o
TISCOMP_D=$(MAIN)/tiscomp.d

all: $(TISCOMP_T)

$(TISCOMP_T): $(TISCOMP_O)
	$(CXX) -o $@ $(LDFLAGS) $(TISCOMP_O) $(LIBS)

clean:
	$(RM) $(TISCOMP_T) $(TISCOMP_O) $(wildcard $(TISCOMP_D)*)

%.d: %.cpp
	@$(RM) $@ && \
	$(CXX) -M $(CPPFLAGS) $(CXXFLAGS) $< > $@.$$$$ && \
	$(SED) 's,\($(*F)\)\.o[ :]*,$*.o $@ : ,g' < $@.$$$$ > $@ && \
	$(RM) $@.$$$$

.PHONY: all clean depend

ifneq ($(MAKECMDGOALS),clean)
include $(TISCOMP_D)
endif
