`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:    13:31:48 09/08/10
// Design Name:    
// Module Name:    bus_control
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

module bus_control(
							sram_flag,
							data_CH1,addr_CH1,ce_CH1,oe_CH1,we_CH1,
							data_CH2,addr_CH2,ce_CH2,oe_CH2,we_CH2,
							sram1_Ab,sram1_Db,sram1_ce,sram1_we,sram1_oe,
							sram2_Ab,sram2_Db,sram2_ce,sram2_we,sram2_oe
							);
	
	input	sram_flag;

	//DA
	input		[19:0] addr_CH1;
	input		ce_CH1;
	input		oe_CH1;
	input		we_CH1;
	output	[15:0]data_CH1;
	
	//AD
	input		[19:0]addr_CH2;	
	input		ce_CH2;
	input		oe_CH2;
	input		we_CH2;
//	inout		[15:0]data_CH2;
	input		[15:0]data_CH2;
		
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
	
	//SRAM1 接口控制
	assign	sram1_Ab = (sram_flag)?addr_CH2:addr_CH1;
	assign	sram1_ce = (sram_flag)?ce_CH2:ce_CH1;	
	assign	sram1_we = (sram_flag)?we_CH2:we_CH1;
	assign	sram1_oe	= (sram_flag)?oe_CH2:oe_CH1;
	assign	sram1_Db = (sram_flag)?data_CH2:16'hzzzz; 
	//SRAM2 接口控制
	assign	sram2_Ab = (!sram_flag)?addr_CH2:addr_CH1;
	assign	sram2_ce = (!sram_flag)?ce_CH2:ce_CH1;	
	assign	sram2_we = (!sram_flag)?we_CH2:we_CH1;
	assign	sram2_oe	= (!sram_flag)?oe_CH2:oe_CH1;
	assign	sram2_Db = (!sram_flag)?data_CH2:16'hzzzz; 
	//SRAM数据读取
	assign 	data_CH1 = (sram_flag)?sram2_Db:sram1_Db;
//	assign 	data_CH2 = (oe_CH2==0&&ce_CH2==0)?((sram_flag)?sram1_Db:sram2_Db):16'hzzzz;

endmodule
