K=kernel
U=user

OBJS = \
  $K/entry.o \
  $K/start.o \
	$K/vga.o \
	$K/pci.o \
	$K/uart.o \
  $K/main.o \

ifndef TOOLPREFIX
TOOLPREFIX := $(shell if riscv64-unknown-elf-objdump -i 2>&1 | grep 'elf64-big' >/dev/null 2>&1; \
	then echo 'riscv64-unknown-elf-'; \
	elif riscv64-linux-gnu-objdump -i 2>&1 | grep 'elf64-big' >/dev/null 2>&1; \
	then echo 'riscv64-linux-gnu-'; \
	elif riscv64-unknown-linux-gnu-objdump -i 2>&1 | grep 'elf64-big' >/dev/null 2>&1; \
	then echo 'riscv64-unknown-linux-gnu-'; \
	else echo "***" 1>&2; \
	echo "*** Error: Couldn't find a riscv64 version of GCC/binutils." 1>&2; \
	echo "*** To turn off this error, run 'gmake TOOLPREFIX= ...'." 1>&2; \
	echo "***" 1>&2; exit 1; fi)
endif

QEMU = qemu-system-riscv64

CC = $(TOOLPREFIX)gcc
AS = $(TOOLPREFIX)as
LD = $(TOOLPREFIX)ld

CFLAGS = -Wall
CFLAGS += -O0
CFLAGS += -ggdb
CFLAGS += -mcmodel=medany


RUNFLAGS = -machine virt
RUNFLAGS += -bios none
RUNFLAGS += -gdb tcp::1234
RUNFLAGS += -kernel kernel/kernel
RUNFLAGS += -m 128M
# RUNFLAGS += -nographic
RUNFLAGS += -device VGA
RUNFLAGS += -vga cirrus
RUNFLAGS += -monitor stdio
RUNFLAGS += -smp 1


DEBUGFLAGS = -machine virt
DEBUGFLAGS += -bios none
DEBUGFLAGS += -gdb tcp::1234
DEBUGFLAGS += -kernel kernel/kernel
DEBUGFLAGS += -m 128M
# DEBUGFLAGS += -nographic
DEBUGFLAGS += -device VGA
DEBUGFLAGS += -vga cirrus
DEBUGFLAGS += -monitor stdio
DEBUGFLAGS += -smp 1
DEBUGFLAGS += -S

RUN = qemu-system-riscv64 $(RUNFLAGS)
DEBUG = qemu-system-riscv64 $(DEBUGFLAGS)


# qemu-system-riscv64 -machine virt -bios none -gdb tcp::1234 -kernel kernel -m 128M -nographic



$K/kernel: $(OBJS) $K/kernel.ld
	$(LD) $(LDFLAGS) -T $K/kernel.ld -o $K/kernel $(OBJS)

compile: $K/kernel

run: $K/kernel
	$(RUN)

debug: $K/kernel
	$(DEBUG)

clean:
	rm */*.asm */*.sym */*.o
