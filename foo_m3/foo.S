# systick configuration registers
.equ systick_csr,   0xE000E010
.equ systick_rvr,   0xE000E014
.equ systick_cvr,   0xE000E018
.equ systick_calib, 0xE000E01c

.equ timout,        0x00ffffff

.section .vectors
vector_table:
	.word 0x20001000
	.word reset_handler
.org 0x3C
	.word systick_handler
	.zero 400
	
	
	.section .text
	.align 1
	.type reset_handler, %function
reset_handler:
	mov r1,#7
	mov r2,#3
	mov r3,#1
	
	push {r1,r2,r3}
	
	ldr r0, =systick_csr
	ldr r1, =systick_rvr
	ldr r2, =systick_cvr
	ldr r3, =timout
	
	str r3,[r1]
	mov r3, #0x0
	str r3, [r2]
	mov r3, #0x7
	str r3, [r0]
	
	mov r5, #0
	
	b myStartFunction
	
	.section .text
	.align 1
	.type systick_handler, %function
systick_handler:
	push {r4-r7}
	
	mov r0, r8
	mov r1, r9
	mov r2, r10
	mov r3, r11
	
	push {r0-r3}
	
	add r5, r5, #1
	b reset_handler
break_here:
	bx lr

	
