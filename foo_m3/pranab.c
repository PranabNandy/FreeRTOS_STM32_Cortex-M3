#include <limits.h>
#include <stdint.h>

volatile uint32_t systick_ticks = 0;
volatile uint8_t current_task = 0; // 0 = foo, 1 = myStartFunction


//__attribute__((section(".data")))   --> Need to verify
/*
    Here’s why you see that "Cannot find bounds of current function" and why GDB can’t show it:

GDB, when you step into that address, sees:
    “Hmm… the PC is inside a section that’s not executable, 
     so I have no symbol boundaries or debug lines for it.”

even though the CPU happily runs the bytes (ARM doesn’t care about section flags).
*/
void foo() {
    int a = INT_MAX;
    while (a) {
        a--;
        // Optional: break early if tick changes
        if (systick_ticks & 1) break;
    }
}
__attribute__((section(".new_section1")))
void myStartFunction() {  // 0x00000250
    int a = INT_MAX;
    while (a) {
        a--;
        // Optional: break early if tick changes
        if ((systick_ticks & 1) == 0) break;
    }
}

// SysTick handler (called from your assembly file)
__attribute__((section(".new_section2")))
void SysTick_Handler5(void) {   // 0x000002a8
    systick_ticks++;
    // Flip task every tick
    current_task ^= 1;
}

/// @brief
/// @param
__attribute__((section(".new_section1")))
void run_scheduler(void) {    // 0x00000288
    while (1) {
        if (current_task == 0) {
            foo();
        } else {
            myStartFunction();
        }
    }
}
