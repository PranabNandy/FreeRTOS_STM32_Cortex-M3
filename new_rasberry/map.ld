ENTRY(_start)

SECTIONS
{
  /*  . = 0x8000;            /* Pi boots at 0x8000 */
    . = 0x10000;
    .text : {
        *(.init)
        *(.text*)
    }

    .rodata : {
        *(.rodata*)
    }

    .data : {
        *(.data*)
    }

    .bss : {
        *(.bss*)
        *(COMMON)
    }

    . = ALIGN(8);
    stack_top = . + 0x1000;  /* 4KB stack */
}
