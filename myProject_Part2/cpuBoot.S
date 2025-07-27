    .section .vectors
vector_table:
    .word _stack          /* Initial stack pointer */
    .word reset_handler   /* Reset handler */
	.word default
	.word default
	.word default
	.word default
	.word default
	.word default
	.word default
	.word default
	.word default
	.word vPortSVCHandler
	.word default
	.word default
	.word xPortPendSVHandler
	.word xPortSysTickHandler
	.word default
	.zero 400             /* Reserved space for other vectors */

    .section .text
    .align 1
    .type reset_handler, %function
reset_handler:
    b myStartFunction     /* Branch to myStartFunctiontart function */
	mov r1, #1
	mov r2, #2
	add r3,r1,r2
    b .                   /* Infinite loop (safety) */
	
    .section .text
    .align 1
    .type default, %function
default:
    b .                   /* Infinite loop (safety) */