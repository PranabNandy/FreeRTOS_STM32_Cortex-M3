# Project Configuration
PROJ = main
CPU ?= cortex-m3
BOARD ?= stm32vldiscovery


FREERTOS_PATH = ../FreeRTOS-Kernel
# Object files
OBJ = cpuBoot.o myStart.o portFunction.o\
	  $(FREERTOS_PATH)/tasks.o \
	  $(FREERTOS_PATH)/list.o \
	  $(FREERTOS_PATH)/portable/MemMang/heap_4.o \
	  $(FREERTOS_PATH)/portable/GCC/ARM_CM3/port.o \
	  
	  

INC = -I$(FREERTOS_PATH)/include/ \
	  -I$(FREERTOS_PATH)/portable/GCC/ARM_CM3 \
	  -I./
# Toolchain
CC = arm-none-eabi-gcc
AS = arm-none-eabi-as
LD = arm-none-eabi-ld
OBJDUMP = arm-none-eabi-objdump
READELF = arm-none-eabi-readelf

# QEMU and GDB
QEMU = qemu-system-arm
GDB = gdb-multiarch

# Build Rules
all: $(PROJ).elf

%.o: %.S
	$(AS) -mthumb -mcpu=$(CPU) -g -c $^ -o $@

%.o: %.c
	$(CC) $(INC) -mthumb -mcpu=$(CPU) -g -c $^ -o $@
	

$(PROJ).elf: $(OBJ)
	$(LD) -Tmap.ld $^ -o $@
	$(OBJDUMP) -D -S $@ > $@.lst
	$(READELF) -a $@ > $@.debug

# Run on QEMU
qemu:
	$(QEMU) -S -M $(BOARD) -cpu $(CPU) -nographic -kernel $(PROJ).elf -gdb tcp::1234

# Debug with GDB
gdb:
	$(GDB) -q $(PROJ).elf -ex "target remote localhost:1234"

# Clean build files
clean:
	rm -rf *.o *.out *.elf .gdb_history *.lst *.debug
