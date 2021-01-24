#include "nrf51_uart.h"

int main() {
	nrf51_uart_init();
	while (1) {
		nrf51_uart_send_message("Hello World");
	}
	return 0;
}
