`include "timescale.v"
// synopsys translate_on

`include "i2c_master_defines.v"
////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:    14:20:55 01/06/07
// Design Name:    
// Module Name:    I2C_Ctrl
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

module I2C_Ctrl(clk, rst, din, ack, err, rty, sel, rom_data,//input
						 cyc, stb, we, dout, adr, rom_addr,Finish
						 );//output
	 input 		clk;
    input 		rst;
	 input 		[7:0] din;
    input 		ack, err, rty;
	 input		[7:0] rom_data; 

	 output 		sel;
	 output  	rom_addr;				  
	 output 		cyc;
	 output 		stb;
    output 		we;
    output 		dout;
    output 		adr;
	 output 		Finish;

	 reg  		[5:0]  rom_addr;
	 reg			[2:0]	 adr;
	 reg			[7:0]	 dout;
	 reg 			cyc, stb, we, sel, Finish;

	 //?	 
	 parameter PRER_LO = 3'b000;//��Ƶ�Ĵ�����λ��ַ
	 parameter PRER_HI = 3'b001;//��λ��ַ
	 parameter CTR     = 3'b010;//���ƼĴ�����ַ��(7)ʹ��λ|6�ж�ʹ��λ|5-0���ౣ��λ
	 parameter RXR     = 3'b011;//���ܼĴ�����ַ��(7)���ܵ������һ���ֽڵ�����
	 parameter TXR     = 3'b011;//����Ĵ�����ַ��(7)�����ַʱ���һλΪ��дλ��1Ϊ��
	 parameter CR      = 3'b100;//����Ĵ�����ַ��
	 //(7)��ʼ|6����|5��|4д|3Ӧ����Ϊ���ܷ�ʱ������Ӧ���źţ���0��ΪӦ�𣬡�1��Ϊ��Ӧ��|2����λ|1����λ|0�ж�Ӧ��λ�����λ�Զ���?	 
	 parameter SR      = 3'b100;//״̬�Ĵ�����ַ��(7)����Ӧ��?��Ϊ�ʵ���|6�λ��������ʼ�źź���?�������źź��Ϊ0�|5ٲ�λ|4-2����λ|1������λ��1��ʾ���ڴ������ݣ�0�ʴ���|�жϱ��?//	 parameter SR      = 3'b101;
	 parameter TXR_R   = 3'b101; // undocumented / reserved output
	 parameter CR_R    = 3'b110; // undocumented / reserved output
	 
	 reg 			[21:0] STATE;
	 //����״̬����																										
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

	 reg	[5:0]data_cnt;
	 reg	[20:0] cnt_ddd;	 //��ʱ������ͼ���ȶ�
	  //module body
	  always @ (posedge clk or negedge rst)			  //��λ����ʼ��?	  
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
				rom_addr <= 8'b0;
				
				data_cnt <= 0;

				cnt_ddd <= 0;

				Finish <= 1'b0;
	      end
	  else 
	      case (STATE)																  
			IDLE:  begin								//��ʼ״̬
				      STATE<=STATE1;
						adr  <= 3'bx;
			         dout <= 8'bx;
			         cyc  <= 1'b0;
			         stb  <= 1'bx;
			         we   <= 1'hx;
						sel  <= 1'bx;
						rom_addr <= 8'b0;
						
						data_cnt <= 0;

						cnt_ddd <= 0;
						Finish <= 1'b0;
	             end
	      STATE1:			                     //����ʱ�ӷ�Ƶϵ����λ
			       begin
					 	STATE<=STATE2;
						adr  <= PRER_LO;				//���ʱ�ӷ�Ƶ�Ĵ�����λ��ַ
			         dout <= 8'h64;	 				//50M/100K*5��100��h'64
			         cyc  <= 1'b1;
			         stb  <= 1'b1;
			         we   <= 1'b1;
						sel  <= 1'b1;
	             end

	      STATE2:										//�ȴ��ӽ��Ӧ����?			       
					begin
					 	if(~ack)
						   STATE<=STATE2;
	               else
							begin
								STATE<=STATE3;				//��Ӧ?
							end
							
					 end
			STATE3:									 	//���س�ʼ״̬
			       begin
					   STATE<=STATE4;
						cyc  <= 1'b0;
			         stb  <= 1'bx;
			         adr  <= 3'bx;
			         dout <= 8'bx;
			         we   <= 1'hx;
						sel  <= 1'bx;
					 end

			STATE4:			                     //����ʱ�ӷ�Ƶϵ����λ
			       begin
					 	STATE<=STATE5;
						adr  <= PRER_HI;				//���ʱ�ӷ�Ƶ�Ĵ����λ���?			         
						dout <= 8'h00;	 				
			         cyc  <= 1'b1;
			         stb  <= 1'b1;
			         we   <= 1'b1;
						sel  <= 1'b1;
	             end

	      STATE5:										//ȴ��ӽڵ��Ӧ���ź?			       
					begin
					 	if(~ack)
						   STATE<=STATE5;
	               else
							begin
								STATE<=STATE6;				//�յ�Ӧ��	
							end
						   
	             end

	      STATE6:									 	//���س�ʼ״̬
			       begin
					   STATE<=STATE7;
						cyc  <= 1'b0;
			         stb  <= 1'bx;
			         adr  <= 3'bx;
			         dout <= 8'bx;
			         we   <= 1'hx;
						sel  <= 1'bx;
					 end

	      STATE7:                             //�ӿ�ʹ��
			       begin
					 	STATE<=STATE8;
						adr  <= CTR; 					//������ƼĴ�����?			         
						dout <= 8'h80;					//8'b1000_0000,��CTR[7] = 1�ӿ�ʹ��
			         cyc  <= 1'b1;
			         stb  <= 1'b1;
			         we   <= 1'b1;
						sel  <= 1'b1;
					 end

	      STATE8:	                          	//�ȴ��ӽڵ��Ӧ���ź�
			       begin
					 	if(~ack)
						   STATE<=STATE8;
	               else
						   STATE<=STATE9;				//�յ�Ӧ��
	             end
	      STATE9:		 								//���س�ʼ״̬
			       begin
					   STATE<=STATE10;
						cyc  <= 1'b0;
			         stb  <= 1'bx;
			         adr  <= 3'bx;
			         dout <= 8'bx;
			         we   <= 1'hx;
						sel  <= 1'bx;
					 end

	      STATE10:		                     	//��������
			       begin
					   STATE<=STATE11;
						adr  <= TXR;
						
						case(data_cnt)
						'd0:	dout <= 8'h40;//rom_data;
						'd1:  dout <= 8'h00;//rom_data;
						'd2:  dout <= 8'h00;								
						'd3:	dout <= 8'h40;
						'd4:	dout <= 8'h04;
						'd5:  dout <= 8'h57;
						'd6:  dout <= 8'h40;
						'd7:  dout <= 8'h17;
						'd8:	dout <= 8'h41;
						'd9:  dout <= 8'h40;
						'd10: dout <= 8'h31;
						'd11: dout <= 8'h02;//rom_data;
						'd12: dout <= 8'h40;//rom_data;
						'd13: dout <= 8'h3d;
						'd14: dout <= 8'ha2;
						'd15: dout <= 8'h40;
						'd16: dout <= 8'h3e;
						'd17: dout <= 8'h6a;
						'd18: dout <= 8'h40;
						'd19: dout <= 8'h3f;
						'd20: dout <= 8'ha0;//rom_data;
						'd21: dout <= 8'h40;//rom_data;
						'd22: dout <= 8'h0e;
						'd23: dout <= 8'h80;
						'd24: dout <= 8'h40;
						'd25: dout <= 8'h55;
						'd26: dout <= 8'h81;
						'd27: dout <= 8'h40;
						'd28: dout <= 8'h0e;
						'd29: dout <= 8'h00;
						default: dout <= 8'bx;
						endcase

			         cyc  <= 1'b1;
			         stb  <= 1'b1;
			         we   <= 1'b1;
						sel  <= 1'b1;
					 end

	      STATE11:                             //�ȴ��ӽڵ��Ӧ���ź�
			       begin
					 	if(~ack)
						   STATE<=STATE11;
	               else
						   begin
						      STATE<=STATE12;		//յ?						      
								rom_addr <=rom_addr+1;			//�޸ĵ�ַ
	                  end
	             end
	      STATE12:							      	//���س�ʼ״̬
			       begin
					   STATE<=STATE13;
						cyc  <= 1'b0;
			         stb  <= 1'bx;
			         adr  <= 3'bx;
			         dout <= 8'bx;
			         we   <= 1'hx;
						sel  <= 1'bx;
	             end

			STATE13:		                    		//��������
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
						default: dout <= 8'bx;
						endcase
							
			         cyc  <= 1'b1;
			         stb  <= 1'b1;
			         we   <= 1'b1;
						sel  <= 1'b1;
					 end

	      STATE14:										//�ȴ��ӽڵ��Ӧ���ź�
			       begin
					 	if(~ack)
						   STATE<=STATE14;
	               else
						   begin
						      STATE<=STATE15;		//�յ�Ӧ��
								rom_addr <=rom_addr+1;	//�޸ĵ�ַ
								data_cnt <= data_cnt + 1;
	                  end
	             end				 
			STATE15:				                             //���س�ʼ��
		       begin
				   STATE<=STATE16;
					cyc  <= 1'b0;
		         stb  <= 1'bx;
		         adr  <= 3'bx;
		         dout <= 8'bx;
		         we   <= 1'hx;
		         sel  <= 1'bx;
             end
				 	
			STATE16:		                                   //��״̬�Ĵ���
		       begin
		         STATE<=STATE17;
		         adr  <= SR;
		         dout <= 8'bx;
		         cyc  <= 1'b1;
		         stb  <= 1'b1;
		         we   <= 1'b0;
		         sel  <= 1'b1;
             end
			STATE17:										//�ȴ��ӽڵ��Ӧ���ź�
			       begin
					 	if(~ack)
						   STATE<=STATE17;
	               else
						   begin
						      STATE<=STATE18;		//�յ�Ӧ��
								
	                  end
	             end				 

      	STATE18:														
		       	begin
				   	cyc  <= 1'b0;					//���س�ʼ״̬
			         stb  <= 1'bx;
			         adr  <= 3'bx;
			         dout <= 8'bx;
			         we   <= 1'hx;
						sel  <= 1'bx;

					   if(din[1])						 //��鴫���Ƿ����
					       STATE<=STATE16;
	               else
						    STATE<=STATE19;
             	end
	      STATE19:		                    		
			       begin									
						if(data_cnt== 'd30)		//�Ƿ��?0������
						  begin
						  	STATE<=STATE_DELAY;				//������ɣ��ֹͣ״�?
						  end
						else
							STATE<=STATE10;
						  				//û�������꣬��������
	             end
			STATE_DELAY:
					begin
						Finish <= 1'b0;

						if(&cnt_ddd)
						begin
							STATE<=STATE20;

							cnt_ddd <= 0;
						end
						else
						begin
							STATE<=STATE_DELAY;

							cnt_ddd <= cnt_ddd +1;
						end		
					end
	      STATE20:										//ֹͣ״̬
			       begin
							STATE<=STATE20;
							Finish <= 1'b1;	
	             end
			
	      default: STATE<=STATE20;
	     endcase
	   end
			
endmodule  
