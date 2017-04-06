`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:    13:25:01 07/28/09
// Design Name:    
// Module Name:    adv7180_config_top
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
module adv7180_config_top(rst,clk, //input
					ADV7180_SCL,ADV7180_SDA,finish);//output
//	
	input rst;
	input clk;
	
	output ADV7180_SCL;
	output ADV7180_SDA;
	output finish;

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
	//wire	ADV7180_SCL = scl_oen ? 1'bz : scl_o;
	wire	ADV7180_SDA = sda_oen ? 1'bz : sda_o;
	wire  ADV7189_SCL = scl_oen ? 1'bz : scl_o;
//	//wire ADV7180_SDA;
//	if(scl_oen)
//		wire ADV7180_SDA = 1'bz;
//	else 
//		wire ADV7180_SDA = scl_o;


	//连接I2C总线模块
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

										.sda_pad_i(ADV7180_SDA),
									   .scl_pad_i(ADV7180_SCL),									

										.scl_pad_o(scl_o),
										.scl_padoen_o(scl_oen),
										.sda_pad_o(sda_o),
										.sda_padoen_o(sda_oen)
										);
	//连接控制模块
	I2C_Ctrl	Control_module(
							         .clk(clk),
										.rst(rst),
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
										.Finish(finish)
									 	);

endmodule
