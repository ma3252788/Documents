`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    13:56:13 12/07/2016 
// Design Name: 
// Module Name:    top 
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
/*				

*//////////////////////////////////////////////////////////////////////////////////
module top( clk_59m, rst, 
				ADV7180_SCL, ADV7180_SDA, ADV7180_LLC, ADV7180_P, ADV7180_RST,	ADV7180_PWDOWN,
				ADV7179_SDA, ADV7179_SCL, ADV7179_RST, ADV7179_P, ADV7179_CLK, ADV7179_TTX, ADV7179_TTXREQ, ADV7179_SCRESET, ADV7179_BLANK, ADV7179_VS, ADV7179_HS,
				AD1,DA,			
				sram1_Ab,sram1_Db,sram1_ce,sram1_we,sram1_oe,sram1_LB,sram1_UB,
				sram2_Ab,sram2_Db,sram2_ce,sram2_we,sram2_oe,sram2_LB,sram2_UB,
				sram3_Ab,sram3_Db,sram3_ce,sram3_we,sram3_oe,
				sram4_Ab,sram4_Db,sram4_ce,sram4_we,sram4_oe
				);
	input  rst,clk_59m;
	//ADV7180
	input		ADV7180_P, ADV7180_LLC;
	input	 	[7:0] AD1;
	output 	ADV7180_SCL, ADV7180_SDA, ADV7180_RST, ADV7180_PWDOWN;
	//ADV7179
	input  	ADV7179_P;
	output 	ADV7179_SDA, ADV7179_SCL, ADV7179_RST, ADV7179_CLK;
	output 	ADV7179_TTX, ADV7179_TTXREQ, ADV7179_SCRESET, ADV7179_BLANK, ADV7179_VS, ADV7179_HS;
	output	[7:0] DA;
	//SRAM
	output	[19:0]sram1_Ab,sram2_Ab,sram3_Ab,sram4_Ab;	
	inout		[15:0]sram1_Db,sram2_Db,sram3_Db,sram4_Db;	
	output	sram1_ce,sram1_we,sram1_oe,sram1_LB,sram1_UB;
	output	sram2_ce,sram2_we,sram2_oe,sram2_LB,sram2_UB;
	output	sram3_ce,sram3_we,sram3_oe;
	output	sram4_ce,sram4_we,sram4_oe;
	//AD DA
	wire		ADV7180_RST = 1'b1;
	wire  	ADV7180_PWDOWN = 1'b1;
	wire		finish7180;

	wire  	ADV7179_TTX = 1'b1;	
	wire 		ADV7179_TTXREQ = 1'b1;
	wire		ADV7179_SCRESET = 1'b1;
	wire		ADV7179_BLANK = 1'b1;
	wire		ADV7179_VS = 1'b1;
	wire		ADV7179_HS = 1'b1;
	wire		ADV7179_CLK;
	wire		finish7179;
	wire		[7:0] DA;
/////////////////////////////////////////////////////////////////////////
/////system clock
	wire	clk59M_DCMed;
	wire	clk10M_DCMed;
	sys_dcm dcm59m (
									 .CLKIN_IN(clk_59m), 
									 .RST_IN(!rst), 
									 .CLKDV_OUT(clk10M_DCMed), 
									 .CLKIN_IBUFG_OUT(clk59M_DCMed)
									 );
									 	
	wire	clk27M_DCMed;
	wire	clk13_5M_DCMed;
	dcm27m dcm27m (
											 .CLKIN_IN(ADV7180_LLC), 
											 .RST_IN((!rst)),  //||(!video_switch_rst)切换时要复位DCM，否则13.5M与27M时钟对齐有问题
											 .CLKDV_OUT(clk13_5M_DCMed),
											 .CLKIN_IBUFG_OUT(clk27M_DCMed)
											 );
	//assign ADV7179_CLK = clk27M_DCMed;								 
/////////////////////////////////////////////////////////////////////////
/////configure AD&DA	
	
	adv7180_config_top 	adv7180_config_top_module(
										.rst(rst),//原来是rst && re_cfg
										.clk(clk59M_DCMed), 
										.ADV7180_SCL(ADV7180_SCL),
										.ADV7180_SDA(ADV7180_SDA),
										.finish(finish7180),
										.vedio_swich(ch_video_switch/*video_switch*/)//video_switch_dly)
										);

	adv7179_config_top 	adv7179_config(
											.rst(rst),
											.clk(clk59M_DCMed),																
											.ADV7179_SCL(ADV7179_SCL),
											.ADV7179_SDA(ADV7179_SDA),
											.ADV7179_RST(ADV7179_RST),
											.finish7179(finish7179)
											);
											
	assign	config_done = finish7180&finish7179;
	
/////////////////////////////////////////////////////////////////////////
/////7180解码，并存储到SRAM	
	wire sram_flag;
	wire ce_CH2,oe_CH2,we_CH2;
	wire [19:0]addr_CH2;
	wire [15:0]datain_CH2;
	adv7180_video_in decode (
										 .reset(rst), 
										 .llck(clk27M_DCMed), 
										 .llck_hf(clk13_5M_DCMed), 
										 .clk59m(clk59M_DCMed), 
										 .vpo(AD1), 
										 .capture(config_done), 
										 .error(), 
										 .flag(sram_flag), 
										 .field(), 
										 .ce_sram12(ce_CH2), 
										 .oe_sram12(oe_CH2), 
										 .we_sram12(we_CH2), 
										 .addr_sram12(addr_CH2), 
										 .data_sram12(datain_CH2)
										 );
			
/////////////////////////////////////////////////////////////////////////
/////7179编码，从SRAM读取			这段什么意思？？？》????????????????????????????????????????
	wire cross_output,video_zoom,video_switch;
	assign cross_output = 1;
	assign video_zoom = 0;
	assign video_switch = 1;
	
	wire [15:0]dataout_CH1;
	wire [19:0]addr_CH1;
	wire ce_CH1,oe_CH1,we_CH1;
	
	adv7179_video_out encode (
		 .clk59m(clk59M_DCMed),
		 .rst(rst),
		 .qd(AD1),
		 .clk(clk27M_DCMed),
		 .clk135(clk13_5M_DCMed), 
		 .config_done(config_done),
		 .qd_out(DA),
		 .clkout(ADV7179_CLK), 
		 .data_saaSRAM(dataout_CH1),
		 .addr_SRAM(addr_CH1),
		 .ce_saaSRAM(ce_CH1),
		 .oe_saaSRAM(oe_CH1),
		 .we_saaSRAM(we_CH1), 
		 .cross_output(cross_output),
		 .video_zoom(video_zoom),
		 .video_switch(video_switch),
		 
		 .video_pip2(),
		 .video_pip4(),
		 .video_pip8(), 
		 .rd_ce(),
		 .rd_oe(),
		 .rd_we(),
		 .rd_dout(),
		 .rd_addr(), 	     
		 .field(),
		 .line_cnt(), 
		 .enhance_enable(), 
		 .qfv()
		 );
		 
///////////////////////////////////////////////////////////////////////////
/////SRAM总线控制
	wire [19:0]sram1_Ab,sram2_Ab,sram3_Ab,sram4_Ab;
	wire [15:0]sram1_Db,sram2_D,bsram3_Db,sram4_Db;
	wire sram1_ce,sram1_we,sram1_oe;
	wire sram2_ce,sram2_we,sram2_oe;
	wire sram3_ce,sram3_we,sram3_oe;
	wire sram4_ce,sram4_we,sram4_oe;
	
	sram_bus_control sram_bus_control (
		 .sram_flag(sram_flag), 
		 .dataout_CH1(dataout_CH1),.addr_CH1(addr_CH1),.ce_CH1(ce_CH1),.oe_CH1(oe_CH1),.we_CH1(we_CH1), 
		 .datain_CH2(datain_CH2),  .addr_CH2(addr_CH2),.ce_CH2(ce_CH2),.oe_CH2(oe_CH2),.we_CH2(we_CH2), 
		 .data_pro(),.dataout_pro(),.addr_pro(),.ce_pro(),.oe_pro(),.we_pro(), 
		 .sram1_Ab(sram1_Ab),.sram1_Db(sram1_Db), .sram1_ce(sram1_ce), .sram1_we(sram1_we),.sram1_oe(sram1_oe), 
		 .sram2_Ab(sram2_Ab),.sram2_Db(sram2_Db), .sram2_ce(sram2_ce), .sram2_we(sram2_we),.sram2_oe(sram2_oe),
		 .sram3_Ab(sram3_Ab),.sram3_Db(sram3_Db), .sram3_ce(sram3_ce), .sram3_we(sram3_we),.sram3_oe(sram3_oe),
		 .sram4_Ab(sram4_Ab),.sram4_Db(sram4_Db), .sram4_ce(sram4_ce), .sram4_we(sram4_we),.sram4_oe(sram4_oe)    
		 );
	assign sram1_LB = 0;	
	assign sram1_UB = 0;
	assign sram2_LB = 0;	
	assign sram2_UB = 0;
	
///////////////////////////////////////////////////////////////////////////
/////串口通讯







endmodule
