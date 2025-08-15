liteup — SQLite amalgamation helper and builds

Overview
- Provide SQLite amalgamation sources under ./src (sqlite3.c, sqlite3.h, sqlite3ext.h) to build.
- The Makefile builds:
  - sqlite3 CLI (requires shell.c)
  - Shared library
  - Static library

Quick start

1) Build a dynamic library:
   make shared
   # Produces ./lib/libsqlite3.so on Linux, ./lib/libsqlite3.dylib on macOS

2) Build a static library:
   make static
   # Produces ./lib/libsqlite3.a

3) Build the sqlite3 CLI shell:
   # Note: Requires ./src/shell.c (not included in the amalgamation zip)
   # Obtain shell.c from the SQLite source tree (src/shell.c.in processed as shell.c)
   make cli
   # Produces ./bin/sqlite3

Targets
- help: shows short usage
- shared: builds the dynamic library
- static: builds libsqlite3.a
- cli: builds the shell, linking against readline and curses (ncurses on Linux; curses on macOS)
- clean: removes build artifacts (bin/, lib/, build/)

Variables
- SRC_DIR: source directory (default: src)
- THREADSAFE: 1 by default; adds -DSQLITE_THREADSAFE and pthread flags to builds

System dependencies
- Build tools: make, a C compiler (cc/clang/gcc), ar, ranlib
- Libraries:
  - Pthreads (libpthread)
  - zlib (libz)
  - math library (libm)
  - On Linux: dynamic loader (libdl)
  - For CLI: readline (libreadline) and curses
    - Linux and most others: ncurses (libncurses)
    - macOS (Darwin): system curses (link as -lcurses)

Examples
- make shared
- make static
- CLI_LIBS="-lreadline -lncursesw" make cli

Notes
- The amalgamation zip from sqlite.org contains sqlite3.c, sqlite3.h, sqlite3ext.h. It does not contain shell.c.
- To build the CLI, provide a shell.c in SRC_DIR. It can be produced from the SQLite source tree (src/shell.c.in).

License
See LICENSE.