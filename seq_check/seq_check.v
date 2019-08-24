module seq_check
	(clk,
	rstb,
	in_a,
	out_b);

input wire clk;
input wire rstb;
input wire in_a;
output reg out_b;

localparam S0 = 3'b000,
S1 = 3'b001,
S2 = 3'b010,
S3 = 3'b011,
S4 = 3'b100;

reg [2:0] now_state,state_nxt;

always@(*)
begin
	state_nxt = now_state;
	case(now_state)
	S0:
	begin
		if(in_a)
		begin
			state_nxt = S1;
		end
		else
		begin
			state_nxt = S0;
		end
	end
	S1:
	begin
		if(in_a)
		begin
			state_nxt = S2;
		end
		else
		begin
			state_nxt = S0;
		end
	end
	S2:
	begin
		if(!in_a)
		begin
			state_nxt = S3;
		end
		else
		begin
			state_nxt = S2;
		end
	end
	S3:
	begin
		if(in_a)
		begin
			state_nxt = S4;
		end
		else
		begin
			state_nxt = S0;
		end
	end
	S4:
	begin
		if(in_a)
		begin
			state_nxt = S1;
		end
	    else
		begin
			state_nxt = S0;
		end
	end	
	default:begin end
endcase
end

always@(posedge clk or negedge rstb)
begin
	if(!rstb)
	begin
		now_state = S0;
	end
	else
	begin
		now_state <= state_nxt;
		out_b <= (now_state === S4);
	end
end

endmodule


