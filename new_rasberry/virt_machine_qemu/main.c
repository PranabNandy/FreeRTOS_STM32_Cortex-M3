// qemu-system-arm -M virt -cpu cortex-a15 -nographic -kernel kernel.img -serial mon:stdio -nodefaults

#define UART0_BASE  0x09000000
#define UART0_DR    (*(volatile unsigned int *)(UART0_BASE + 0x00))
#define UART0_FR    (*(volatile unsigned int *)(UART0_BASE + 0x18))

void uart_putc(char c) {
    while (UART0_FR & (1 << 5)) ;  // Wait until TX FIFO not full
    UART0_DR = c;
}


#define UART0_CR   (*(volatile unsigned int *)(UART0_BASE + 0x30))
#define UART0_IBRD (*(volatile unsigned int *)(UART0_BASE + 0x24))
#define UART0_FBRD (*(volatile unsigned int *)(UART0_BASE + 0x28))
#define UART0_LCRH (*(volatile unsigned int *)(UART0_BASE + 0x2C))

void uart_init(void) {
    UART0_CR = 0x0;          // Disable UART
    UART0_IBRD = 1;          // Integer baud divisor
    UART0_FBRD = 40;         // Fractional baud divisor
    UART0_LCRH = (3 << 5);   // 8-bit, no parity, 1 stop bit, FIFO disabled
    UART0_CR = (1 << 9) | (1 << 8) | 1; // Enable TX, RX, UART
}



int main(void) {
    uart_init();
    uart_putc('H');
    uart_putc('i');
    uart_putc('\n');
    while (1);
}
