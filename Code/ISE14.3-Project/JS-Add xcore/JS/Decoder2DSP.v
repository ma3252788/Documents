`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:47:22 08/01/2009 
// Design Name: 
// Module Name:    adv7180_decode 
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
module Decoder2DSP(
							reset,llck,vpo,capture,error,int4,int6,int5,
							RAM_OE,RAM_WE,laddr,ldata
							);

		input reset;			//异步复位
		//from adv7180
		input llck;				//SAA7180 video clock (27 MHz)
		input [7:0] vpo;		//vpo data from SAA7180
		input capture;			//flag for grab video data
		//to ram
		output error;				//state indicator,to LED
		output RAM_OE;				//双口RAM使能
		output RAM_WE;				//双口RAM写
		output [15:0] laddr;		//address bus
		output [7:0] ldata;		//data bus
		//to dsp
		output int4;  			//奇场中断
		output int5;  			//偶场中断
		output int6;  			//行中断，24行
		//output registers
		//to RAM
		reg [15:0] laddr;
		reg [7 :0] ldata;
		reg RAM_OE;
		reg RAM_WE;		
		//to DSP
		reg int4;
		reg int5;
		reg int6;
		
		reg error;

		//video in state machine declaration
		reg [3:0] State;//
		reg [3:0] returnState;

		//parameters
		parameter	Intr_hang = 24;  //每24行Y分量一次中断
		//state declaration
		parameter 	stIdle = 4'b0000;					//IDLE STATE,START UP OF A STATE MACHINE,RESET
		parameter	stWaitForEscape = 4'b0001;		//CHECK FOR "FF",START OF TIMING REFERENCE CODE
		parameter	stCheckEscape1 = 4'b0010;		//CHECK FOR "00",SECOND
		parameter	stCheckEscape2 = 4'b0011;		//CHECK FOR "00",THIRD
		parameter	stCheckForNewPage = 4'b0100;	//CHECK FOR "01",It is in vertical blanking stage,
		parameter	stCheckForFirstLine = 4'b0101;//CHECK FOR "000",for SAV in valid row
		parameter	stChromaBlue = 4'b0110;			//write Cb to sram,here not in use
		parameter	stLumaBlue = 4'b0111;			//write Lb to sram
		parameter	stChromaRed = 4'b1000;			//write Cr to sram,not in use
		parameter	stLumaRed = 4'b1001;				//write Lr to sram,
		parameter	stCheckForEndLine = 4'b1010;	//CHECK for end of line
		parameter	stCheckForNewLine = 4'b1011;	//CHECK for new line
		parameter	stError = 4'b1100;				//ERROR state

		//各分量的采样计数器
		reg [14:0] grab_cntr_Lum;	 	//704*24*12
		reg [6: 0] grab_int_hang;	//counter for vertical 24			
		//水平、垂直计数器
		reg [9:0] cntr_hori;//counter for horizon 720
		reg [8:0] cntr_vert;//counter for vertical 288
		
		//乒乓存储算法标志
		reg flag;
		//场标志
		reg field;							
		
		//grab data from vpo bus
		always @(posedge llck or negedge reset)
		begin
			if (!reset)
				begin
					State <= stIdle;						
					returnState <= stIdle;							
				
					cntr_hori 		<= 10'h000;
					cntr_vert 		<= 9'h00;
					grab_cntr_Lum 	<=	15'h0000;
					grab_int_hang	<= 7'h00;

					flag <= 1'bx;//乒乓标志，用于产生存储地址
					field <= 1'bx;	//场标志无效

					error <= 1'b0;
					
					//中断无效
					int4<=1'b0;
					int5<=1'b0;
					int6<=1'b0;

					//RAM无效
					RAM_OE <= 1'b0; 
					RAM_WE <= 1'b0;					
					ldata <=	8'h00;
					laddr <=	16'h0000;
						 
				end
			else 
			begin
				//state machine
				case (State)
					stIdle:// 0
						begin
							int6 <= 1'b0;	//清除最后一个偶场行中断

							if (capture == 1'b1)
								begin
									cntr_hori <= 10'h000;
									cntr_vert <= 9'h00;
									grab_cntr_Lum <=	15'h0000;
									grab_int_hang	<= 7'h00;

									error <= 1'b0;											
								
									//RAM无效
									RAM_OE <= 1'b0; 
									RAM_WE <= 1'b0;  
									ldata <=	 8'h00;
									laddr	<= 16'h0000;

									State <= stWaitForEscape;	// Look for an escape sequence
									returnState <= stCheckForNewPage;// Check for start of field 0
								end
							else
								State <= stIdle;
						end

					stWaitForEscape://Look for the first character in the sequence, keep looking until found
						begin
						if (vpo == 8'hFF)
							begin	
							State <= stCheckEscape1;				
							end
						else
							State <= stWaitForEscape;
						end
					stCheckEscape1://Second character in the escape sequence is 0					
						if (vpo == 8'h00)
								State <= stCheckEscape2;
						else
							State <= stError;

					stCheckEscape2://Third charcter in the escape sequence is 0.  Go to returnState to check SAV/EAV code
						if (vpo == 8'h00)
							State <= returnState;
						else
							State <= stError;

					stCheckForNewPage://Wait for an SAV or EAV in field 0 while in the vertical blanking stage
						if (vpo[6:5] == 2'b01) //If it is then wait until the first line of active video
							begin
								State <= stWaitForEscape;
								returnState <= stCheckForFirstLine;						

								//initialise all counters for a new frame
								cntr_hori <= 10'h000;
								cntr_vert <= 6'h00;
								grab_cntr_Lum 	<=	15'h0000;
							end
						else  //Look for another SAV/EAV until we find the type we want.
							begin
								State <= stWaitForEscape;
								returnState <= stCheckForNewPage;
							end

					stCheckForFirstLine://Wait for an SAV in field 0 while in the active video region
					begin
						if (vpo[6:4] == 3'b000)  //start recording data
							begin
								State <= stChromaBlue;
								
								int4 <= 1'b1;	//触发奇场中断
								//RAM有效
								RAM_OE <= 1'b1;
							end
						else  //Look for another SAV/EAV until we find the type we want.
							begin
								State <= stWaitForEscape;
								returnState <= stCheckForFirstLine;
							end
					end
					//处理U分量
					stChromaBlue://This may be the start of another pair of pixels or the end of data
					begin					
						RAM_WE <= 1'b0; 
						ldata <= 8'h00; 										
						laddr <=	16'h0000; 

							int4 <= 1'b0;	  //清除奇场中断
							int5 <= 1'b0;

						if (vpo == 8'hFF) //If the byte is FF then it is the start of the EAV.
							begin
								State <= stCheckEscape1;//Go to second state of subroutine
								returnState <= stCheckForEndLine;//Check if this is the last line of the field
							end
						else if (vpo == 8'h00)
							State <= stError;			
						else //latch data into register and continue
							begin
								State <= stLumaBlue;														 		
							end
					end
					//处理Lb分量
					stLumaBlue://As long as valid data is present continue latching data
						if ((vpo !== 8'hFF) && (vpo !== 8'h00))
							begin
								State <= stChromaRed;
								
								cntr_hori <= cntr_hori+1;	//Increment horizontal counter every two pixels
								grab_cntr_Lum <= grab_cntr_Lum + 1;	  //increase counter										
								
								//RAM写
								RAM_WE <= 1'b1; 									
								ldata <= vpo; 
								laddr  <= flag*20480 + grab_cntr_Lum;																
							end
						else
							begin								
								State <= stError;
							end
							
					//处理V分量		
					stChromaRed://As long as valid data is present continue latching data
					begin				
						RAM_WE <= 1'b0; 
						ldata <= 8'h00; 										
						laddr <=	16'h0000; 
														
						if ((vpo !== 8'hFF) && (vpo !== 8'h00))
							begin
								State <= stLumaRed;								
							end
						else
							State <= stError;
					end
					//处鞮r分量
					stLumaRed://As long as valid data is present continue latching data and setup to write current data
						if ((vpo !== 8'hFF) && (vpo !== 8'h00))
							begin
								State <= stChromaBlue;						
								
//								cntr_hori <= cntr_hori+1;	//Increment horizontal counter every two pixels
//								grab_cntr_Lum <= grab_cntr_Lum + 1;	  //increase counter
//								
//								//RAM有效
//								RAM_WE <= 1'b1; 
//								ldata <= vpo;										
//								laddr<= flag*20480 + grab_cntr_Lum;									
																		
							end
						else
							State <= stError;

					stCheckForEndLine://possible conditions here are the end of field 0, end of field 1,or an EAV code indicating a new line in the active region.					
					begin
						//RAM无效
						RAM_OE <= 1'b0; 
						RAM_WE <= 1'b0;  
						ldata <=	 8'h00;
						laddr	<= 16'h0000;
						  
						if (vpo[6:4] == 3'b111) //end of field 1
							begin

								State <= stIdle;						

								field <= 0;	 //下一场为奇场
//								int6<=1'b1;	  //偶场最后一个行中断
								flag <= 1'b0;//为一帧的奇场图像指定初始存储块
							end
						else if (vpo[6:4] == 3'b011) //end of field 0
							begin
								State <= stWaitForEscape;
								returnState <= stCheckForNewLine;//start capture at first new line
							
								field <= 1;	  //下一场为偶场
								int6 <= 1'b1;		//奇场最后一个行中断
								flag <= 1'b0;	 //为一帧的奇场图像指定初始存储块

								//initialize all counters for field 1
								cntr_hori <= 10'h000;
								cntr_vert <= 9'h000;
								grab_cntr_Lum <=	15'h0000;
								grab_int_hang <= 7'h00;
							end
						else if (vpo[5:4] == 2'b01) //end of line
								begin
									//行中断
									if((grab_int_hang == Intr_hang-1)&&(field==0)) //只取奇场
										begin 							
											int6 <= 1'b1;		//行中断

											flag <= ~flag;		//乒乓切换

											//initialize counters for new data block									
											grab_int_hang <= 7'h00;
											grab_cntr_Lum <=	15'h0000;
										end											
									else
										begin
											grab_int_hang <= grab_int_hang+1;	// go to next line
										end

																			
									cntr_hori <= 10'h000;		//为新的行初始化计数器
									cntr_vert <= cntr_vert + 1;
																								
									State <= stWaitForEscape;
									returnState <= stCheckForNewLine;//capture next line from start
								end
							else // EAV expected but SAV received
								State <= stError;
					end
					stCheckForNewLine://Wait until an SAV in the active video range arrives
					begin						
						if (vpo[5:4] == 2'b00)
							begin
								State <= stChromaBlue;// capture next line

								int6 <= 1'b0;	//清除行中断,包括最后一个奇场行中断	

								//RAM有效
								RAM_OE <= 1'b1;
 							end
						else	// Wait for another code
							begin
								State <= stWaitForEscape;
								returnState <= stCheckForNewLine;
							end
					end
					stError://Wait until another capture is requested before continuing
						if (capture == 1'b1)
							begin
								State <= stIdle;
							end
						else
							begin
								//RAM无效
								RAM_OE <= 1'b0; 
								RAM_WE <= 1'b0;
								ldata <=	8'h00;
								laddr	<= 16'h0000;

								int4<=1'b0;
								int6<=1'b0;

								State <= stError;
								error <= 1'b1;//indicate error on error LED
							end

					default:
						State <= stError;
				endcase
			end
		end
endmodule

