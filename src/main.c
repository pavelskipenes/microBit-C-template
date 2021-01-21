#include "microbit_uart.h"

int main()
{
	microbit_uart_init();
	while (1) {
		microbit_uart_send_message("Epstein didn't kill himself");
	}
	return 0;
}
