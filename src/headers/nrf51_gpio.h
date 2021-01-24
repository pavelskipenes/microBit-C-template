#pragma once
#include <stdint.h>
#include <stdbool.h>

#define GPIO ((NRF51_GPIO_REG*)0x50000000)

typedef struct {
	volatile uint32_t RESERVED0[321];
	volatile uint32_t OUT;
	volatile uint32_t OUTSET;
	volatile uint32_t OUTCLR;
	volatile uint32_t IN;
	volatile uint32_t DIR;
	volatile uint32_t DIRSET;
	volatile uint32_t DIRCLR;
	volatile uint32_t RESERVED1[120];
	volatile uint32_t PIN_CNF[32];
} NRF51_GPIO_REG;

#define ID_A 0
#define ID_B 1
#define ID_C 2
#define ID_D 8
#define ID_E 16

// Pin direction
enum NRF51_GPIO_DIR {
	DIR_OUTPUT = 0 << ID_A,	// Configure pin as an input pin
	DIR_INPUT = 1 << ID_A	// Configure pin as an output pin
};

// Connect or disconnect input buffer
enum NRF51_GPIO_INPUT {
	INPUT_CONNECTED = 0 << ID_B,	// Connect input buffer
	INPUT_DISCONNECTED = 1 << ID_B	// Disconnect input buffer
};

// Pull configuration
enum NRF51_GPIO_PULL {
	PULL_NOPULL = 0 << ID_C,	// No pull
	PULL_PULLDOWN = 1 << ID_C,	// Pull down on pin
	PULL_PULLUP = 3 << ID_C	// Pull up on pin
};

// Drive configuration
enum NRF51_GPIO_DRIVE {
	DRIVE_S0S1 = 0 << ID_D,	// Standard '0', standard '1'
	DRIVE_H0S1 = 1 << ID_D,	// High drive '0', standard '1'
	DRIVE_S0H1 = 2 << ID_D,	// Standard '0', high drive '1'
	DRIVE_H0H1 = 3 << ID_D,	// High drive '0', high 'drive '1'
	DRIVE_D0S1 = 4 << ID_D,	// Disconnect '0' standard '1'
	DRIVE_D0H1 = 5 << ID_D,	// Disconnect '0', high drive '1'
	DRIVE_S0D1 = 6 << ID_D,	// Standard '0'. disconnect '1'
	DRIVE_H0D1 = 7 << ID_D	// High drive '0', disconnect '1'
};

// Pin sensing mechanism
enum NRF51_GPIO_SENSE {
	SENSE_DISABLED = 0 << ID_E,	// Disabled,
	SENSE_HIGH = 2 << ID_E,	// Sense for high level,
	SENSE_LOW = 3 << ID_E	// Sense for low level
};

// Write GPIO port
void nrf51_GPIO_write(int pin_number, bool value);

// Set individual bits in GPIO port
void nrf51_GPIO_set(int pin_number);

// Clear individual bits in GPIO port
void nrf51_GPIO_clear(int pin_number);

// Read GPIO port
bool nrf51_GPIO_read(int32_t pin_number);

// Direction of GPIO pins
void nrf51_GPIO_direction(int pin_number, bool input);

// Checks if pin is output
bool nrf51_GPIO_is_output(int pin_number);

// Configuration of GPIO pins
void nrf51_GPIO_configure(int pin_number, uint32_t configuration);

// Reset configuration of GPIO pin
void nrf51_GPIO_reset(int pin_number);
