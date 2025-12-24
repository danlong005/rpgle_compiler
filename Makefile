# RPGLE Free Format Compiler
# Compatible with IBM i v7r5

CC = gcc
YACC = bison
LEX = flex

CFLAGS = -Wall -Wno-unused-function -I./include -g
YFLAGS = -d -v
LFLAGS = 

SRCDIR = src
INCDIR = include
OBJDIR = obj
BINDIR = bin
TESTDIR = test

# Source files
LEX_SRC = $(SRCDIR)/rpgle.l
YACC_SRC = $(SRCDIR)/rpgle.y
C_SRCS = $(SRCDIR)/main.c $(SRCDIR)/ast.c $(SRCDIR)/codegen.c

# Generated files
LEX_GEN = $(SRCDIR)/lex.yy.c
YACC_GEN = $(SRCDIR)/rpgle.tab.c
YACC_HDR = $(SRCDIR)/rpgle.tab.h

# Object files
LEX_OBJ = $(OBJDIR)/lex.yy.o
YACC_OBJ = $(OBJDIR)/rpgle.tab.o
C_OBJS = $(patsubst $(SRCDIR)/%.c,$(OBJDIR)/%.o,$(C_SRCS))

# Target executable
TARGET = $(BINDIR)/rpglec

.PHONY: all clean test directories

all: directories $(TARGET)

directories:
	@mkdir -p $(OBJDIR)
	@mkdir -p $(BINDIR)

# Generate lexer
$(LEX_GEN): $(LEX_SRC)
	$(LEX) $(LFLAGS) -o $@ $<

# Generate parser
$(YACC_GEN) $(YACC_HDR): $(YACC_SRC)
	$(YACC) $(YFLAGS) -o $(YACC_GEN) $<

# Compile generated lexer
$(LEX_OBJ): $(LEX_GEN) $(YACC_HDR)
	$(CC) $(CFLAGS) -c -o $@ $<

# Compile generated parser
$(YACC_OBJ): $(YACC_GEN) $(YACC_HDR)
	$(CC) $(CFLAGS) -c -o $@ $<

# Compile C source files
$(OBJDIR)/%.o: $(SRCDIR)/%.c
	$(CC) $(CFLAGS) -c -o $@ $<

# Link everything
$(TARGET): $(YACC_OBJ) $(LEX_OBJ) $(C_OBJS)
	$(CC) $(CFLAGS) -o $@ $^ -lm

# Clean build artifacts
clean:
	rm -f $(OBJDIR)/*.o
	rm -f $(LEX_GEN) $(YACC_GEN) $(YACC_HDR)
	rm -f $(SRCDIR)/*.output
	rm -f $(TARGET)
	rm -rf $(OBJDIR) $(BINDIR) $(TESTDIR)

# Test target
test: $(TARGET)
	@echo "Running test examples..."
	@mkdir -p $(TESTDIR)
	@for f in examples/*.rpgle; do \
		if [ -f "$$f" ]; then \
			base=$$(basename "$$f" .rpgle); \
			echo "Compiling $$f..."; \
			$(TARGET) "$$f" -o "$(TESTDIR)/$${base}.c" && \
			$(CC) -o "$(TESTDIR)/$${base}" "$(TESTDIR)/$${base}.c" -lm 2>/dev/null || true; \
		fi \
	done
	@echo "Test files compiled to $(TESTDIR)/ directory"

# Install (optional)
install: $(TARGET)
	install -d $(DESTDIR)/usr/local/bin
	install -m 755 $(TARGET) $(DESTDIR)/usr/local/bin/

# Help
help:
	@echo "RPGLE Free Format Compiler - Makefile"
	@echo ""
	@echo "Targets:"
	@echo "  all      - Build the compiler (default)"
	@echo "  clean    - Remove all build artifacts (obj/, bin/, test/)"
	@echo "  test     - Compile all examples to test/ directory"
	@echo "  install  - Install the compiler to /usr/local/bin"
	@echo "  help     - Show this help message"
	@echo ""
	@echo "Usage:"
	@echo "  make          - Build the compiler"
	@echo "  make clean    - Clean build artifacts"
	@echo "  make test     - Run tests"
