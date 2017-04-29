/*
Copyright by Pouya Taatizadeh
Developed for the Digital Systems Design course (COE3DQ5)
Department of Electrical and Computer Engineering
McMaster University
Ontario, Canada
*/

`timescale 1ns/100ps
`default_nettype none

`include "define_state.h"

module M3 (

	input logic CLOCK_50_I,                   // 50 MHz clock
	input logic resetn, 					  // top level master reset
	input logic M3_start,
	output logic M3_done, 
	// signals for the SRAM
	input logic [15:0] M3_SRAM_read_data,
	output logic [15:0] M3_SRAM_write_data,
	output logic [17:0] M3_SRAM_address,
	output logic M3_SRAM_we_n

);


M3_state_type top_state;

logic start_buf;
//// M3 signals

always @(posedge CLOCK_50_I or negedge resetn) begin
	if (~resetn) begin
		top_state <= S_M3_IDLE;
		start_buf <= 1'b0;
		M3_done <= 1'b0;

		M3_SRAM_we_n <= 1'b1;
		M3_SRAM_write_data <= 16'd0;
		M3_SRAM_address <= 18'd0;
		
	end else begin

		case (top_state)
		S_M3_IDLE: begin
			if(M3_start && ~start_buf) begin
				top_state <= S_M3_1;
			end 

		end
		//// ADD YOUR CODE HERE
		S_M3_1: begin
			top_state <= S_M3_DONE;
		end
		S_M3_DONE: begin

			M3_done <= 1'b1;
		end

		default: top_state <= S_M3_IDLE;
		endcase
	end
end
endmodule
