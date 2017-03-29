//分频，得到波特率9600，偶校验
module div1_8mm(clk50m,clk1_8m,rst); //384分频，59M/384/16＝9600
input	rst;
input clk50m;
output clk1_8m;

reg		[11:0]clk_cnt;
reg		clk_out;

parameter	full_time = 32;//384;
parameter	half_time = 16;//192;

assign	clk1_8m = clk_out;

always @(posedge clk50m or negedge rst)
begin
	if(!rst)
		begin
			clk_cnt <= 0;
			clk_out <= 1'b0; 
		end
	else
		begin
			if(clk_cnt < half_time)
				begin
					clk_out <= 1'b1;
					clk_cnt <= clk_cnt + 1;
				end
			else if(clk_cnt >= half_time && clk_cnt < full_time)
				begin
					clk_out <= 1'b0;
					clk_cnt <= clk_cnt + 1;
				end
			else
				begin
					clk_cnt <= 0;
				end
		end
end

endmodule

