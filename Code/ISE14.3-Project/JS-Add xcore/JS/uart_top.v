`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:    13:09:19 10/28/08
// Design Name:    
// Module Name:    uart_top
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
module uart_top(
					clk, rst,
					rxd, txd,
					db, ab, cs_n, wr_n, rd_n, 
					MZJ_SWICH_Z_FMZJZH,MZJ_SWICH_XXCFW,MZJ_SWICH_FHZM,MZJ_SWICH_CJJSMKG,MZJ_SWICH_WGMZJFHZM,
					MZJ_LXBBSL,MZJ_LXBBSL_BUSY,MZJ_LXBBSL_CLR,
					MZJ_WGMZJDY,MZJ_WGMZJDY_BUSY,MZJ_WGMZJDY_CLR,
					CZT_SWICH_HPJFBX,CZT_SWICH_BLJQBX,CZT_SWICH_SPXZDQD,CZT_SWICH_SPXBZDQD,CZT_SWICH_JGCJFS,CZT_SWICH_BLJQJF,CZT_SWICH_HPJF,
					CZT_GAODI,CZT_GAODI_JIAOYAN,CZT_FANGXIANG,CZT_FANGXIANG_JIAOYAN,
					GDJ_SWICH_JF,GDJ_SWICH_JT,GDJ_SWICH_ZY,
					GDJ_GAODI,GDJ_GAODI_BUSY,GDJ_GAODI_CLR,
					FXJ_SWICH_JF,FXJ_SWICH_SDZH,FXJ_SWICH_PTGDQ,
					FXJ_FANGXIANG,FXJ_FANGXIANG_BUSY,FXJ_FANGXIANG_CLR,
					PDH_SWICH_DY,PDH_SWICH_JSJ,PDH_SWICH_PT,PDH_SWICH_PK,
					hk_rxd,hk_txd					
					);

input		clk;
input 	rst;

input 	rxd;
output 	txd;

output	[19:0] ab;
output	cs_n,wr_n,rd_n;
inout		[7:0]	db;

input 	MZJ_SWICH_Z_FMZJZH; 
input		MZJ_SWICH_XXCFW; 
input 	MZJ_SWICH_FHZM; 
input 	MZJ_SWICH_CJJSMKG; 
input 	MZJ_SWICH_WGMZJFHZM;
 
input 	[7:0]MZJ_LXBBSL; 
input 	MZJ_LXBBSL_BUSY; 
input 	MZJ_LXBBSL_CLR;
 
input 	[7:0]MZJ_WGMZJDY; 
input 	MZJ_WGMZJDY_BUSY; 
input 	MZJ_WGMZJDY_CLR; 
input 	CZT_SWICH_HPJFBX; 
input 	CZT_SWICH_BLJQBX; 
input 	CZT_SWICH_SPXZDQD; 
input 	CZT_SWICH_SPXBZDQD; 
input 	CZT_SWICH_JGCJFS; 
input 	CZT_SWICH_BLJQJF; 
input 	CZT_SWICH_HPJF; 
input 	[10:0]CZT_GAODI; 
input 	CZT_GAODI_JIAOYAN; 
input 	[10:0]CZT_FANGXIANG; 
input 	CZT_FANGXIANG_JIAOYAN; 
input 	GDJ_SWICH_JF;
input 	GDJ_SWICH_JT; 
input 	GDJ_SWICH_ZY; 
input 	[7:0]GDJ_GAODI; 
input 	GDJ_GAODI_BUSY; 
input 	GDJ_GAODI_CLR; 
input 	FXJ_SWICH_JF; 
input 	FXJ_SWICH_SDZH; 
input 	FXJ_SWICH_PTGDQ; 
input 	[7:0]FXJ_FANGXIANG; 
input 	FXJ_FANGXIANG_BUSY; 
input 	FXJ_FANGXIANG_CLR; 
input 	PDH_SWICH_DY; 
input 	PDH_SWICH_JSJ; 
input 	PDH_SWICH_PT; 
input 	[2:0]PDH_SWICH_PK;

input		hk_rxd;
output	hk_txd; 
	

wire		clk_baud;

wire		cs_sram;
wire		wr_sram;
wire		rd_sram;
wire		[7:0]data_sram;
wire		[19:0]addr_sram;
wire		sram_data_ready;

wire		start_dc;

wire		data_send_over;

wire		[5:0]addra;
wire		[5:0]addrb;
wire		clka;
wire		clkb;
wire		[7:0]dina;
wire		[7:0]dinb;
wire		[7:0]douta;
wire		[7:0]doutb;
wire		wea;
wire		web;

wire		dram_read_en;

uart_if uart_ifuu(
							.clk(clk_sample),
							.rst(rst),
							.txd(txd),
							.rxd(rxd),

							.start_dc(start_dc),
							.sram_data_ready(sram_data_ready),
			
							.cs_sram(cs_sram),
							.wr_sram(wr_sram),
							.rd_sram(rd_sram),
							.data_sram(data_sram),
							.addr_sram(addr_sram),//code
							.ab(ab),
							.db(db),
							.cs_n(cs_n),
							.wr_n(wr_n),
							.rd_n(rd_n),
							.data_send_over(data_send_over)
							);
clk_div	clk_divuu(
						.clk(clk),
						.rst(rst),
						.clk_sample(clk_sample)
						);

data_collection	data_collectionuu(
								 .clk(clk_sample), 
								 .rst(rst), 
								 .start_dc(start_dc), 
								 .sram_data_ready(sram_data_ready), 

                         .cs_sram(cs_sram), 
								 .wr_sram(wr_sram), 
								 .rd_sram(rd_sram), 
								 .data_sram(data_sram), 
								 .addr_sram(addr_sram),

								 .data_send_over(data_send_over),

								 .MZJ_SWICH_Z_FMZJZH(MZJ_SWICH_Z_FMZJZH),
								 .MZJ_SWICH_XXCFW(MZJ_SWICH_XXCFW),
								 .MZJ_SWICH_FHZM(MZJ_SWICH_FHZM),
								 .MZJ_SWICH_CJJSMKG(MZJ_SWICH_CJJSMKG),
								 .MZJ_SWICH_WGMZJFHZM(MZJ_SWICH_WGMZJFHZM),
								 .MZJ_LXBBSL(MZJ_LXBBSL),
								 .MZJ_LXBBSL_BUSY(MZJ_LXBBSL_BUSY),
								 .MZJ_LXBBSL_CLR(MZJ_LXBBSL_CLR),
								 .MZJ_WGMZJDY(MZJ_WGMZJDY),
								 .MZJ_WGMZJDY_BUSY(MZJ_WGMZJDY_BUSY),
								 .MZJ_WGMZJDY_CLR(MZJ_WGMZJDY_CLR),
								 .CZT_SWICH_HPJFBX(CZT_SWICH_HPJFBX),
								 .CZT_SWICH_BLJQBX(CZT_SWICH_BLJQBX),
								 .CZT_SWICH_SPXZDQD(CZT_SWICH_SPXZDQD),
								 .CZT_SWICH_SPXBZDQD(CZT_SWICH_SPXBZDQD),
								 .CZT_SWICH_JGCJFS(CZT_SWICH_JGCJFS),
								 .CZT_SWICH_BLJQJF(CZT_SWICH_BLJQJF),
								 .CZT_SWICH_HPJF(CZT_SWICH_HPJF),
								 .CZT_GAODI(CZT_GAODI),
								 .CZT_GAODI_JIAOYAN(CZT_GAODI_JIAOYAN),
								 .CZT_FANGXIANG(CZT_FANGXIANG),
								 .CZT_FANGXIANG_JIAOYAN(CZT_FANGXIANG_JIAOYAN),
								 .GDJ_SWICH_JF(GDJ_SWICH_JF),
								 .GDJ_SWICH_JT(GDJ_SWICH_JT),
								 .GDJ_SWICH_ZY(GDJ_SWICH_ZY),
								 .GDJ_GAODI(GDJ_GAODI),
								 .GDJ_GAODI_BUSY(GDJ_GAODI_BUSY),
								 .GDJ_GAODI_CLR(GDJ_GAODI_CLR),
								 .FXJ_SWICH_JF(FXJ_SWICH_JF),
								 .FXJ_SWICH_SDZH(FXJ_SWICH_SDZH),
								 .FXJ_SWICH_PTGDQ(FXJ_SWICH_PTGDQ),
								 .FXJ_FANGXIANG(FXJ_FANGXIANG),
								 .FXJ_FANGXIANG_BUSY(FXJ_FANGXIANG_BUSY),
								 .FXJ_FANGXIANG_CLR(FXJ_FANGXIANG_CLR),
								 .PDH_SWICH_DY(PDH_SWICH_DY),
								 .PDH_SWICH_JSJ(PDH_SWICH_JSJ),
								 .PDH_SWICH_PT(PDH_SWICH_PT),
								 .PDH_SWICH_PK(PDH_SWICH_PK),
								 .ram_addr(addrb),
								 .ram_din(dinb),
								 .ram_dout(doutb),
								 .ram_we(web),
								 .dram_read_en(dram_read_en)
								 );
	hk_uart_ram		hk_uart_ramuu(
											.addra(addra),
											.addrb(addrb),
											.clka(clka),
											.clkb(clkb),
											.dina(dina),
											.dinb(dinb),
											.douta(douta),
											.doutb(doutb),
											.wea(wea),
											.web(web)
										  );
	hk_uart_if		hk_uart_ifuu(
											.clk(clk_sample), 
											.rst(rst),
											.hk_rxd(hk_rxd),
											.hk_txd(hk_txd),
											.ram_addr(addra),
											.ram_din(dina),
											.ram_dout(douta),
											.ram_we(wea),
											.dram_read_en(dram_read_en)
										);


endmodule
