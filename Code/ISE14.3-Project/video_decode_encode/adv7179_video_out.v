`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Create Date:    14:12:16 07/31/2009 
// Design Name: 
// Module Name:    adv7179_video_out 
//////////////////////////////////////////////////////////////////////////////////
module adv7179_video_out(
								clk59m, rst, qd, clk, clk135, config_done,enhance_enable,
								qd_out, clkout,
								data_saaSRAM, addr_SRAM, ce_saaSRAM, oe_saaSRAM, we_saaSRAM,//addr_saaSRAM,//added by li																
								//画电十字
								cross_output,//input
								//读取画中画图像
								video_pip2, video_pip4, video_pip8,
								rd_ce, rd_oe, rd_we, rd_dout,	rd_addr,
								//ZOOM算法控制
								field, line_cnt, video_zoom, video_switch,
								qfv
								);					
	/*** ports ***/
	input		clk59m;
	input		rst;
	input		[7:0]	qd;//利用直接的输入数据把SRAM中的数据送入7179
	input		clk,clk135;

	input		video_zoom;
	input		video_switch;
	input		cross_output;
	input		video_pip2;
	input		video_pip4;
	input		video_pip8;

	input enhance_enable;
	
	input 	[15:0]data_saaSRAM;
	output	[19:0]addr_SRAM;//added by li
	output	ce_saaSRAM,oe_saaSRAM,we_saaSRAM;

	output	[7:0]	qd_out; 
	output   clkout;

	input		config_done;

	//读画中画结果图像
	output	rd_ce;
	output	rd_oe;
	output	rd_we;
	output [15:0] rd_addr;
	reg	rd_ce;
	reg	rd_oe;
	reg	rd_we;
	reg 	[15:0] rd_addr;	
	input [7:0] rd_dout;
	output	field;
	output		[8:0] line_cnt;

	output	qfv;

	reg		ce_saaSRAM,oe_saaSRAM,we_saaSRAM;
	reg		[19:0]addr_saaSRAM;


	////////////////////////////////////////////////////////
	//	用于判断是否需要画中画
	////////////////////////////////////////////////////////
	reg		[19:0]addr_saaSRAM_temp;
	reg		video_pip2_dly;
	reg		video_pip2_dly1;
	reg		video_pip4_dly;
	reg		video_pip4_dly1;
	reg		video_pip8_dly;
	reg		video_pip8_dly1;

	always @(posedge clk or negedge rst)
		begin
			if(!rst)
				begin
					video_pip2_dly <= 1'b0;
					video_pip2_dly1 <= 1'b0;

					video_pip4_dly <= 1'b0;
					video_pip4_dly1 <= 1'b0;

					video_pip8_dly <= 1'b0;
					video_pip8_dly1 <= 1'b0;
				end
			else
				begin
					video_pip2_dly  <= video_pip2;
					video_pip2_dly1 <= video_pip2_dly;
					
					video_pip4_dly  <= video_pip4;
					video_pip4_dly1 <= video_pip4_dly;
					
					video_pip8_dly  <= video_pip8;
					video_pip8_dly1 <= video_pip8_dly;	
				end	
		end

	////////////////////////////////////////////////////////
	//	用于判断是否为小视场，以便于判断是否需要电子变倍
	////////////////////////////////////////////////////////
	reg video_switch_dly;
	reg video_switch_dly1;
	reg re_config;
	reg [2:0] cnt;	
	always @(posedge clk or negedge rst)
		begin
			if(!rst)
				begin
					video_switch_dly <= 1'b0;
					video_switch_dly1 <= 1'b0;
				end
			else
				begin
					video_switch_dly  <= video_switch;
					video_switch_dly1 <= video_switch_dly;	
				end	
		end


	/////////////////////////////////////////////////////////
	//internal 
	reg 		qfv;
	reg		[10:0]	qfv_cnt;
	reg		[7:0]	qd_dly,qd_dly1;
	reg 		[7:0]	MP;
	reg		[8:0] line_cnt;
	reg		[9:0] line_cnt_2;
	reg		[10:0]qfv_cnt_2;


	wire 		clkout;
	assign 	clkout = clk;

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
		qd_dly1 <= qd_dly;
		end
	end

	reg video_zoom_dly;
	reg video_zoom_dly1;	

	always @(posedge clk or negedge rst)
		begin
			if(!rst)
				begin
					video_zoom_dly <= 1'b0;
					video_zoom_dly1 <= 1'b0;
				end
			else
				begin
					video_zoom_dly  <= video_zoom;
					video_zoom_dly1 <= video_zoom_dly;	
				end	
		end

	reg cross_output_dly;
	reg cross_output_dly1;	

	always @(posedge clk or negedge rst)
		begin
			if(!rst)
				begin
					cross_output_dly <= 1'b0;
					cross_output_dly1 <= 1'b0;
				end
			else
				begin
					cross_output_dly  <= cross_output;
					cross_output_dly1 <= cross_output_dly;	
				end	
		end

	reg	error;

	reg	field;//场标志

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
	parameter stCb_or_Cr				= 4'd10;
	parameter stY						= 4'd11;

	reg	[15:0] databuffer4zoom;

	//SRAM地址生成
	assign addr_SRAM = addr_saaSRAM;//+addr_saaSRAM_offset;  //added by li						

	always @ (posedge clk or negedge rst)
	begin
		if(!rst) 
			begin
				STATE <= stIdle;
				nextSTATE <= stIdle;

				qfv_cnt <= 11'b00000000000;
				qfv<=1'b0;

				qfv_cnt_2 <= 0;

				line_cnt <= 9'h000;
				line_cnt_2 <= 1'b0;

				rd_ce <= 1'b1;
				rd_oe <= 1'b1;
				rd_we <= 1'b1;
				rd_addr <= 1'bx;
//				pic_ram_addr <= 1'b0;

				error <= 1'b0;
				MP <= 8'h00;

				ce_saaSRAM<=1'b1;
				oe_saaSRAM<=1'b1;
				we_saaSRAM<=1'b1;
				addr_saaSRAM <= 20'h00000;

				addr_saaSRAM_temp <= 20'h00000;			

				databuffer4zoom<= 0;

				field <= 1'bx;	//场标志无效
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
									qfv <= 1'b0;

									qfv_cnt_2 <= 0;

									line_cnt <= 9'h000;
									line_cnt_2 <= 1'b0;

									rd_ce <= 1'b1;
									rd_oe <= 1'b1;
									rd_we <= 1'b1;
									rd_addr <= 1'b0;

									error <= 1'b0;
									MP <= 8'h00;
								
									ce_saaSRAM<=1'b1;
									oe_saaSRAM<=1'b1;
									we_saaSRAM<=1'b1;

									addr_saaSRAM <= 20'h00000;

									databuffer4zoom<= 0;

									field <= 1'bx;	//场标志无效	
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

											field <= 1'b0;
							
											rd_ce <= 1'b0;
											rd_oe <= 1'b0;
											rd_we <= 1'b1;
											rd_addr <= 1'b0;

											//SRAM 使能
											ce_saaSRAM<=1'b0;
											oe_saaSRAM<=1'b0;
											we_saaSRAM<=1'b1;
											addr_saaSRAM <= 20'h00000;

											databuffer4zoom<= 0;
										end
									else
										begin
											STATE <= stWaitForEscape;
											nextSTATE <= stCheckODD;
										end
								end
						stACTIVE: 
								begin
									if(qd_dly==8'hff)
										begin
											STATE <= stCheckEscape1;
											nextSTATE <= stCheckForEndLine;
										end	
									else
										begin					
											if(qfv_cnt == 11'd1439)//读取的第一个有效数据在下面先被标记为1再进行的操作，
												begin						//我觉得应该改为1440而不是1439
													qfv_cnt <= 11'b00000000000;
													qfv <= 1'b0;
								
													databuffer4zoom<= 0;

													STATE <= stWaitForEscape;
													nextSTATE <= stCheckForEndLine;
												end
											else
												begin	
													qfv <= 1'b1;								
													qfv_cnt <= qfv_cnt + 1'b1;	
													qfv_cnt_2 <= (qfv_cnt>>1);
													line_cnt_2 <= 2*line_cnt;
																						
													if(qfv_cnt%2==0)
														begin							
															if( (cross_output_dly1 == 1)&&(( (((line_cnt == 145)&&(field==1'b0))||((line_cnt == 144)&&(field==1'b1))) && (qfv_cnt_2 >= 341) && (qfv_cnt_2 <= 381) ) || ( ((qfv_cnt_2 == 361) ) && (line_cnt >= 134) && (line_cnt <= 154) )) )//画电十字
																begin
																	MP <= (data_saaSRAM[7:0] > 'd128)? 'd15 : 'd245;
																end
															else 
																begin
																	if(video_zoom_dly1 && video_switch_dly1)
																		begin
																			if(((qfv_cnt_2 % 4) == 1) || ((qfv_cnt_2 % 4) == 2))
																				begin
																				   if (data_saaSRAM[7:0]==8'hFF)
																					   MP<=data_saaSRAM[7:0]-1;
																					else
																					   MP <= data_saaSRAM[7:0];													
																				end
																			else if((qfv_cnt_2 % 4) == 3)
																				begin
																				   if (data_saaSRAM[15:8]==8'hFF)
																					   MP <= data_saaSRAM[15:8]-1;
																				   else
																					   MP <= data_saaSRAM[15:8];
																				end
																			else if((qfv_cnt_2 % 4) == 0)
																				begin
																				   if (data_saaSRAM[15:8]==8'hFF)
																					   MP <= data_saaSRAM[15:8]-1;
																				   else
																					   MP <= data_saaSRAM[15:8];
																						
																					addr_saaSRAM <= 20'h40000*(field)+(line_cnt>>1)*720 + ((qfv_cnt_2)>>2);//+ 26010											
																				end																			
																		end
																	else
																		begin
																			MP <= data_saaSRAM[7:0];//																								
																			addr_saaSRAM <= (20'h40000*field) + (line_cnt*720) + (qfv_cnt_2);//
																		end
																end			
														end
													else	
														begin
															MP <= data_saaSRAM[15:8];//8'h80;
														end//80H将色差信息置为128，显示灰度图像。
													
													STATE <= stACTIVE;
												end
										end
								end
						stCheckForEndLine:
								begin
									ce_saaSRAM<=1'b1;
									oe_saaSRAM<=1'b1;
									we_saaSRAM<=1'b1;

									rd_ce <= 1'b1;
									rd_oe <= 1'b1;
									rd_we <= 1'b1;

									if (qd_dly[6:4] == 3'b111) //end of field 1
										begin
											STATE <= stIdle;						
										end
									else if (qd_dly[6:4] == 3'b011) //end of field 0
										begin
											STATE <= stWaitForEscape;
											nextSTATE <= stCheckForNewLine;

											field <= 1'b1;

											line_cnt <= 9'h000;																											
										end
									else if (qd_dly[5:4] == 2'b01) //end of line
										begin																					
											STATE <= stWaitForEscape;
											nextSTATE <= stCheckForNewLine;

											line_cnt <= line_cnt+1;							
										end
									else 
										STATE <= stError;
								end
						stCheckForNewLine:
								begin
									if (qd_dly[5:4] == 2'b00)
										begin
											STATE <= stACTIVE;//next line

											ce_saaSRAM<=1'b0;
											oe_saaSRAM<=1'b0;
											we_saaSRAM<=1'b1;

											rd_ce <= 1'b0;
											rd_oe <= 1'b0;
											rd_we <= 1'b1;
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
									error <= 1'b1;//indicate error on error LED

									ce_saaSRAM<=1'b1;
									oe_saaSRAM<=1'b1;
									we_saaSRAM<=1'b1;

									rd_ce <= 1'b1;
									rd_oe <= 1'b1;
									rd_we <= 1'b1;
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
						qfv<=1'b0;

						line_cnt <= 9'h000;

						error <= 1'b0;
						MP <= 8'h00;

						ce_saaSRAM<=1'b1;
						oe_saaSRAM<=1'b1;
						we_saaSRAM<=1'b1;
						addr_saaSRAM <= 20'h00000;
		
						rd_ce <= 1'b1;
						rd_oe <= 1'b1;
						rd_we <= 1'b1;
						rd_addr <= 1'bx;

						field <= 1'bx;	//场标志无效
					end
			end			
	end

	//图像输出
	wire	[7:0]	qd_out = (!qfv) ?qd_dly : MP;	// qd_dly1 :qd;//	  	 


endmodule