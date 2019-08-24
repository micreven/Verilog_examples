`timescale 1ns/1ps
module seq_check_tb();

reg clk;
reg rstb;
reg in_a;

wire out_b;

initial
begin
	clk = 1'b0;
	rstb = 1'b0;
	#50 rstb = 1'b1;
end

always
begin
	#50 clk = ~clk;
end

always@(clk)
begin
	in_a = $random%255;
end

seq_check seq_check_instance(
	.clk(clk),
	.rstb(rstb),
	.in_a(in_a),
	.out_b(out_b)
);

initial begin
$dumpfile("tb_seq_check.vcd");
$dumpvars(0,seq_check_tb);
end

initial #100000 $finish;

endmodule

