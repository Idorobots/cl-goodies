CC = dmd
DFLAGS = -Isrc -Ilibs/pegged -unittest
CTDFLAGS = -Jsrc/cl -version=CompileTime $(DFLAGS)
LDLIBS = -L-Llibs/pegged -L-lpegged

VPATH = src:src/cl

CTOBJS = quote.d loop.d examples.d
OBJS = loopparser.o $(CTOBJS)

all: pegged parser goodies

pegged:
	$(MAKE) -C libs/pegged

parser:
	libs/pegged/peggeden src/cl/loopgrammar src/cl/loopparser.d

goodies: $(OBJS)
	$(CC) $(DFLAGS) $^ $(LDLIBS) -of$@

goodies-ct: $(CTOBJS)
	$(CC) $(CTDFLAGS) $^ $(LDLIBS) -of$@

%.o: %.d
	$(CC) $(DFLAGS) $^ $(LDLIBS) -c

clean:
	rm -f *.o
	$(MAKE) -C libs/pegged clean
