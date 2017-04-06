`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:    18:39:58 10/30/08
// Design Name:    
// Module Name:    uart_if
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
module uart_ifff( clk, rst, 

					rxd, txd,
					//信息
		 			view,
					view_max_min,
					flag_data_recieve,

					video_switch_enable,
					big_to_small_flag,
					
					foc_dir,
					foc_enable,
					foc_step,

					power_self_check,
					alert,
										
					Iris_enable, Iris_dir, Iris_step, 

					touwu,
					pre_view,
					pre_view_enable,

					focus_sta,
					self_check_sta,
					video_swich_sta,
					pre_view_sta_from_control,
					view_swich_sta_from_control,
					foc_sta_from_control,
					touwu_sta_from_control,

//					auto_focus_dir,
//					auto_focus_enable,
					
					led_test					
					);
//串口波特率9600，8位数据，1位停止，无校验
//收到来自主机的指令8'hF3后启动数据发送
input 	clk;
input 	rst;
input		rxd;

output 	txd;
output	[7:0]led_test;
reg	[7:0]led_test;

//信息
output	[2:0]view;
output	[1:0]view_max_min;
reg		[2:0]view;

input 	flag_data_recieve;

//连续变倍指令
input	video_switch_enable;
input	big_to_small_flag;

//手动聚焦
input	foc_dir;
input	foc_enable;
input [3:0] foc_step;
//自动调焦
//input   auto_focus_dir;
//input	  auto_focus_enable;	

//电机自检信息与报警信息
output	power_self_check;
output	alert;

//调光指令
input		Iris_enable;
input		Iris_dir;
input		[4:0]Iris_step;

//新增状态与透雾、视场预置
input touwu;
input [7:0]pre_view;
input pre_view_enable;
//控制板返回的信息
output	[2:0]pre_view_sta_from_control;
output	view_swich_sta_from_control;
output	foc_sta_from_control;
output	touwu_sta_from_control;


input [1:0]focus_sta;
input [1:0]self_check_sta;
input [1:0]video_swich_sta;

reg	flag_data_recieve_dly;
reg	flag_data_recieve_dly1;
always @(posedge clk or negedge rst)
if(!rst)
begin
	flag_data_recieve_dly <= 0;
	flag_data_recieve_dly1 <= 0;
end
else
begin
	flag_data_recieve_dly <= flag_data_recieve;
	flag_data_recieve_dly1 <= flag_data_recieve_dly;
end

////////////////////////////////////////////////////////////////////
//串口内核
//////////////////////////////////////////////////////////////////
wire		clk_baud;
reg[3:0] cnt;

always @(posedge clk or negedge rst)
begin
  if(!rst)
    cnt<=0;
  else
    cnt<=cnt+1;
end

assign clk_baud = cnt[3];

wire		data_ready;
wire		send_over;
reg		wrn;
reg		rdn;
reg		[7:0]din;
wire		[7:0]dout;

uart	uartuuuuu(
				.clk(clk), 
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
////////////////////////////////////////////////////////////////////


///////////////////////////////////////////////////////////////////
//	指令发送
///////////////////////////////////////////////////////////////////
reg	[1:0]view_max_min;
reg	[1:0]foc_max_min;
reg	[1:0]Aperture_max_min;	 
reg	[1:0]view_max_min_tmp;
reg	[1:0]foc_max_min_tmp;
reg	[1:0]Aperture_max_min_tmp;

reg	[1:0]focus_sta_tmp;
reg	[1:0]self_check_sta_tmp;
reg	[1:0]video_swich_sta_tmp;
reg	[7:0]pre_view_tmp;
reg	touwu_tmp;

reg	flag_data_send;
reg	flag_data_ack;

//wire 	auto_foc_sta;
//assign 	 auto_foc_sta=	(auto_focus_dir)?	2'b10:2'b01;


reg	[13:0]STATE_SEND;	
parameter Head				 			= 14'b00000000000001;
parameter Head_SEND					= 14'b00000000000010;
parameter Head_SEND_ACK				= 14'b00000000000100;
parameter IDLE_GO			 			= 14'b00000000001000;
parameter DATA_SEND					= 14'b00000000010000;
parameter DATA_SEND_ACK				= 14'b00000000100000;
parameter Veif				 			= 14'b00000001000000;
parameter Veif_SEND					= 14'b00000010000000;
parameter Veif_SEND_ACK				= 14'b00000100000000;
parameter WAIT_SEND					= 14'b00001000000000;
parameter Send_rec_STOP				= 14'b00010000000000;

parameter IDLE_GO2			 		= 14'b00100000000000;
parameter DATA_SEND2					= 14'b01000000000000;
parameter DATA_SEND_ACK2			= 14'b10000000000000;

reg	[3:0]dlycnt;
reg	data_send_done;
reg	flag_receive;

reg	video_switch_enable_tmp;	
reg	big_to_small_flag_tmp;
reg	foc_dir_tmp;
reg	foc_enable_tmp;
reg 	[3:0] focus_step_tmp;
reg   pre_view_enable_tmp;

//wire 	[1:0]self_check_status;
//wire	[1:0]video_swich_status;
//wire  [1:0]focus_status; 
//
//若有限位，步长置0
wire [3:0]switch_step = 4'b1111;//(((view_max_min==2'b10)&&(big_to_small_flag_tmp==1))||((view_max_min==2'b01)&&(big_to_small_flag_tmp==0)))? 0: 4'b1111;
wire [3:0]focus_step = foc_step;//(((foc_max_min==2'b10)&&(foc_dir_tmp==0))||((foc_max_min==2'b01)&&(foc_dir_tmp==1)))? 0: 4'b0110;
wire [3:0]autoiris_step = Iris_step[3:0];//(((Aperture_max_min==2'b10)&&(Iris_dir==0))||((Aperture_max_min==2'b01)&&(Iris_dir==1)))? 0: Iris_step[3:0];

reg	[7:0] Ctrl_byte;
reg	[7:0] Ctrl_byte2;

always @(posedge clk_baud or posedge flag_data_recieve)
begin
	if(flag_data_recieve)  //flag_data_recieve系统收到上位机指令
		begin
			din <= 8'hxx;	   
			wrn <= 1;

			led_test <= 8'h00;

			dlycnt <= 0;

			data_send_done <= 1'b0;

			video_switch_enable_tmp <= video_switch_enable;					
			big_to_small_flag_tmp <= big_to_small_flag;			  						
			
			foc_dir_tmp <= foc_dir;
			foc_enable_tmp <= foc_enable;	
			focus_step_tmp	<= focus_step;

			focus_sta_tmp<=focus_sta;
			self_check_sta_tmp<=self_check_sta;
			video_swich_sta_tmp<=video_swich_sta;
			pre_view_tmp<=pre_view;
			touwu_tmp<=touwu;

//			if(auto_focus_enable)
//				begin
//					focus_sta_tmp<=auto_foc_sta;	
//				end
//			else
//				begin
//					focus_sta_tmp<=focus_sta;
//				end

			pre_view_enable_tmp<=pre_view_enable;

			Ctrl_byte <= 8'h00;

			STATE_SEND <= Head;		
		end
	else
		begin
			case(STATE_SEND)
			Head:
				begin
					data_send_done <= 1'b0;
					
					wrn <= 1;
					din <= 8'h77;

	
					if(video_switch_enable_tmp||foc_enable_tmp||pre_view_enable_tmp)
						begin
							Ctrl_byte<={0,touwu_tmp,focus_sta_tmp,video_swich_sta_tmp,self_check_sta_tmp};
							Ctrl_byte2<=pre_view;
							STATE_SEND <= Head_SEND;
						end
					else
						begin
							Ctrl_byte <= 8'h00;
							Ctrl_byte2<=8'h00;

							STATE_SEND <= Send_rec_STOP;	
						end
//					Ctrl_byte <= {(~big_to_small_flag_tmp),(~big_to_small_flag_tmp),big_to_small_flag_tmp,big_to_small_flag_tmp,switch_step};					
//
//					if(video_switch_enable_tmp)//变倍,变倍＋：1100，变倍－：0011
//					begin	
//						Ctrl_byte <= {(~big_to_small_flag_tmp),(~big_to_small_flag_tmp),big_to_small_flag_tmp,big_to_small_flag_tmp,switch_step};					
//
//						STATE_SEND <= Head_SEND;
//					end
//					else if(foc_enable_tmp)	  //聚焦,调焦＋：1010，调焦－：0101
//					begin
//						Ctrl_byte <= {foc_dir_tmp,(~foc_dir_tmp),foc_dir_tmp,(~foc_dir_tmp),focus_step_tmp};
//
//						STATE_SEND <= Head_SEND;
//					end
//					else if(Iris_enable)		  //调光,调光＋：1001，调光－：0110
//					begin
//						Ctrl_byte <= {Iris_dir,(~Iris_dir),(~Iris_dir),Iris_dir,autoiris_step};
//
//						STATE_SEND <= Head_SEND;
//					end
//					else
//					begin
//						Ctrl_byte <= 8'h00;
//
//						STATE_SEND <= Send_rec_STOP;
//					end						
				end
			Head_SEND:
				begin
					wrn <= 0;

					STATE_SEND <= Head_SEND_ACK; 	
				end
			Head_SEND_ACK:
				begin
					wrn <= 1;
					din <= 8'hxx;

					if(send_over)
						begin
							STATE_SEND <=  IDLE_GO;					
						end
					else
						begin
							STATE_SEND <= Head_SEND_ACK;
						end
				end
			IDLE_GO:
				begin
					data_send_done <= 1'b0;
					
					wrn <= 1;  
					
					din <= Ctrl_byte;
					
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
					din <= 8'hxx;

					if(send_over)
						begin							
							STATE_SEND <=  IDLE_GO2;						
						end
					else
						begin
							STATE_SEND <= DATA_SEND_ACK;
						end
				end
			IDLE_GO2:
				begin
					data_send_done <= 1'b0;
					
					wrn <= 1;  
					
					din <= Ctrl_byte2;
					
					STATE_SEND <= DATA_SEND2;				
				end
			DATA_SEND2:
				begin
					wrn <= 0;				

					STATE_SEND <= DATA_SEND_ACK2; 	
				end
			DATA_SEND_ACK2:
				begin
					wrn <= 1;
					din <= 8'hxx;

					if(send_over)
						begin							
							STATE_SEND <=  Veif;						
						end
					else
						begin
							STATE_SEND <= DATA_SEND_ACK2;
						end
				end
			Veif:
				begin
					data_send_done <= 1'b0;
					
					wrn <= 1;
					din <= (8'haa^Ctrl_byte^Ctrl_byte2);//8'h77^8'hDD	= 8'haa;

					STATE_SEND <= Veif_SEND;			
				end
			Veif_SEND:
				begin
					wrn <= 0;				

					STATE_SEND <= Veif_SEND_ACK; 	
				end
			Veif_SEND_ACK:
				begin
					wrn <= 1;
					din <= 8'hxx;

					if(send_over)
						begin
							STATE_SEND <=  WAIT_SEND;	
							
							//产生发送完成脉冲,
							data_send_done <= 1'b1;					
						end
					else
						begin
							STATE_SEND <= Veif_SEND_ACK;
						end
				end
			WAIT_SEND:
				begin
					if(&dlycnt)
						begin
							dlycnt <= 0;

							data_send_done <= 1'b0;
							STATE_SEND <= Send_rec_STOP;
						end
					else
						begin
							dlycnt <= dlycnt + 1;
							STATE_SEND <= WAIT_SEND;	
						end	
				end 						
			Send_rec_STOP:
				begin
					video_switch_enable_tmp <= 0;						
					big_to_small_flag_tmp <= 0;		
					foc_dir_tmp <= 0;
					foc_enable_tmp <= 0;
					pre_view_enable_tmp<=0;
					Ctrl_byte <= 8'h00;
					Ctrl_byte2 <= 8'h00;

					focus_sta_tmp<=0;
					video_swich_sta_tmp<=0;
					self_check_sta_tmp<=0;

					STATE_SEND <= Send_rec_STOP;
				end
			default:
				begin
					STATE_SEND <= Send_rec_STOP;
				end
			endcase
		end
end

/////////////////////////////////////////////////////////////////////
//指令接收
//
////////////////////////////////////////////////////////////////////
reg	power_self_check;
reg	[1:0] alert;
reg	[2:0]pre_view_sta_from_control;
reg	view_swich_sta_from_control;
reg	foc_sta_from_control;
reg	touwu_sta_from_control;

reg	[10:0] focus_location_tmp;
reg	power_self_check_tmp;
reg	[1:0] alert_tmp;
reg	[2:0]pre_view_sta_from_control_tmp;
reg	view_swich_sta_from_control_tmp;
reg	foc_sta_from_control_tmp;
reg	touwu_sta_from_control_tmp;

reg	[8:0]STATE;	 
reg	[8:0]nextSTATE;
parameter IDLE 				= 9'b000000001;
parameter READY 				= 9'b000000010;
parameter Check_head 		= 9'b000000100;
parameter Check_data1 		= 9'b000001000;
parameter Check_data2 		= 9'b000010000;
parameter Check_data3 		= 9'b000100000;
parameter Check_data4 		= 9'b001000000;
parameter Check_data5 		= 9'b010000000;
parameter RECEIVE 			= 9'b100000000;

always @(posedge clk_baud or negedge rst)
begin
	if(!rst)
  		begin	  
			rdn <= 1;

			flag_receive <= 1'b0;		

			view <= 3'bxxx;

			view_max_min<= 2'bxx;
			foc_max_min<= 2'b00;
			Aperture_max_min<= 2'b00;		   
			power_self_check <= 1'b1;
			alert <= 2'b00;
			pre_view_sta_from_control<=3'bxxx;
			view_swich_sta_from_control<=0;
			foc_sta_from_control<=0;
			touwu_sta_from_control<=1'bx;


			view_max_min_tmp<= 2'bxx;
			foc_max_min_tmp<= 2'b00;
			Aperture_max_min_tmp<= 2'b00;		   
			focus_location_tmp <= 11'h0;
			power_self_check_tmp <= 1'b1;
			alert_tmp <= 2'b00;
			pre_view_sta_from_control_tmp<=3'bxxx;
			view_swich_sta_from_control_tmp<=0;
			foc_sta_from_control_tmp<=0;
			touwu_sta_from_control_tmp<=1'bx;


		   STATE <= IDLE;
		end
	else
		begin
			case(STATE)			
			IDLE:
				begin	  
					rdn <= 1;

					if(data_send_done)  //等待指令发送完成
					begin	  
						flag_receive <= 1'b0;

						STATE <= READY;
						nextSTATE <= Check_head;
					end
					else
						STATE <= IDLE;	
				end
			READY:	
				begin
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
			Check_head:
				begin
					if(dout == 8'h55)
					begin
						STATE <= READY;
						nextSTATE <= Check_data1;
					end
					else
					begin
						STATE <= READY;
						nextSTATE <= Check_head;
					end						
				end
			Check_data1:
				begin
					if(dout[7:6]==2'b11)
					begin
						//信息
						view_max_min_tmp<= dout[5:4];
						foc_max_min_tmp<= dout[3:2];	 //
						Aperture_max_min_tmp<= dout[1:0];
					
						STATE <= READY;
						nextSTATE <= Check_data2;		
					end
					else
					begin
						STATE <= RECEIVE;
					end				
				end
			Check_data2:
				begin
//					if(dout[7]==1'b1)
//					begin
//						//信息
//						focus_location_tmp[10:4] <= dout[6:0];
//						
//						STATE <= READY;
//						nextSTATE <= Check_data3;
//					end
//					else
//					begin
//						STATE <= RECEIVE;
//					end	
					if(dout>=14 && dout<=18)
						pre_view_sta_from_control_tmp<=3'b000;
					else if(dout>=19 && dout<=27)
						pre_view_sta_from_control_tmp<=3'b001;
					else if(dout>=28 && dout<=46)
						pre_view_sta_from_control_tmp<=3'b010;
					else if(dout>=47 && dout<=106)
						pre_view_sta_from_control_tmp<=3'b011;
					else if(dout>=107 && dout<=230)
						pre_view_sta_from_control_tmp<=3'b100;
					else
						pre_view_sta_from_control_tmp<=3'bxxx;
					
					STATE<=READY;
					nextSTATE <= Check_data3;
				end
			Check_data3:
				begin
//					if(dout[7]==1'b1)
//					begin
//						//信息
//						focus_location_tmp[3:0] <= dout[6:3];
//						power_self_check_tmp <= dout[2];
//						alert_tmp <= dout[1:0];
//						
//						STATE <= RECEIVE;
//						nextSTATE <= RECEIVE;
//					end
//					else
//					begin
//						STATE <= RECEIVE;
//					end	
					view_swich_sta_from_control_tmp<=dout[1:0];
					foc_sta_from_control_tmp<=dout[3:2];
					touwu_sta_from_control_tmp<=dout[4];

					STATE<=READY;
					nextSTATE <= Check_data4;						
				end
			Check_data4:
				begin	
//					view_swich_sta_from_control_tmp<=dout[1:0];
//					foc_sta_from_control_tmp<=dout[3:2];
//					touwu_sta_from_control_tmp<=dout[4];
				
					STATE <= RECEIVE;
//					nextSTATE <= Check_data5;
				end
//			Check_data5:
//				begin
//					
//
//					STATE<=RECEIVE;
//				end
			RECEIVE:
				begin
					flag_receive <= 1'b1;

//					view <= focus_location_tmp[6:4]-1'b1;
					view <= pre_view_sta_from_control_tmp;

					view_max_min<= view_max_min_tmp;
					foc_max_min<= foc_max_min_tmp;
					Aperture_max_min<= Aperture_max_min_tmp;		   
					power_self_check <= power_self_check_tmp;
					alert <= alert_tmp;

					pre_view_sta_from_control<=pre_view_sta_from_control_tmp;
					view_swich_sta_from_control<=view_swich_sta_from_control_tmp;
					foc_sta_from_control<=foc_sta_from_control_tmp;
					touwu_sta_from_control<=touwu_sta_from_control_tmp;

					STATE <= IDLE;
				end		
			default:	STATE <= IDLE;
			endcase
		end	  
end

endmodule

