`timescale 1ns/1ps
module mod3_tb;

reg clk;
reg input_num;
reg rstb;
wire res;

initial
begin
	clk = 1'b1;
	rstb = 1'b0;
	#50 rstb = ~rstb;
end

always
begin
	//input_num = {$random}%2;
	#50 clk = ~clk;
	//input_num = {$random}%2;
end

always@(posedge clk)
begin
	input_num = {$random}%2;
end


mod3 mod3_instance(
	.clk(clk),
	.rstb(rstb),
	.input_num(input_num),
	.res(res));

initial begin
	$dumpfile("mod3_tb.vcd");
	$dumpvars(0,mod3_tb);
end

initial #10000 $finish;

endmodule
