This contains only basic Cortex-M3 demo where we set up stack and vector table specially reset_handler.

Then we try to multiple function call from reset_handler

-----------------------------------------------------------------------------------------------------
# 1st pdf
<img width="1195" height="720" alt="image" src="https://github.com/user-attachments/assets/c1f8e97a-b94b-433d-b805-5bf946803f82" />

## Triggering the System Call from EL0
```ASM
// user program in EL0 making a system call (e.g., write syscall)
mov x8, #64 // syscall number for write (Linux ARM64)
mov x0, #1 // file descriptor (stdout = 1)
adr x1, print_msg // pointer to message
mov x2, #12 // length of message

svc #0 // trigger system call to EL1
print_msg:
    .asciz "Hey from EL0, this message is for EL1\n"

```
- I load the system call number (64 for write in Linux ARM64)
into x8, set up arguments in x0–x2 (per the Linux ABI), and issue svc #0.

- The immediate value (#0) is mostly ignored in practice but can be used by the kernel
to differentiate types of supervisor calls.
- When svc executes, the processor **(automatically happens in h/w, no s/w intervention is required)**:
  - Switches to EL1.
  - Saves the program counter `(PC)` to `ELR_EL1` (Exception Link Register for EL1)
  - Saves the status register `(PSTATE)` to `SPSR_EL1` (Saved Program Status Register
for EL1)
   - Jumps to the vector table entry for synchronous exceptions.

Note: The svc instruction doesn’t save general-purpose registers (x0–x30). That’s
on the kernel to handle, or you risk clobbering user state.

## The Vector Table and Synchronous Exception Handling
When the svc instruction fires, the processor looks at the Vector Base Address
Register (VBAR_EL1). For a 64-bit EL0 app, the processor jumps to the “Synchronous, Lower EL, AArch64”
entry.
```ASM
// vector table in EL1
.align 11 // align to 2KB boundary (ARMv8a architecture requirement)
vector_table:
    // synchronous exception from current EL with SP0
    b sync_handler
    .align 7 // each entry is 128 bytes (ARMv8a architecture requirement)
    // other entries (interrupts, FIQ, etc.)
    b .
    .align 7
    b .
    .align 7
    b .
    .align 7
    // synchronous exception from lower EL (EL0, AArch64)
    b sync_lower_el

sync_handler:
// handle synchronous exceptions (e.g., svc from EL1)
    b .

sync_lower_el:
    // save context, parse the ESR, handle syscall, restore the context, return to EL0
    bl save_context // save registers (Explained in detail in the next section)
    bl parse_and_handle_syscall // call syscall handler (Explained in detail in the next section)
    bl restore_context // restore the registers (Explained in detail in the next section)
    eret // return to EL0

```
The vector table must be aligned to a 2KB boundary (hence .align 11). Each entry is
128 bytes, allowing for small handlers or branches to larger ones. For our system
call, the processor jumps to sync_lower_el.

## Context Switching
In EL1, the kernel saves the EL0 context (general-purpose registers, etc.) to
ensure the user program can resume. On return, it restores the context before
**eret.**

```ASM
Context save/restore sub-routines:
// context save in EL1
save_context:
    sub sp, sp, #256 // allocate space for context
    stp x0, x1, [sp, #16 * 0] // save x0, x1
    stp x2, x3, [sp, #16 * 1] // save x2, x3
    stp x4, x5, [sp, #16 * 2]
    stp x6, x7, [sp, #16 * 3]
    stp x8, x9, [sp, #16 * 4]
    stp x10, x11, [sp, #16 * 5]
    stp x12, x13, [sp, #16 * 6]
    stp x14, x15, [sp, #16 * 7]
    stp x16, x17, [sp, #16 * 8]
    stp x18, x19, [sp, #16 * 9]
    stp x20, x21, [sp, #16 * 10]
    stp x22, x23, [sp, #16 * 11]
    stp x24, x25, [sp, #16 * 12]
    stp x26, x27, [sp, #16 * 13]
    stp x28, x29, [sp, #16 * 14]
    stp x30, xzr, [sp, #16 * 15] // save x30, pad with zero
    ret


// context restore in EL1
restore_context:
    ldp x0, x1, [sp, #16 * 0] // restore x0, x1
    ldp x2, x3, [sp, #16 * 1] // restore x2, x3
    ldp x4, x5, [sp, #16 * 2]
    ldp x6, x7, [sp, #16 * 3]
    ldp x8, x9, [sp, #16 * 4]
    ldp x10, x11, [sp, #16 * 5]
    ldp x12, x13, [sp, #16 * 6]
    ldp x14, x15, [sp, #16 * 7]
    ldp x16, x17, [sp, #16 * 8]
    ldp x18, x19, [sp, #16 * 9]
    ldp x20, x21, [sp, #16 * 10]
    ldp x22, x23, [sp, #16 * 11]
    ldp x24, x25, [sp, #16 * 12]
    ldp x26, x27, [sp, #16 * 13]
    ldp x28, x29, [sp, #16 * 14]
    ldp x30, xzr, [sp, #16 * 15]
    add sp, sp, #256 // free up the space (remember we allocated this in save_context)
    ret
```

## Parsing ESR_EL1
The `Exception Syndrome Register (ESR_EL1)` identifies the exception cause. Remember,
**h/w will only be able to identify that a synchronous exception from lower EL and
the control would be transferred to the appropriate entry in vector table which
is sync_lower_el.** We will have to identify if it is indeed a svc call or not, and
for that, we will have to decode the exception syndrome register.
For a system call, it confirms an svc instruction and provides details.


```ASM
// Parse annd handle syscalls
parse_and_handle_syscall:
    // parse ESR_EL1 to identify exception type and handle them accordingly
    mrs x0, esr_el1 // read ESR_EL1
    ubfx x1, x0, #26, #6 // extract Exception Class bits - BITs 31:26
    cmp x1, #0x15 // EC for SVC from AArch64 = 0x15
    b.eq handle_svc // branch to SVC handler (at this point we have with certainity figured it's // handle other exceptions
    b other_exception
handle_svc:
    ubfx x2, x0, #0, #16 // extract ISS (Instruction Specific Syndrome)
    // x2 contains SVC immediate
    ret
other_exception:
    // handle other cases
    b .

```

## ELR_EL1 and Returning to EL0

ELR_EL1 holds the return address (usually the instruction after svc). The kernel
can modify it for special cases.
```ASM
// prepare to return to EL0
return_to_el0:
    // ELR_EL1 holds return address
    // SPSR_EL1 holds saved PSTATE
    bl restore_context
    eret // return to EL0
```
The **eret instruction** restores PC from ELR_EL1 and state from SPSR_EL1.
-----------------------------------------------------------------------------------------------------
# 2nd pdf

## EL0 : User Application
**EL0 code can’t even touch the memory management unit (MMU)** configuration. The
page tables it uses are set up **by EL1 (the OS)**, and EL0 has to trust them
blindly. This isolation is great for security as third-party code should
seldom be trusted.

## EL1: The OS / Kernel Layer
It’s got way more power than EL0, with direct access to **hardware resources like the MMU,**
interrupts, and most system registers.

## EL2: Hypervisor - (I like to think of it as Scheduler for Kernels/VMs)
```ASM
// Vector table entry for synchronous exception of EL2
sync_exception_entry:
    // ESR_EL2 contains the exception cause details
    mrs x0, esr_el2 // Exception Syndrome Register
    ubfx x1, x0, #0, #26 // Extract syndrome
    ubfx x2, x0, #26, #6 // Extract exception class (EC)
    cmp x2, #0x16 // Check whether it was hypervisor call (0x16 is the value for hvc from EL1)
    b.eq hvc_handler
    // Code for handling other sync exceptions


hvc_handler:
    // Read HVC immediate value (passed via hvc #imm_id)
    ubfx x3, x1, #0, #16 // Extract immediate value from ISS
    // E.g. Handle specific HVC call (e.g., imm_id == 0x1 for guest info request)
    cmp x3, #0x1
    b.eq hadnle_guest_info
    // Handling of other HVC imm_ids
    ...
    ...
return_to_el1:
    eret // Return to EL1 (we will also have to modify spsr, we will cover in detail in next
```
## EL3: The Secure Monitor
```ASM
// Vector table entry for synchronous exception at EL3
sync_exception_entry:
    mrs x9, esr_el3 // Read Exception Syndrome Register
    and x10, x9, #0x3F // Extract exception class
    cmp x10, #0x17 // Check whether it was secure monitor call (0x17 is the value for smc from EL1/b.eq smc_handler
    // Code for handling other sync exceptions
smc_hanlder:
    // Based on the request ID, decide whether switch to secure world is needed or not
    // If needed modify SCR_EL3 appropriately and then return
    eret
```


The secure monitor (EL3) acts as a gatekeeper, using the **`scr_el3 (Secure Configuration Register)`** to control and switch between the two worlds. The snippet shows
that switch from NS to S world.
```ASM
    // scr_el3 to switch to secure world
    mrs x0, scr_el3
    orr x0, x0, #1 // Set NS bit to 0 (Secure world)
    msr scr_el3, x0
    isb
    // Set elr_el3 correspondingly
    eret // Control would be transferred to secure world post the exception return
```


-----------------------------------------------------------------------------------------------------
# 3rd pdf
## 1. Vector Table
When an interrupt occurs, the ARM processor performs a semi hardware-assisted
exception handling (What do I mean by semi-assisted, we will find answer real
soon).

For synchronous exceptions (like data aborts) or asynchronous exceptions (like
IRQs and FIQs) taken from `EL0`, the processor jumps to an entry point specified in
the **Vector Base Address Register (`VBAR_EL1`).**


Each exception level (`EL1, EL2, EL3`) has its own `VBAR`. When an exception is taken,
the processor determines the target exception level (which is EL1 if we’re coming
from EL0) and uses that EL’s VBAR (i.e EL1 VBAR) to locate the vector table. The vector table
contains addresses of the exception handlers.

**NOTE:** While we are executing at EL0, any interrupt will be taken to EL1. This
is a fundamental concept in ARMv8-A exception handling. We can’t directly handle
interrupts at EL0; the architecture mandates a transition to a higher exception
level (typically EL1) to handle them. IRQs/FIQs and other exceptions are deemed
crucial enough to not be handled at EL0 user space.


```ASM
// EL1 Vector Table
.align 11 // Vector table must be 2KB aligned (2^11)
el1_vector_table: // This address will be loaded in VBAR_EL1 during boot time
    // ... other exception entries ...
    // EL1_SYNC: Synchronous exception from EL0 (At offset 0x400)
    b el1_sync_handler
    // EL1_IRQ: IRQ from EL0 (At offset 0x480)
    b el1_irq_handler // This is where our IRQ handling journey begins!
    // EL1_FIQ: FIQ from EL0 (At offset 0x500)
    b el1_fiq_handler
    // EL1_SERROR: SError from EL0 (At offset 0x580)
    b el1_serror_handler
    // ... other exception entries ...
el1_irq_handler:
    // This is our main IRQ handler entry point
    // We'll dive into the details of this handler shortly
    // We will cover the full vector table structure in some other posts
    b .
```

## 2. Are Interrupts Masked by default in an interrupt context?

To answer it shortly, **Yes,** when an exception is taken, the hardware automatically
**masks** asynchronous exceptions (IRQs and FIQs) at the target exception level.

Specifically, upon entering an exception handler at EL1 (from EL0), the `PSTATE.I`
(IRQ mask bit) and `PSTATE.F` (FIQ mask bit) bits are set to 1, effectively disabling
further IRQs and FIQs. This prevents immediate re-entry into an interrupt handler
before the current one has had a chance to save its context or establish its own
interrupt handling policy.

We can re-enable interrupts within our handler if we intend to support nested
interrupts.


## 3. GIC and CPU Interface’s Interaction

It’s a separate `hardware block` responsible for aggregating
interrupt sources, prioritizing them, and presenting them to the ARM core. The CPU
interface is the part of the GIC that directly communicates with the ARM processor.







-----------------------------------------------------------------------------------------------------
## Raspberry Pi 4 Model B Boot Sequence

### 1.Power-On and Initial Hardware Initialization
- Power Application: Power is supplied via the USB-C port, and the Voltage
Controller IC (PMIC) distributes stable power to the Broadcom BCM2711 SoC and
other components.
- SoC Reset: The ARM Cortex-A72 processor is held in reset, and the VideoCore
IV GPU takes control to execute initial code.
- Boot ROM Activation: The SoC’s internal Boot ROM, a non-volatile memory,
contains the first code executed during boot.


### 2.First-Stage Bootloader (Boot ROM)
- The Boot ROM searches for a bootable medium in this order:
    - SD Card: Checks for a FAT32/FAT16 partition with boot files.
    - USB Device: If USB boot is enabled (via OTP or configuration) and no SD
card is found.
    - Network Boot: If configured and no SD/USB is available.
    - Fallback: Halts if no bootable medium is found, with the green LED blinking
to indicate failure.
- The Boot ROM loads bootcode.bin from the boot partition into the GPU’s L2 cache
and executes it.


### 3.Second-Stage Bootloader (bootcode.bin)
- Role of bootcode.bin: This proprietary firmware, executed by the GPU, initializes:
    - SDRAM (DDR4 memory).
    - SD card interface (for SD boot).
    - Clock and power management.
    - Next Stage: Loads start.elf (or start4.elf for Pi 4) into RAM.
- If bootcode.bin is missing or corrupted, the boot process fails, indicated by
LED blinking.


### 4.Third-Stage Bootloader (start.elf)
- GPU Firmware Execution: start.elf configures hardware further, including:
    - Memory split between GPU and CPU (set in config.txt).
    - Peripherals like HDMI, USB, and Ethernet.
    - Parsing config.txt for user-defined boot settings (e.g., overclocking, display).
- Loading Kernel and Device Tree:
    - Loads Device Tree Blob (e.g., bcm2711-rpi-4-b.dtb) for hardware configuration.
    - Loads the Linux kernel (e.g., kernel8.img for 64-bit or kernel7l.img for
32-bit) into RAM.
- Optional Files:
    - cmdline.txt: Specifies kernel parameters (e.g., root filesystem location).
    - Overlays: Device tree overlays from config.txt enable specific hardware
features.


### 5.CPU Activation and Kernel Execution
- Handover to CPU: start.elf releases the ARM Cortex-A72 from reset and jumps to
the kernel’s entry point.
- Kernel Initialization: The Linux kernel initializes:
    - Hardware drivers (e.g., MMU, interrupts).
    - Filesystem mounting (per cmdline.txt).
    - Core system services (e.g., init or systemd).
- The kernel mounts the root filesystem (typically on the second SD/USB partition)
and starts the init system.


### 6.Operating System Boot
- Init System: The init system (e.g., systemd on Raspberry Pi OS):
    - Loads drivers for peripherals (e.g., Wi-Fi, Bluetooth, GPIO).
    - Starts system services (e.g., networking, SSH, desktop).
    - Launches a login prompt or graphical desktop (e.g., LXDE).
- User Environment: A graphical interface or command-line interface is presented
based on configuration.


### 7.Optional Boot Modes
- USB Boot: Enabled via OTP or firmware updates for booting from USB drives.
- Network Boot: Uses a PXE server and specific firmware settings to boot over
the network.
- EEPROM Updates: The Boot EEPROM stores bootcode.bin and can be updated to modify
boot behavior.


### Notes
- The VideoCore IV GPU handles early boot stages before the ARM CPU is activated.
- config.txt allows customization (e.g., overclocking, kernel selection).
- Boot failures are indicated by specific green LED blink patterns (e.g., 4
blinks for “start.elf not found”).
- Supports 32-bit and 64-bit OS, determined by the kernel image.
- **start.elf/start4.elf:** GPU firmware for hardware setup and kernel loading.
