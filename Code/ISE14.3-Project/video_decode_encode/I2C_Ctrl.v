`include "timescale.v"
// synopsys translate_on

`include "i2c_master_defines.v"
////////////////////////////////////////////////////////////////////////////////
// Create Date:    14:20:55 01/06/07
// Design Name:    
// Module Name:    I2C_Ctrl
//由于这个板子与老师所给例程对应的板子有所不同，所以有些变量可能无用，
//例如利用vedio_swich进行判断的地方可以可忽略并改成这个板子对应的视频输入
////////////////////////////////////////////////////////////////////////////////

module I2C_Ctrl(clk, rst, din, ack, err, rty, sel, rom_data,//input
						 cyc, stb, we, dout, adr, Finish,vedio_swich
						 ,re_config//re_config貌似没用
						 );//output
	 input 		clk;
    input 		rst;
	 input 		[7:0] din;
    input 		ack, err, rty;
	 input		[7:0] rom_data;
	 input		vedio_swich;	 

	 output 		sel;				  
	 output 		cyc;
	 output 		stb;
    output 		we;
    output 		dout;
    output 		adr;
	 output 		Finish;
	 output		re_config;

	 reg			[2:0]	 adr;
	 reg			[7:0]	 dout;
	 reg 			cyc, stb, we, sel, Finish;

	reg vedio_swich_dly;
	reg vedio_swich_dly1;
	reg re_config;
	reg [3:0] cnt;	
	always @(posedge clk or negedge rst)
		begin
			if(!rst)
				begin
					vedio_swich_dly <= 1'b0;
					vedio_swich_dly1 <= 1'b0;
				end
			else
				begin
					vedio_swich_dly  <= vedio_swich;
					vedio_swich_dly1 <= vedio_swich_dly;	
				end	
		end
	
		always @(posedge clk or negedge rst)
		if(!rst)
			begin
				re_config <= 1'b0;
				cnt <= 1'b0;
			end
		else 
		if((!vedio_swich_dly1&vedio_swich_dly)||(vedio_swich_dly1&!vedio_swich_dly))
			begin
				re_config <= 1'b1;
				cnt <= 1'b0;
			end
		else if (&cnt)
				re_config <= 1'b0;
				else
					cnt <= cnt+1'b1;

//	assign re_config = (!vedio_swich_dly1&vedio_swich_dly)||(vedio_swich_dly1&!vedio_swich_dly)?1'b0:1'b1;
	
	 //?	 
	 parameter PRER_LO = 3'b000;//分频寄存器低位地址
	 parameter PRER_HI = 3'b001;//高位地址
	 parameter CTR     = 3'b010;//控制寄存器地址，(7)使能位|6中断使能位|5-0其余保留位
	 parameter RXR     = 3'b011;//接受寄存器地址，(7)接受到的最后一个字节的数据
	 parameter TXR     = 3'b011;//传输寄存器地址，(7)传输地址时最后一位为读写位，1为读
	 parameter CR      = 3'b100;//命罴拇嫫鞯刂罚?	 //(7)开始|6结束|5读|4写|3应答（作为接受方时，发送应答信号，“0”为应答，“1”为不应答）|2保留位|1保留位|0中断应答位，这宋蛔远宄?	 
	 parameter SR      = 3'b100;//状态寄存器地址，(7)接受应唬?”为邮到答6ξ唬ú夹藕藕蟊湮?，结束信号后变为0﹟5俨梦粅4-2保留位|1传输中位（1表示正在传输数据，0硎传）|中断标疚?//	 parameter SR      = 3'b101;
	 parameter TXR_R   = 3'b101; // undocumented / reserved output
	 parameter CR_R    = 3'b110; // undocumented / reserved output
	 
	 reg 			[21:0] STATE;
	 //设置状态参数																										
    parameter 	 IDLE    	 = 22'b0000000000000000000001;		   //
	 parameter	 STATE1  	 = 22'b0000000000000000000010;			//
	 parameter	 STATE2  	 = 22'b0000000000000000000100;			//
	 parameter	 STATE3  	 = 22'b0000000000000000001000;			//
	 parameter 	 STATE4  	 = 22'b0000000000000000010000;			//
	 parameter 	 STATE5  	 = 22'b0000000000000000100000;			//
	 parameter 	 STATE6  	 = 22'b0000000000000001000000;			//
	 parameter 	 STATE7  	 = 22'b0000000000000010000000;			//
	 parameter 	 STATE8      = 22'b0000000000000100000000;			//
	 parameter 	 STATE9	    = 22'b0000000000001000000000;			//
	 parameter 	 STATE10     = 22'b0000000000010000000000;			//
	 parameter 	 STATE11     = 22'b0000000000100000000000;			//
	 parameter 	 STATE12     = 22'b0000000001000000000000;			//
	 parameter 	 STATE13     = 22'b0000000010000000000000;			//
	 parameter 	 STATE14     = 22'b0000000100000000000000;			//
	 parameter 	 STATE15		 = 22'b0000001000000000000000;			//
	 parameter 	 STATE16 	 = 22'b0000010000000000000000;			//
	 parameter 	 STATE17	    = 22'b0000100000000000000000;			//
	 parameter 	 STATE18 	 = 22'b0001000000000000000000;			//
	 parameter 	 STATE19 	 = 22'b0010000000000000000000;			//
	 parameter 	 STATE20 	 = 22'b0100000000000000000000;			//
	 parameter	 STATE_DELAY = 22'b1000000000000000000000;
	 parameter	 Wait_st		 = 22'b0000000000000000000000;
    parameter   STATE_finish= 22'b0000000000000000000011;
	 
	 reg	[5:0]data_cnt;
	 reg	[15:0]re_config_cnt;
	 reg	[15:0] cnt_ddd;	 //延时有利于图像稳定
	  //module body
	  always @ (posedge clk or negedge rst)// or negedge re_config)			  //复位，初始刺?	  
	  begin
	  if(!rst)
	  		begin
				STATE<=IDLE;
				adr  <= 3'bx;
			   dout <= 8'bx;
			   cyc  <= 1'b0;
			   stb  <= 1'bx;
			   we   <= 1'hx;
				sel  <= 1'bx;
				
				data_cnt <= 0;

				re_config_cnt <= 0;

				cnt_ddd <= 0;

				Finish <= 1'b0;
	      end
