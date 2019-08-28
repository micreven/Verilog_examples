module asynch_fifo #(parameter FIFO_PTR = 4,
							   FIFO_WIDTH = 32)
	   (input wrclk,
		input rstb_wrclk,
		input write_en,
		input [FIFO_WIDTH-1:0] write_data,
		input snapshot_wrptr,
		input rollback_wrptr,
		input reset_wrptr, //wr signs
		input rdclk,
		input rstb_rdclk,
		input read_en,
		output [FIFO_WIDTH-1:0] read_data,
		input snapshot_rdptr,
		input rollback_rdptr,
		input reset_rdptr, //rd signs
		output reg fifo_full,
		output reg fifo_empty,
		output reg [FIFO_PTR:0] room_avail,
		output reg [FIFO_PTR:0] data_avail);

localparam FIFO_DEPTH = (1<<FIFO_PTR);
localparam FIFO_TWICEDEPTH_MINUS1 = (2*FIFO_DEPTH)-1;

reg  [FIFO_PTR:0] wr_ptr_wab,wr_ptr_wab_nxt;
wire [FIFO_PTR:0] room_avail_nxt;
reg  [FIFO_PTR:0] wr_ptr_snapshot_value;
wire [FIFO_PTR:0] wr_ptr_snapshot_value_nxt;
wire fifo_full_nxt;
wire [FIFO_PTR-1:0] wr_ptr;
reg  [FIFO_PTR:0] rd_ptr_wab,rd_ptr_wab_nxt;
wire [FIFO_PTR:0] data_avail_nxt;
reg  [FIFO_PTR:0] rd_ptr_snapshot_value;
wire [FIFO_PTR:0] rd_ptr_snapshot_value_nxt;
wire fifo_empty_nxt;
wire [FIFO_PTR-1:0] rd_ptr;

//Write pointer control logic
//*****************************************************
always@(*)
begin
	wr_ptr_wab_nxt = wr_ptr_wab;
	if(reset_wrptr)
		wr_ptr_wab_nxt = 'd0;
	else if(rollback_wrptr)
		wr_ptr_wab_nxt = wr_ptr_snapshot_value;
	else if(write_en&&(wr_ptr_wab == FIFO_TWICEDEPTH_MINUS1)) //ptr have roll two cycles
		wr_ptr_wab_nxt = 'd0;
	else if(write_en)
		wr_ptr_wab_nxt = wr_ptr_wab +1;
end

//Take a snapshot of write pointer that can be used to reload it later
//********************************************************************
assign wr_ptr_snapshot_value_nxt = 
	snapshot_wrptr?wr_ptr_wab:wr_ptr_snapshot_value;
always@(posedge wrclk or negedge rstb_wrclk)
begin
	if(!rstb_wrclk)
	begin
		wr_ptr_wab <= 'd0;
		wr_ptr_snapshot_value <= 'd0;
	end
	else
	begin
		wr_ptr_wab <= wr_ptr_wab_nxt;
		wr_ptr_snapshot_value <= wr_ptr_snapshot_value_nxt;
	end
end

//conver the binary wr ptr to gray,flop it and then pass it to read domain
//************************************************************************
reg  [FIFO_PTR:0] wr_ptr_wab_gray;
wire [FIFO_PTR:0] wr_ptr_wab_gray_nxt;

b2g #(.PTR(FIFO_PTR)) b2g_instance_wr
					  (.binary_value(wr_ptr_wab_nxt),
					   .gray_value(wr_ptr_wab_gray_nxt));

always@(posedge wrclk or negedge rstb_wrclk)
begin
	if(!rstb_wrclk)
		wr_ptr_wab_gray <= 'd0;
	else
		#20 wr_ptr_wab_gray <= wr_ptr_wab_gray_nxt;
end

//synchronize wr_ptr_wab_gray into read clock domain
//************************************************************************
reg [FIFO_PTR:0] wr_ptr_wab_gray_sync1;
reg [FIFO_PTR:0] wr_ptr_wab_gray_sync2;

always@(posedge rdclk or negedge rstb_rdclk)
begin
	if(!rstb_rdclk)
	begin
		wr_ptr_wab_gray_sync1 <= 'd0;
		wr_ptr_wab_gray_sync2 <= 'd0;
	end
	else
	begin
		 wr_ptr_wab_gray_sync1 <= wr_ptr_wab_gray;
		 wr_ptr_wab_gray_sync2 <= wr_ptr_wab_gray_sync1;
	end
end

//cover wr_ptr_wab_gray_sync2 back to binary form
//**************************************************************************
reg  [FIFO_PTR:0] wr_ptr_wab_rdclk;
wire [FIFO_PTR:0] wr_ptr_wab_rdclk_nxt;
g2b #(.PTR(FIFO_PTR)) g2b_instance_wr
					  (.gray_value(wr_ptr_wab_gray_sync2),
					   .binary_value(wr_ptr_wab_rdclk_nxt));

always@(posedge rdclk or negedge rstb_rdclk)
begin
	if(!rstb_rdclk)
		wr_ptr_wab_rdclk <= 'd0;
	else
		wr_ptr_wab_rdclk <= wr_ptr_wab_rdclk_nxt;
end

//read pointer control logic
//**************************************************************************
always@(*)
begin
	rd_ptr_wab_nxt = rd_ptr_wab;
	if(reset_rdptr)
		rd_ptr_wab_nxt = 'd0;
	else if(rollback_rdptr)
		rd_ptr_wab_nxt = rd_ptr_snapshot_value;
	else if(read_en&&(rd_ptr_wab == FIFO_TWICEDEPTH_MINUS1))
		rd_ptr_wab_nxt = 'd0;
	else if(read_en)
		rd_ptr_wab_nxt = rd_ptr_wab+1;
