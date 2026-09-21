module Simple_mac #(
	parameter int INPUT_WIDTH = 8,
	parameter int ACC_WIDTH   = 32
	)(
    input  logic                                clk,
    input  logic                                rst,
	input  logic  							valid_in,
	input  logic  							acc_clr,
    input  logic signed [INPUT_WIDTH-1:0]       a,
    input  logic signed [INPUT_WIDTH-1:0]       b,
    output logic                                valid_out,
    output logic signed [ACC_WIDTH-1:0]         acc
    
);
	localparam PRODUCT_WIDTH  = 2*INPUT_WIDTH;
    logic signed [PRODUCT_WIDTH-1:0] product;
	logic signed [PRODUCT_WIDTH-1:0] product_reg;
    logic signed [ACC_WIDTH-1:0]	   signed_ext_product;
    logic signed [ACC_WIDTH-1:0] 	   adder_sum;
	logic  							   product_valid;
	
	// Parameter legality check
	initial begin
		if (ACC_WIDTH < PRODUCT_WIDTH)
			$fatal(
				"Invalid MAC configuration: ACC_WIDTH=%0d, PRODUCT_WIDTH=%0d",
				ACC_WIDTH,
				PRODUCT_WIDTH
			);
	end
    
	always_comb
		begin
		  product = a*b;
		  //product_reg = product;
		  signed_ext_product = {{ACC_WIDTH-PRODUCT_WIDTH{product_reg[PRODUCT_WIDTH-1]}},product_reg};
		  adder_sum = signed_ext_product + acc;
		end
		
	always_ff @(posedge clk)
		begin
			if (rst) begin
				product_reg   <= 16'b0;
				product_valid <= 1'b0;
				valid_out <= 1'b0;
				acc           <= 32'b0;
			end
			else 
				begin
					if(acc_clr)
						begin 
							acc<=32'b0;
							product_valid<=0;
							valid_out <= 1'b0;
						end 
					else 
						begin
							// Stage 1: capture new product only when input is valid
							if (valid_in)
								product_reg <= product;

							// Move valid information with the pipeline
							product_valid <= valid_in;
							
							// Output valid when accumulator gets updated 
							valid_out <= product_valid;

							// Stage 2: accumulate previously stored valid product
							if (product_valid)
								acc <= adder_sum;
						end 
				end
		end
					
endmodule
