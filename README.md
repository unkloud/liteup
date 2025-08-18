liteup — SQLite amalgamation helper and builds

Overview
- Provide SQLite amalgamation sources under ./src (sqlite3.c, sqlite3.h, sqlite3ext.h) to build.
- The Makefile builds:
  - sqlite3 CLI (requires shell.c)
  - Shared library
  - Static library
- litebuild.sh: helper to build and place artifacts into a chosen directory.

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
- clean: removes build artifacts (bin/, lib/, build/) with safety checks (refuses unsafe directories)

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

Safety
- liteup.sh refuses unsafe destinations (no absolute paths, no '.', '/', or parent references).
- Makefile clean refuses unsafe directories (absolute paths, root, '.', empty).

litebuild.sh
- Usage: ./litebuild.sh <src_dir> <bin|dll|static> <dest_dir>
- Examples:
  - ./litebuild.sh src dll out            # builds libsqlite3.(so|dylib) into ./out
  - ./litebuild.sh src static dist        # builds libsqlite3.a into ./dist
  - ./litebuild.sh src bin ./artifacts    # builds sqlite3 CLI into ./artifacts (requires shell.c)
- Notes:
  - <src_dir> and <dest_dir> may be absolute or relative. If relative, they are resolved against the current working directory (PWD) and the Makefile receives the full absolute paths.
  - The src_dir should contain sqlite3.c (and shell.c for bin).
  - Artifacts are written directly into dest_dir.
  - Safety: refuses to use '/' as destination.

Notes
- The amalgamation zip from sqlite.org contains sqlite3.c, sqlite3.h, sqlite3ext.h. It does not contain shell.c.
- To build the CLI, provide a shell.c in SRC_DIR. It can be produced from the SQLite source tree (src/shell.c.in).

License
See LICENSE.