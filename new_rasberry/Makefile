CROSS = arm-none-eabi-
CC = $(CROSS)gcc
LD = $(CROSS)ld
OBJCOPY = $(CROSS)objcopy

CFLAGS = -O2 -ffreestanding -nostdlib -Wall -mcpu=arm1176jzf-s
LDFLAGS = -T map.ld

all: kernel.img

startup.o: startup.S
	$(CC) $(CFLAGS) -c startup.S -o startup.o

main.o: main.c
	$(CC) $(CFLAGS) -c main.c -o main.o

kernel.elf: startup.o main.o
	$(LD) $(LDFLAGS) startup.o main.o -o kernel.elf

kernel.img: kernel.elf
	$(OBJCOPY) kernel.elf -O binary kernel.img

clean:
	rm -f *.o *.elf *.img
