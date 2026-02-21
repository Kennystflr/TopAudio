// =============================================================================
//                           COPYRIGHT NOTICE
// Copyright 2023 (c) Lattice Semiconductor Corporation
// ALL RIGHTS RESERVED
// This confidential and proprietary software may be used only as authorised by
// a licensing agreement from Lattice Semiconductor Corporation.
// The entire notice above must be reproduced on all authorized copies and
// copies may only be made to the extent permitted by a licensing agreement from
// Lattice Semiconductor Corporation.
//
// Lattice Semiconductor Corporation        TEL : 1-800-Lattice (USA and Canada)
// 5555 NE Moore Court                            408-826-6000 (other locations)
// Hillsboro, OR 97124                     web  : http://www.latticesemi.com/
// U.S.A                                   email: techsupport@lscc.com
// =============================================================================

// MODULE:   rr_arbiter
// DESIGN:   rr_arbiter
// FILENAME: rr_arbiter_tb.v
// PROJECT:  LFD2NX_example
// VERSION:  1.1
//
// Description:
//
// This is the Radiant example design for Certus-NX. This is a simple round robin arbiter which takes in 8 requests
// and provides grants based on the requests received. There is a timer which counts upto a certain time for each grant.
//
// This design can be targetted to Certus-NX Versa Evaluation board by using the constraints provided in the PDC file. This 
// design can be targetted to any other Certus-NX boards by changing the constraints. 
//
// The design includes a PLL IP to generate the clock and a FIFO IP to collect all the requests from the user (connected 
// to the switches on the target board). The fifo_write_en port is used as a write enable to the FIFO. The fifo_write_en port is connected
// to a push button on the board. The push button must be pressed after every request for the FIFO to read in the request values.
//
// The design also includes Reveal Analyzer and Controller feature usage demos. Reveal Analyzer is used to monitor the request and
// grant signals in the design. Reveal Controller is used to write to the PLL in the design using LMMI, to pause and resume the design's
// operation. For more information on this Reveal Controller demo, refer to "pll_control.tcl" in this project's top-level directory. It 
// includes additional instructions on how to use this part of the design with Reveal.
//
// Port descriptions:
// clock_in: input port used as an input clock to the PLL
// RESET_N: input port used as reset
// request: input port used as requests. These are mapped to the switches on the target board
// fifo_write_en: input port used as a write enable to the FIFO that collects all the requests. This is mapped to the push button on the target board
// grant: output port to provide grants. These are mapped to the status LEDs on the target board
// seg_out: output port used to display the grant value based on the request received. This is mapped to the 7 segement display on the target board
// 
//*****************************************************************************************************