end

//take a snapshot of the read pointer that can be used to relad later
//**************************************************************************
assign rd_ptr_snapshot_value_nxt = 
	   snapshot_rdptr ? rd_ptr_wab:rd_ptr_snapshot_value;

always@(posedge rdclk or negedge rstb_rdclk)
begin
	if(!rstb_rdclk)
	begin
		rd_ptr_wab <= 'd0;
		rd_ptr_snapshot_value <= 'd0;
	end
	else
	begin
		#20 rd_ptr_wab <= rd_ptr_wab_nxt;
		rd_ptr_snapshot_value <= rd_ptr_snapshot_value_nxt;
	end
end

//convert the binary rd_ptr to gray and then pass it to write clock domain
//***************************************************************************
reg  [FIFO_PTR:0] rd_ptr_wab_gray;
wire [FIFO_PTR:0] rd_ptr_wab_gray_nxt;

b2g #(.PTR(FIFO_PTR)) b2g_instance_rd
					  (.binary_value(rd_ptr_wab_nxt),
					   .gray_value(rd_ptr_wab_gray_nxt));

always@(posedge rdclk or negedge rstb_rdclk)
begin
	if(!rstb_rdclk)
		rd_ptr_wab_gray <= 'd0;
	else
		#20 rd_ptr_wab_gray <= rd_ptr_wab_gray_nxt;
end

//synchronize rd_ptr_gray into write clock domian
//****************************************************************************
reg [FIFO_PTR:0] rd_ptr_wab_gray_sync1;
reg [FIFO_PTR:0] rd_ptr_wab_gray_sync2;

always@(posedge wrclk or negedge rstb_wrclk)
begin
	if(!rstb_wrclk)
	begin
		rd_ptr_wab_gray_sync1 <= 'd0;
		rd_ptr_wab_gray_sync2 <= 'd0;
	end
	else
	begin
		rd_ptr_wab_gray_sync1 <= rd_ptr_wab_gray;
		rd_ptr_wab_gray_sync2 <= rd_ptr_wab_gray_sync1;
	end
end

//convert rd_ptr_wab_gray_sync2 back to binary
//****************************************************************************
reg  [FIFO_PTR:0] rd_ptr_wab_wrclk;
wire [FIFO_PTR:0] rd_ptr_wab_wrclk_nxt;

g2b #(.PTR(FIFO_PTR)) g2b_instance_rd
					  (.gray_value(rd_ptr_wab_gray_sync2),
					   .binary_value(rd_ptr_wab_wrclk_nxt));

always@(posedge wrclk or negedge rstb_wrclk)
begin
	if(!rstb_wrclk)
		rd_ptr_wab_wrclk <= 'd0;
	else
		rd_ptr_wab_wrclk <= rd_ptr_wab_wrclk_nxt;
end

assign wr_ptr = wr_ptr_wab[FIFO_PTR-1:0];
assign rd_ptr = rd_ptr_wab[FIFO_PTR-1:0];

//SRAM
//****************************************************************************
sram #(.FIFO_PTR   (FIFO_PTR),
	   .FIFO_WIDTH (FIFO_WIDTH)) sram_0
								 (.wrclk  (wrclk),
								  .wren   (write_en),
								  .wrptr  (wr_ptr),
								  .wrdata (write_data),
								  .rdclk  (rdclk),
								  .rden   (read_en),
								  .rdptr  (rd_ptr),
								  .rddata (read_data));

//Generate fifo_full
//****************************************************************************
assign fifo_full_nxt = 
	(wr_ptr_wab_nxt[FIFO_PTR] != rd_ptr_wab_wrclk_nxt[FIFO_PTR]) && 
	(wr_ptr_wab_nxt[FIFO_PTR-1:0] == rd_ptr_wab_wrclk_nxt[FIFO_PTR-1:0]);

assign room_avail_nxt = 
	(wr_ptr_wab[FIFO_PTR] == rd_ptr_wab_wrclk[FIFO_PTR])?
	(FIFO_DEPTH-(wr_ptr_wab[FIFO_PTR-1:0]-rd_ptr_wab_wrclk[FIFO_PTR-1:0])): // wrptr is in front of rdptr 
	(rd_ptr_wab_wrclk[FIFO_PTR-1:0]-wr_ptr_wab[FIFO_PTR-1:0]); //rdptr is in front of wrptr

//Generate fifo_empty
//****************************************************************************
assign fifo_empty_nxt = 
	(rd_ptr_wab_nxt[FIFO_PTR:0] == wr_ptr_wab_rdclk_nxt[FIFO_PTR:0]);

assign data_avail_nxt = 
	(rd_ptr_wab[FIFO_PTR] == wr_ptr_wab_rdclk[FIFO_PTR])?
	(wr_ptr_wab_rdclk[FIFO_PTR-1:0]-rd_ptr_wab[FIFO_PTR-1:0]):
	(FIFO_DEPTH - (rd_ptr_wab[FIFO_PTR-1:0]-wr_ptr_wab_rdclk[FIFO_PTR-1:0]));

always@(posedge wrclk or negedge rstb_wrclk)
begin
	if(!rstb_wrclk)
	begin
		fifo_full  <= 1'b0;
		room_avail <= FIFO_DEPTH;
	end
	else
	begin
		fifo_full   <= fifo_full_nxt;
		room_avail  <= room_avail_nxt;
	end
end

always@(posedge rdclk or negedge rstb_rdclk)
begin
	if(!rstb_rdclk)
	begin
		fifo_empty <= 1'b1;
		data_avail <= 'd0;
	end
	else
	begin
		fifo_empty <= fifo_empty_nxt;
		data_avail <= data_avail_nxt;
	end
end
endmodule


