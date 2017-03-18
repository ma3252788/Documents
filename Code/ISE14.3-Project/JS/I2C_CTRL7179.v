`include "timescale.v"
// synopsys translate_on

`include "i2c_master_defines.v"
////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:    15:24:39 07/21/08
// Design Name:    
// Module Name:    I2C_CTRL7179
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
module I2C_CTRL7179(clk, rst, din, ack, err, rty, sel, //input			 
						 cyc, stb, we, dout, adr, Finish);//output

    input 		clk;
    input 		rst;
	 input 		[7:0] din;
    input 		ack, err, rty;	 

	 output 		sel;
	 output 		cyc;
	 output 		stb;
    output 		we;
    output 		dout;
    output 		adr;
	 output 		Finish;

	 reg			[2:0]	 adr;
	 reg			[7:0]	 dout;
	 reg 			cyc, stb, we, sel, Finish;

	 //�Ĵ�����ַ
	 parameter PRER_LO = 3'b000;//��Ƶ�Ĵ�����λ��ַ
	 parameter PRER_HI = 3'b001;//��λ��ַ
	 parameter CTR     = 3'b010;//���ƼĴ�����ַ��(7)ʹ��λ|6�ж�ʹ��λ|5-0���ౣ��λ
	 parameter RXR     = 3'b011;//���ܼĴ�����ַ��(7)���ܵ������һ���ֽڵ�����
	 parameter TXR     = 3'b011;//����Ĵ�����ַ��(7)�����ַʱ���һλΪ��дλ��1Ϊ��
	 parameter CR      = 3'b100;//����Ĵ�����ַ��
	 //(7)��ʼ|6����|5��|4д|3Ӧ����Ϊ���ܷ�ʱ������Ӧ���źţ���0��ΪӦ�𣬡�1��Ϊ��Ӧ��|2����λ|1����λ|0���Ӧ��λ�����λ�Զ���?	 
	 parameter SR      = 3'b100;//״̬�Ĵ�����ַ��(7)����Ӧ��λ����0��Ϊ���ܵ�Ӧ��|6æλ��������ʼ�źź��Ϊ1������źź���?��|5�ٲ�λ|4-2����λ|1������λ��1��ʾ��ڴ������?��ʾ��������|��ϱ־?//	 parameter SR      = 3'b101;
	 parameter TXR_R   = 3'b101; // undocumented / reserved output
	 parameter CR_R    = 3'b110; // undocumented / reserved output
	 
	 reg 			[19:0] STATE;
	 //����״̬����																										
    parameter 	[19:0] IDLE   =20'b00000000000000000000;		   //
	 parameter	[19:0] STATE1 =20'b00000000000000000001;			//
	 parameter	[19:0] STATE2 =20'b00000000000000000010;			//
	 parameter	[19:0] STATE3 =20'b00000000000000000100;			//
	 parameter 	[19:0] STATE4 =20'b00000000000000001000;			//
	 parameter 	[19:0] STATE5 =20'b00000000000000010000;			//
	 parameter 	[19:0] STATE6 =20'b00000000000000100000;			//
	 parameter 	[19:0] STATE7 =20'b00000000000001000000;			//
	 parameter 	[19:0] STATE8 =20'b00000000000010000000;			//
	 parameter 	[19:0] STATE9 =20'b00000000000100000000;			//
	 parameter 	[19:0] STATE10=20'b00000000001000000000;			//
	 parameter 	[19:0] STATE11=20'b00000000010000000000;			//
	 parameter 	[19:0] STATE12=20'b00000000100000000000;			//
	 parameter 	[19:0] STATE13=20'b00000001000000000000;			//
	 parameter 	[19:0] STATE14=20'b00000010000000000000;			//
	 parameter 	[19:0] STATE15=20'b00000100000000000000;			//
	 parameter 	[19:0] STATE16=20'b00001000000000000000;			//
	 parameter 	[19:0] STATE17=20'b00010000000000000000;			//
	 parameter 	[19:0] STATE18=20'b00100000000000000000;			//
	 parameter 	[19:0] STATE19=20'b01000000000000000000;			//
	 parameter 	[19:0] STATE20=20'b10000000000000000000;			//
	 
	 reg	[6:0]data_cnt;

	  //module body
	  always @ (posedge clk or negedge rst)			  //��λ���ʼ�̬
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

				Finish <= 1'b0;
	      end
	  else
	      case (STATE)																  
			IDLE:  
					 begin						
							STATE<=STATE1;	//��ʼ״̬	

							adr  <= 3'bx;
				         dout <= 8'bx;
				         cyc  <= 1'b0;
				         stb  <= 1'bx;
				         we   <= 1'hx;
							sel  <= 1'bx;

							data_cnt <= 0;

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

	      STATE2:										//�ȴ��ӽڵ��Ӧ���ź�
			       begin
					 	if(~ack)
						   STATE<=STATE2;
	               else
						   STATE<=STATE3;				//�յ�Ӧ��
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
						adr  <= PRER_HI;				//���ʱ�ӷ�Ƶ�Ĵ�����λ��ַ
			         dout <= 8'h00;	 				
			         cyc  <= 1'b1;
			         stb  <= 1'b1;
			         we   <= 1'b1;
						sel  <= 1'b1;
	             end

	      STATE5:										//�ȴ��ӽڵ�Ħ���ź?			       
					begin
					 	if(~ack)
						   STATE<=STATE5;
	               else
						   STATE<=STATE6;				//�յ�Ӧ��
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
						adr  <= CTR; 					//������ƼĴ�����ַ
			         dout <= 8'h80;					//8'b1000_0000,��CTR[7] = 1�ӿڹ�?			         
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
						if(data_cnt == 'd0)
							begin
								dout <= 8'h54;//rom_data;
							end
						else if(data_cnt == 'd1)
							begin
								dout <= 8'h00;//rom_data;
							end
						else if(data_cnt == 'd2)
							begin
								dout <= 8'h05;//rom_data;
							end
						else if(data_cnt == 'd3)
							begin
								dout <= 8'h58;	 //01H  bit[7]=1/0: color bar enable/disable;bit[6]=1/0: DAC A disable/enable;bit[5]=1/0: DAC B disable/enable;bit[4]=1/0: DAC C disable/enable; 
							end
						else if(data_cnt == 'd4)
							begin
								dout <= 8'h40;	 //02H  bit[4]=1/0: color disable/enable
							end
						else if(data_cnt == 'd5)
							begin
								dout <= 8'h00;
							end
						else if(data_cnt == 'd6)
							begin
								dout <= 8'h00;
							end
						else if(data_cnt == 'd7)
							begin
								dout <= 8'h54;
							end
						else if(data_cnt == 'd8)
							begin
								dout <= 8'h07;
							end
						else if(data_cnt == 'd9)
							begin
								dout <= 8'h08;
							end
						else if(data_cnt == 'd10)
							begin
								dout <= 8'h00;
							end
						else if(data_cnt == 'd11)
							begin
								dout <= 8'hcb;
							end
						else if(data_cnt == 'd12)
							begin
								dout <= 8'h8a;
							end
						else if(data_cnt == 'd13)
							begin
								dout <= 8'h09;
							end
						else if(data_cnt == 'd14)
							begin
								dout <= 8'h2a;
							end

						else if(data_cnt == 'd15)
							begin
								dout <= 8'h01;
							end
						else if(data_cnt == 'd16)
							begin
								dout <= 8'h0f;
							end
						else if(data_cnt == 'd17)
							begin
								dout <= 8'h00;
							end
						else if(data_cnt == 'd18)
							begin
								dout <= 8'h0c;
							end
						else if(data_cnt == 'd19)
							begin
								dout <= 8'ha7;
							end
						else if(data_cnt == 'd20)
							begin
								dout <= 8'h00;
							end
						else if(data_cnt == 'd21)
							begin
								dout <= 8'h00;
							end
						else if(data_cnt == 'd22)
							begin
								dout <= 8'h00;
							end
						else if(data_cnt == 'd23)
							begin
								dout <= 8'h00;
							end
						else if(data_cnt == 'd24)
							begin
								dout <= 8'h00;
							end
						else if(data_cnt == 'd25)
							begin
								dout <= 8'h00;
							end
						else if(data_cnt == 'd26)
							begin
								dout <= 8'h00;
							end
						else if(data_cnt == 'd27)
							begin
								dout <= 8'h00;
							end
						else
							begin
								dout <= 8'bx;
							end
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
						      STATE<=STATE12;		//�յ�Ӧ��
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
						if(data_cnt == 'd0)
							begin
								dout <= 8'h90;
							end
						else if(data_cnt == 'd1)
							begin
								dout <= 8'h10;
							end
						else if(data_cnt == 'd2)
							begin
								dout <= 8'h10;
							end
						else if(data_cnt == 'd3)
							begin
								dout <= 8'h10;
							end
						else if(data_cnt == 'd4)
							begin
								dout <= 8'h10;
							end
						else if(data_cnt == 'd5)
							begin
								dout <= 8'h10;
							end
						else if(data_cnt == 'd6)
							begin
								dout <= 8'h50;
							end
						else if(data_cnt == 'd7)
							begin
								dout <= 8'h90;
							end
						else if(data_cnt == 'd8)
							begin
								dout <= 8'h10;
							end
						else if(data_cnt == 'd9)
							begin
								dout <= 8'h10;
							end
						else if(data_cnt == 'd10)
							begin
								dout <= 8'h10;
							end
						else if(data_cnt == 'd11)
							begin
								dout <= 8'h10;
							end
						else if(data_cnt == 'd12)
							begin
								dout <= 8'h10;
							end
						else if(data_cnt == 'd13)
							begin
								dout <= 8'h10;
							end
						else if(data_cnt == 'd14)
							begin
								dout <= 8'h10;
							end

						else if(data_cnt == 'd15)
							begin
								dout <= 8'h10;
							end
						else if(data_cnt == 'd16)
							begin
								dout <= 8'h10;
							end
						else if(data_cnt == 'd17)
							begin
								dout <= 8'h10;
							end
						else if(data_cnt == 'd18)
							begin
								dout <= 8'h10;
							end
						else if(data_cnt == 'd19)
							begin
								dout <= 8'h10;
							end
						else if(data_cnt == 'd20)
							begin
								dout <= 8'h10;
							end
						else if(data_cnt == 'd21)
							begin
								dout <= 8'h10;
							end
						else if(data_cnt == 'd22)
							begin
								dout <= 8'h10;
							end
						else if(data_cnt == 'd23)
							begin
								dout <= 8'h10;
							end
						else if(data_cnt == 'd24)
							begin
								dout <= 8'h10;
							end
						else if(data_cnt == 'd25)
							begin
								dout <= 8'h10;
							end
						else if(data_cnt == 'd26)
							begin
								dout <= 8'h10;
							end
						else if(data_cnt == 'd27)
							begin
								dout <= 8'h90;
							end
						else
							begin
								dout <= 8'bx;
							end				
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
								data_cnt <= data_cnt + 1;
	                  end
	             end				 
			STATE15:				                             //���س�ʼ��
		       begin
				   STATE<=STATE16;
					cyc  <= 1'b0;
		         stb  <= 1'bx;
		         adr  <= {3{1'bx}};
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
						if(data_cnt == 'd28)		//�Ƿ���152������
						begin
						  STATE<=STATE20;				//������ɣ�����ֹͣ״̬
						end
	               else
						  STATE<=STATE10;				//û�������꣬��������
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
