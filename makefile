CC = dmd
DFLAGS = -Jsrc/cl -Isrc -Iimports
LDLIBS = -L-Llib -L-lpegged

VPATH = src:src/cl

TARGET = loop

OBJS = loopparser.o loop.o examples.o

all: $(TARGET)

$(TARGET): $(OBJS)
	$(CC) $^ $(LDLIBS) -of$@

%.o : %.d
	$(CC) $(DFLAGS) $^ -c

clean:
	rm -f $(OBJS)
	rm -f $(TARGET)

