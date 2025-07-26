MEMORY
{
    FLASH (rx) : ORIGIN = 0x00000000, LENGTH = 128K
    RAM (rwx)  : ORIGIN = 0x20000000, LENGTH = 8K
}

SECTIONS
{
    .text : {
        *(.vectors)
        *(.text)
    } > FLASH

    /* You can add .data and .bss if needed later */
}

_StackTop = ORIGIN(RAM) + LENGTH(RAM);
PROVIDE(_stack = _StackTop - 4);
