module Simple_mac_tb;

	parameter int INPUT_WIDTH = 8;
	parameter int ACC_WIDTH   = 32;
	parameter int PRODUCT_WIDTH = 2*INPUT_WIDTH;

	logic clk;
	logic rst;
	logic valid_in;
	logic acc_clr;

	logic signed [INPUT_WIDTH-1:0] a;
	logic signed [INPUT_WIDTH-1:0] b;

	logic valid_out;
	logic signed [ACC_WIDTH-1:0] acc;


	// Reference model variables
	logic signed [PRODUCT_WIDTH-1:0] expected_product;
	logic signed [ACC_WIDTH-1:0]     expected_acc;
	logic                             expected_product_valid;
	logic                             expected_valid_out;

	int pass_count;
	int fail_count;


	Simple_mac #(
		.INPUT_WIDTH(INPUT_WIDTH),
		.ACC_WIDTH(ACC_WIDTH)
	) dut (
		.clk(clk),
		.rst(rst),
		.valid_in(valid_in),
		.acc_clr(acc_clr),
		.a(a),
		.b(b),
		.valid_out(valid_out),
		.acc(acc)
	);


	// Clock generation
	initial begin
		clk = 0;
		forever #5 clk = ~clk;
	end


	// Reference model and checker
	always @(posedge clk)
		begin

			if (rst)
				begin
					expected_product       = '0;
					expected_acc           = '0;
					expected_product_valid = 1'b0;
					expected_valid_out     = 1'b0;
				end

			else if (acc_clr)
				begin
					expected_product       = '0;
					expected_acc           = '0;
					expected_product_valid = 1'b0;
					expected_valid_out     = 1'b0;
				end

			else
				begin

					// Previous product should now reach accumulator
					expected_valid_out = expected_product_valid;

					if (expected_product_valid)
						expected_acc = expected_acc + expected_product;


					// Capture current input for next pipeline cycle
					if (valid_in)
						expected_product = a*b;

					expected_product_valid = valid_in;

				end


			// Wait for DUT non-blocking assignments to update
			#1;


			// Check valid_out
			if (valid_out !== expected_valid_out)
				begin
					$display(
						"FAIL VALID: time=%0t expected=%0b actual=%0b",
						$time,
						expected_valid_out,
						valid_out
					);

					fail_count = fail_count + 1;
				end


			// Check accumulator
			if (acc !== expected_acc)
				begin
					$display(
						"FAIL ACC: time=%0t expected=%0d actual=%0d",
						$time,
						expected_acc,
						acc
					);

					fail_count = fail_count + 1;
				end

			else if (expected_valid_out)
				begin
					$display(
						"PASS: time=%0t expected ACC=%0d actual ACC=%0d",
						$time,
						expected_acc,
						acc
					);

					pass_count = pass_count + 1;
				end

		end


	// Stimulus
	initial begin

		pass_count = 0;
		fail_count = 0;

		rst      = 1'b1;
		valid_in = 1'b0;
		acc_clr  = 1'b0;
		a        = '0;
		b        = '0;


		#20;

		rst = 1'b0;


		// Transaction 1
		// 2 * 3 = 6
		@(negedge clk);
		valid_in = 1'b1;
		a        = 8'sd2;
		b        = 8'sd3;


		// Transaction 2
		// 4 * 5 = 20
		@(negedge clk);
		valid_in = 1'b1;
		a        = 8'sd4;
		b        = 8'sd5;


		// Transaction 3
		// -2 * 4 = -8
		@(negedge clk);
		valid_in = 1'b1;
		a        = -8'sd2;
		b        = 8'sd4;


		// Stop sending transactions
		@(negedge clk);
		valid_in = 1'b0;
		a        = '0;
		b        = '0;


		// Allow pipeline to empty
		repeat(2)
			@(negedge clk);


		// Clear accumulator
		acc_clr = 1'b1;

		@(negedge clk);
		acc_clr = 1'b0;


		repeat(2)
			@(negedge clk);


		// Final test result
		if (fail_count == 0)
			begin
				$display("");
				$display("==========================");
				$display("       TEST PASSED");
				$display("       PASSES = %0d", pass_count);
				$display("==========================");
			end

		else
			begin
				$display("");
				$display("==========================");
				$display("       TEST FAILED");
				$display("       FAILURES = %0d", fail_count);
				$display("==========================");
			end


		$finish;

	end

endmodule