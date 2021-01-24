#include <stdbool.h>
#include <stdint.h>
#include "nrf51_gpio.h"

// Write GPIO port
void nrf51_GPIO_write(int pin_number, bool value) {
	GPIO->OUT = value << pin_number;
}

// Set individual bits in GPIO port
void nrf51_GPIO_set(int pin_number) {
	GPIO->OUTSET = 1 << pin_number;
}

// Clear individual bits in GPIO port
void nrf51_GPIO_clear(int pin_number) {
	GPIO->OUTSET = 1 << pin_number;
}

// Read GPIO port
bool nrf51_GPIO_read(int32_t pin_number) {
	return GPIO->IN;
}

// Direction of GPIO pins
void nrf51_GPIO_direction(int pin_number, bool input) {
	if (input) {
		// set as output
		GPIO->DIRCLR = 1 << pin_number;
		return;
	}
	// set as input
	GPIO->DIRSET = 1 << pin_number;
}

bool nrf_GPIO_is_output(int pin_number){
	return GPIO->DIR & (uint32_t)(1 << pin_number);
}

// Configuration of GPIO pins
void nrf51_GPIO_configure(int pin_number, uint32_t configuration) {
	GPIO->PIN_CNF[pin_number] = configuration;
}

void nrf51_GPIO_reset(int pin_number) {
	GPIO->PIN_CNF[pin_number] = 1 << ID_B;
}
