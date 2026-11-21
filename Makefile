# tools
AS = nasm
ASFLAGS = -f elf64 -g -F dwarf
LD = ld


build:
	mkdir -p build


hi: build src/hi.asm
	$(AS) $(ASFLAGS) src/hi.asm -o build/hi.o
	$(LD) build/hi.o -o build/hi

clean:
	rm -rf build

.PHONY: hi clean