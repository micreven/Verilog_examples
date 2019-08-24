`timescale 1ns/1ps
module synch_fifo_tb;

reg rstb;
reg  fifo_clk;
reg fifo_wren;
reg [31:0] fifo_wrdata;
reg fifo_rden;

wire [31:0] fifo_rddata;
wire fifo_full;
wire fifo_empty;
wire [4:0] fifo_room_avail;
wire [4:0] fifo_data_avail;

initial
begin
	rstb = 1'b0;
	fifo_clk = 1'b0;
	fifo_wren = 1'b0;
	fifo_wrdata = 'd0;
	fifo_rden = 1'b0;
	#50 rstb = ~rstb;
end

always
begin
	#50 fifo_clk = ~fifo_clk;
end

always@(posedge fifo_clk)
begin

	#2 fifo_wrdata = {$random}%100;
	if(fifo_full)
		fifo_wren = 1'b0;
	else
		fifo_wren = {$random}%2;
	if(fifo_empty)
		fifo_rden = 1'b0;
	else
		fifo_rden = {$random}%2;
end

synch_fifo synch_fifo_instance(
	.rstb(rstb),
	.fifo_clk(fifo_clk),
	.fifo_wren(fifo_wren),
	.fifo_wrdata(fifo_wrdata),
	.fifo_rden(fifo_rden),
	.fifo_rddata(fifo_rddata),
	.fifo_full(fifo_full),
	.fifo_empty(fifo_empty),
	.fifo_room_avail(fifo_room_avail),
	.fifo_data_avail(fifo_data_avail));


initial
begin
	//$dumpfile("synch_fifo_tb.vcd");
	//$dumpvars(0,synch_fifo_tb);
	$vcdplusfile("fifo.vpd");
	$vcdpluson(0);
	$vcdplusmemon(0);
end

initial #10000 $finish;
endmodule
