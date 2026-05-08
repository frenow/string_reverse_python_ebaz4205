`timescale 1ns / 1ps


module top_blink(
    input  wire clk,        // 50MHz do Zynq
    input  wire rst_n,      // FCLK_RESET0_N do Zynq
    input  wire uart_rx,    
    output wire uart_tx,    
    output wire led_green,   
    output wire led_red    	
);

parameter                        CLK_FRE  = 50;
parameter                        UART_FRE = 115200;
parameter                        BUFFER_SIZE = 256;

localparam                       IDLE      = 0;
localparam                       RECEIVE   = 1;
localparam                       SEND      = 2;

reg[7:0]                         tx_data;
reg                              tx_data_valid;
wire                             tx_data_ready;
reg[7:0]                         tx_cnt;
wire[7:0]                        rx_data;
wire                             rx_data_valid;
wire                             rx_data_ready;
reg[2:0]                        state;
reg[7:0]                         rx_buf [0:BUFFER_SIZE-1];
reg[7:0]                         rx_cnt;
reg                              send_active;

assign rx_data_ready = 1'b1;
assign led_green = (state == RECEIVE) ? 1'b1 : 1'b0;
assign led_red   = (state == SEND) ? 1'b1 : 1'b0;

always@(posedge clk or negedge rst_n)
begin
	if(rst_n == 1'b0)
	begin
		rx_cnt <= 8'd0;
		tx_cnt <= 8'd0;
		tx_data_valid <= 1'b0;
		send_active <= 1'b0;
		state <= IDLE;
	end
	else
	case(state)
IDLE:
			begin
				rx_cnt <= 8'd0;
				tx_cnt <= 8'd0;
				tx_data_valid <= 1'b0;
				send_active <= 1'b0;
				state <= RECEIVE;
			end
RECEIVE:
		begin
			if(rx_data_valid)
			begin
				if(rx_data == 8'h0A && rx_cnt > 0)
				begin
					state <= SEND;
				end
				else if(rx_cnt < BUFFER_SIZE)
				begin
					rx_buf[rx_cnt] <= rx_data;
					rx_cnt <= rx_cnt + 8'd1;
				end
			end
		end
SEND:
		begin
			tx_data <= rx_buf[rx_cnt - 1 - tx_cnt];
			tx_data_valid <= 1'b1;

			if(tx_data_valid && tx_data_ready)
			begin
				tx_data_valid <= 1'b0;
				if(tx_cnt < rx_cnt - 1)
				begin
					tx_cnt <= tx_cnt + 8'd1;
				end
				else
				begin
					state <= IDLE;
				end
			end
		end
		default:
			state <= IDLE;
	endcase
end

uart_rx#(
	.CLK_FRE(CLK_FRE),
	.BAUD_RATE(UART_FRE)
) uart_rx_inst
(
	.clk                        (clk                      ),
	.rst_n                      (rst_n                    ),
	.rx_data                    (rx_data                  ),
	.rx_data_valid              (rx_data_valid            ),
	.rx_data_ready              (rx_data_ready            ),
	.rx_pin                     (uart_rx                  )
);

uart_tx#(
	.CLK_FRE(CLK_FRE),
	.BAUD_RATE(UART_FRE)
) uart_tx_inst
(
	.clk                        (clk                      ),
	.rst_n                      (rst_n                    ),
	.tx_data                    (tx_data                  ),
	.tx_data_valid              (tx_data_valid            ),
	.tx_data_ready              (tx_data_ready            ),
	.tx_pin                     (uart_tx                  )
);
endmodule