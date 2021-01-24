#pragma once
#include <stdint.h>

/**
 * @brief Initializes the UART peripheral with parameters
 * that will work for the micro:bit hardware. Must be
 * called before @c uart_send and @c uart_receive are used.
 */
void nrf51_uart_init();

/**
 * @brief Send a singe byte over the UART interface.
 *
 * @param byte Byte to be sent over UART.
 */
void nrf51_uart_send(uint8_t byte);

/**
 * @brief sends a message over UART
 * 
 * @param const char* 
 */
void nrf51_uart_send_message(const char *message);

/**
 * @brief Attempts to receive a single byte over UART.
 * If the UART has received data, it will be placed into
 * the location pointed to by @p p_byte, and 1 will be
 * returned. If the UART has not received any data, this
 * function will return 0, and the data in @p p_byte will
 * remain unchanged.
 *
 * @param p_byte Pointer to a location of where to store
 * incoming data.
 *
 * @return 1 if the UART has received data; 0 otherwise.
 */
uint8_t nrf51_uart_receive(uint8_t * p_byte);
