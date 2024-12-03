TARGET    = tasm
CSRCS     = tasmmain.c tasm.c errlog.c fname.c lookup.c macro.c \
            parse.c rules.c str.c wrtobj.c
INCLUDES  = 
OBJECTS   = $(CSRCS:.c=.o)
LIBRARIES =

# Define the standard tool paths and options.
CC       = clang
LD       = $(CC)
CCFLAGS  = -std=c11 -ggdb3 -O3 -Wall -Wextra -Wno-deprecated-declarations \
           -funsigned-char -fshort-enums -pthread \
           $(foreach inc,$(INCLUDES),-I$(inc)) \
           $(foreach def,$(DEFINES),-D$(def))
LDFLAGS  = 

# Rule to build the executable
all: $(TARGET)

$(TARGET): $(OBJECTS)
	$(LD) $(LDFLAGS) -o $(TARGET) $(OBJECTS) $(LIBRARIES)

# Rule to compile C files
%.o: %.c
	$(CC) -c $(CCFLAGS) -MMD -MP -o $@ $<

# Include dependencies generated automatically
-include $(OBJECTS:.o=.d)

# A rule to clean up
clean:
	rm -f $(TARGET) $(OBJECTS) $(OBJECTS:.o=.d) *~ *.core core tests/*.obj tests/*.lst tests/*.sym

# Rule to run tests after compiling
tests: $(TARGET)
	@echo "Running tests..."
	export TASMTABS=./tables && \
	./$(TARGET) -80 -x tests/testz80.asm && \
	./$(TARGET) -65 -x tests/test65.asm && \
	./$(TARGET) -51 tests/test51.asm && \
	./$(TARGET) -85 tests/test85.asm && \
	./$(TARGET) -05 -x tests/test05.asm && \
	./$(TARGET) -3210 tests/test3210.asm && \
	./$(TARGET) -3225 tests/test3225.asm && \
	./$(TARGET) -68 -x tests/test68.asm && \
	./$(TARGET) -70 tests/test70.asm && \
	./$(TARGET) -96 -x tests/test96.asm



# Define environment variable and path to add to shell config files
TASMTABS=$(HOME)/.tasm/tables
BIN_PATH=$(HOME)/.tasm/bin

# Rule for installation
install: $(TARGET)
	@echo "Installing on system..."
	@sh ./install.sh

# Rule for uninstallation
uninstall:
	@echo "Uninstalling on system..."
	@sh ./uninstall.sh
	
.PHONY: all clean tests install uninstall
