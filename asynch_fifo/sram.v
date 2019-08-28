module sram #(parameter FIFO_PTR = 4,
						FIFO_WIDTH = 32,
						FIFO_DEPTH = 16)
	   (wrclk,
	    wren,
		wrptr,
		wrdata,
		rdclk,
		rden,
		rdptr,
		rddata);

input wrclk;
input wren;
input [FIFO_PTR-1:0] wrptr;
input [FIFO_WIDTH-1:0] wrdata;
input rdclk;
input rden;
input [FIFO_PTR-1:0] rdptr;
output [FIFO_WIDTH-1:0] rddata;

wire wrclk;
wire  wren;
wire [FIFO_PTR-1:0] wrptr;
wire [FIFO_WIDTH-1:0] wrdata;
wire rdclk;
wire rden;
wire [FIFO_PTR-1:0] rdptr;
reg [FIFO_WIDTH-1:0] rddata;

reg [FIFO_WIDTH-1:0] ram [0:FIFO_DEPTH-1];
initial begin
$readmemh("data.txt",ram);
end

always@(posedge wrclk)
begin
	#5 if(wren)
	ram[wrptr] = wrdata;
end

always@(posedge rdclk)
begin
	if(rden)
	rddata = ram[rdptr];
end

endmodule

