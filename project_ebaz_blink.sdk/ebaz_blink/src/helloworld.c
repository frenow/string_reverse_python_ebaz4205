#include "xparameters.h"
#include "xuartps.h"
#include "xil_printf.h"

int main() {
    XUartPs uart;
    XUartPs_Config *config = XUartPs_LookupConfig(XPAR_PS7_UART_1_DEVICE_ID);
    XUartPs_CfgInitialize(&uart, config, config->BaseAddress);

    u8 send_buffer[6] = "BRASIL";
    u8 recv_buffer[6];

    xil_printf("Enviando: %s\r\n", send_buffer);
    XUartPs_Send(&uart, send_buffer, 6);

    // Espera receber 6 bytes de volta
    int received = 0;
    while(received < 6) {
        received += XUartPs_Recv(&uart, &recv_buffer[received], 6 - received);
    }

    xil_printf("Recebido Invertido: ");
    for(int i=0; i<6; i++) outbyte(recv_buffer[i]);

    return 0;
}
