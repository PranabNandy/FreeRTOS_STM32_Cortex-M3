# FreeRTOS_STM32_Cortex-M3
MCU - https://github.com/PranabNandy/Linux-Kernel-Internals/tree/main/3.MCU

Cortex M3 - https://github.com/PranabNandy/Arm-Architecture/tree/main 

## Free RTOS from Scratch
- It also focus on Arm M3 cortex
- STM32VLDISCOVERY board
- Only RTOS kernel

## Install the these dependency
- sudo apt update
- sudo apt upgrade
- sudo apt install qemu-system-aarch64
- sudo apt install gcc-aarch64-linux-gnu
- sudo apt install crossbuild-essential-arm64

  
# Resources
- [FreeRTOS Documentation](https://github.com/FreeRTOS/FreeRTOS-Kernel-Book/releases/download/V1.1.0/Mastering-the-FreeRTOS-Real-Time-Kernel.v1.1.0.pdf)
- [FreeRTOS Kernel Repo](https://github.com/FreeRTOS/FreeRTOS-Kernel)
- [ARM M for Beginners](https://community.arm.com/cfs-file/__key/telligent-evolution-components-attachments/01-2142-00-00-00-00-52-96/White-Paper-_2D00_-Cortex_2D00_M-for-Beginners-_2D00_-2016-_2800_final-v3_2900_.pdf)
- [STM32VLDISCOVERY Board](https://www.st.com/resource/en/user_manual/um0919-stm32vldiscovery-stm32-value-line-discovery-stmicroelectronics.pdf)
  - [Datasheet](https://www.st.com/resource/en/reference_manual/dm00031020-stm32f405-415-stm32f407-417-stm32f427-437-and-stm32f429-439-advanced-arm-based-32-bit-mcus-stmicroelectronics.pdf)

# License

All rights reserved. Only for learning purposes.

## STM board
Due to its fixed memory map, the **code area** starts from address `0x0000 0000` (accessed
through the ICode/DCode buses) while the **data area (SRAM)** starts from address
`0x2000 0000` (accessed through the system bus).

## stm32vldiscovery ( which uses an STM32F100RB )
| Region           | Start Addr | Size   | Purpose                    |
| ---------------- | ---------- | ------ | -------------------------- |
| Flash            | 0x08000000 | 128 KB | Program code, constants    |
| SRAM             | 0x20000000 | 8 KB   | Data, stack, heap          |
| System Memory    | 0x1FFFF000 | 2 KB   | ST factory bootloader      |
| Option Bytes     | 0x1FFFF800 | 16 B   | Configuration settings     |
| Peripheral space | 0x40000000 | —      | Registers for peripherals  |
| Cortex-M3 PPB    | 0xE0000000 | —      | NVIC, SysTick, debug, etc. |


### What it is PPB (Private Pheripheral Bus)
It’s a special memory region inside the ARM memory map.

Used for **core peripherals that are private to the CPU core** (not the general microcontroller peripherals like GPIO, USART, etc.).

These registers are always present in every Cortex-M3, regardless of the microcontroller vendor.

### Peripherals are also important

- MMU, GIC, Timers, Caches, Synchronization, Interconnect ( Coherent{AXI,ACE} & Non-coherent )

### Bus Protocol & Cache Coherent Interconnect

- ACE, AXI
