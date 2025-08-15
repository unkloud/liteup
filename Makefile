# liteup — Simple SQLite build Makefile

# Dirs and tools
SRC_DIR ?= src
BUILD_DIR ?= build
BIN_DIR ?= bin
LIB_DIR ?= lib
CC ?= cc
AR ?= ar
RANLIB ?= ranlib

# Flags
OPTFLAGS ?= -O2
THREADSAFE ?= 1
CFLAGS ?= $(OPTFLAGS) -fPIC -I$(SRC_DIR) -DSQLITE_THREADSAFE=$(THREADSAFE) -pthread -D_REENTRANT
LDFLAGS ?= -pthread

# OS specifics
UNAME_S := $(shell uname -s 2>/dev/null || echo Unknown)
ifeq ($(UNAME_S),Darwin)
  SHLIB_EXT := dylib
  SHLIB_LDFLAGS := -dynamiclib -Wl,-install_name,@rpath/libsqlite3.$(SHLIB_EXT)
  SYS_LIBS ?= -lpthread -lm -lz
  CLI_LIBS ?= -lreadline -lcurses
else
  SHLIB_EXT := so
  SHLIB_LDFLAGS := -shared -Wl,-soname,libsqlite3.$(SHLIB_EXT)
  SYS_LIBS ?= -lpthread -ldl -lm -lz
  CLI_LIBS ?= -lreadline -lncurses
endif

# Sources
SQLITE3_C := $(SRC_DIR)/sqlite3.c
SHELL_C := $(SRC_DIR)/shell.c

.PHONY: help shared static cli clean

help:
	@echo "Targets: shared | static | cli | clean"
	@echo "Vars: SRC_DIR=$(SRC_DIR) BUILD_DIR=$(BUILD_DIR) BIN_DIR=$(BIN_DIR) LIB_DIR=$(LIB_DIR) THREADSAFE=$(THREADSAFE)"
	@echo "Examples: make shared  |  make static  |  make cli"


$(BUILD_DIR):
	@mkdir -p $(BUILD_DIR)
$(BIN_DIR):
	@mkdir -p $(BIN_DIR)
$(LIB_DIR):
	@mkdir -p $(LIB_DIR)

# Object from amalgamation
$(BUILD_DIR)/sqlite3.o: $(SQLITE3_C) | $(BUILD_DIR)
	@[ -f $(SQLITE3_C) ] || { echo "Error: $(SQLITE3_C) not found. Ensure SQLite amalgamation sources are present in $(SRC_DIR)." >&2; exit 1; }
	$(CC) $(CFLAGS) -c $(SQLITE3_C) -o $@

# Shared library
shared: $(LIB_DIR)/libsqlite3.$(SHLIB_EXT)
$(LIB_DIR)/libsqlite3.$(SHLIB_EXT): $(BUILD_DIR)/sqlite3.o | $(LIB_DIR)
	$(CC) $(SHLIB_LDFLAGS) $(LDFLAGS) -o $@ $< $(SYS_LIBS)
	@echo Built $@

# Static library
static: $(LIB_DIR)/libsqlite3.a
$(LIB_DIR)/libsqlite3.a: $(BUILD_DIR)/sqlite3.o | $(LIB_DIR)
	$(AR) rcs $@ $<
	@$(RANLIB) $@ 2>/dev/null || true
	@echo Built $@

# CLI shell
cli: $(BIN_DIR)/sqlite3
$(BIN_DIR)/sqlite3: $(SHELL_C) $(BUILD_DIR)/sqlite3.o | $(BIN_DIR)
	@[ -f $(SHELL_C) ] || { echo "Error: $(SHELL_C) not found. Place shell.c into $(SRC_DIR) and re-run 'make cli'." >&2; exit 1; }
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $(SHELL_C) $(BUILD_DIR)/sqlite3.o $(CLI_LIBS) $(SYS_LIBS)
	@echo Built $@

clean:
	@set -e; \
	for d in "$(BUILD_DIR)" "$(BIN_DIR)" "$(LIB_DIR)"; do \
	  case "$$d" in \
	    ""|"/"|"."|".."|"./"|"../"|/*) echo "Refusing to clean unsafe dir: '$$d'" >&2; exit 1;; \
	  esac; \
	done; \
	rm -rf "$(BUILD_DIR)" "$(BIN_DIR)" "$(LIB_DIR)"; \
	echo Cleaned
