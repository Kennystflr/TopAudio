
// MODULE:   rr_arbiter
// DESIGN:   rr_arbiter
// FILENAME: rr_arbiter_tf.v
// PROJECT:  LFD2NX_example
// VERSION:  2.0
// Testbench file


`timescale 1 ns / 1 ps

module rr_arbiter_tb();

// GSR and PUR
    GSR GSR_INST (.GSR_N(1'b1), .CLK());
    PUR PUR_INST (.PUR(1'b1));

// Inputs
    reg clock_in
    reg RESET_N;
    reg [3:0] request;
    reg fifo_write_en;
// Outputs
    wire [3:0] grant;
	
  always
	#25 clock_in = ~clock_in;

// Instantiate the UUT
    rr_arbiter UUT (
        .clock_in(clock_in), 
        .RESET_N(RESET_N), 
        .request(request), 
        .fifo_write_en(fifo_write_en), 
        .grant(grant)
        );

// Initialize Inputs
    initial begin
			clock_in = 0;
            RESET_N = 0;
            request = 0;
            fifo_write_en = 0;
			#200 RESET_N = 1;
			#200 request = 4'b0001;
			fifo_write_en = 1;
			#20 fifo_write_en =0;
			#200 request = 4'b0100;
			fifo_write_en = 1;
			#20 fifo_write_en =0;
			#200 request = 4'b0001;
			fifo_write_en = 1;
			#20 fifo_write_en =0;
			#200 request = 4'b0010;
			fifo_write_en = 1;			
			#20 fifo_write_en =0; 
			request = 4'b0000;
    end

endmodule // rr_arbiter_tf