//	  else if(!re_config)
//	  		begin
//				STATE<=STATE10;
//				adr  <= 3'bx;
//			   dout <= 8'bx;
//			   cyc  <= 1'b0;
//			   stb  <= 1'bx;
//			   we   <= 1'hx;
//				sel  <= 1'bx;
//				
//				data_cnt <= 33;
//
//				re_config_cnt <= 0;
//
//				cnt_ddd <= 0;
//
//				Finish <= 1'b0;
//	      end
	  else 
	      case (STATE)																  
			IDLE:  begin								//初始状态
				      STATE<=STATE1;
						adr  <= 3'bx;
			         dout <= 8'bx;
			         cyc  <= 1'b0;
			         stb  <= 1'bx;
			         we   <= 1'hx;
						sel  <= 1'bx;
						
						data_cnt <= 0;

						re_config_cnt <= 0;
						cnt_ddd <= 0;
						//Finish <= 1'b0;
	             end
	      STATE1:			                     //发送时钟分频系数低位
			       begin
					 	STATE<=STATE2;
						adr  <= PRER_LO;				//输出时钟分频寄存器低位地址
			         dout <= 8'h64;	 				//50M/100K*5＝100＝h'64
			         cyc  <= 1'b1;
			         stb  <= 1'b1;
			         we   <= 1'b1;
						sel  <= 1'b1;
	             end

	      STATE2:										//等待从节愕应答信?			       
					begin
					 	if(~ack)
						   STATE<=STATE2;
	               else
							begin
								STATE<=STATE3;				//收应?
							end
							
					 end
			STATE3:									 	//返回初始状态
			       begin
					   STATE<=STATE4;
						cyc  <= 1'b0;
			         stb  <= 1'bx;
			         adr  <= 3'bx;
			         dout <= 8'bx;
			         we   <= 1'hx;
						sel  <= 1'bx;
					 end

			STATE4:			                     //发送时钟分频系数高位
			       begin
					 	STATE<=STATE5;
						adr  <= PRER_HI;				//输出时钟分频寄存器呶坏刂?			         
						dout <= 8'h00;	 				
			         cyc  <= 1'b1;
			         stb  <= 1'b1;
			         we   <= 1'b1;
						sel  <= 1'b1;
	             end

	      STATE5:										//却咏诘愕挠Υ鹦藕?			       
					begin
					 	if(~ack)
						   STATE<=STATE5;
	               else
							begin
								STATE<=STATE6;				//收到应答	
							end
						   
	             end

	      STATE6:									 	//返回初始状态
			       begin
					   STATE<=STATE7;
						cyc  <= 1'b0;
			         stb  <= 1'bx;
			         adr  <= 3'bx;
			         dout <= 8'bx;
			         we   <= 1'hx;
						sel  <= 1'bx;
					 end

	      STATE7:                             //接口使能
			       begin
					 	STATE<=STATE8;
						adr  <= CTR; 					//输出控制寄存器刂?			         
						dout <= 8'h80;					//8'b1000_0000,即CTR[7] = 1接口使能
			         cyc  <= 1'b1;
			         stb  <= 1'b1;
			         we   <= 1'b1;
						sel  <= 1'b1;
					 end

	      STATE8:	                          	//等待从节点的应答信号
			       begin
					 	if(~ack)
						   STATE<=STATE8;
	               else
						   STATE<=STATE9;				//收到应答
	             end
	      STATE9:		 								//返回初始状态
			       begin
					   STATE<=STATE10;
						cyc  <= 1'b0;
			         stb  <= 1'bx;
			         adr  <= 3'bx;
			         dout <= 8'bx;
			         we   <= 1'hx;
						sel  <= 1'bx;
					 end

	      STATE10:		                     	//发送数据
			       begin
					   STATE<=STATE11;
						adr  <= TXR;
						
						case(data_cnt)
