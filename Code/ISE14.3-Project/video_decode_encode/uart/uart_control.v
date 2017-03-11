`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Create Date:    11:22:35 12/26/2016 
// Design Name: 
// Module Name:    uart_control 
//////////////////////////////////////////////////////////////////////////////////
module uart_control(
							clk1_8m, rst,
							rxd, txd, 
							video_switch, video_zoom, cross_output
							
							
							);

	input clk1_8m; 
	input rst;
	input rxd;
	
	output txd;
	output video_switch, video_zoom, cross_output;
////////////////////////////////////////////////////////////////////////////////
///产生波特率115200
	wire clk_baud;
	reg [3:0] cnt;
	always @(posedge clk1_8m or negedge rst)
		begin
		  if(!rst)
			 cnt <= 0;
		  else
			 cnt <= cnt + 1;
		end
	assign clk_baud = cnt[3];
/////////////////////////////////////////////////////////////////////////////////
///串口内核
	wire	data_ready;
	wire	send_over;
	reg	wrn;
	reg	rdn;
	reg	[7:0] din;
	wire	[7:0] dout;
	uart	uart_1(
					.clk(clk1_8m), 
					.clk_baud(clk_baud),
					.rst(rst), 
					.rxd(rxd), 
					.din(din), 
					.wrn(wrn), 
					.txd(txd), 
					.rdn(rdn), 
					.dout(dout), 
					.data_ready(data_ready),
					.send_over(send_over)
					);



	reg	[6:0]STATE;
	reg	[6:0]nextSTATE;
	parameter IDLE 					= 7'b0000001;
	parameter READY 					= 7'b0000010;
	parameter CHECK_1					= 7'b0000100;
	parameter CHECK_2					= 7'b0001000;
	parameter ANALYSE					= 7'b0010000;		
	parameter CHECK_DATA				= 7'b0100000;
	parameter WAIT						= 7'b1000000;


	always @(posedge clk_baud or negedge rst)
	begin
		if(!rst)
			begin	  
				rdn <= 1;
				//清零
				cnt_dly<=0;
				flag_data_recieve_normal <= 1'b0;

				check_head_reg <= 8'h00;			

				video_zoom_normal_temp <= 1'b0;	
				cross_output_temp <= 1'b0;	
			  
				STATE <= IDLE;
				nextSTATE <= IDLE;
			end
		else
			begin
				case(STATE)			
				IDLE:
					begin	  
						rdn <= 1;

						video_zoom_temp <= 1'b0;	
						cross_output_temp <= 1'b0;								
						data_received_temp <= 8'h00;

						cnt_dly<=0;
						flag_data_recieve_normal <= 1'b0;
						check_head_reg_1 <= 8'h00;
						check_head_reg_2 <= 8'h00;
						
						STATE <= READY;
						nextSTATE <= CHECK_1;
					end
				READY:	
					begin
						cnt_dly<=0;
						flag_data_recieve_normal <= 1'b0;					

						if(data_ready)	
							begin
								rdn <= 1'b0;												
								STATE <= nextSTATE;						
							end
						else
							begin
								rdn <= 1'b1;
								STATE <= READY;		
							end					 
					end  
				CHECK_1:
					begin
						cnt_dly<=0;
						flag_data_recieve_normal <= 1'b0;
						check_head_reg_1 <= dout;//保存帧头，用于反馈指令时判断帧类别

						if(dout == 'hF5)
							begin
								rdn <= 1'b1;
								STATE <= READY;
								nextSTATE <= CKECK_2;
							end
						else
							begin							 							
								rdn <= 1'b1;
								STATE <= READY;
								nextSTATE <= CHECK_1;
							end								
					end
				CHECK_2:
					begin
						cnt_dly <= 0;
						flag_data_recieve_normal <= 1'b0;
						check_head_reg_2 <= dout;//保存帧头，用于反馈指令时判断帧类别
						
						if(dout == 'h55)
							begin
								rdn <= 1'b1;
								STATE <= READY;
								nextSTATE <= ANALYSE;
							end
						else
							begin
								rdn <= 1'b1;
								STATE <= READY;
								nextSTATE <= CHECK_1;
							end
					end
				ANALYSE:
					begin
						data_received_temp <= dout;

						cnt_dly<=0;
						flag_data_recieve_normal <= 1'b0;

						//自己设置指令：
						video_zoom_temp <= dout[1];
						cross_output_temp <= dout[0];

						rdn <= 1'b1;
						STATE <= READY;
						nextSTATE <= CHECK_DATA;
					end
				CHECK_DATA:
					begin		 
						cnt_dly<=0;
						flag_data_recieve_normal <= 1'b0;  
						rdn <= 1'b1;

						if(dout == (data_received_temp ^ 8'hF5 ^ 8'h55))
							begin		
								video_zoom <= video_zoom_temp;
								cross_output <= cross_output_temp;
								
								flag_data_recieve_normal <= 1'b1;
								STATE <= WAIT;	
								nextSTATE <= WAIT;
							end
						else
							begin
								STATE <= READY;
								nextSTATE <= CHECK_1;
							end				
					end	
				WAIT:
					begin
						cnt_dly <= cnt_dly + 1;
						if(&cnt_dly)
							begin
								STATE <= READY;
								nextSTATE <= CHECK_1;

								cnt_dly <= 0;
								flag_data_recieve_normal <= 1'b0;						
							end
						else
							begin
								flag_data_recieve_normal <= 1'b1;

								STATE <= WAIT;
								nextSTATE <= WAIT;	
							end		
					end
				
				default:	STATE <= IDLE;
				endcase
			end
	end

	reg [7:0] STATE_SEND;

	parameter IDLE_SEND 					= 8'b00000001;
	parameter READY_SEND 				= 8'b00000010;
	parameter DATA_PRE_SEND 			= 8'b00000100;
	parameter DATA_SEND					= 8'b00001000;
	parameter DATA_SEND_ACK				= 8'b00010000;
	parameter DATA_CNT_SEND				= 8'b00100000;
	parameter WAIT_SEND					= 8'b01000000;
	parameter FINISH_SEND 				= 8'b10000000;

	reg	[7:0]dlycnt;
	reg	[2:0]data_send_cnt;
	reg	[7:0]data_check_self;

	always @(posedge clk_baud or negedge rst)
	begin
		if(!rst)
			begin
				din <= 8'hxx;	   
				wrn <= 1;

				dlycnt <= 0;
				data_send_cnt <= 0;
				data_check_self <= 8'hdd;
				
				STATE_SEND <= IDLE_SEND;	
			end
		else
			begin
				case(STATE_SEND)
				IDLE_SEND:
					begin
						din <= 8'hxx;	   
						wrn <= 1;

						dlycnt <= 0;
						data_send_cnt <= 0;
						data_check_self <= 8'hdd;

						if(flag_data_recieve)
							begin
								STATE_SEND <= READY_SEND;
							end
						else
							begin
								STATE_SEND <= IDLE_SEND;
							end
					end
				READY_SEND:
					begin
						data_send_cnt <= 0;
						data_check_self <= 8'hdd;
						STATE_SEND <= DATA_PRE_SEND;
					end
				DATA_PRE_SEND:
					begin
						if(check_head_reg==8'hf3)
							begin
								case(data_send_cnt)
								'd0:
									begin
										din <= 8'h3f;
										data_check_self <= data_check_self ^ 8'h3f;

									end
								'd1:
									begin	
										if(config_done == 1&&bug_type_in==4'b0000)
											begin
												din <= 8'h55;
												data_check_self <= data_check_self ^ 8'h55;
											end
										else
											begin
												din <= 8'haa;
												data_check_self <= data_check_self ^ 8'haa;
											end		
									end
								'd2:
									begin
										din[1:0] <= data_received[1:0];
										din[2] <= ~self_check_done;
										din[7:3] <= data_received[7:3];
									end
								'd3:
									begin
										din <= data_received_pip;	//
										data_check_self <= data_check_self ^ din;
									end
								'd4:
									begin
										din <= data_check_self ^ data_received_pip;
									end
									
								default:din <= 8'hxx;

								endcase
							end
						else
							din <= 8'h00;
									
						STATE_SEND <= DATA_SEND;
					end
				DATA_SEND:
					begin
						wrn <= 0;
						STATE_SEND <= DATA_SEND_ACK; 	
					end
				DATA_SEND_ACK:
					begin
						wrn <= 1;
						
						if(send_over)
							begin
								STATE_SEND <= DATA_CNT_SEND;
							end
						else
							begin
								STATE_SEND <= DATA_SEND_ACK;
							end
					end
				DATA_CNT_SEND:
					begin
						if(check_head_reg==8'hF3)
						begin
							if(data_send_cnt == 4)
	//						if(data_send_cnt == 8)
								begin
									data_send_cnt <= 0;
									STATE_SEND <= WAIT_SEND;
								end
							else
								begin
									data_send_cnt <= data_send_cnt + 1;
									STATE_SEND <= DATA_PRE_SEND;
								end	
						end
						else if(check_head_reg==8'hD7)
						begin
							if(data_send_cnt == 2)
								begin
									data_send_cnt <= 0;
									STATE_SEND <= WAIT_SEND;
								end
							else
								begin
									data_send_cnt <= data_send_cnt + 1;
									STATE_SEND <= DATA_PRE_SEND;
								end	
						end
					end
				WAIT_SEND:
					begin
						if(&dlycnt)
							begin
								dlycnt <= 0;
								STATE_SEND <= FINISH_SEND;
							end
						else
							begin
								dlycnt <= dlycnt + 1;
								STATE_SEND <= WAIT_SEND;	
							end	
					end
				FINISH_SEND:
					begin
						STATE_SEND <= IDLE_SEND;	
					end
				default:
					begin
						STATE_SEND <= IDLE_SEND;
					end
				endcase
			end
	end
endmodule
