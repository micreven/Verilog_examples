module add(
	input clk,
	input [3:0] add_a,
	input [3:0] add_b,
	output [4:0] add_res);

	wire [3:0] add_a,add_b;
	reg [4:0] add_res;

	wire c_1;
	wire c_2;
	wire c_3;
	wire c_4;

	assign c_1 = add_a[0] & add_b[0];
	assign c_2 = (add_a[1] & add_b[1]) | ((add_a[1] ^ add_b[1]) & c_1);
	assign c_3 = (add_a[2] & add_b[2]) | ((add_a[2] ^ add_b[2]) & c_2);
	assign c_4 = (add_a[3] & add_b[3]) | ((add_a[3] ^ add_b[3]) & c_3);

	always@(posedge clk)
	begin
		add_res[0] <= add_a[0] ^ add_b[0];
		//c_1 <= add_a[0] & add_b[0];
		add_res[1] <= add_a[1] ^ add_b[1] ^ c_1;
		//c_2 <= (add_a[1] & add_b[1]) | ((add_a[1] ^ add_b[1]) & c_1);
		add_res[2] <= add_a[2] ^ add_b[2] ^ c_2;
		//c_3 <= (add_a[2] & add_b[2]) | ((add_a[2] ^ add_b[2]) & c_2);
		add_res[3] <= add_a[3] ^ add_b[3] ^ c_3;
		//c_4 <= (add_a[3] & add_b[3]) | ((add_a[3] ^ add_b[3]) & c_3);
		add_res[4] <= c_4;
	end

	endmodule


		