//						'd0:	dout <= 8'h40;//rom_data;
//						'd1:  dout <= 8'h00;//rom_data;
//						'd2:  dout <= (vedio_swich_dly1)? 8'h03:8'h00;	
						'd0:	dout <= 8'h40;
						'd1:	dout <= 8'h04;
						'd2:  dout <= 8'h53;//57
						'd3:  dout <= 8'h40;
						'd4:  dout <= 8'h17;
						'd5:	dout <= 8'h41;
						'd6:  dout <= 8'h40;
						'd7: dout <= 8'h31;
						'd8: dout <= 8'h02;//rom_data;
						'd9: dout <= 8'h40;//rom_data;
						'd10: dout <= 8'h3d;
						'd11: dout <= 8'ha2;
						'd12: dout <= 8'h40;
						'd13: dout <= 8'h3e;
						'd14: dout <= 8'h6a;
						'd15: dout <= 8'h40;
						'd16: dout <= 8'h3f;
						'd17: dout <= 8'ha0;//rom_data;
						'd18: dout <= 8'h40;//rom_data;
						'd19: dout <= 8'h0e;
						'd20: dout <= 8'h80;
						'd21: dout <= 8'h40;
						'd22: dout <= 8'h55;
						'd23: dout <= 8'h81;
						'd24: dout <= 8'h40;
						'd25: dout <= 8'h0e;
						'd26: dout <= 8'h00;
						'd27: dout <= 8'h40;
						'd28: dout <= 8'hf4;
						'd29: dout <= 8'haa;
						'd30: dout <= 8'h40;
						'd31: dout <= 8'hc4;
						'd32: dout <= 8'h80;//MAN_MUX_EN = 1
						'd33: dout <= 8'h40;
						'd34: dout <= 8'hc3;
						'd35: dout <= 8'h01;//(vedio_swich_dly1)?8'h04:8'h01;这个板子只连接了AIN1
						
						default: dout <= 8'bx;
						endcase

			         cyc  <= 1'b1;
			         stb  <= 1'b1;
			         we   <= 1'b1;
						sel  <= 1'b1;
					 end

	      STATE11:                             //等待从节点的应答信号
			       begin
					 	if(~ack)
						   STATE<=STATE11;
	               else
						   begin
						      STATE<=STATE12;		//盏?						      
	                  end
	             end
	      STATE12:							      	//返回初始状态
			       begin
					   STATE<=STATE13;
						cyc  <= 1'b0;
			         stb  <= 1'bx;
			         adr  <= 3'bx;
			         dout <= 8'bx;
			         we   <= 1'hx;
						sel  <= 1'bx;
	             end

			STATE13:		                    		//发送命令
			       begin
					   STATE<=STATE14;
						adr  <= CR;
			         
						case(data_cnt)
						'd0:	dout <= 8'h90;//rom_data;
						'd1:  dout <= 8'h10;//rom_data;
						'd2:  dout <= 8'h50;								
						'd3:	dout <= 8'h90;
						'd4:	dout <= 8'h10;
						'd5:  dout <= 8'h50;
						'd6:  dout <= 8'h90;
						'd7:  dout <= 8'h10;
						'd8:	dout <= 8'h50;
						'd9:  dout <= 8'h90;
						'd10: dout <= 8'h10;
						'd11: dout <= 8'h50;//rom_data;
						'd12: dout <= 8'h90;//rom_data;
						'd13: dout <= 8'h10;
						'd14: dout <= 8'h50;
						'd15: dout <= 8'h90;
						'd16: dout <= 8'h10;
						'd17: dout <= 8'h50;
						'd18: dout <= 8'h90;
						'd19: dout <= 8'h10;
						'd20: dout <= 8'h50;//rom_data;
						'd21: dout <= 8'h90;//rom_data;
						'd22: dout <= 8'h10;
						'd23: dout <= 8'h50;
						'd24: dout <= 8'h90;
						'd25: dout <= 8'h10;
						'd26: dout <= 8'h50;
						'd27: dout <= 8'h90;
						'd28: dout <= 8'h10;
						'd29: dout <= 8'h50;
						'd30: dout <= 8'h90;
						'd31: dout <= 8'h10;
						'd32: dout <= 8'h50;
						'd33: dout <= 8'h90;
						'd34: dout <= 8'h10;
						'd35: dout <= 8'h50;
						default: dout <= 8'bx;
						endcase
							
			         cyc  <= 1'b1;
			         stb  <= 1'b1;
			         we   <= 1'b1;
						sel  <= 1'b1;
					 end

	      STATE14:										//等待从节点的应答信号
			       begin
					 	if(~ack)
						   STATE<=STATE14;
	               else
						   begin
						      STATE<=STATE15;		//收到应答
								data_cnt <= data_cnt + 1;
	                  end
	             end				 
			STATE15:				                             //返回初始化
		       begin
				   STATE<=STATE16;
					cyc  <= 1'b0;
		         stb  <= 1'bx;
		         adr  <= 3'bx;
		         dout <= 8'bx;
		         we   <= 1'hx;
		         sel  <= 1'bx;
             end
				 	
			STATE16:		                                   //读状态寄存器
		       begin
		         STATE<=STATE17;
		         adr  <= SR;
		         dout <= 8'bx;
		         cyc  <= 1'b1;
		         stb  <= 1'b1;
		         we   <= 1'b0;
		         sel  <= 1'b1;
             end
			STATE17:										//等待从节点的应答信号
			       begin
					 	if(~ack)
						   STATE<=STATE17;
	               else
						   begin
						      STATE<=STATE18;		//收到应答
								
	                  end
	             end				 

      	STATE18:														
		       	begin
				   	cyc  <= 1'b0;					//返回初始状态
			         stb  <= 1'bx;
			         adr  <= 3'bx;
			         dout <= 8'bx;
			         we   <= 1'hx;
						sel  <= 1'bx;

					   if(din[1])						 //检查传输是否结束
					       STATE<=STATE16;
	               else
						    STATE<=STATE19;
             	end
	      STATE19:		                    		
			       begin									
						if(data_cnt== 'd36)		//是否⑼?0个数据
						  begin
						  	STATE<=Wait_st;				//配置完成，胪Ｖ棺刺?
						  end
						else
							STATE<=STATE10;
						  				//没有配置完，继续配置
	             end
			Wait_st:
					begin
						if(&cnt_ddd)
						begin
							STATE<=STATE20;//STATE_finish;//
				
							cnt_ddd <= 0;
						end
						else
						begin
							STATE<=Wait_st;
							cnt_ddd <= cnt_ddd +1;
						end		
					end
//			STATE_finish:										//停棺刺?			       
//					begin					 	
//							STATE<=STATE_finish;
//							Finish <= 1'b1;	
//	             end
	      STATE20:										//停止状态
			       begin
					 	if(re_config)
							begin
								STATE<=STATE_DELAY;
							end
						else
							begin
								STATE<=STATE20;
								Finish <= 1'b1;	
							end
	             end
			STATE_DELAY:
				begin
					if(&re_config_cnt)
						begin
							STATE <= IDLE;
							Finish <= 1'b0;
							re_config_cnt <= 0;
							
							STATE<=STATE10;
							data_cnt <= 33;

							adr  <= 3'bx;
							dout <= 8'bx;
							cyc  <= 1'b0;
							stb  <= 1'bx;
							we   <= 1'hx;
							sel  <= 1'bx;				
						end
					else
						begin
							STATE<=STATE_DELAY;
							re_config_cnt <= re_config_cnt + 1;	
						end
				end
	      default: STATE<=IDLE;//STATE<=STATE20;
	     endcase
	   end
			
endmodule  
