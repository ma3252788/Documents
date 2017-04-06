`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:    08:44:33 11/28/09
// Design Name:    
// Module Name:    Equilization_alg
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
// 直方图均衡化
////////////////////////////////////////////////////////////////////////////////
module Equilization_alg(rst, qd, clk, clk50, config_done, frame_sw,/* field, */
			
			gray_lookup_table, we, addr4out,max_gray

//			,intField	 , hist_done,

			);

	input		rst;
	input		[7:0]	qd;
	input		clk;
	input		clk50;
	input		frame_sw;
	input		config_done;
	input	[9:0] max_gray; //最大灰度值，用于增强
//	input 	intField;
//	input 	hist_done;

	//直方图统计表
//	output	we_histRAM;

	//输出直方图双口RAM
	output	[7:0]gray_lookup_table;	//输出直方图查找表，new_gray = gray_lookup_table[old_gray]
	output	we;
	output	[9:0]addr4out;
	reg	[9:0]addr4out;

	/////////////////////////////////////////////////////////////////////////////
	//internal
	//写新的灰度查找表
	reg [11:0] new_gray;	//处理越界	
	reg	we;
	reg [7:0] addr4out_tmp;

	//internal 
	reg		[10:0]	qfv_cnt;
	wire		[9:0]	qfv_cnt_2;
	reg		[8:0]	line_cnt;
	wire		qfv;
	reg		[7:0]	qd_dly,qd_dly1;
//	reg		intFrame;
	reg		intField;
	reg		hist_done;
//

//	assign gray_lookup_table =	(new_gray>250)? 250:((new_gray[7:0]>200)? (new_gray[7:0]-50) : ((new_gray[7:0]>170)? (new_gray[7:0]-30): new_gray[7:0]) );  //处理越界	 (new_gray>250)? 250:(new_gray[7:0]);//	
	assign gray_lookup_table =	(new_gray>250)? 250: (new_gray[7:0]);  //处理越界
	/////////////////////////////直方图统计////////////////////////////


	//直方图统计表RAM	 
	wire	[31:0] data_tohistRAM;
	wire	[31:0]data_fromhistRAM;	
	wire	[7:0]addr_histRAM;  
	wire	we_histRAM;	
	wire	ce_histRAM;

	reg	[31:0] data_tohistRAM_a;
	reg	[31:0] data_tohistRAM_b;	
	reg	[7:0]addr_histRAM_a;	//直方图统计
	reg	[7:0]addr_histRAM_b;	//均衡运算		
	reg	we_histRAM_a;
	reg	we_histRAM_b;	
	reg	ce_histRAM_a;
	reg	ce_histRAM_b;
	reg	[31:0] hist_rd;

	always @ (posedge clk or negedge rst) 
	begin
		if(~rst)
		begin
			qd_dly <= 0;
			qd_dly1 <= 0;
		end
		else 
		begin
		qd_dly  <= qd;
		qd_dly1  <= qd_dly;
		end
	end	

	reg	[3:0]	STATE;
	reg	[3:0] nextSTATE;
	parameter stIdle			 		= 4'd0;
	parameter stWaitForEscape 		= 4'd1;
	parameter stCheckEscape1  		= 4'd2;
	parameter stCheckEscape2  		= 4'd3;
	parameter stCheckNEWpage   	= 4'd4;
	parameter stCheckODD    		= 4'd5;
	parameter stACTIVE    			= 4'd6;	
	parameter stCheckForEndLine   = 4'd7;
	parameter stCheckForNewLine   = 4'd8;
	parameter stError 				= 4'd9;

	reg en_finish;
	
//	直方图统计（field==0）和均衡运算（field==1）时操作直方图RAM	
//	assign	ce_histRAM = (en_finish==1)? ce_histRAM_a : ce_histRAM_b ;	//(field==0)
//	assign	we_histRAM = (en_finish==1)? we_histRAM_a : we_histRAM_b ;
//	assign	addr_histRAM = (en_finish==1)? addr_histRAM_a : addr_histRAM_b;
//	assign	data_tohistRAM = (en_finish==1)? data_tohistRAM_a : data_tohistRAM_b;

	assign	ce_histRAM = (hist_done==0)? ce_histRAM_a : ce_histRAM_b ;	//(field==0)
	assign	we_histRAM = (hist_done==0)? we_histRAM_a : we_histRAM_b ;
	assign	addr_histRAM = (hist_done==0)? addr_histRAM_a : addr_histRAM_b;
	assign	data_tohistRAM = (hist_done==0)? data_tohistRAM_a : data_tohistRAM_b;

	hist_ram hist_table(
								.addr(addr_histRAM),
								.clk(clk),
								.din(data_tohistRAM),
								.dout(data_fromhistRAM),
								.en(ce_histRAM),
								.we(we_histRAM)
								);

	//奇场亮度分量
	assign	qfv_cnt_2 = (qfv_cnt>>1);	// 
	assign	qfv = ((qfv_cnt_2%2))? 1'b1 :1'b0;	//只统计360*288，奇场直方图
	reg	[7:0]addr_tmp;

	reg	[1:0]field_sta;

	//直方图统计
	reg	[3:0]	SState;
	parameter idle			= 4'b0001;
	parameter read			= 4'b0010;
	parameter write 		= 4'b0100;
	parameter delay		= 4'b1000;
	always @(posedge clk or posedge qfv)
	if(qfv)
		begin
			SState <= write; 

			addr_tmp	<= qd_dly;
			addr_histRAM_a <= qd_dly;										
			data_tohistRAM_a <= 32'hzz; 
			we_histRAM_a <= 1'b1;
			ce_histRAM_a <= 1'b0;

			hist_rd <= 32'h0;
		end
	else
	case(SState) 			
		write:
			begin 
				SState <= delay;

				addr_histRAM_a <= qd_dly1;								
				data_tohistRAM_a <= data_fromhistRAM+1;
				we_histRAM_a <= 1'b0;
				ce_histRAM_a <= 1'b0;	
			end
		 delay:
			begin
				SState <= delay;
							
				we_histRAM_a <= 1'b0;
				ce_histRAM_a <= 1'b0;
			end
		default:
				SState <= delay;	
	endcase


	always @ (posedge clk or negedge rst)
	begin
		if(!rst) 
			begin
				STATE <= stIdle;
				nextSTATE <= stIdle;

				qfv_cnt <= 11'b00000000000;
				line_cnt <= 9'h000;

				hist_done <= 1'b0;
				intField <= 1'b0;		 //场中断

				field_sta<=2'b00;
//				intFrame <= 1'b0;
			end
		else
			begin
				if(config_done)
					begin
						case(STATE)
						stIdle:
								begin	
									STATE <= stWaitForEscape;
									nextSTATE <= stCheckNEWpage;

									qfv_cnt <= 11'b00000000000;
									line_cnt <= 9'h000;
								end
						stWaitForEscape: 			
								begin
									if(qd_dly==8'hff)
										STATE <= stCheckEscape1;
									else
										STATE <= stWaitForEscape;
								end
	
						stCheckEscape1:
								begin
									if(qd_dly==8'h00)
										STATE <= stCheckEscape2;
									else 
										STATE <= stError;
								end

						stCheckEscape2:	
								begin
									if(qd_dly==8'h00)
										STATE <= nextSTATE;
									else
										STATE <= stError;
								end
						stCheckNEWpage:
								begin
									if(qd_dly[6:5]==2'b01)
										begin
											STATE <= stWaitForEscape;
											nextSTATE <= stCheckODD;
										end
									else
										begin
											STATE <= stWaitForEscape;
											nextSTATE <= stCheckNEWpage;
										end	
								end
						stCheckODD:	
								begin
									if(qd_dly[6:4] == 3'b000)
										begin
											STATE <= stACTIVE;
										
//											intFrame <= 1'b1;	 //帧开始中断
											field_sta<=1;
											
											intField <= 1'b1;	//场中断	
											hist_done <= 1'b0;															
										end
									else
										begin
											STATE <= stWaitForEscape;
											nextSTATE <= stCheckODD;
										end
								end
						stACTIVE: 
								begin		
//									intFrame <= 1'b0;

									intField <= 1'b0;	//场中断	
															
									if(qd_dly==8'hff)
										begin
											STATE <= stCheckEscape1;
											nextSTATE <= stCheckForEndLine;
										end	
									else
										begin					
											if(qfv_cnt == 11'd1440)
												begin					
													qfv_cnt <= 11'b00000000000;
								
													STATE <= stWaitForEscape;
													nextSTATE <= stCheckForEndLine;
												end
											else
												begin	  								
													qfv_cnt <= qfv_cnt + 1'b1;	
											
													STATE <= stACTIVE;
												end
										end
								end
						stCheckForEndLine:
								begin																  
									if (qd_dly[6:4] == 3'b111) //end of field 1
											begin
												STATE <= stIdle;	
												hist_done <= 1'b0;	
														
											end
										else if (qd_dly[6:4] == 3'b011) //end of field 0
											begin
												STATE <= stWaitForEscape;
												nextSTATE <= stCheckForNewLine;
											
												hist_done <= 1'b1; //直方图统计结束，开始均衡运算
												field_sta<=2;
												line_cnt	<= 'h0;																					
											end
										else if (qd_dly[5:4] == 2'b01) //end of line
													begin																					
														STATE <= stWaitForEscape;
														nextSTATE <= stCheckForNewLine;
														
														line_cnt <= line_cnt + 1;			
													end
												else 
													STATE <= stError;
								end
						stCheckForNewLine:
								begin
									if (qd_dly[5:4] == 2'b00)
										begin
											STATE <= stACTIVE;//next line	 
												
//											hist_done <= 1'b0;																								
										end
									else
										begin
											STATE <= stWaitForEscape;
											nextSTATE <= stCheckForNewLine;
										end
								end

						stError:
								begin
									STATE <= stError;
								end

						default:
									STATE <= stError;
						endcase
					end
				else
					begin
						STATE <= stIdle;
						nextSTATE <= stIdle;

						qfv_cnt <= 11'b00000000000;
					end
			end			
	end

	///////////////////////////////////////均衡运算//////////////////////////////////////////
	reg [17:0] delta_hist;
	reg	[31:0] qqq;
//	reg	[33:0] qqq;
	wire	[8:0] q_shift;
	reg  [17:0]hist_tmp;	//720*288
	//灰度级
	reg	[7:0] grayLevel;

	reg [19:0] State;
	parameter IDLE 					= 20'b00000000000000000001;
	parameter Wait 					= 20'b00000000000000000010;
	parameter Hist_start				= 20'b00000000000000000100;
	parameter Hist_read_dly			= 20'b00000000000000001000;
	parameter Hist_read_dly1		= 20'b00000000000000010000;
	parameter Hist_read 				= 20'b00000000000000100000;
	parameter Hist_acc 				= 20'b00000000000001000000;
	parameter Hist_multi	 			= 20'b00000000000010000000; 
	parameter Hist_shift    		= 20'b00000000000100000000;
	parameter Hist_caculate 		= 20'b00000000001000000000;
	parameter Hist_lookup_wr		= 20'b00000000010000000000;
	parameter Hist_lookup_wr_dly	= 20'b00000000100000000000; 			
	parameter STOP 					= 20'b00000001000000000000;
	parameter Hist_clear				= 20'b00000010000000000000;
	parameter Hist_clear_dly		= 20'b00000100000000000000;	
	parameter STOP_clear 			= 20'b00001000000000000000;
	parameter Finished 	 			= 20'b00010000000000000000;
	
	reg [9:0]  max_gray_buff;
	//获得最大灰度级
//	assign max_gray_buff = hist_done? ((max_gray>=120)? max_gray : ( ((max_gray<120)&&(max_gray>=80))? 180 : 150 ) ) : 0;	

	wire rfd;
	reg	aclr;
	reg [5:0] cnt_dly;
	divider_ip divider(
							.dividend(qqq), //
							.divisor(71840),//51840
							.quot(q_shift),  //q_shift
							.remd(),
							.clk(clk50),
							.rfd(rfd),
							.aclr(aclr),
							.sclr(),
							.ce()
							);

	always @(posedge clk or posedge intField or negedge rst) 
	if(intField)
		begin
			we <= 1'b0;		
			addr4out <= 10'h000;
			grayLevel <= 0; 
			delta_hist <= 0;
			hist_tmp <= 'hxx;

			max_gray_buff <= 0;

			qqq <= 32'h00000000;

			ce_histRAM_b <= 1'b1; 
			we_histRAM_b <= 1'b1;
			data_tohistRAM_b <= 32'hzzzzzzzz;
			addr_histRAM_b <= 8'hxx;

			cnt_dly<=0;
			aclr <= 1'b0;

			en_finish<=0;

			State <= IDLE;
		end
	else
	if(!rst)
		 begin
		 	we <= 1'b0;		
			addr4out <= 10'h000;
			grayLevel <= 0; 
			delta_hist <= 0;
			hist_tmp <= 'hxx;

			max_gray_buff <= 0;

			qqq <= 32'h00000000;

			ce_histRAM_b <= 1'b1; 
			we_histRAM_b <= 1'b1;
			data_tohistRAM_b <= 32'hzzzzzzzz;
			addr_histRAM_b <= 8'hxx;

			cnt_dly<=0;
			aclr <= 1'b0;

			State <= IDLE;
		 end
	else
	begin
		case(State)
		IDLE:
			begin
 				we <= 1'b0;
				addr4out <= 10'h000;
				grayLevel <= 0;//从灰度级0开始
				delta_hist <= 0;	
				hist_tmp <= 'hxx;

				max_gray_buff <= 0;

				qqq <= 32'h00000000;

				ce_histRAM_b <= 1'b1; 
				we_histRAM_b <= 1'b1;
				data_tohistRAM_b <= 32'hzzzzzzzz;
				addr_histRAM_b <= 8'hxx;

				cnt_dly<=0;
				aclr <= 1'b0;

				State <= Wait;
			end
		Wait:
			begin	
				if(hist_done)
				begin				   															
					State <= Hist_start;//运算开始
					
					//获得最大灰度级
//					if(max_gray<200)
//						max_gray_buff <= 255;
//					else
						max_gray_buff <= max_gray;	  
//					max_gray_buff <= 255;

					cnt_dly<=0;
					aclr <= 1'b0;

					we <= 1'b0;
					addr4out <= 'hxx;
					hist_tmp <= 'h00;
					grayLevel <= 0;//从灰度级0开始
					delta_hist <= 0;					

					ce_histRAM_b <= 1'b1;
					we_histRAM_b <= 1'b1;
					data_tohistRAM_b <= 32'hzzzzzzzz;
					addr_histRAM_b <= 8'hxx;			 
				end
				else
					State <= Wait;			
			end
		Hist_start:
			begin
				State <= Hist_read_dly;//Hist_read;
				
				cnt_dly<=0;
				aclr <= 1'b0;

				we <= 1'b0;
				addr4out <= 'hxx;
				
				hist_tmp <= 'h00;

				qqq <= 32'h00000000;

				ce_histRAM_b <= 1'b0;
				we_histRAM_b <= 1'b1;
				data_tohistRAM_b <= 32'hzzzzzzzz;
				addr_histRAM_b <= grayLevel;
			end
		Hist_read_dly:
			begin
				State <= Hist_read_dly1;	
			end
		Hist_read_dly1:
			begin
				State <= Hist_read;	
			end
		Hist_read:	//读直方图表
			begin				
				hist_tmp <= data_fromhistRAM;
				
				State <= Hist_acc;	
			end					
		Hist_acc:
			begin								
				delta_hist <= delta_hist + hist_tmp;
				
				we <= 1'b0;
				addr4out <= 'hxx;

				ce_histRAM_b <= 1'b1;
				we_histRAM_b <= 1'b1;
				data_tohistRAM_b <= 32'hzzzzzzzz;
				addr_histRAM_b <= 8'hxx;

				State <= Hist_multi;								
			end
		Hist_multi:
			begin			
				if(rfd)
					begin
						cnt_dly<=0;

						qqq<=max_gray_buff*delta_hist;  
						State <= Hist_shift;	//乘以255*5
					end
				else
					begin
						State <= Hist_multi;	
					end

				we <= 1'b0;
				addr4out <= 'hxx;

				ce_histRAM_b <= 1'b1;
				we_histRAM_b <= 1'b1;
				data_tohistRAM_b <= 32'hzzzzzzzz;
				addr_histRAM_b <= 8'hxx;
			end
		Hist_shift:
			begin
				//除法器输出延时
				if(cnt_dly==50)
					State <= Hist_caculate;		
				else
					begin
						State <= Hist_shift;

						cnt_dly <= cnt_dly + 1'b1;
					end				
				
				we <= 1'b0;
				addr4out <= 'hxx;

				ce_histRAM_b <= 1'b1;
				we_histRAM_b <= 1'b1;
				data_tohistRAM_b <= 32'hzzzzzzzz;
				addr_histRAM_b <= 8'hxx;	
			end		
		Hist_caculate:
			begin
				State <= Hist_lookup_wr;

				hist_tmp <= 'h00;						

				ce_histRAM_b <= 1'b1;
				we_histRAM_b <= 1'b1;
				data_tohistRAM_b <= 32'hzzzzzzzz;
				addr_histRAM_b <= 8'hxx;	
			end
		Hist_lookup_wr:
			begin
				State <= Hist_lookup_wr_dly;//STOP;				

				new_gray <= (q_shift>250)?250:q_shift;	//grayLevel;//
				we <= 1'b1;	 //写新查找表
				addr4out <= (512*frame_sw) + grayLevel;

				ce_histRAM_b <= 1'b1;
				we_histRAM_b <= 1'b1;
				data_tohistRAM_b <= 32'hzzzzzzzz;
				addr_histRAM_b <= 8'hxx;
			end
		Hist_lookup_wr_dly:
			begin
				State <= STOP;	

				qqq <= 32'h00000000;
				cnt_dly<=0;
				aclr <= 1'b1;

				ce_histRAM_b <= 1'b1;
				we_histRAM_b <= 1'b1;
				data_tohistRAM_b <= 32'hzzzzzzzz;
				addr_histRAM_b <= 8'hxx;
			end
		STOP:
			begin		
				we <= 1'b0;			
				
				ce_histRAM_b <= 1'b1;
				we_histRAM_b <= 1'b1;
				data_tohistRAM_b <= 32'hzzzzzzzz;
				addr_histRAM_b <= 8'hxx;
					
				if(grayLevel<255)//max_gray_buff)//
				begin
					grayLevel <= grayLevel +1'b1;

					State <= Hist_start;	
				end
				else
				begin		
					delta_hist<=0;			

					grayLevel <= 0;					

					State <= Hist_clear;
				end
			end
		Hist_clear:
			begin			
				State <= Hist_clear_dly;//STOP_clear;

				ce_histRAM_b <= 1'b0;
				we_histRAM_b <= 1'b0;
				data_tohistRAM_b <= 32'h00000000;
				addr_histRAM_b <= grayLevel;
			end
		Hist_clear_dly:
			begin			
				State <= STOP_clear;

				ce_histRAM_b <= 1'b0;
				we_histRAM_b <= 1'b0;
				data_tohistRAM_b <= 32'h00000000;
				addr_histRAM_b <= grayLevel;
			end
		STOP_clear:
			begin								
				if(grayLevel < 255)
				begin
					grayLevel <= grayLevel +1'b1;					

					State <= Hist_clear;	
				end
				else
				begin
					ce_histRAM_b <= 1'b1;
					we_histRAM_b <= 1'b1;
					data_tohistRAM_b <= 32'hzzzzzzzz;
					addr_histRAM_b <= 8'hxx;
				 
					grayLevel <= 0;

					State <= Finished;	
				end
			end
		Finished:
			begin
				State <= Finished;

				we <= 1'b0;		
				addr4out <= 'hxx;

				en_finish<=1;
				
				ce_histRAM_b <= 1'b1;
				we_histRAM_b <= 1'b1;
				data_tohistRAM_b <= 32'hzzzzzzzz;
				addr_histRAM_b <= 8'hxx;
			end
		default: State <= Finished;
		endcase
	end
										

endmodule
