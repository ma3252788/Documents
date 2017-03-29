`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:    17:43:15 09/07/10
// Design Name:    
// Module Name:    top
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
module top(	clk_59m,rst,
				ADV7180_SCL, ADV7180_SDA, ADV7180_LLC, ADV7180_P, ADV7180_RST,	ADV7180_PWDOWN,ADV7180_HS,ADV7180_VS,ADV7180_SFL,ADV7180_INT,
				ADDA_DONE,
				ADV7179_SDA, ADV7179_SCL, ADV7179_RST, ADV7179_P, ADV7179_CLK,ADV7179_TTX, ADV7179_TTXREQ, ADV7179_SCRESET, ADV7179_BLANK, ADV7179_VS, ADV7179_HS,

				SRAM_A_D, SRAM_A_A, SRAM_A_CE, SRAM_A_WE, SRAM_A_OE, SRAM_A_UB, SRAM_A_LB,
				SRAM_B_D, SRAM_B_A, SRAM_B_CE, SRAM_B_WE, SRAM_B_OE, SRAM_B_UB, SRAM_B_LB,

				ttl_en,enhance_enable,cross_output,video_zoom,

				test
				);

//system
input 	clk_59m;
input 	rst;

//AD7180
input		ADV7180_LLC;
input		[7:0]ADV7180_P;
input		ADV7180_HS;//no use
input		ADV7180_VS;//no use
input		ADV7180_SFL;//no use
input 	ADV7180_INT;//no use

output	ADV7180_SCL;
output	ADV7180_SDA;
output	ADV7180_RST;//always high
output	ADV7180_PWDOWN;//always high

wire		ADV7180_RST = 1'b1;
wire		ADV7180_PWDOWN = 1'b1;


//AD7179
output	ADV7179_TTX;//always low
output	ADV7179_TTXREQ;//always low.But it should be an input signal.
output	ADV7179_SCRESET;//always low
output   ADV7179_BLANK;//always low
output	ADV7179_VS;//always low
output 	ADV7179_HS;//always low
output	ADV7179_SDA;
output	ADV7179_SCL;
output	ADV7179_RST;
output	[7:0]ADV7179_P;
output	ADV7179_CLK;

wire		ADV7179_BLANK = 1'b0;
wire		ADV7179_VS = 1'b0;
wire		ADV7179_HS = 1'b0;
wire		ADV7179_SCRESET = 1'b0;
wire  	ADV7179_TTX = 1'b0;
wire 		ADV7179_TTXREQ = 1'b0;
//SRAM
output	[19:0]SRAM_A_A;
output	SRAM_A_CE;
output	SRAM_A_WE;
output	SRAM_A_OE;
output	SRAM_A_UB;
output	SRAM_A_LB;

output	[19:0]SRAM_B_A;
output	SRAM_B_CE;
output	SRAM_B_WE;
output	SRAM_B_OE;
output	SRAM_B_UB;
output	SRAM_B_LB;
	
inout		[15:0]SRAM_A_D;
inout		[15:0]SRAM_B_D;

assign	SRAM_A_UB=0;
assign	SRAM_A_LB=0;
assign	SRAM_B_UB=0;
assign	SRAM_B_LB=0;

//UART
//input		RS232_RXD1;
//output	RS232_TXD1;
//input		RS232_RXD2;
//output	RS232_TXD2;

//TEST
output 	ADDA_DONE;
output 	[7:0]test;
output 	ttl_en;
assign	ttl_en=1'b1;
input		enhance_enable,
			cross_output,
			video_zoom;


//DCM module
wire		clk27M_DCMed;
DCM27M DCM_27Muu (
   					.CLKIN_IN(ADV7180_LLC), 
    					.RST_IN(rst), 
    					.CLKIN_IBUFG_OUT(clk27M_DCMed) 
    					);
wire		 clk59M_DCMed;
DCM59M DCM_59Muu (
					    .CLKIN_IN(clk_59m), 
					    .RST_IN(rst), 
					    .CLKIN_IBUFG_OUT(clk59M_DCMed) 
					    );

///7180.7179config module
wire	finish7179;
wire	finish7180;
adv7180_config_top 	adv7180_config_top_module(
																.rst(rst),
																.clk(clk59M_DCMed), 
																.ADV7180_SCL(ADV7180_SCL),
																.ADV7180_SDA(ADV7180_SDA),
																.finish(finish7180)
																);


adv7179_config_top 	adv7179_config			(
															.rst(rst),
															.clk(clk59M_DCMed),																
															.ADV7179_SCL(ADV7179_SCL),
															.ADV7179_SDA(ADV7179_SDA),
															.ADV7179_RST(ADV7179_RST),
															.finish7179(finish7179)
															);

wire	ADDA_DONE=finish7180&finish7179;
wire 	config_done=finish7180&finish7179;


//watch dog
reg 	 [25:0]reset_cnt;
wire	 qfv;
reg	 RSTW;

always @(posedge  clk27M_DCMed or posedge qfv)
begin
	if(qfv)
		begin
			reset_cnt<=25'h0000000;	
			RSTW<=1'b1;
		end
   else
		begin
 			reset_cnt<=reset_cnt+1;	
	
			RSTW<=((reset_cnt > 45000 ) && (reset_cnt < 45002))? 1'b0:1'b1;
		end 	
end
wire	 rst_internal=RSTW&rst;





//decord module
wire		oe_sram_write_7113;
wire		we_sram_write_7113;
wire		ce_sram_write_7113;
wire 		[19:0]addr_sram_write_7113;
wire		[15:0]data_sram_write_7113;
wire		frame_sw;
wire		[9:0]addr_4newtable;
wire	 	[7:0]data_4newtable;
//wire		enhance_enable;
wire		[7:0]max_gray;
SAA7113_decode SAA7113_decode_uut(
													.reset(rst_internal),//rst), //
													.llck(clk27M_DCMed), 
													.vpo(ADV7180_P), 
													.capture(config_done), 
													.error(), 														

													.flag(frame_sw),
													.Img_mean(Img_mean), 
													.Iris_int(Iris_int), 

													//最大灰度级
													.max_gray(max_gray),	 // 

													.RAM_OE(oe_sram_write_7113), 
													.RAM_WE(we_sram_write_7113), 
													.RAM_CE(ce_sram_write_7113), 
													.laddr(addr_sram_write_7113), 							    
													.ldata(data_sram_write_7113), 

													.enhance_enable(enhance_enable), 	//enhance_enable

													.addr_4newtable(addr_4newtable), 
													.data_4newtable(data_4newtable)
											);	
											
//output module
wire		[7:0]MP_temp;
wire 		clk_temp;
Out_CTRL out_ctrl_uut(
								.clk(clk59M_DCMed), 
								.ctrl(rst&config_done),
								.clk_in(clk_temp), 
								.MP_in(MP_temp),
								.clk_out(ADV7179_CLK), 
								.MP_out(ADV7179_P)
								);

wire	 	ce_sram_read_7179;
wire		oe_sram_read_7179;
wire		we_sram_read_7179;
wire		[15:0]data_sram_read_7179;
wire		[19:0]addr_sram_read_7179;
wire		video_zoom;//zzz       video_zoom_out;
//wire		cross_output;
adv7179_video_out		adv7179_video_out_module(
															.rst(rst_internal),//rst),//	
															.config_done(config_done),				
															.qd(ADV7180_P),	
															.clk(clk27M_DCMed),			
															.qd_out(MP_temp),
															.clkout(clk_temp),

															.qfv(qfv),

															.data_saaSRAM(data_sram_read_7179),
															.addr_saaSRAM(addr_sram_read_7179),
															.ce_saaSRAM(ce_sram_read_7179),
															.oe_saaSRAM(oe_sram_read_7179),
															.we_saaSRAM(we_sram_read_7179),
															
															//zzz   .video_zoom(video_zoom_out),//video_zoom
															.video_zoom(video_zoom),
															.cross_output(cross_output),//cross_output
															.video_pip(1'b0)
															);	

bus_control 	bus_control_module(											
											.sram_flag(frame_sw), 
											
											//DA
											.data_CH1(data_sram_read_7179),
											.addr_CH1(addr_sram_read_7179),
											.ce_CH1(ce_sram_read_7179),
											.oe_CH1(oe_sram_read_7179),
											.we_CH1(we_sram_read_7179),
											
											//AD
											.addr_CH2(addr_sram_write_7113), 
											.data_CH2(data_sram_write_7113), 
											.ce_CH2(ce_sram_write_7113), 
											.oe_CH2(oe_sram_write_7113), 
											.we_CH2(we_sram_write_7113), 

											.sram1_Ab(SRAM_B_A), 
											.sram1_Db(SRAM_B_D), 
											.sram1_ce(SRAM_B_CE), 
											.sram1_we(SRAM_B_WE), 
											.sram1_oe(SRAM_B_OE),

											.sram2_Ab(SRAM_A_A), 
											.sram2_Db(SRAM_A_D), 
											.sram2_ce(SRAM_A_CE), 
											.sram2_we(SRAM_A_WE), 
											.sram2_oe(SRAM_A_OE)
											);

//增强模块
wire	[7:0]max_gray_buff;
assign max_gray_buff =(max_gray>=150)? max_gray : ( 'd200 );//	 ((max_gray<120)&&(max_gray>=80))? 180 : 
wire		[7:0]data_2newtableRAM;
wire		we_2newtableRAM;
wire		[9:0]addr_2newtableRAM;
Equilization_alg Equilization_alg_uut(														
													.rst(rst_internal), // config_done
													.qd(ADV7180_P), 
													.clk(clk27M_DCMed),
													.clk50(clk59M_DCMed),
													.config_done(config_done), 	  //config_done
													.frame_sw(frame_sw),			

													//最大灰度级
													.max_gray(255),	 //max_gray

													//写新查找表
													.gray_lookup_table(data_2newtableRAM), 
													.we(we_2newtableRAM), 
													.addr4out(addr_2newtableRAM)
												);
new_gray_table NEW_table_RAM(
										.clka(clk27M_DCMed),
										.addra(addr_2newtableRAM),
										.dina(data_2newtableRAM),
										.wea(we_2newtableRAM), 										
										
										.clkb(clk27M_DCMed),
										.addrb(addr_4newtable),
										.doutb(data_4newtable)
										);

endmodule
