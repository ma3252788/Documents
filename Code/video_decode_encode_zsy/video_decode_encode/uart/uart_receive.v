`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Create Date:    12:22:49 11/19/2016 
// Design Name: 
// Module Name:    uart_receive 
//////////////////////////////////////////////////////////////////////////////////
module uart_receive(clk_sample, rst, rxd, dout, rdn, data_ready);

input 	clk_sample;		//采样时钟是波特率的16倍
input 	rst;				//复位0有效
input 	rxd;				//串口输入
input		rdn;				//读使能信号

output 	[7:0] dout;		//读入数据的输出
output	data_ready;		

reg		rxd1;				//读使能信号，由1变为0使数据读入
reg		rxd2;

reg		[3:0]	rcvbit_cnt;//读入数据位数计数器	
reg		[7:0] shift_reg; //移位寄存器
reg		[7:0]	data_reg;  //读入数据存储寄存器
reg		shift_en;		  //移位使能标志位
reg		shift_over;		  //移位完成标志位

reg		[4:0]dlycnt;	  //延时

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

assign	dout = (!rdn) ? data_reg : 8'hzz;//把读入数据输出

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

always @(posedge clk_sample or negedge rst)//根据波特率使能标志位进行波特率时钟控制
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

reg	[3:0]clkdiv;//16分频
wire	clk_baud;

always @(posedge clk_sample or negedge rst)//利用采样时钟获得波特率
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
										
					STATE <= WAIT;//原来为RECEIVE
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
			if(rcvbit_cnt >= 4'b0001 && rcvbit_cnt <= 4'b1000)
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
endmodule