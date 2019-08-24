`timescale 1ns/1ps
module sram_tb;

reg clk;
wire wrclk;
reg wren;
reg [3:0] wrptr;
reg [31:0] wrdata;

wire rdclk;
reg rden;
reg [3:0] rdptr;
wire [31:0] rddata;

initial
begin
	clk <= 1'b0;
end

always
begin
	#50 clk <=~clk;
end

assign	wrclk = clk;
assign	rdclk = clk;

always@(posedge clk)
begin
	wren <= {$random}%2;
	wrptr <= {$random}%16;
	wrdata <= {$random}%100;

	rden <= ($random)%2;
	rdptr <= {$random}%16;
end

sram sram_instance(
	.wrclk(clk),
	.wren(wren),
	.wrptr(wrptr),
	.wrdata(wrdata),
	.rdclk(rdclk),
	.rden(rden),
	.rdptr(rdptr),
	.rddata(rddata));

initial
begin
	$readmemh("data.txt",sram_instance.ram);
end

initial
begin
	//$dumpfile("tb_sram.vpd");
	$vcdplusfile("tb_sram.vpd");
	//$dumpvars(0,sram_tb);
	$vcdpluson(0);
	$vcdplusmemon(0);
	//$vcdplusmemon;
end

initial #10000 $finish;
endmodule
