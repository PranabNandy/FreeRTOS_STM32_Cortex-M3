MEMORY
{
    FLASH (rx) : ORIGIN = 0x00000000, LENGTH = 128K
    RAM (rwx)  : ORIGIN = 0x20000000, LENGTH = 8K
}

SECTIONS
{
    /* Code and Read-Only Data in FLASH */
    .text :
    {
        _stext = .;
        KEEP(*(.vectors))   /* Interrupt Vector Table */
        *(.text*)           /* Program code */
        *(.rodata*)         /* Read-only data */
        . = ALIGN(4);
        _etext = .;
    } > FLASH

    /* Initialized Data in RAM, but stored in FLASH */
    .data : ALIGN(4)
    {
        _sdata = .;
        _sidata = LOADADDR(.data); /* Start of init values in FLASH */
        *(.data*)
        . = ALIGN(4);
        _edata = .;
    } > RAM AT > FLASH

    /* Uninitialized Data (.bss) in RAM */
    .bss : ALIGN(4)
    {
        _sbss = .;
        *(.bss*)
        . = ALIGN(4);
        _ebss = .;
    } > RAM

    /* Stack Pointer: Top of RAM */
    __StackTop = ORIGIN(RAM) + LENGTH(RAM);
    PROVIDE(__stack = __StackTop);
}
