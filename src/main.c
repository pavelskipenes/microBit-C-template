#include "microbit_uart.h"

int main()
{
	microbit_uart_init();
	while (1) {
		microbit_uart_send_message("Hello World");
	}
	return 0;
}