`timescale 1 ns / 1 ps

module rr_arbiter (
  input  wire           	clock_in,
  input						RESET_N, 
  input      [3:0] 			request,
  input						fifo_write_en,
  output reg [3:0]			grant,  
  output reg [7:0]			seg_out
  );  

  reg [19:0] count;
  reg [2:0] state;
  reg [2:0] next_state;
  reg [3:0] grant_reg;
  reg [3:0]  comp_reg;
  wire [3:0] request_out;
  wire CLK;
  wire empty;
  wire lock;
  reg enable_reg;
  reg trigger;
  wire write_fifo;
  
  parameter [2:0]  		idle 	= 3'b000,
						read	= 3'b001,
						process	= 3'b010,
						grant0 	= 3'b011,
						grant1 	= 3'b100,
						grant2 	= 3'b101,
						grant3  = 3'b110;

//***********************************************************************
//PLL IP to generate the clock. clock_in is 20 MHz and CLK is is 100 MHz
//***********************************************************************
  my_pll pll_inst(.clki_i(clock_in),
        .rstn_i(RESET_N ),
        .clkop_o(CLK),
        .lock_o(lock ));

//***********************************************************************
//FIFO IP instantiation to collect requests
//***********************************************************************
  my_fifo fifo_inst(.clk_i(CLK ),
        .rst_i(!RESET_N ),
        .wr_en_i(write_fifo ),
        .rd_en_i(enable_reg ),
        .wr_data_i(request ),
        .full_o( ),
        .empty_o(empty ),
        .almost_full_o( ),
        .almost_empty_o( ),
        .rd_data_o(request_out));
  
  assign write_fifo = (!fifo_write_en && (request != 4'h0)) ? 1 : 0;
  
  always @(posedge CLK or negedge RESET_N) begin	
	  if(!RESET_N) begin
		  state <= idle;
		  grant <= 4'hF;
		  comp_reg <= 0;		  
	  end   
	  else begin
		  state <= next_state;
		  grant <= grant_reg;  
		  if (next_state == read) 
			  comp_reg <= request_out;			  
	  end	  
  end
  always @ (posedge CLK or negedge RESET_N) begin
	if (!RESET_N) seg_out <= 8'hFF;
	else case (grant)
		4'b1110: seg_out <= 8'b11000000; //0
		4'b1101: seg_out <= 8'b11001111; //1
		4'b1011: seg_out <= 8'b10100100; //2
		4'b0111: seg_out <= 8'b10000110; //3
		default: seg_out <= 8'hFF;
		endcase
	end

  always @(posedge CLK or negedge RESET_N) begin	
 	  if(!RESET_N) begin
		  count <= 20'b0;
	  end  
	  else begin		  
		  if (trigger) begin	  
			if (count == 20'h5FFFF) count <= 8'b0;
			else count <= count + 1'b1;						
		  end	  
		  else begin
			count <= 20'b0;			  
		  end  
	  end
  end

//*****************************************************************
//State machine tp process grants based on the requests
//*****************************************************************

  always @(*) begin
	  if (!RESET_N) begin
		  enable_reg = 0;
		  next_state = idle;
		  grant_reg = 4'hF;
		  trigger = 0;		  
		  end
	  else case (state)		  
		idle: begin
					grant_reg = 4'hF;
					trigger = 0;
					enable_reg = 0;					
					if (!empty && lock) begin
						enable_reg = 1;						
						next_state = read;					
					end
					else next_state = idle;					
				end				
		read: begin
					enable_reg = 0;		
					grant_reg = 4'hF;
					trigger = 0;
					if (comp_reg == request_out) next_state = process;
					else next_state = read;						
				end
				
		process: begin	
					enable_reg = 0;		
					grant_reg = 4'hF;
					trigger = 0;					
					if (request_out[0]) next_state = grant0;
					else if (request_out[1]) next_state = grant1;	
					else if (request_out[2]) next_state = grant2;
					else if (request_out[3]) next_state = grant3;
					else next_state = idle;					
				end
				
		grant0: begin
					enable_reg = 0;
					grant_reg = 4'b1110;
					trigger = 1;					
					if (count == 20'h5FFFF) begin
						next_state = idle;
						trigger = 0;
					end
					else next_state = grant0;
				end
			
		grant1: begin
					enable_reg = 0;
					grant_reg = 4'b1101;
					trigger = 1;					
					if (count == 20'h5FFFF) begin
						next_state = idle;
						trigger = 0;
					end
					else next_state = grant1;						
				end
				
		grant2: begin
					enable_reg = 0;
					grant_reg = 4'b1011;
					trigger = 1;					
					if (count == 20'h5FFFF) begin
						next_state = idle;
						trigger = 0;
					end
					else next_state = grant2;						
				end		
				
		grant3: begin
					enable_reg = 0;
					grant_reg = 4'b0111;
					trigger = 1;					
					if (count == 20'h5FFFF) begin
						next_state = idle;
						trigger = 0;
					end
					else next_state = grant3;						
				end						
		
		default: begin
					next_state = idle;
					enable_reg = 0;
					grant_reg = 4'hF;		
					trigger = 0;					
				end				
			endcase						
  end  
endmodule