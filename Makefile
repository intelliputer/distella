APP_VERSION := 3.02-SNAPSHOT
APP_COMPILE := $(shell date -u +%Y-%m-%d)

CC ?= cc
CPPFLAGS := -DAPP_VERSION=\"$(APP_VERSION)\" -DAPP_COMPILE=\"$(APP_COMPILE)\"
CFLAGS ?= -O2 -g
CFLAGS += -std=c11 -Wall -Wextra -Wpedantic
LDFLAGS ?=

TARGET := distella
SOURCE := src/distella.c

.PHONY: all clean test sanitize

all: $(TARGET)

$(TARGET): $(SOURCE) src/table.c src/vcs.c src/maria.c src/queue.c
	$(CC) $(CPPFLAGS) $(CFLAGS) $(LDFLAGS) $(SOURCE) -o $@

test: $(TARGET)
	./tests/smoke.sh ./$(TARGET)

sanitize:
	$(MAKE) clean
	ASAN_OPTIONS=detect_leaks=0 $(MAKE) CFLAGS='-O1 -g -std=c11 -Wall -Wextra -Wpedantic -fsanitize=address,undefined -fno-omit-frame-pointer' LDFLAGS='-fsanitize=address,undefined' test

clean:
	rm -f $(TARGET)
