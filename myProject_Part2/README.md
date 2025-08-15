## Flow Example
- Power-up / Reset

    - CPU starts in **Thread Mode with MSP.**

    - Stack pointer = _stack_top from vector table.

- RTOS Starts

    - OS switches tasks to **Thread Mode + PSP for user threads.**

- Interrupt Hits (e.g., SysTick)

    - CPU pushes Thread registers on **MSP** (even though Thread was using PSP).

    - Switches to Handler Mode.

    - ISR executes.

- ISR Returns

    - CPU pops state from **MSP**, resumes Thread Mode using **PSP** again.
