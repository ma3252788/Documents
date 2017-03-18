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
module SAA7113_decode(
							reset,llck,vpo,capture,error,flag,/*field,intFrame,*/Img_mean,Iris_int,
							RAM_OE,RAM_WE,RAM_CE,laddr,ldata,

							enhance_enable, 

							addr_4newtable, data_4newtable,

							max_gray

							,vpo_dly,vpo_dly1,vpo_dly2
							);
		input reset;			//异步复位
		//from SAA7113
		input llck;				//SAA7180 video clock (27 MHz)                
		input [7:0] vpo;		//vpo data from SAA7180
		input capture;			//flag for grab video data
		//to ram
		output error;				//state indicator,to LED
		output RAM_OE;				//双口RAM使能
		output RAM_WE;				//双口RAM写
		output RAM_CE;
		output [19:0] laddr;		//address bus
		output [15:0] ldata;		//data bus

		output	flag;
//		output	field;
//		output	intFrame;
		output	Iris_int;
		output	[7:0] Img_mean; //图像均值输出

		output	[7:0] max_gray; //最大灰度值，用于增强
		reg	[7:0] max_gray;
		reg	[7:0] max_gray_buff;
//		reg	max_gray_int;

		//增强使能
		input		enhance_enable;

		//读新灰度级表
		output	[9:0]	addr_4newtable;		 
		input		[7:0] data_4newtable;				 	
		
		output	[7:0]vpo_dly;
		output	[7:0]vpo_dly1;
		output	[7:0]vpo_dly2;
				
		//地址乒乓切换
		reg	[7:0] data_enhanced;
		wire	[7:0]	addr_4newtable_tmp;
		reg	[7:0]	addr_4newtable_tmppp;
//reg	[7:0]	addr_4newtable_tmp;					
		assign	addr_4newtable = (512*(!flag)) + addr_4newtable_tmp;//(1024*(!flag)) + 256*field + addr_4newtable_tmp;		
		
		//帧中断脉冲
//		reg	intFrame;
		reg Iris_int;

		//整帧均值输出
		reg	[31:0]Img_mean_buff;
		assign	Img_mean = (Img_mean_buff>>17);//除以512*256
		 	
		//output registers
		//to SRAM
		reg [19:0] laddr;
		reg [15:0] ldata;
		reg RAM_OE;
		reg RAM_WE;
		reg RAM_CE;
		reg [7:0]LB_data;

		reg error;																    

		//视频数据缓冲
		reg		[7:0]	vpo_dly;
		reg		[7:0]	vpo_dly1;
		reg		[7:0]	vpo_dly2;
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
		
		//水平、垂直计数器
		reg [9:0] cntr_hori;//counter for horizon 720
		reg [9:0] cntr_vert;//counter for vertical 576
		reg [19:0] cntr_pixel;

		//乒乓存储算法标志
		reg flag;
		//场标志
		reg field;
		
		//增强使能时，输出读取新灰度双口RAM的地址,在数据输出之前建立了
		assign	addr_4newtable_tmp = (enhance_enable && (State==stChromaBlue || State==stChromaRed))?vpo_dly:addr_4newtable_tmppp;
