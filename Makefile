CC = dmd
DFLAGS = -Isrc -Ilibs/pegged
CTDFLAGS = -Jsrc/cl -version=CompileTime $(DFLAGS)
LDLIBS = -L-Llibs/pegged -L-lpegged

VPATH = src:src/cl

CTOBJS = loop.d examples.d
OBJS = loopparser.o $(CTOBJS)

all: pegged parser loop

pegged:
	$(MAKE) -C libs/pegged

parser:
	libs/pegged/peggeden src/cl/loopgrammar src/cl/loopparser.d

loop: $(OBJS)
	$(CC) $(DFLAGS) $^ $(LDLIBS) -of$@

loop-ct: $(CTOBJS)
	$(CC) $(CTDFLAGS) $^ $(LDLIBS) -of$@

%.o: %.d
	$(CC) $(DFLAGS) $^ $(LDLIBS) -c

clean:
	rm -f *.o
	rm -f loop
	$(MAKE) -C libs/pegged clean
