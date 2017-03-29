`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Create Date:    13:04:30 12/15/2016 
// Design Name: 
// Module Name:    sram_bus_control 
//////////////////////////////////////////////////////////////////////////////////
module sram_bus_control(
							sram_flag,
							dataout_CH1,addr_CH1,ce_CH1,oe_CH1,we_CH1,
							datain_CH2,addr_CH2,ce_CH2,oe_CH2,we_CH2,
							data_pro,dataout_pro,addr_pro,ce_pro,oe_pro,we_pro,
							
							sram1_Ab,sram1_Db,sram1_ce,sram1_we,sram1_oe,
							sram2_Ab,sram2_Db,sram2_ce,sram2_we,sram2_oe,
							sram3_Ab,sram3_Db,sram3_ce,sram3_we,sram3_oe,
							sram4_Ab,sram4_Db,sram4_ce,sram4_we,sram4_oe
							);
	input	sram_flag;

	//READ
	input		[19:0] addr_CH1;
	input		ce_CH1;
	input		oe_CH1;
	input		we_CH1;
	output	[15:0]dataout_CH1;
	
	//WRITE
	input		[19:0]addr_CH2;	
	input		ce_CH2;
	input		oe_CH2;
	input		we_CH2;
	input		[15:0]datain_CH2;
	
	input		[19:0]addr_pro;	
	input		ce_pro;
	input		oe_pro;
	input		we_pro;
	output	[31:0]data_pro;
	input		[31:0]dataout_pro;
	
	//sram
	output [19:0] 	sram1_Ab;
	inout  [15:0] 	sram1_Db;
	output			sram1_ce;
	output			sram1_we;
	output			sram1_oe;

	output [19:0] 	sram2_Ab;
	inout  [15:0] 	sram2_Db;
	output			sram2_ce;
	output			sram2_we;
	output			sram2_oe;
	
	output [19:0] 	sram3_Ab;
	inout  [15:0] 	sram3_Db;
	output			sram3_ce;
	output			sram3_we;
	output			sram3_oe;
	
	output [19:0] 	sram4_Ab;
	inout  [15:0] 	sram4_Db;
	output			sram4_ce;
	output			sram4_we;
	output			sram4_oe;
	
	//SRAM1 接口控制
	assign	sram1_Ab = (sram_flag)?addr_CH2:addr_CH1;
	assign	sram1_ce = (sram_flag)?ce_CH2:ce_CH1;	
	assign	sram1_we = (sram_flag)?we_CH2:we_CH1;
	assign	sram1_oe	= (sram_flag)?oe_CH2:oe_CH1;
	assign	sram1_Db = (sram_flag)?datain_CH2:16'hzzzz; 
	//SRAM2 接口控制
	assign	sram2_Ab = (!sram_flag)?addr_CH2:addr_CH1;
	assign	sram2_ce = (!sram_flag)?ce_CH2:ce_CH1;	
	assign	sram2_we = (!sram_flag)?we_CH2:we_CH1;
	assign	sram2_oe	= (!sram_flag)?oe_CH2:oe_CH1;
	assign	sram2_Db = (!sram_flag)?datain_CH2:16'hzzzz; 
	//SRAM数据读取
	assign 	dataout_CH1 = (sram_flag)?sram2_Db:sram1_Db;
	
	
	assign	sram3_Ab = addr_pro;
	assign	sram3_ce = ce_pro;	
	assign	sram3_we = we_pro;
	assign	sram3_oe	= oe_pro;
	assign	sram3_Db = ((!we_pro)&&(!ce_pro))?dataout_pro[15:0]:16'hzzzz;
	
	assign	sram4_Ab = addr_pro;
	assign	sram4_ce = ce_pro;	
	assign	sram4_we = we_pro;
	assign	sram4_oe	= oe_pro;
	assign	sram4_Db = ((!we_pro)&&(!ce_pro))?dataout_pro[31:16]:16'hzzzz;
	//SRAM数据读取
	assign 	data_pro = {sram4_Db,sram3_Db};
	


endmodule
