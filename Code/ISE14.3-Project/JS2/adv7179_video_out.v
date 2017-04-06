`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:12:16 07/31/2009 
// Design Name: 
// Module Name:    adv7179_video_out 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module adv7179_video_out(
								rst,					
								qd,
								clk,
								qd_out,
								clkout,
								field,

								data_saaSRAM,
								addr_saaSRAM,
								ce_saaSRAM,
								oe_saaSRAM,
								we_saaSRAM,

								config_done,

								video_zoom,
								cross_output,
								video_pip

								,qfv,qfv_cnt,qfv_cnt_2,qd_dly,qd_dly1
								);					
/*** ports ***/
input		rst;
input		[7:0]	qd;
input		clk;
input		video_zoom;

input		cross_output;
input		video_pip;

input 	[15:0]data_saaSRAM;
output	[19:0]addr_saaSRAM;
output	ce_saaSRAM,oe_saaSRAM,we_saaSRAM;

output	[7:0]	qd_out; 
output   clkout;
output	field;

output	qfv;
output		[10:0]qfv_cnt;	 
output		[10:0]qfv_cnt_2;
output		[7:0]	qd_dly;
output		[7:0] qd_dly1;

input		config_done;

reg		ce_saaSRAM,oe_saaSRAM,we_saaSRAM;
wire		[19:0]addr_saaSRAM;
wire		[19:0]addr_saaSRAM_ZOOM;
wire		[19:0]addr_saaSRAM_PIP;
reg		[19:0]addr_saaSRAM_buff;
////////////////////////////////////////////////////////
//	�����ж��Ƿ���Ҫ���л�
////////////////////////////////////////////////////////
reg		video_pip_dly;
reg		video_pip_dly1;

	always @(posedge clk or negedge rst)
		begin
			if(!rst)
				begin
					video_pip_dly <= 1'b0;
					video_pip_dly1 <= 1'b0;
				end
			else
				begin
					video_pip_dly  <= video_pip;
					video_pip_dly1 <= video_pip_dly;	
				end	
		end

/////////////////////////////////////////////////////////
//internal 
reg 		qfv;
reg		[10:0]qfv_cnt;	 
wire		[10:0]qfv_cnt_2;
reg		[7:0]	qd_dly,qd_dly1;
reg 		[7:0]	MP;
reg		[8:0] line_cnt;

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
reg video_zoom_cmd;	

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

reg	flag_cross;

reg	error;

reg	field;//����־

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

//(***)�������ʮ�ּܵȹ���ʱ��ɫ��������в���
reg [7:0] Y0,Y1;
reg [7:0] Cb,Cr;
reg [7:0] CbCr;	

assign qfv_cnt_2 = (qfv_cnt >> 1);

assign addr_saaSRAM_ZOOM = (qfv_cnt%8==0)?((20'h32A00*(field)) + 52020 + ((line_cnt>>1)*720) + (qfv_cnt_2>>1)):(addr_saaSRAM_buff+1); // 
//assign addr_saaSRAM_PIP = (line_cnt < 96 && qfv_cnt_2 < 240)?( (qfv_cnt%8==0)?((20'h32A00*field) + 86700 + ((line_cnt>>1)*720) + (qfv_cnt_2>>1))
//																									 :(addr_saaSRAM_buff+1) ):((20'h32A00*field) + (line_cnt*720) + qfv_cnt_2);	

assign addr_saaSRAM = (video_zoom_dly1)? addr_saaSRAM_ZOOM: ((20'h32A00*(field)) + (line_cnt*720) + qfv_cnt_2 );	//( (video_pip_dly1)? addr_saaSRAM_PIP:	 // 

	
always @ (posedge clk or negedge rst)
begin
	if(!rst) 
		begin
			STATE <= stIdle;
			nextSTATE <= stIdle;

			qfv_cnt <= 11'b00000000000;
			qfv<=1'b0;

			line_cnt <= 9'h000;

			error <= 1'b0;
			MP <= 8'h200;//8'h00;

			ce_saaSRAM<=1'b1;
			oe_saaSRAM<=1'b1;
			we_saaSRAM<=1'b1;
//			addr_saaSRAM <= 20'h00000;
			
			Y0	<= 8'h10;
			Y1	<= 8'h10;
			Cb	<= 8'h155;//8'h80; 
			Cr	<= 8'h115;//8'h80; 
			CbCr <= 8'h112;//8'h80;����������֮��û�б仯

			flag_cross  <= 0;

			field <= 1'bx;	//����־��Ч
		end
	else
		begin
			case(STATE)
			stIdle:
					begin	
						if(config_done)
						begin
							STATE <= stWaitForEscape;
							nextSTATE <= stCheckNEWpage;

							qfv_cnt <= 11'b00000000000;
							qfv <= 1'b0;

							line_cnt <= 9'h000;

							error <= 1'b0;
							MP <= 8'h112;//8'h00;

							ce_saaSRAM<=1'b1;
							oe_saaSRAM<=1'b1;
							we_saaSRAM<=1'b1;
//									addr_saaSRAM <= 20'h00000;
						
							Y0	<= 8'h10;
							Y1	<= 8'h10;
							Cb	<= 8'h80; 
							Cr	<= 8'h80; 
							CbCr <= 8'h80;

							flag_cross <= 0;

							field <= 1'bx;	//����־��Ч
						end
						else
						begin
							STATE <= stIdle;
							nextSTATE <= stIdle;
						end
					end
			stWaitForEscape: 			
					begin
						MP <= 8'h00;

						if(qd_dly==8'hff)
							STATE <= stCheckEscape1;
						else
							STATE <= stWaitForEscape;
					end

			stCheckEscape1:
					begin
						MP <= 8'h00;

						if(qd_dly==8'h00)
							STATE <= stCheckEscape2;
						else 
							STATE <= stError;
					end

			stCheckEscape2:	
					begin
						MP <= 8'h00;

						if(qd_dly==8'h00)
							STATE <= nextSTATE;
						else
							STATE <= stError;
					end
			stCheckNEWpage:
					begin
						MP <= 8'h00;

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
						MP <= 8'h00;

						if(qd_dly[6:4] == 3'b000)
							begin
								STATE <= stACTIVE;	 																

								field <= 1'b0;
					
								//SRAM ʹ��
								ce_saaSRAM<=1'b0;
								oe_saaSRAM<=1'b0;
								we_saaSRAM<=1'b1;
//										addr_saaSRAM <= 20'h00000;	 //���ַ���ݶ���������ʧ��һ��Cb����
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
								MP <= 8'h00;

								STATE <= stCheckEscape1;
								nextSTATE <= stCheckForEndLine;
							end	
						else
							begin					
								if(qfv_cnt == 11'd1439)
									begin					
										qfv_cnt <= 11'b00000000000;
										qfv <= 1'b0;												

										MP <= 8'h00;

										STATE <= stWaitForEscape;
										nextSTATE <= stCheckForEndLine;
									end
								else
									begin	  								
										qfv_cnt <= qfv_cnt + 1'b1;	
										
										qfv <= 1'b1;

										if(qfv_cnt%2==0)	 //ɫ�����													
											begin
												//ʮ��
												if( (cross_output == 1)&&(( (line_cnt == 144) && (qfv_cnt_2 >= 335) && (qfv_cnt_2 < 385) ) || ( (qfv_cnt_2 == 360) && (line_cnt > 134) && (line_cnt <= 154) )) )//����ʮ��
//														if( (cross_output == 1)&&((line_cnt == 144) || (qfv_cnt_2 == 360)))//����ʮ��
													begin
														MP <= 8'h150;//8'h80; 	//ɫ��������㣬��������ڰ�ʮ��	,8'h80
//																addr_saaSRAM <= (20'h32A00*field) + (line_cnt*720) + qfv_cnt_2; //�������ȷ������Ծ����ڻ��ʮ��
													end
												else	//�䱶 //�䱶�ͻ��л�����8������Ϊһ�鿼��CbYCrY���������														 														
												if(video_zoom_dly1) 
													begin
														if(qfv_cnt%8==0) 	
															begin													
																MP <= 100;//data_saaSRAM[7:0];//Cb
																Cb <= 120;//data_saaSRAM[7:0];//����Cb,Y0����,��һ��������																																					
																Y0 <= 98;//data_saaSRAM[15:8];  
//																		addr_saaSRAM <= (20'h32A00*field) + 52020 + ((line_cnt>>1)*720) + (qfv_cnt_2>>1);//ȡ����һ����Cb��Y����
																addr_saaSRAM_buff<= addr_saaSRAM;
															end
														else
														if (qfv_cnt%8==2)
															begin
																MP <= 100;//data_saaSRAM[7:0];//Cr
																Cr <= 120;//data_saaSRAM[7:0];//����Cr,Y1����,��һ��������																																					
																Y1 <= 98;//data_saaSRAM[15:8]; 
//																		addr_saaSRAM <= addr_saaSRAM + 1'b1;	//ȡ����һ��Cr����
															end
														else
														if (qfv_cnt%8==4)
															MP <= 100;//Cb;
														else
														if	(qfv_cnt%8==6)
															MP <= 100;//Cr;
													end														 
												else //����
													begin
														if(qfv_cnt%4==0)
														begin
															MP <= 8'b11010010;//data_saaSRAM[7:0];//CbCr;	//Ϊ�˽������ʱCB,CR��λ�������һ�ε�ɫ������ӳٵ���һ��
														//CbCr <= data_saaSRAM[7:0];
//																addr_saaSRAM <= (20'h32A00*field) + (line_cnt*720) + qfv_cnt_2; 											
														end
													end																		
											end	
										else		//���ȷ���
											begin							
												if( (cross_output == 1)&&(( (line_cnt == 144) && (qfv_cnt_2 >= 335) && (qfv_cnt_2 < 385) ) || ( (qfv_cnt_2 == 360) && (line_cnt > 134) && (line_cnt <= 154) )) )//����ʮ��
//														if( (cross_output == 1)&&( (line_cnt == 144) || (qfv_cnt_2 == 360)) )//����ʮ��
													begin
														MP <=112;// (data_saaSRAM[15:8] > 128)? 20 : 220; 
													end
												else
												if(video_zoom_dly1) // && video_switch_dly1
													begin
														if(qfv_cnt%8==1) 																	
															begin																			
																MP <= Y0;//��ֵ																			
															end
														else
														if(qfv_cnt%8==3)	 
															begin
																MP <= Y0;																			
															end
														else
														if(qfv_cnt%8==5)	 
															begin
																MP <= Y1;																			
															end
														else
														if(qfv_cnt%8==7)	 
															begin
																MP <= Y1;																			
															end		
													end
												else
													begin
														MP <= data_saaSRAM[15:8];													
													end			
											end

										STATE <= stACTIVE;
									end
							end
					end
			stCheckForEndLine:
					begin
						ce_saaSRAM<=1'b1;
						oe_saaSRAM<=1'b1;
						we_saaSRAM<=1'b1;

						MP <= 8'h00;

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
//											addr_saaSRAM <= 20'h32A00;//����ż����һ����ַ															
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
						MP <= 8'h00;

						if (qd_dly[5:4] == 2'b00)
							begin
								STATE <= stACTIVE;//next line	 

								ce_saaSRAM<=1'b0;
								oe_saaSRAM<=1'b0;
								we_saaSRAM<=1'b1;																												
							end
						else
							begin
								STATE <= stWaitForEscape;
								nextSTATE <= stCheckForNewLine;
							end
					end

			stError:
					begin
						MP <= 8'h00;//���ˣ�ԭ����00,����֮��û��Ӧ


						if (config_done)
						begin
							STATE <= stIdle;
							nextSTATE <= stIdle;
						end
						else
						begin
						
							STATE <= stError;

							error <= 1'b1;//indicate error on error LED

							ce_saaSRAM<=1'b1;
							oe_saaSRAM<=1'b1;
							we_saaSRAM<=1'b1;
						end
					end

			default:
						STATE <= stError;
			endcase
		end			
end

wire	[7:0]	qd_out = (qfv)?MP:qd_dly1;

endmodule
