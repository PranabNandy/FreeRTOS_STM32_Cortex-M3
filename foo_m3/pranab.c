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
