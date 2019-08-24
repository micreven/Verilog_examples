module synch_fifo #(parameter FIFO_PTR = 4,
							  FIFO_WIDTH = 32,
							  FIFO_DEPTH = 16)
	   (rstb,
		fifo_clk,
		fifo_wren,
		fifo_wrdata,
		fifo_rden,
		fifo_rddata,
		fifo_full,
		fifo_empty,
		fifo_room_avail,
		fifo_data_avail);

input fifo_clk;
input rstb;
input fifo_wren;
input [FIFO_WIDTH-1:0] fifo_wrdata;
input fifo_rden;
output [FIFO_WIDTH-1:0] fifo_rddata;
output fifo_full;
output fifo_empty;
output [FIFO_PTR:0] fifo_room_avail;
output [FIFO_PTR:0] fifo_data_avail;
localparam  FIFO_DEPTH_MINUS1 = FIFO_DEPTH-1;

reg [FIFO_PTR-1:0] wr_ptr,wr_ptr_nxt;
reg [FIFO_PTR-1:0] rd_ptr,rd_ptr_nxt;
reg [FIFO_PTR:0] num_entries,num_entries_nxt;
reg fifo_full,fifo_empty;
wire fifo_full_nxt,fifo_empty_nxt;
reg [FIFO_PTR:0] fifo_room_avail;
wire [FIFO_PTR:0] fifo_room_avail_nxt;
wire [FIFO_PTR:0] fifo_data_avail;

//wr_ptr control logic
//*******************************************
always@(*)
begin
	wr_ptr_nxt = wr_ptr;
	if(fifo_wren)
	begin
		if(wr_ptr==FIFO_DEPTH_MINUS1)
			wr_ptr_nxt = 'd0;
		else
			wr_ptr_nxt = wr_ptr + 1'b1;
	end
end

//rd_ptr control logic
//******************************************
always@(*)
begin
	rd_ptr_nxt = rd_ptr;
	if(fifo_rden)
	begin
		if(rd_ptr==FIFO_DEPTH_MINUS1)
			rd_ptr_nxt = 'd0;
		else
			rd_ptr_nxt = rd_ptr + 1'b1;
	end
end

//caculate num of occupied entries in FIFO
//*****************************************
always@(*)
begin
	num_entries_nxt = num_entries;
	if(fifo_wren&&fifo_rden)
		num_entries_nxt = num_entries;
	else if(fifo_wren)
		num_entries_nxt = num_entries + 1'b1;
	else if(fifo_rden)
		num_entries_nxt = num_entries - 1'b1;
end

assign fifo_full_nxt = (num_entries_nxt == FIFO_DEPTH);
assign fifo_empty_nxt = (num_entries_nxt == 'd0);
assign fifo_data_avail = num_entries;
assign fifo_room_avail_nxt = (FIFO_DEPTH - num_entries);

always@(posedge fifo_clk or negedge rstb)
begin
	if(!rstb)
	begin
		wr_ptr <= 'd0;
		rd_ptr <= 'd0;
		num_entries <= 'd0;
		num_entries_nxt <= 'd0;
		fifo_full <= 'd0;
		fifo_empty <= 'd1;
		fifo_room_avail <= FIFO_DEPTH;
	end
	else
	begin
		wr_ptr <= wr_ptr_nxt;
		rd_ptr <= rd_ptr_nxt;
		num_entries <= num_entries_nxt;
		fifo_full <= fifo_full_nxt;
		fifo_empty <= fifo_empty_nxt;
		fifo_room_avail <= fifo_room_avail_nxt;
	end
end

sram #(.FIFO_PTR(FIFO_PTR),
	 .FIFO_WIDTH(FIFO_WIDTH)) sram_0
	 (.wrclk(fifo_clk),
	  .wren(fifo_wren),
	  .wrptr(wr_ptr),
	  .wrdata(fifo_wrdata),
	  .rdclk(fifo_clk),
	  .rden(fifo_rden),
	  .rdptr(rd_ptr),
	  .rddata(fifo_rddata));

endmodule

