`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    09:51:21 12/14/2016 
// Design Name: 
// Module Name:    adv7180_video_in 
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
module adv7180_video_in(
							reset, llck, llck_hf, clk59m, vpo, capture, error, flag, field,						
							ce_sram12, oe_sram12, we_sram12,	addr_sram12, data_sram12						
							);
		input reset;			//异步复位
		
		input llck;				//from ADV7180 video clock (27 MHz)  
		input llck_hf;  
		input clk59m;        //系统时钟    
		input [7:0] vpo;		//vpo data from ADV7180
		input capture;			//7179.7180配置完成标志位
		
		output error;			//state indicator,to LED
		output flag;			//乒乓存储算法标志
		output field;			//场标志位
		
		output ce_sram12;//存入SRAM
		output oe_sram12;
		output we_sram12;
		output [19:0] addr_sram12;
		output [15:0] data_sram12;

		/////////////////////////////////////////////////////////////////////////////
		//output registers
		reg [19:0] addr_sram12;
		reg [15:0] data_sram12;
		reg oe_sram12;
		reg we_sram12;
		reg ce_sram12;
		reg [7:0]LB_data;
		reg [7:0]UB_data;

		reg error;																    

		reg [7:0] vpo_dly;
		reg [7:0] vpo_dly1;
		reg [7:0] vpo_dly2;
		always @ (posedge llck or negedge reset) 
		begin
			if(~reset)
			begin
				vpo_dly <= 0;
				vpo_dly1 <= 0;
				vpo_dly2 <= 0;
			end
			else 
			begin
				vpo_dly  <= vpo;
				vpo_dly1  <= vpo_dly;
				vpo_dly2  <= vpo_dly1;
			end		
		end

		//video in state machine declaration
		reg [3:0] State;//
		reg [3:0] returnState;
		//parameters
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
		
		//生成水平、垂直计数器
		reg [9:0] cntr_hori_word;//counter for horizon 720
		reg [9:0] cntr_hori_byte;//counter for horizon 1440
		reg [8:0] cntr_vert;//counter for vertical 576
		reg [9:0] pixel_cnt;
		
		//生成场标志
		reg field;
		
		//生成乒乓存储算法标志
		reg flag;

		//16bits mode 
/*		always begin
			if(State == stChromaRed) begin
				addr_sram12 <= (20'h40000*(field)) +(720*(cntr_vert) + cntr_hori_word);	//把360改为了720
				//we_sram12 <= (State==stChromaRed)?1'b0:1'b1;//在读完16bit后再写入
				oe_sram12 <= 1'b1;
				we_sram12 <= 1'b0;
				end
			else
				we_sram12 <= 1'b1;
		end*/
		
//		//16bits mode
//		assign addr_sram12 = (20'h40000*(field)) +(512*(cntr_vert) + cntr_hori_word);	
//		assign we_sram12 = (State==stChromaRed)?1'b0:1'b1;
//		assign oe_sram12 = 1'b1;
		
//		//8bits mode
//		assign addr_sram12 = (20'h50000*(field)) +(1024*(cntr_vert) + cntr_hori_byte);	
//		assign we_sram12 = (State==stChromaBlue||State==stChromaRed)?1'b0:1'b1;
//		assign oe_sram12 = 1'b1;
		
		//Video decoder
		//grab data from vpo bus
		always @(posedge llck or negedge reset)
		begin
			if (!reset)
				begin
					State <= stIdle;						
					returnState <= stIdle;							
					
					cntr_hori_byte <= 10'h000;//fff
					cntr_hori_word <= 10'h000;
					cntr_vert <= 10'h0;
					pixel_cnt<= 10'hfff;	
					
					flag <= 1'b0;//乒乓标志，用于控制SRAM切换
					field <= 1'b0;	//场标志

					error <= 1'b0;				
					
					ce_sram12 <= 1'b1;//RAM无效							
				end
			else 
			begin
				//state machine
				case (State)
					stIdle:// 0
						begin
							if (capture == 1'b1)
								begin
									error <= 1'b0;											
								
									//initialize all counters for field 0
									cntr_hori_byte <= 10'h000;
									cntr_hori_word <= 10'h000;//	360;//
									cntr_vert <= 10'h000;//	287;//
									pixel_cnt<= 10'hfff;

									field <= 1'b0;	//偶场标志								
									flag <= ~flag;	 //乒乓帧切换，控制SRAM总线切换													
									
									ce_sram12 <= 1'b1;//SRAM无效 
					
									State <= stWaitForEscape;	// Look for an escape sequence
									returnState <= stCheckForNewPage;// Check for start of field 0
								end
							else
								State <= stIdle;
						end

					stWaitForEscape://Look for the first character in the sequence, keep looking until found
						begin										
						if (vpo_dly1 == 8'hFF)
							begin															
								State <= stCheckEscape1;				
							end
						else
							State <= stWaitForEscape;
							
						end
						
					stCheckEscape1://Second character in the escape sequence is 0	
						begin										
						if (vpo_dly1 == 8'h00)
							State <= stCheckEscape2;
						else
							State <= stError;
						end

					stCheckEscape2://Third charcter in the escape sequence is 0.  Go to returnState to check SAV/EAV code
						if (vpo_dly1 == 8'h00)
							State <= returnState;
						else
							State <= stError;

					stCheckForNewPage://Wait for an SAV or EAV in field 0 while in the vertical blanking stage
						if (vpo_dly1[6:5] == 2'b01) //If it is then wait until the first line of active video
							begin
								State <= stWaitForEscape;
								returnState <= stCheckForFirstLine;																										
								
								//initialise all counters for a new frame
								cntr_hori_byte <= 10'h000;
								cntr_hori_word <= 10'h000;//	360;//
								cntr_vert <= 10'h000;//	287;//
								pixel_cnt<= 10'hfff;
							end
						else  //Look for another SAV/EAV until we find the type we want.
							begin
								State <= stWaitForEscape;
								returnState <= stCheckForNewPage;
							end

					stCheckForFirstLine://Wait for an SAV in field 0 while in the active video region
					begin
						if (vpo_dly1[6:4] == 3'b000)  //start recording data
							begin
								State <= stChromaBlue;
								//进之前检测是否计满1440个数
							end
						else  //Look for another SAV/EAV until we find the type we want.
							begin
								State <= stWaitForEscape;
								returnState <= stCheckForFirstLine;
							end
					end
					//处理Cr分量或Br分量
					stChromaBlue://This may be the start of another pair of pixels or the end of data
					begin																							
						if (vpo_dly1 == 8'hFF) //If the byte is FF then it is the start of the EAV.
							begin
								State <= stCheckEscape1;//Go to second state of subroutine
								returnState <= stCheckForEndLine;//Check if this is the last line of the field
										
								ce_sram12 <= 1'b1;//SRAM无效//ce_sram12该成ce_sram12								
							end
						else if (vpo_dly1 == 8'h00)
							State <= stError;										
						else //latch data into register and continue
							begin
								State <= stChromaRed;
								
								ce_sram12 <= 1'b0;//SRAM有效	 //ce_sram12改为SRAM片选																																																
								UB_data <= vpo_dly1;	//16bits存储到SRAM						
								cntr_hori_byte <= cntr_hori_byte+1;//记录有效数据个数，从0开始到1439
								
								we_sram12 <= 1'b1;//
							end
					end					
					//处理Y分量
					stChromaRed://As long as valid data is present continue latching data and setup to write current data
						if ((vpo_dly1 !== 8'hFF) && (vpo_dly1 !== 8'h00))//感觉这里应该把00去除
							begin							   															
								data_sram12[7:0] <= vpo_dly1;//写入数据16bits
								data_sram12[15:8] <= UB_data; 								
								
								cntr_hori_byte <= cntr_hori_byte+1;								
								State <= stChromaBlue;	
								//先产生数据，在产生地址，在产生写信号。写信号维持时间长一些，直到下次数据写入前再无效
								//这样保证了数据的稳定性。
								addr_sram12 <= (20'h40000*(field)) +(720*(cntr_vert) + cntr_hori_word);	//把360改为了720
								oe_sram12 <= 1'b1;
								we_sram12 <= 1'b0;								
								
								cntr_hori_word <= cntr_hori_word+1;//记录16位数据，用来进行地址增量，0到719							
							end
						else
							State <= stError;

					stCheckForEndLine://possible conditions here are the end of field 0, end of field 1,or an EAV code indicating a new line in the active region.					
					begin															 
						if (vpo_dly1[6:4] == 3'b111) //end of field 1
							begin
								State <= stIdle;						
								
								field <= 0;//将场标志位改为0
								//initialize all counters for field 0
								cntr_hori_byte <= 10'h000;
								cntr_hori_word <= 10'h000;//720;//	
								cntr_vert <= 10'h000;//287;//
								pixel_cnt <= 10'hfff;
							end
						else if (vpo_dly1[6:4] == 3'b011) //end of field 0
							begin
								State <= stWaitForEscape;
								returnState <= stCheckForNewLine;//start capture at first new line
								
								field <= 1;	  //下一场为奇场
								
								//initialize all counters for field 1
								cntr_hori_byte <= 10'h000;
								cntr_hori_word <= 10'h000; // 360;//
								cntr_vert <= 10'h000;//287;// 
								pixel_cnt <= 10'hfff;
							end
						else if (vpo_dly1[5:4] == 2'b01) //end of line
								begin	
									pixel_cnt <= 10'hfff;		
									cntr_hori_byte <= 10'h000;
									cntr_hori_word <= 10'h000;//720;//		//为新的行初始化计数器
									cntr_vert <= cntr_vert + 1;									
																								
									State <= stWaitForEscape;
									returnState <= stCheckForNewLine;//capture next line from start
					
								end
							else // EAV expected but SAV received
								State <= stError;
					end
					stCheckForNewLine://Wait until an SAV in the active video range arrives
					begin						
						if (vpo_dly1[5:4] == 2'b00)
							begin
								State <= stChromaBlue;// capture next line

								ce_sram12 <= 1'b0;
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
								ce_sram12 <= 1'b1; 
						
								State <= stError;
								error <= 1'b1;//indicate error on error LED
							end

					default:
						State <= stError;
				endcase
			end
		end
endmodule
