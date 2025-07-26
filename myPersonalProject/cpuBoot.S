    .section .vectors
vector_table:
    .word _stack          /* Initial stack pointer */
    .word reset_handler   /* Reset handler */
    .zero 400             /* Reserved space for other vectors */

    .section .text
    .align 1
    .type reset_handler, %function
reset_handler:
    b myStartFunction     /* Branch to myStartFunctiontart function */
    b .                   /* Infinite loop (safety) */