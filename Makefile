CC = dmd
DFLAGS = -Jsrc/cl -Isrc -Ilibs/pegged
LDLIBS = -L-Llibs/pegged -L-lpegged

VPATH = src:src/cl

TARGET = loop

OBJS = loopparser.o loop.o examples.o

all: pegged parser $(TARGET)

pegged:
	$(MAKE) -C libs/pegged

parser:
	libs/pegged/peggeden src/cl/loopgrammar src/cl/loopparser.d

$(TARGET): $(OBJS)
	$(CC) $^ $(LDLIBS) -of$@

%.o : %.d
	$(CC) $(DFLAGS) $^ -c

clean:
	rm -f $(OBJS)
	rm -f $(TARGET)

