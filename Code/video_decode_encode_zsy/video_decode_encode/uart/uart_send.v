`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Create Date:    10:56:21 11/19/2016 
// Design Name: 
// Module Name:    uart_send 
//////////////////////////////////////////////////////////////////////////////////
module uart_send(clk_sample, clk_baud, rst, txd, din, wrn, send_over);

input 	clk_sample;		//采样时钟波特率的16倍
input		clk_baud;   	//波特率
input 	rst;        	//复位
input		[7:0]din;		//输入数据
input		wrn;				//写数据使能，1无效，0有效

output 	txd;				//串口发送
output	send_over;		

reg	txd;
reg	send_over;

reg	[3:0]sendbit_cnt;	//数据发送位数计数器
reg	shift_en;			//移位寄存器使能
reg	shift_over;			//数据发送完成标志位
reg	[7:0]shift_reg;	//移位寄存器
reg	[7:0]data_reg;		//输入数据存储

reg	[4:0]dlycnt;		//全为1时延时结束

reg	wrn1;					//用来检测写数据使能由1变为0
reg	wrn2;

reg	[4:0]STATE;			//串口发送的当前状态

parameter	IDLE				=	5'b00001;//空闲
parameter	WAIT				=	5'b00010;//等待
parameter	SEND				=	5'b00100;//发送
parameter	DELAY				=	5'b01000;//发送完成后延时一段时间。
parameter	FINISH			=	5'b10000;//完成

always @(posedge clk_sample or negedge rst)
begin
	if(!rst)
		begin
			wrn1 <= 1'b1;
			wrn2 <= 1'b1;
		end
	else
		begin
			wrn1 <= wrn;
			wrn2 <= wrn1;
		end
end

always @(posedge clk_sample or negedge rst)
begin
	if(!rst)
		begin
			shift_en <= 1'b0;
			send_over <= 1'b0;
			data_reg <= 0;
			dlycnt <= 0;

			STATE <= IDLE;
		end
	else
		begin
			case(STATE)
			IDLE:
				begin
					shift_en <= 1'b0;
					send_over <= 1'b0;
					data_reg <= 0;
					dlycnt <= 0;

					STATE <= WAIT;
				end
			WAIT:
				begin
					if(!wrn1 && wrn2)
						begin
							data_reg <= din;
							shift_en <= 1'b1;
							STATE <= SEND;
						end
					else
						begin
							STATE <= WAIT;
						end
				end
			SEND:
				begin
					if(shift_over)
						begin
							send_over <= 1'b1;
							shift_en <= 1'b0;
							STATE <= DELAY;
						end
					else
						begin
							STATE <= SEND;
						end
				end
			DELAY:
				begin
					if(&dlycnt)
						begin
							STATE <= FINISH;
						end
					else
						begin
							dlycnt <= dlycnt + 1;
							STATE <= DELAY;
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
			txd <= 1'b1;
			shift_reg <= 0;
			sendbit_cnt <= 4'b0000;
		end
	else
		begin
			if(shift_en)
				begin
					if(sendbit_cnt == 4'b0000)
						begin
							shift_reg <= data_reg;
							sendbit_cnt <= sendbit_cnt + 1;
							txd <= 1'b1;
						end 
					else if(sendbit_cnt == 4'b0001)
						begin
							txd <= 1'b0;
							sendbit_cnt <= sendbit_cnt + 1;
						end
					else if(sendbit_cnt >= 4'b0010 && sendbit_cnt <= 4'b1001)
						begin
							//MSB First
							//shift_reg[7:1] <= shift_reg[6:0] ;
							//shift_reg[0] <= 1'b0;
							//txd <= shift_reg[7] ;
							

							//LSB First	
							shift_reg[6:0] <= shift_reg[7:1] ;
							shift_reg[7] <= 1'b0 ;
							txd <= shift_reg[0] ;
							sendbit_cnt <= sendbit_cnt + 1;
						end
					else if(sendbit_cnt == 4'b1010)
						begin
							txd <= 1'b1;
							shift_over <= 1'b1;
							sendbit_cnt <= sendbit_cnt + 1;
						end
					else
						begin
						 	sendbit_cnt <= sendbit_cnt + 1;
						end
				end
			else
				begin
					txd <= 1'b1;
					sendbit_cnt <= 4'b0000;
					shift_over <= 1'b0;
					shift_reg <= 0;
				end
		end
end
endmodule
