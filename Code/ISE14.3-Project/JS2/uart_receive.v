`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:    13:07:00 10/28/08
// Design Name:    
// Module Name:    uart_receive
// Project Name:   
// Target Device:  
// Tool versions:  
// Description:
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////
module uart_receive(clk_sample, rst, rxd, dout, rdn, data_ready);

input 	clk_sample;
input 	rst;
input 	rxd;
input		rdn;

output 	[7:0] dout;
output	data_ready;

reg		rxd1;
reg		rxd2;

reg		[3:0]	rcvbit_cnt;
reg		[7:0] shift_reg;
reg		[7:0]	data_reg;
reg		shift_en;
reg		shift_over;

reg		[4:0]dlycnt;

reg		data_ready;

//reg		start_rcv;
reg		[6:0]	STATE;

parameter	IDLE			= 7'b0000001;
parameter	RECEIVE		= 7'b0000010;
parameter	WAIT			= 7'b0000100;
parameter	READY			= 7'b0001000;
parameter	DELAY1		= 7'b0010000;
parameter	DELAY2		= 7'b0100000;
parameter	FINISH		= 7'b1000000;

assign	dout = (!rdn) ? data_reg : 8'hzz;

//检测输入rxd，检测到起始位，经过判断后开始接收，以rxd2为低为判断位
always @(posedge clk_sample or negedge rst)
begin	
	if(!rst)
		begin
			rxd1 <= 1'b1;
			rxd2 <= 1'b1;
		end
	else
		begin
			rxd1 <= rxd;
			rxd2 <= rxd1;
		end
end

reg	clk_baud_en;

always @(posedge clk_sample or negedge rst)
begin
	if(!rst)
		begin
			clk_baud_en <= 1'b0;
		end
	else
		begin
			if(!rxd1 && rxd2)
				begin
					clk_baud_en <= 1'b1;
				end
			else if(rcvbit_cnt == 4'b1010)
				begin
					clk_baud_en <= 1'b0;
				end
		end
end

reg	[3:0]clkdiv;
wire	clk_baud;

always @(posedge clk_sample or negedge rst)
begin
	if (!rst)
		begin
			clkdiv <= 4'b0000 ;
		end
	else
		begin
			if (clk_baud_en)
				begin
					clkdiv <= clkdiv +1 ;
				end
			else
				begin
					clkdiv <= 4'b0000;
				end
		end
end

assign clk_baud = clkdiv[3] ;

always @(posedge clk_sample or negedge rst)
begin
	if(!rst)
		begin
			data_ready <= 1'b0;
			shift_en <= 1'b0;
			dlycnt <= 0;

			STATE <= IDLE;
		end
	else
		begin
			case(STATE)
			IDLE:
				begin
					data_ready <= 1'b0;
					shift_en <= 1'b0;
					dlycnt <= 0;
										
					STATE <= RECEIVE;
				end
			WAIT:
				begin
					if(!rxd1 && rxd2)
						begin
							shift_en <= 1'b1;
							STATE <= RECEIVE;
						end
					else
						begin
							STATE <= WAIT;
						end
				end
			RECEIVE:
				begin
					if(rcvbit_cnt == 4'b1010)
						begin
							data_ready <= 1'b1;
							shift_en <= 1'b0;

							STATE <= DELAY2;
						end
					else
						begin
							STATE <= RECEIVE;
						end
				end
			DELAY1:
				begin
					data_ready <= 1'b0;
					STATE <= FINISH;							
				end
			DELAY2:
				begin
					if(&dlycnt)
						begin
							data_ready <= 1'b0;
							STATE <= FINISH;
						end
					else
						begin
							dlycnt <= dlycnt + 1;
							STATE <= DELAY2;
						end
				end
			FINISH:
				begin
					STATE <= IDLE;
				end
			default:
				begin
					STATE <= IDLE;
				end
			endcase
		end
end

always @(posedge clk_baud or negedge rst)
begin
	if(!rst)
		begin
			data_reg <= 0;
			shift_reg <= 0;
			shift_over <= 1'b0;
		end
	else
		begin
			/*if(rcvbit_cnt == 4'b0000)
				begin
					data_reg <= 0;
					shift_over <= 1'b0;
					shift_reg <= 0;
				end
			else */if(rcvbit_cnt >= 4'b0001 && rcvbit_cnt <= 4'b1000)
				begin
					//LSB First
					shift_reg[7] <= rxd2;
					shift_reg[6:0] <= shift_reg[7:1];
					//MSB First
					//shift_reg[0] <= rxd2;
					//shift_reg[7:1] <= shift_reg[6:0];
					shift_over <= 1'b0;
				end
			else if(rcvbit_cnt == 4'b1001)
				begin
					data_reg <= shift_reg;
				end
			else if(rcvbit_cnt == 4'b1010)
				begin
					shift_reg <= 0;
					shift_over <= 1'b1;
				end
		end
end

always @(posedge clk_baud or negedge rst or negedge clk_baud_en)
begin
	if (!rst)
		begin
			rcvbit_cnt <= 4'b0000;
		end
	else
		begin
			if (!clk_baud_en)
				begin
					rcvbit_cnt <= 4'b0000 ;
				end
			else
				begin
					rcvbit_cnt <= rcvbit_cnt + 1;
				end
		end
end
endmodule
