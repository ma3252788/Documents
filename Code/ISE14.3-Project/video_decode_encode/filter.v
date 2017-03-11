module filter(clk,rst_in,rst_out1,rst_out2, cnt);
input   clk,rst_in;
output  rst_out1;
output  rst_out2;
output	cnt;

reg     rst_out1;
reg     rst_out2;

reg [31:0] cnt;

always  @(posedge clk or negedge rst_in)
if(!rst_in)
begin
  rst_out1 <= 1'b1;
  rst_out2 <= 1'b0;

  cnt <= 1'b0;
end
else
begin
	if(cnt<295000)//5ms
	begin
  		rst_out1 <= 1'b1;
		rst_out2 <= 1'b0;

		cnt <= cnt + 1;
	end
	else
	if((cnt>=295000)&&(cnt<590000))//5ms
	begin
  		rst_out1 <= 1'b0;
		rst_out2 <= 1'b0;

		cnt <= cnt + 1;
	end
	else
	if((cnt>=590000)&&(cnt<885000))//5ms
	begin
		rst_out1 <= 1'b1;
		rst_out2 <= 1'b0;

		cnt <= cnt + 1;
	end
	else
	begin
		rst_out1 <= 1'b1;
		rst_out2 <= 1'b1;
	end
end

endmodule
 