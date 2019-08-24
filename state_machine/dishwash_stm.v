module dishwash_stm
		(clk,
		rstb,
		start_but_pressed,
		hfminute_tick,
		blow_dry,
		do_foam_dispensing,
		do_scrubbing,
		do_rinsing,
		do_drying);
input clk;
input rstb;
input start_but_pressed;
input hfminute_tick;
input blow_dry;
output do_foam_dispensing;
output do_scrubbing;
output do_rinsing;
output do_drying;

localparam IDLE = 3'd0,
FOAM = 3'd1,
SCRUB = 3'd2,
RINSE = 3'd3,
BLOWDRY = 3'd4;

parameter FOAM_DURATION =10,
	SCRUB_DURATION =16,
	RINSE_DURATION = 10,
	BLOWDRY_DURATION = 12;

reg [2:0] dw_state,dw_state_nxt;
reg [4:0] minutes_timer,minutes_timer_nxt;
reg do_foam_dispensing,do_foam_dispensing_nxt;
reg do_scrubbing,do_scrubbing_nxt;
reg do_rinsing,do_rinsing_nxt;
reg do_drying,do_drying_nxt;
wire foam_done,scrub_done;
wire rinse_done,blowdry_done;
wire timer_expired;
wire [4:0] minutes_timer_minus_one;

assign timer_expired = (minutes_timer == 'd0);
assign foam_done = timer_expired;
assign scrub_done = timer_expired;
assign rinse_done = timer_expired;
assign blowdry_done = timer_expired;
assign minutes_timer_minus_one = minutes_timer-1'b1;

always@(*)
begin
	//assign all default values here
	dw_state_nxt = dw_state;
	minutes_timer_nxt = minutes_timer;
	do_foam_dispensing_nxt = 1'b0;
	do_scrubbing_nxt = 1'b0;
	do_rinsing_nxt = 1'b0;
	do_drying_nxt = 1'b0;

	case(dw_state)

	IDLE:
	begin
		if(start_but_pressed)
		begin
			dw_state_nxt = FOAM;
			do_foam_dispensing_nxt = 1'b1;
			minutes_timer_nxt = FOAM_DURATION;
		end
	end

	FOAM:
	begin
		if(foam_done)
		begin
			do_foam_dispensing_nxt = 1'b0;
			dw_state_nxt = SCRUB;
			do_scrubbing_nxt = 1'b1;
			minutes_timer_nxt = SCRUB_DURATION;
		end
		else
		begin
			do_foam_dispensing_nxt = 1'b1;
			if(hfminute_tick)
				minutes_timer_nxt = minutes_timer_minus_one;
		end
	end

	SCRUB:
	begin
		if(scrub_done)
		begin
			do_scrubbing_nxt = 1'b0;
			dw_state_nxt = RINSE;
			do_rinsing_nxt = 1'b1;
			minutes_timer_nxt = RINSE_DURATION;
		end
		else
		begin
			do_scrubbing_nxt = 1'b1;
			if(hfminute_tick) 
				minutes_timer_nxt = minutes_timer_minus_one;
		end
	end

	RINSE:
	begin
		if(rinse_done)
		begin
			do_rinsing_nxt = 1'b0;
			if(blow_dry)
			begin
				dw_state_nxt = BLOWDRY;
				do_drying_nxt = 1'b1;
				minutes_timer_nxt = BLOWDRY_DURATION;
			end
			else
				dw_state_nxt = IDLE;
		end
		else
		begin
		if(hfminute_tick)
			minutes_timer_nxt = minutes_timer_minus_one;
			do_rinsing_nxt = 1'b1;
		end
	end

	BLOWDRY:
	begin
		if(blowdry_done)
		begin
			do_drying_nxt = 1'b0;
			dw_state_nxt = IDLE;
		end
		else
		begin
			do_drying_nxt = 1'b1;
			if(hfminute_tick)
				minutes_timer_nxt = minutes_timer_minus_one;
		end
	end

	default:begin end
endcase
end

always@(posedge clk or negedge rstb)
begin
	if(!rstb)
	begin
		dw_state <= IDLE;
		minutes_timer <= 'd0;
		do_foam_dispensing <= 1'b0;
		do_scrubbing <= 1'b0;
		do_rinsing <= 1'b0;
		do_drying <= 1'b0;
	end
	else
	begin
		dw_state <= dw_state_nxt;
		minutes_timer <= minutes_timer_nxt;
		do_foam_dispensing <= do_foam_dispensing_nxt;
		do_scrubbing <= do_scrubbing_nxt;
		do_rinsing <= do_rinsing_nxt;
		do_drying <= do_drying_nxt;
	end
end
endmodule