//		assign	addr_4newtable_tmp = (enhance_enable && (State==stLumaBlue || State==stLumaRed))?vpo_dly1:8'h00;

		wire [19:0] paraSUM_neg=(field==1'b0)? 20'h329FF :20'h653FF ; 
		//Video decoder
		//grab data from vpo bus
		always @(posedge llck or negedge reset)
		begin
			if (!reset)
				begin
					State <= stIdle;						
					returnState <= stIdle;							
				
					cntr_hori <= 10'h000;
					cntr_vert <= 10'h00;
					cntr_pixel <= 20'h00000;

//					intFrame <= 1'b0;
					Img_mean_buff <= 32'h00000000;

					flag <= 1'b0;//乒乓标志，用于控制SRAM切换
					field <= 1'b0;	//场标志
					Iris_int <= 1'b0;	 //调光中断标志

					error <= 1'b0;

					//RAM无效
					RAM_OE <= 1'b1; 
					RAM_WE <= 1'b1;
					RAM_CE <= 1'b1;					

					max_gray <= 8'h00;
					max_gray_buff<=8'h00;
//					max_gray_int<=0;

					laddr <=	20'hxxxxx;	
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
									cntr_hori <= 10'h000;//	719;//
									cntr_vert <= 10'h000;//	287;//
									cntr_pixel <= 20'h00000;

									field <= 1'b0;	//奇场标志
									
									flag <= ~flag;	 //乒乓帧切换，控制SRAM总线切换

									//初始化均值
									Img_mean_buff <= 32'h00000000;							
																									
//									intFrame <= 1'b1;//帧中断
									Iris_int <= 1'b0;	 //调光中断标志

									//RAM无效
									RAM_OE <= 1'b1; 
									RAM_WE <= 1'b1;
									RAM_CE <= 1'b1; 
									laddr	<= 20'hxxxxx;

									max_gray<=max_gray_buff;

									State <= stWaitForEscape;	// Look for an escape sequence
									returnState <= stCheckForNewPage;// Check for start of field 0
								end
							else
								State <= stIdle;
						end

					stWaitForEscape://Look for the first character in the sequence, keep looking until found
						begin		
//						intFrame <= 1'b0;
							
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
								cntr_hori <= 10'h000;//	719;//
								cntr_vert <= 10'h000;//	287;//
								cntr_pixel <= 20'h00000;
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

								RAM_CE <= 1'b0;														
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
						//写无效  
						RAM_WE <= 1'b1; 						
												
						if (vpo_dly1 == 8'hFF) //If the byte is FF then it is the start of the EAV.
							begin
								State <= stCheckEscape1;//Go to second state of subroutine
								returnState <= stCheckForEndLine;//Check if this is the last line of the field
							end
						else if (vpo_dly1 == 8'h00)
							State <= stError;			
						else //latch data into register and continue
							begin
								State <= stLumaBlue;	
								
								RAM_CE <= 1'b0;
								LB_data <= vpo_dly1;	
								
								cntr_hori <= cntr_hori+1;	//Increment horizontal counter every two pixels	
								laddr <= (20'h32A00*(field)) +(720*(cntr_vert) + cntr_hori);
//								if(field == 0)	//奇场数据正常倒转，575……3、1					 
//									laddr <= paraSUM_neg-(720*cntr_vert + cntr_hori);	 //建立地址
//								else //偶场只要2、4……574倒转，即574、……4、2、576
//								begin
//									if(cntr_vert==287)
//										laddr <= (20'h32A00*(field)) +(720*(cntr_vert) + cntr_hori);
//									else
//										laddr <= paraSUM_neg-(720*(cntr_vert+1) + cntr_hori);	
//								end

								addr_4newtable_tmppp<=addr_4newtable_tmp;																																																					 		
							end
					end
					//处理Lb分量
					stLumaBlue://As long as valid data is present continue latching data
						if ((vpo_dly1 !== 8'hFF) && (vpo_dly1 !== 8'h00))
							begin
								State <= stChromaRed;																							
								
								cntr_pixel <= cntr_pixel+1;
								//灰度累加,512*256图像区间
								if((field == 0)&&(cntr_hori>=104)&&(cntr_hori<616)&&(cntr_vert>=30)&&(cntr_vert<286))	
									Img_mean_buff <= Img_mean_buff + (vpo_dly1);

								//保存最大灰度级
								if(vpo_dly1>=max_gray_buff)
									max_gray_buff <= vpo_dly1;

								//RAM写 
								RAM_WE <= 1'b0;
								ldata[7:0] <= LB_data;
								ldata[15:8] <=  (enhance_enable)? data_4newtable : (vpo_dly1); 	// 是否增强		(255-vpo_dly) 																																																								
							end
						else
							begin								
								State <= stError;
							end
							
					//处理V分量		
					stChromaRed://As long as valid data is present continue latching data
					begin	
						//写无效  
						RAM_WE <= 1'b1; 
																													
						if ((vpo_dly1 !== 8'hFF) && (vpo_dly1 !== 8'h00))
							begin
								State <= stLumaRed;	
								
								LB_data <= vpo_dly1;		
								
								cntr_hori <= cntr_hori+1;	//Increment horizontal counter every two pixels	
								laddr <= (20'h32A00*(field)) +(720*(cntr_vert) + cntr_hori);
//								if(field == 0)	//奇场数据正常倒转，575……3、1					 
//									laddr <= paraSUM_neg-(720*cntr_vert + cntr_hori);	 //建立地址
//								else //偶场只要2、4……574倒转，即574、……4、2、576
//								begin
//									if(cntr_vert==287)
//										laddr <= (20'h32A00*(field)) +(720*(cntr_vert) + cntr_hori);
//									else
//										laddr <= paraSUM_neg-(720*(cntr_vert+1) + cntr_hori);	
//								end

								addr_4newtable_tmppp<=addr_4newtable_tmp;																										
							end
						else
							State <= stError;
					end
					//处鞮r分量
					stLumaRed://As long as valid data is present continue latching data and setup to write current data
						if ((vpo_dly1 !== 8'hFF) && (vpo_dly1 !== 8'h00))
							begin
								State <= stChromaBlue;						
								
								cntr_pixel <= cntr_pixel+1;
								//灰度累加,512*256图像区间
								if((field == 0)&&(cntr_hori>=104)&&(cntr_hori<616)&&(cntr_vert>=30)&&(cntr_vert<286))	
									Img_mean_buff <= Img_mean_buff + (vpo_dly1);

								//保存最大灰度级
								if(vpo_dly1>=max_gray_buff)
									max_gray_buff <= vpo_dly1;

								//RAM写
								RAM_WE <= 1'b0;
								ldata[7:0] <= LB_data;
								ldata[15:8] <=  (enhance_enable)? data_4newtable : (vpo_dly1); 	// 是否增强		(255-vpo_dly) 							 																																																								
							end
						else
							State <= stError;

					stCheckForEndLine://possible conditions here are the end of field 0, end of field 1,or an EAV code indicating a new line in the active region.					
					begin
						//RAM无效
						RAM_OE <= 1'b1; 
						RAM_WE <= 1'b1;
						RAM_CE <= 1'b1; 
						laddr	<= 20'hxxxxx;						
						 
						if (vpo_dly1[6:4] == 3'b111) //end of field 1
							begin
								State <= stIdle;						

								field <= 0;
								//initialize all counters for field 0
								cntr_hori <= 10'h000;//719;//	
								cntr_vert <= 10'h000;//287;//

								cntr_pixel <= 20'h00000;
							end
						else if (vpo_dly1[6:4] == 3'b011) //end of field 0
							begin
								State <= stWaitForEscape;
								returnState <= stCheckForNewLine;//start capture at first new line
							
								field <= 1;	  //下一场为偶场
								
								Iris_int <= 1'b0;	 //调光中断标志

								//initialize all counters for field 1
								cntr_hori <= 10'h000; // 719;//
								cntr_vert <= 10'h000;//287;//  

								cntr_pixel <= 20'h00000;
							end
						else if (vpo_dly1[5:4] == 2'b01) //end of line
								begin																		
									cntr_hori <= 10'h000;//719;//		//为新的行初始化计数器
									cntr_vert <= cntr_vert + 1;
									
									//输出调光中断
									if((field == 0)&&(cntr_vert==286))
									begin	
										Iris_int <= 1'b1;	 //调光中断标志
									end
																								
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

								RAM_CE <= 1'b0;	
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
//								intFrame <= 1'b0;

								//RAM无效
								RAM_OE <= 1'b1; 
								RAM_WE <= 1'b1;
								RAM_CE <= 1'b1; 
								laddr	<= 20'hxxxxx;

								State <= stError;
								error <= 1'b1;//indicate error on error LED
							end

					default:
						State <= stError;
				endcase
			end
		end


endmodule

