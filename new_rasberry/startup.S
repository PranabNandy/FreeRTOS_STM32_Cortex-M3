    .section .init
    .global _start
_start:
    ldr sp, =stack_top        // Initialize stack pointer
    bl main                   // Call C main
hang:
    b hang                    // Loop forever
