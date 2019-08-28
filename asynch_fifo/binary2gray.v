module g2b #(parameter PTR=8)
	   (input  [PTR:0] gray_value,
		output [PTR:0] binary_value);


assign binary_value[PTR] = gray_value[PTR];

generate
	genvar i;
	for(i=0;i<(PTR);i=i+1)
	begin
		assign binary_value[i] = binary_value[i+1]^gray_value[i];
	end
endgenerate
endmodule

module b2g #(parameter PTR=8)
		(input  [PTR:0] binary_value,
		 output [PTR:0] gray_value);


assign gray_value[PTR] = binary_value[PTR];

generate
	genvar i;
	for(i=0;i<(PTR);i=i+1)
	begin
		assign gray_value[i]=binary_value[i+1]^binary_value[i];
	end
endgenerate
endmodule
