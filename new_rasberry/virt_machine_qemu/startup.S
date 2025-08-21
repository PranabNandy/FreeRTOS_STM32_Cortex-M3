    .section .text
    .global _start

_start:
    /* Enter SVC mode with IRQ/FIQ disabled (ARMv7-A) */
//    cpsid   if
//    mrs     r0, cpsr
//    bic     r0, r0, #0x1f
//    orr     r0, r0, #0x13        /* SVC mode */
//    msr     cpsr_c, r0

    /* Set up stack */
    ldr     sp, =stack_top

    bl      main

1:  b       1b                    /* hang */
