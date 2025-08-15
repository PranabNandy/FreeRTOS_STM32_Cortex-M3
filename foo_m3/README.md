## Mini Scheduler 
- It is a timer based scheduler

## Linker Script
- When we don't mention any section for any function, by default compiler will consider it the text section




## ✅ Conclusion:
- If you use **.ramfunc** and make sure your linker marks it as `EXEC`, GDB will recognize it and show foo() as expected.
- If you just dump the code into **.data**, GDB won’t, because .data is never `EXEC`.

<img width="1827" height="633" alt="image" src="https://github.com/user-attachments/assets/fd6b39f0-d4fc-4d2d-bdce-5493e73dadf2" />

```ld
.data : AT (LOADADDR(.text) + SIZEOF(.text) + SIZEOF(.ramfunc))
    {
        _sdata = .;
        *(.data*)
        _edata = .;
    } > RAM
    _sidata = LOADADDR(.data);

.ramfunc :
{

} > RAM AT > MEM
```

| Attribute | Meaning                                                |
| --------- | ------------------------------------------------------ |
| **VMA**   | RAM — the section is linked to *execute* from RAM      |
| **LMA**   | Flash — the section is *stored* in Flash in the binary |

```ld
LMA(.data) = LMA(.text) + size_of(.text) + size_of(.ramfunc)
```
That means:

Flash layout: `[ .text ][ .ramfunc ][ .data_init_values ] ... `

RAM layout (at runtime): `[ .ramfunc (copied from Flash) ][ .data (copied from Flash) ] `

In the above LD script, we have to copy .data section from **LMA to VMA.**

```c++
#include <limits.h>
#include <stdint.h>

volatile uint32_t systick_ticks = 0;
volatile uint8_t current_task = 0; // 0 = foo, 1 = myStartFunction

void foo() {
    int a = INT_MAX;
    while (a) {
        a--;
        // Optional: break early if tick changes
        if (systick_ticks & 1) break;
    }
}

void myStartFunction() {
    int a = INT_MAX;
    while (a) {
        a--;
        // Optional: break early if tick changes
        if ((systick_ticks & 1) == 0) break;
    }
}

// SysTick handler (called from your assembly file)
void SysTick_Handler5(void) {
    systick_ticks++;
    // Flip task every tick
    current_task ^= 1;
}

/// @brief
/// @param
void run_scheduler(void) {
    while (1) {
        if (current_task == 0) {
            foo();
        } else {
            myStartFunction();
        }
    }
}
```
