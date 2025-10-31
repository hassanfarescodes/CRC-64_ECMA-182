ASM       := nasm
LD        := ld
ASMFLAGS  := -felf64 -I include/
LDFLAGS   :=
SRC_DIR   := src
BUILD_DIR := build
SRC       := $(SRC_DIR)/CRC.asm
OBJ       := $(BUILD_DIR)/CRC.o
BIN       := $(BUILD_DIR)/crc

all: $(BUILD_DIR) $(BIN)

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

$(BIN): $(OBJ)
	$(LD) $(LDFLAGS) -o $@ $^

$(BUILD_DIR)/%.o: $(SRC_DIR)/%.asm | $(BUILD_DIR)
	$(ASM) $(ASMFLAGS) -o $@ $<

clean:
	rm -rf $(BUILD_DIR)

.PHONY: all clean
