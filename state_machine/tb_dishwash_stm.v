`timescale 1ns/1ps
module dishwash_stm_tb; 

reg clk; 
reg rstb;
reg start_but_pressed;
reg hfminute_tick;
reg blow_dry;

wire do_foam_dispensing;
wire do_scrubbing;
wire do_rinsing;
wire do_drying;

initial
begin 
clk = 1'b0;
rstb = 1'b0;
start_but_pressed = 1'b1;
hfminute_tick = 1'b0;
blow_dry = 1'b1;
#50 rstb = 1'b1;
end   

always
begin
	#50 clk = ~clk;
	//#50 hfminute_tick = ~hfminute_tick;
end

always
begin 
	#100 hfminute_tick = ~hfminute_tick;
end


dishwash_stm dishwash_stm_instance( 
.clk(clk),
.rstb(rstb),
.start_but_pressed(start_but_pressed),
.hfminute_tick(hfminute_tick),
.blow_dry(blow_dry),
.do_foam_dispensing(do_foam_dispensing),
.do_scrubbing(do_scrubbing),
.do_rinsing(do_rinsing),
.do_drying(do_drying)
); 

initial begin 
$dumpfile("tb_dishwash_stm.vcd"); 
$dumpvars(0, dishwash_stm_tb); 
end 

initial #10000000 $finish;

endmodule
