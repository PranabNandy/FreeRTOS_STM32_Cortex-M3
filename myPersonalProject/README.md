This contains only basic Cortex-M3 demo where we set up stack and vector table specially reset_handler.

Then we try to multiple function call from reset_handler

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
= config.txt allows customization (e.g., overclocking, kernel selection).
- Boot failures are indicated by specific green LED blink patterns (e.g., 4
blinks for “start.elf not found”).
- Supports 32-bit and 64-bit OS, determined by the kernel image.
- **start.elf/start4.elf:** GPU firmware for hardware setup and kernel loading.
