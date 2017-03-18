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
module uart_if(clk, rst, rxd, txd, config_done,
					
					view,
					view_max_min,
					video_switch_enable,
					big_to_small_flag,
					
					foc_dir,
					foc_enable,
					auto_focus_start,

					video_zoom, 	
					video_zoom_out,				
					cross_output,					
					image_enhancement,
					
					flag_data_recieve,

					power_self_check,
					alert,

					touwu,
					pre_view,
					pre_view_enable,

					focus_sta,
					self_check_sta,
					video_swich_sta,

					led_test
					);

input 	clk;
input 	rst;	
input		config_done;

input		rxd;
output 	txd;

//来自电源板的限位信息
input	[1:0]view_max_min;	  
//input	[1:0]foc_max_min;
//来自电源板的快速变倍位置
input	[2:0] view;

//连续变倍指令,至电源板
output	video_switch_enable;
output	big_to_small_flag;
reg	video_switch_enable;
reg	big_to_small_flag;

//手动聚焦,至电源板
output	foc_dir;
output	foc_enable;
output	auto_focus_start;
reg	foc_dir;
reg	foc_enable;
reg 	auto_focus_start;

//透雾与视场预置
output touwu;
output [7:0]pre_view;
output pre_view_enable;
//自检、调焦、变倍状态
output [1:0]focus_sta;
output [1:0]self_check_sta;
output [1:0]video_swich_sta;

reg	touwu;
reg 	[7:0]pre_view;

//电子变倍
input	video_zoom;
output video_zoom_out;
//电十字
output	cross_output;
reg		cross_output;
//图像增强
output	image_enhancement;
reg		image_enhancement;

//电机自检信息与报警信息
input	power_self_check;
input	[1:0]alert;

output	[7:0]led_test;
reg		[7:0]led_test;

output flag_data_recieve;
////////////////////////////////////////////////////////////
//		串口内核
///////////////////////////////////////////////////////////
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

wire		rst_n = ~rst;

reg		wrn;
reg		rdn;
reg		[7:0]din;

wire		[7:0]dout;


