`timescale 1ns/1ps
module synch_fifo_tb;

localparam FIFO_DEPTH = 16;
localparam FIFO_WIDTH = 32;
localparam FIFO_PTR   = 4;
reg  wrclk;
reg  rstb_wrclk;
reg  write_en;
reg  [FIFO_WIDTH-1:0] write_data;
reg  snapshot_wrptr;
reg  rollback_wrptr;
reg  reset_wrptr;

reg  rdclk;
reg  rstb_rdclk;
reg  read_en;
wire [FIFO_WIDTH-1:0] read_data;
reg  snapshot_rdptr;
reg  rollback_rdptr;
reg  reset_rdptr;


wire fifo_full;
wire fifo_empty;
wire [FIFO_PTR:0] data_avail;
wire [FIFO_PTR:0] room_avail;

initial
begin
	wrclk          = 1'b0;
	rstb_wrclk     = 1'b0;
	write_en       = 1'b0;
	write_data     = 'd0;
	snapshot_wrptr = 1'b0;
	rollback_wrptr = 1'b0;
	reset_wrptr    = 1'b0;

	rdclk          = 1'b0;
	rstb_rdclk     = 1'b0;
	read_en        = 1'b0;
	//read_data      = 'd0;
	snapshot_rdptr = 1'b0;
	rollback_rdptr = 1'b0;
	reset_rdptr    = 1'b0;
	#50 rstb_wrclk = 1'b1;
	rstb_rdclk     = 1'b1;
	//reset_wrptr    = 1'b1;
	//reset_rdptr    = 1'b1;
end

always
begin
 #50 wrclk = ~wrclk;
end

always
begin
 #133 rdclk = ~rdclk;
end

always@(posedge wrclk)
begin
	write_data = {$random}%100;
end

always@(posedge wrclk)
begin
	if(fifo_full)
		write_en = 1'b0;
	else
		write_en = {$random}%2;
end

always@(posedge rdclk)
begin
	if(fifo_empty)
		read_en = 1'b0;
	else
		read_en = {$random}%2;
end

asynch_fifo asynch_fifo_instance(
	.wrclk(wrclk),
	.rstb_wrclk(rstb_wrclk),
	.write_en(write_en),
	.write_data(write_data),
	.snapshot_wrptr(snapshot_wrptr),
	.rollback_wrptr(rollback_wrptr),
	.reset_wrptr(reset_wrptr),
	.rdclk(rdclk),
	.rstb_rdclk(rstb_rdclk),
	.read_en(read_en),
	.read_data(read_data),
	.snapshot_rdptr(snapshot_rdptr),
	.rollback_rdptr(rollback_rdptr),
	.reset_rdptr(reset_rdptr),
	.fifo_full(fifo_full),
	.fifo_empty(fifo_empty),
	.data_avail(data_avail),
	.room_avail(room_avail));


initial
begin
	$vcdplusfile("fifo.vpd");
	$vcdpluson(0);
	$vcdplusmemon(0);
end

initial #10000 $finish;
endmodule
