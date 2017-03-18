`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:    13:56:51 07/28/09
// Design Name:    
// Module Name:    adv7179_config_top
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
module adv7179_config_top( rst, clk, 
									ADV7179_SCL, ADV7179_SDA, ADV7179_RST, finish7179
								  );
	input	rst;
	input	clk;
	
	output	ADV7179_SCL;
	output	ADV7179_SDA;
	output	ADV7179_RST;

	output	finish7179;

//	reg		adv7179_reset_done;
	
	//定义内部线网参数
	wire ack;
	wire [2:0] adr;
	wire [7:0] dat_i;
	wire [7:0] dat_o; 
	wire cyc;
	wire stb;
	wire we;

	wire scl_o;
	wire sda_o;
	wire scl_oen;
	wire sda_oen;

		//三态缓冲输出
	wire	ADV7179_SCL = scl_oen? 1'bz : scl_o;
	wire	ADV7179_SDA = sda_oen? 1'bz : sda_o;
	
   //产生ADV7179的复位信号，5ms，配合ADV7179外部RC硬件电路
	wire	rst7179;
	wire	rst_dly;
	filter rst_dly_module(
						.clk(clk),
						.rst_in(rst),
						.rst_out1(rst7179),
						.rst_out2(rst_dly)
						);
	assign ADV7179_RST = rst7179;//rst;

	i2c_master_top I2C_module(
				                  .wb_clk_i(clk),
									   .wb_rst_i(1'b0), //低，同步复位无效
									   .arst_i(rst),
									   .wb_adr_i(adr[2:0]),
									   .wb_dat_i(dat_o),
									   .wb_dat_o(dat_i),
									   .wb_we_i(we),
									   .wb_stb_i(stb),									
									   .wb_cyc_i(cyc),
									   .wb_ack_o(ack),				
										.wb_inta_o(),

										.sda_pad_i(ADV7179_SDA),
									   .scl_pad_i(ADV7179_SCL),									
										.scl_pad_o(scl_o),
										.scl_padoen_o(scl_oen),
										.sda_pad_o(sda_o),
										.sda_padoen_o(sda_oen)
										);
	//连接控制模块
	I2C_CTRL7179	Contro_modulel7179(
							         .clk(clk),
										.rst(rst_dly),
										.adr(adr[2:0]),
										.din(dat_i),
										.dout(dat_o),
										.cyc(cyc),
										.stb(stb),
										.we(we),
										.ack(ack),
										.sel(),
										.err(1'b0),
										.rty(1'b0),
										.Finish(finish7179)
									 	);
endmodule
