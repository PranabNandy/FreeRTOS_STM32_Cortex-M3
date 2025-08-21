//volatile unsigned int *UART0 = (unsigned int *)0x3F201000; // Pi2/3 PL011 UART

#define UART0_BASE 0x101f1000
volatile unsigned int *UART0 = (unsigned int *)0x101f1000;  // -M versatilepb
//qemu-system-arm -M virt -cpu cortex-a15 -nographic -kernel kernel.img -m 128M -device virtio-net-device,romfile=""




void uart_putc(char c) {
    while (*((volatile unsigned int *)(0x3F201018)) & (1 << 5)); // Wait for TX ready
    *UART0 = c;
}

void uart_puts(const char *s) {
    while (*s) {
        uart_putc(*s++);
    }
}

int main(void) {
    uart_puts("Hello, Raspberry Pi on QEMU!\n");
    while (1);
    return 0;
}
