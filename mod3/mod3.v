module mod3(
	input clk,
	input rstb,
	input input_num,
	output res);

localparam S0 = 2'b00,
	S1 = 2'b01,
	S2 = 2'b10,
	S3 = 2'b11;

wire clk,input_num,rstb;
reg res,num;
reg [1:0] now_state,next_state;

always@(*)
begin
	case(now_state)
		S0:
		begin
			if(num)
				next_state = S1;
			else
				next_state = S0;
		end

		S1:
		begin
			if(num)
				next_state = S3;
			else
				next_state = S2;
		end

		S2: 
		begin
			if(num)
				next_state = S1;
			else
				next_state = S0;
		end

		S3:
		begin
			if(num)
				next_state = S1;
			else
				next_state = S3;
		end
		default:begin end
endcase
end

always@(posedge clk or negedge rstb)
begin
	if(!rstb)
	begin
		now_state <= S0;
		next_state <= S0;
		num <= 1'b0;
	end
	else
	begin
		num <= input_num;
		now_state <= next_state;
		//now_state <= (next_state << 1) % 3;
		if(now_state == S3)
			res = 1'b1;
		else
			res = 1'b0;
	end
end
endmodule
