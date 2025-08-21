ENTRY(_start)

SECTIONS
{
    /* QEMU virt sets PC to 0x00010000 for -kernel raw binary */
    . = 0x10000;

    /* Put _start first, at the load address */
    .text : ALIGN(4) {
        KEEP(*(.text._start))   /* if you name the symbol that way */
        *(.init)                /* our startup.S if it uses .init */
        *(.text*)               /* the rest of .text */
    }

    .rodata : ALIGN(4) {
        *(.rodata*)
    }

    .data : ALIGN(4) {
        *(.data*)
    }

    .bss : ALIGN(4) {
        __bss_start = .;
        *(.bss*)
        *(COMMON)
        __bss_end = .;
    }

    /* Put the stack after everything and export its top */
    . = ALIGN(16);
    . += 0x4000;                /* 16 KB stack */
    PROVIDE(stack_top = .);
}