uart	uartuu(
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
/////////////////////////////////////////////////////////


///////////////////////////////////////////////////////////
//					自检程序	 电子变倍功能
///////////////////////////////////////////////////////////
//自检控制
reg		self_check;	//启动
reg		self_check_done;	//完成

//电子变倍指令生成
reg		video_zoom_normal;	
reg		video_zoom_check;
assign	video_zoom_out = self_check_done ? video_zoom : video_zoom_check;

reg	[5:0]STATE_CHECK;
parameter Idle					   = 6'b000001;
parameter CHECK_EN			   = 6'b000010;
parameter CHECK_WAIT0			= 6'b000100;
parameter CHECK_WAIT1			= 6'b001000;
parameter CHECK_FINISH			= 6'b010000;

wire	clk_check;
reg	[10:0] check_cnt;
reg	[17:0] time_cnt;
reg	flag_data_recieve;

always @(posedge clk_baud or negedge rst)
begin
  if(!rst)
    check_cnt<=0;
  else
    check_cnt<=check_cnt+1;
end

assign  clk_check = check_cnt[10];	

always @(posedge clk_baud or negedge rst)	 //clk_check
begin
	if(!rst)
		begin
			self_check_done <= 0; 
			video_zoom_check <= 0;
			time_cnt <= 0;

			STATE_CHECK <= Idle;
		end
	else
		begin
			case(STATE_CHECK)
			Idle:
				begin
					if(config_done)
						begin
							self_check_done <= 0; 
							video_zoom_check <= 0;
							time_cnt <= 0;

							STATE_CHECK <= CHECK_WAIT0;	
						end
					else
						STATE_CHECK <= Idle;
				end
						
			CHECK_WAIT0:
				begin	 					
					if(&time_cnt)
						begin						
							STATE_CHECK <= CHECK_EN;
							time_cnt <= 0;
						end
					else
						begin
							time_cnt <= time_cnt + 1;
							STATE_CHECK <= CHECK_WAIT0;
						end											
				end

			CHECK_EN:
				begin
					video_zoom_check <= 1;					

					STATE_CHECK <= CHECK_WAIT1;
				end
			CHECK_WAIT1:
				begin
					if(&time_cnt)
						begin						
							STATE_CHECK <= CHECK_FINISH;	 
							time_cnt <= 0;
						end
					else
						begin
							time_cnt <= time_cnt + 1;
							STATE_CHECK <= CHECK_WAIT1;
						end					
				end
			CHECK_FINISH:
				begin	
					video_zoom_check <= 0;				
					if(self_check == 1) //自检只启动一次
						begin	 							
						   self_check_done <= 0; 

							STATE_CHECK <= Idle;
						end
					else
						begin
							self_check_done <= 1;
							STATE_CHECK <= CHECK_FINISH;
						end
				end
			default:
				begin
					STATE_CHECK <= Idle;
				end
			endcase			
		end
end
///////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////
//指令接收
///////////////////////////////////////////////////////////
reg	[9:0]STATE;
reg	[9:0]nextSTATE;
parameter IDLE 				= 10'b0000000001;
parameter READY 				= 10'b0000000010;
parameter CHECK 				= 10'b0000000100;
parameter ANALYSE				= 10'b0000001000;
parameter CHECK_ZOOM			= 10'b0000010000;
parameter CHECK_DATA			= 10'b0000100000;
parameter DELAY				= 10'b0001000000;
parameter FINISH 				= 10'b0010000000;
parameter Wait					= 10'b0100000000;
parameter CLear 				= 10'b1000000000;
parameter Selfcheck 			= 10'b0000000000;

reg	[7:0]data_received;
reg	[7:0]data_received_zoom;

reg	self_check_temp;
reg	video_switch_enable_temp;	
reg	big_to_small_flag_temp;
reg	video_zoom_normal_temp; 
reg	foc_dir_temp;
reg	foc_enable_temp;
reg	cross_output_temp;
reg	image_enhancement_temp;
reg	image_enhancement_temp2;
reg	[3:0] cnt_dly;
reg	auto_focus_start_temp;
reg	touwu_temp;
reg 	[7:0]pre_view_temp;

reg 	pre_view_enable;
reg 	pre_view_enable_temp;

//reg 	touwu_enable;
//reg 	touwu_enable_temp;
//
//reg	self_check_enable;
//reg	self_check_enable_temp;

reg 	[1:0]self_check_sta;
reg 	[1:0]video_swich_sta;
reg	[1:0]focus_sta;

reg 	[1:0]self_check_sta_temp;
reg 	[1:0]video_swich_sta_temp;
reg	[1:0]focus_sta_temp;

always @(posedge clk_baud or negedge rst)
begin
	if(!rst)
  		begin	  
			rdn <= 1;
			
			self_check <= 1'b0;
			video_switch_enable <= 0;					
			big_to_small_flag <= 0;			  			
			video_zoom_normal <= 0;			
			foc_dir <= 0;
			foc_enable <= 0;
			auto_focus_start<=0;
			auto_focus_start_temp<=0;
			cross_output <= 0;	
			image_enhancement <= 1'b0;
			touwu<=0;
			pre_view<=0;

			pre_view_enable<=0;
			pre_view_enable_temp<=0;

			self_check_sta<=0;
			video_swich_sta<=0;
			focus_sta<=0;

			data_received <= 8'h00;
			data_received_zoom <= 8'h00;
			flag_data_recieve <= 1'b0;
			
			self_check_temp <= 1'b0;
			video_switch_enable_temp <= 0;						
			big_to_small_flag_temp <= 0;	
			video_zoom_normal_temp <= 0;		
			foc_dir_temp <= 0;
			foc_enable_temp <= 0;
			cross_output_temp <= 0;			
			image_enhancement_temp <= 1'b0;
			image_enhancement_temp2<=0;
			touwu_temp<=0;
			pre_view_temp<=0;

			self_check_sta_temp<=0;
			video_swich_sta_temp<=0;
			focus_sta_temp<=0;

			led_test <= 8'h00;

			cnt_dly<=0;

		   STATE <= IDLE;
			nextSTATE <= IDLE;
		end
	else
		begin
			case(STATE)			
			IDLE:
				begin	  
					rdn <= 1;

					data_received <= 8'h00;
					data_received_zoom <= 8'h00;
					flag_data_recieve <= 1'b0;
			
					self_check_temp <= 1'bx;
					video_switch_enable_temp <= 0;
					video_switch_enable<=0;						
					big_to_small_flag_temp <= 0;	
					video_zoom_normal_temp <= 0;		
					foc_dir_temp <= 0;
					foc_enable_temp <= 0;
					foc_enable<=0;
					auto_focus_start_temp<=0;
					cross_output_temp <= 0;			
					image_enhancement_temp <= 1'b0;
					image_enhancement_temp2<=0;
					touwu_temp<=0;
					pre_view_temp<=0;

					pre_view_enable<=0;
					pre_view_enable_temp<=0;



					led_test <= 8'h00;				

					cnt_dly<=0;

					STATE <= READY;
					nextSTATE <= CHECK;
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
							flag_data_recieve <= 1'b0;
							STATE <= READY;		
						end	 
				end  
			CHECK:
				begin
					if(dout == 'hf3)		 												//****ZS-OK****//
						begin
							rdn <= 1'b1;
							STATE <= READY;
							nextSTATE <= ANALYSE;
						end
					else
						begin
							rdn <= 1'b1;
							STATE <= READY;
							nextSTATE <= CHECK;
						end								
				end
			ANALYSE:
				begin
					data_received <= dout;
					led_test <= dout;

					// D1~D0，	启动自检（01启动；10正常工作）				  //****ZS-OK****//
					if(dout[1:0] == 2'b01) 
						begin
							self_check_temp <= 1;  //self_check_temp

							self_check_sta_temp<=2'b01;
						end
					else
					if(dout[1:0] == 2'b10) 
						begin
							self_check_temp <= 0;

							self_check_sta_temp<=2'b10;
						end
						
					 
					// D3~D2，	空（00）、视场+（01）、视场-（10）					 
					if(dout[3:2] == 2'b00)											 //****ZS-OK****//
						begin
							big_to_small_flag_temp <= 0;
							video_switch_enable_temp <= 0;		 //空

							video_swich_sta_temp<=2'b00;
						end
					else if(dout[3:2] == 2'b01)
						begin
							big_to_small_flag_temp <= 0;  //小到大
							video_switch_enable_temp <= 1;	
							
							video_swich_sta_temp<=2'b01;	
						end
					else if(dout[3:2] == 2'b10)
						begin
							big_to_small_flag_temp <= 1;	 //大到小
							video_switch_enable_temp <= 1;
							
							video_swich_sta_temp<=2'b10;								
						end
					else
						begin
							big_to_small_flag_temp <= 0;
							video_switch_enable_temp <= 0;
							
							video_swich_sta_temp<=2'b00;							
						end

					//	D5~4，		手动调焦方向 00-保持不变 01-加 10-减
					if(dout[5:4] == 2'b00)										//****ZS-OK****//
						begin
							foc_dir_temp <= 1'b0;
							foc_enable_temp <= 1'b0;		 //调焦控制无效
							auto_focus_start_temp<=1'b0;

							focus_sta_temp<=2'b00;
						end
					else if(dout[5:4] == 2'b01)
						begin
							foc_dir_temp <= 1'b1; //调焦+
							foc_enable_temp <= 1'b1;
							auto_focus_start_temp<=1'b0;

							focus_sta_temp<=2'b01;
						end
					else if(dout[5:4] == 2'b10)
						begin
							foc_dir_temp <= 1'b0;	 //调焦-
							foc_enable_temp <= 1'b1;
							auto_focus_start_temp<=1'b0;

							focus_sta_temp<=2'b10;
						end
					else if(dout[5:4] == 2'b11)
						begin
							foc_dir_temp <= 1'b0;	 //自动调焦
							foc_enable_temp <= 1'b0;
							auto_focus_start_temp<=1'b1;

							focus_sta_temp<=2'b11;
						end

					//	D6，		输出十字架指令（1为输出，0为不输出）
//					if(dout[6] == 1'b0)
//						begin
//							cross_output_temp <= 1'b0;
//						end
//					else
//						begin
//							cross_output_temp <= 1'b1; 	
//						end
//
//					//D7，		图像增强
//					if(dout[7] == 1'b0)
//						begin
//							image_enhancement_temp <= 1'b0;
//						end
//					else	
//						begin
//							image_enhancement_temp <= 1'b1;
//						end

					rdn <= 1'b1;
					STATE <= READY;
					nextSTATE <= CHECK_ZOOM;
				end

			CHECK_ZOOM:
				begin
					data_received_zoom <= dout; 

					//D0 电子变倍控制
					if(dout[0] == 1'b1)									//****ZS-OK****//
						begin
							video_zoom_normal_temp <= 1;
						end
					else
						begin
							video_zoom_normal_temp <= 0;
						end

					//D1 透雾
					if(dout[1]==1'b1)									  //****ZS-OK****// 新增透雾
						begin
							touwu_temp	<=	1;
							image_enhancement_temp2<=1;
						end
					else
						begin
							touwu_temp	<=	0;
							image_enhancement_temp2<=0;
						end

					//D2 增强
					if(dout[2]==1'b1)									  //****ZS-OK****// 增强改至第3字节
						begin
							image_enhancement_temp <= 1'b1;	
						end
					else
						begin
							image_enhancement_temp <= 1'b0;
						end

					//D4~D3  电十字
					if(dout[4:3]==2'b01)									  //****ZS-OK****// 电十字改至第3字节
						begin
							cross_output_temp <= 1'b1;	
						end
					else if(dout[4:3]==2'b00 || dout[4:3]==2'b10)
						begin
							cross_output_temp <= 1'b0;
						end

					//D7~D5 	  视场预置									  //****ZS-OK****// 新增视场预置
//				pre_view<= dout[7:5];
					if(dout[7:5]==3'b000)  	 //空
						begin
							pre_view_temp<=8'b00000000;
							pre_view_enable_temp<=1;
						end
					else if(dout[7:5]==3'b001)	// 18°×13.5°（焦距15mm）
						begin
							pre_view_temp<=8'b00000001;
							pre_view_enable_temp<=1;
						end
					else if(dout[7:5]==3'b010) //	12 ×9      （焦距22.83mm）
						begin
							pre_view_temp<=8'b00000010;
							pre_view_enable_temp<=1;
						end
					else if(dout[7:5]==3'b011) //	 8 ×6       （焦距34.32mm）
						begin
							pre_view_temp<=8'b00000011;
							pre_view_enable_temp<=1;
						end
					else if(dout[7:5]==3'b100)	//4 ×3       （焦距68.73mm）
						begin
							pre_view_temp<=8'b00000100;
							pre_view_enable_temp<=1;
						end
					else if(dout[7:5]==3'b101)	 //1.2°×0.9  （焦距230mm）
						begin
							pre_view_temp<=8'b00000101;
							pre_view_enable_temp<=1;
						end
					else
						begin
							pre_view_enable_temp<=0;
						end

					rdn <= 1'b1;
					STATE <= READY;
					nextSTATE <= CHECK_DATA;
				end

			CHECK_DATA:
				begin
					if(dout == (8'hf3 ^ data_received ^ data_received_zoom ^ 8'hdd))
						begin
							rdn <= 1'b1;
							STATE <= FINISH;
							nextSTATE <= CHECK;
						end
					else
						begin
							flag_data_recieve <= 1'b0;
							rdn <= 1'b1;
							STATE <= READY;
							nextSTATE <= CHECK;
						end
				end
			FINISH:		  //更新指令输出
				begin				 
				   //自检
					self_check <= self_check_temp;
					self_check_sta<= self_check_sta_temp;
				   //视场控制
					big_to_small_flag <= big_to_small_flag_temp;
					video_switch_enable <= video_switch_enable_temp;
					video_swich_sta<=video_swich_sta_temp;
					//调焦
					foc_dir <= foc_dir_temp;	 
					foc_enable <= foc_enable_temp;
					auto_focus_start <= auto_focus_start_temp;
					focus_sta<=focus_sta_temp;

					//电子变倍
					video_zoom_normal <= video_zoom_normal_temp;
					//十字架
					cross_output <= cross_output_temp;
					//增强
					image_enhancement <=image_enhancement_temp;// (image_enhancement_temp||image_enhancement_temp2);	
					//透雾
					touwu<=touwu_temp;
					//视场预置
					pre_view<=pre_view_temp;
					pre_view_enable<=pre_view_enable_temp;	
						
							
				
					flag_data_recieve <= 1'b1;	//脉冲					

					cnt_dly<=0;

					STATE <= Wait;	//CLear;//
				end
			Wait:
				begin
					cnt_dly <= cnt_dly +1;
					if(&cnt_dly)
					begin
						STATE <= CLear;
						flag_data_recieve <= 1'b0;						
					end
					else
						STATE <= Wait;		
				end
			CLear:
				begin
						STATE <= READY; 
						 
						//清零
						self_check <= 1'b0; //自检清零						
						video_switch_enable <= 0;					
						big_to_small_flag <= 1'bx;			  						
						foc_dir <= 1'bx;
						foc_enable <= 0;
						auto_focus_start <= 0;

//						touwu<=0;
//						pre_view<=0;
//						focus_sta<=0;
//						self_check_sta<=0;
//						video_swich_sta<=0;
						pre_view_enable<=0;													
				end	
			default:	STATE <= IDLE;
			endcase
		end	  
end

////////////////////////////////////////////////////////////////////////
//指令反馈 
////////////////////////////////////////////////////////////////////////
reg	[7:0]STATE_SEND;
parameter IDLE_SEND 			= 8'b00000001;
parameter READY_SEND 		= 8'b00000010;
parameter DATA_PRE_SEND 	= 8'b00000100;
parameter DATA_SEND			= 8'b00001000;
parameter DATA_SEND_ACK		= 8'b00010000;
parameter DATA_CNT_SEND		= 8'b00100000;
parameter WAIT_SEND			= 8'b01000000;
parameter FINISH_SEND 		= 8'b10000000;

reg	[3:0]dlycnt;
reg	[2:0]data_send_cnt;

wire	[7:0]data_send_buff = {video_zoom_normal,cross_output,view,~self_check_done,view_max_min[1],view_max_min[0]};							
wire  [7:0]data_send_buff2= {0,0,image_enhancement,touwu,data_received[5:2]};						

reg	[7:0]self_check_result;

reg	[1:0]view_limited;							  //****ZS-OK****//由2bit变为1bit
reg [2:0] alert_buffer [15:0];
reg [3:0] index;

always @(posedge clk_baud or negedge rst)  //posedge flag_data_recieve)//
begin
	if(!rst)	  //if(flag_data_recieve)//	
		begin
			din <= 8'hxx;	   
			wrn <= 1;

			index<=0;

			view_limited <=2'b00;

			dlycnt <= 0;
			data_send_cnt <= 0;
			self_check_result <= 0;

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
					self_check_result <= 0;

					if(flag_data_recieve)		 //电源板数据反馈完成
					begin
						STATE_SEND <= READY_SEND;
						alert_buffer[index]<={power_self_check,alert};
						view_limited <= view_max_min;
					end
					else
						STATE_SEND <= IDLE_SEND;
				end
			READY_SEND:
				begin
					data_send_cnt <= 0;
					STATE_SEND <= DATA_PRE_SEND;
				end
			DATA_PRE_SEND:
				begin
					if(data_send_cnt == 0)							//****ZS-OK****//
						begin
							din <= 8'h3f;
						end
					else if(data_send_cnt == 1)					 //****ZS-OK****//
							if(config_done == 1)						
								begin
									din <= 8'h55;
									self_check_result <= 8'h55;
//									index<=index+1;
								end
							else
								begin
									din <= 8'haa;
									self_check_result <= 8'haa;									
								end
					else if(data_send_cnt == 2)
						begin
							din[0] <= view_limited[0];//	视场限位信息	  	//****ZS-OK****//
							din[1] <= view_limited[1];								//****ZS-OK****//
							din[2] <= ~self_check_done;						 	//****ZS-OK****//
							din[5:3] <= view;											//****ZS-OK****//
							din[6] <= cross_output;									//****ZS-OK****//
							din[7] <= video_zoom_normal;						  	//****ZS-OK****//	  由增强改为电子变倍
						end
					else if(data_send_cnt == 3)
						begin
							din[1:0] <= data_received[3:2];					  //****ZS-OK****//
							din[3:2] <= data_received[5:4];
							din[4] <= touwu;
							din[5] <= image_enhancement;
							din[7:6] <=2'b00;
						end
					else if(data_send_cnt == 4)
						begin
							din <= (8'h3f ^ 8'hdd ^self_check_result ^ data_send_buff ^ data_send_buff2);
						end
					else
						begin
							din <= 8'hxx;
						end

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
					if(data_send_cnt == 4)
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
					STATE_SEND <= IDLE_SEND;//FINISH_SEND;	
				end
			default:
				begin
					STATE_SEND <= IDLE_SEND;//FINISH_SEND;
				end
			endcase
		end
end

endmodule
