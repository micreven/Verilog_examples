`timescale 1ns/1ps
module add_tb; 

reg clk;
reg [3:0] a;
reg [3:0] b;
wire [4:0] add_res;

initial
begin 
a = 3'b101;
b = 3'b011;
clk = 1'b1;
end   

always
begin
	#50 clk = ~clk;
	//a = {$random}%16;
	//b = {$random}%16;
end

always@(negedge clk)
begin
	a = {$random}%16;
	b = {$random}%16;
end

add add_instance( 
.clk(clk),
.add_a(a),
.add_b(b),
.add_res(add_res)
); 

initial begin 
$dumpfile("tb_add.vcd"); 
$dumpvars(0, add_tb); 
end 

initial #10000 $finish;

endmodule
