# tools
AS = nasm
ASFLAGS = -f elf64 -g -F dwarf -i src/
LD = ld


build:
	mkdir -p build


hi: build src/hi.asm
	$(AS) $(ASFLAGS) src/hi.asm -o build/hi.o
	$(LD) build/hi.o -o build/hi

cat: build src/cat.asm
	$(AS) $(ASFLAGS) src/cat.asm -o build/cat.o
	$(LD) build/cat.o -o build/cat

test_lib: build src/test_lib.asm
	$(AS) $(ASFLAGS) src/test_lib.asm -o build/test_lib.o
	$(LD) build/test_lib.o -o build/test_lib

hlvm: build src/main.asm src/lexer.asm src/lib.asm src/tokens.inc
	$(AS) $(ASFLAGS) src/main.asm -o build/main.o
	$(LD) build/main.o -o build/hlvm

clean:
	rm -rf build

.PHONY: hi cat test_lib hlvm clean