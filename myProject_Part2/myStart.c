#include "FreeRTOS.h"
#include "task.h"
extern uint32_t _sdata;    // Start of .data in RAM
extern uint32_t _sidata;   // start of .data in Flash
extern uint32_t _edata;    // End of .data in RAM
extern uint32_t _sbss;     // start of .bss
extern uint32_t _ebss;     // end of .bss



static void vTask1( void *pvParameters){
		volatile int a=10;
		while(1){
			a++;
		};
}
static void vTask2( void *pvParameters){
		volatile int b=10;
		while(1){
			b++;
		};
}

void myStartFunction(){
		BaseType_t xReturn;
		
		// Initialize .data section from Flash to RAM
		uint32_t *src=&_sidata;  // Source Flash
		uint32_t *dst=&_sdata;   // Destination RAM
		while(dst< &_edata) {
			*dst++ = *src++;   // Copy Word and Increment Pointers
		}	
		
		// Initialize .bss section (zero out)
		dst= &_sbss;
		while( dst < &_ebss){
			*dst++ = 0;      // Zero Word and Increment Pointers
		}
		
		xReturn=xTaskCreate(vTask1, "T1", configMINIMAL_STACK_SIZE, NULL, 1, NULL);
		xReturn=xTaskCreate(vTask2, "T2", configMINIMAL_STACK_SIZE, NULL, 1, NULL);
//		vTaskStartScheduler();
        vPortEndScheduler();
		return;
}
