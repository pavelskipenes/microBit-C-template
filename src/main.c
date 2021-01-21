#include "microbit_button.h"
#include "microbit_uart.h"

int main()
{
	microbit_button_init();
	microbit_uart_init();

	while (1) {
		if (microbit_button_a_pressed()) {
			microbit_uart_send_message("Button A has been pressed!");
			while (microbit_button_a_pressed()) ;
		}
		if (microbit_button_b_pressed()) {
			microbit_uart_send_message("Button B has been pressed!");
			while (microbit_button_b_pressed()) ;
		}

	}

	return 0;
}
