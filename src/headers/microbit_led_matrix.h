#pragma once

/**
 * @brief Initialize the LED matrix on the micro:bit.
 * Must be called before @c led_matrix_turn_on and
 * @c led_matrix_turn_off are used.
 */
void microbit_led_matrix_init();

/**
 * @brief Turn the micro:bit LED matrix on.
 */
void microbit_led_matrix_turn_on();

/**
 * @brief Turn the micro:bit LED matrix off.
 */
void microbit_led_matrix_turn_off();
