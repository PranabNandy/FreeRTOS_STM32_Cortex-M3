CROSS   = arm-none-eabi-
CC      = $(CROSS)gcc
LD      = $(CROSS)ld
OBJCOPY = $(CROSS)objcopy

CFLAGS  = -O2 -ffreestanding -fno-pic -nostdlib -Wall -Wextra -mcpu=cortex-a15 -marm
LDFLAGS = -T map.ld

all: kernel.img

startup.o: startup.S
	$(CC) $(CFLAGS) -c startup.S -o startup.o

main.o: main.c
	$(CC) $(CFLAGS) -c main.c -o main.o

kernel.elf: startup.o main.o
	$(LD) $(LDFLAGS) startup.o main.o -o kernel.elf

kernel.img: kernel.elf
	$(OBJCOPY) -O binary kernel.elf kernel.img

run:
	qemu-system-arm -M virt -cpu cortex-a15 -nographic -kernel kernel.img

clean:
	rm -f *.o *.elf *.img
qemu:
	qemu-system-arm -M virt -cpu cortex-a15 -nographic -kernel kernel.img -serial mon:stdio -nodefaults