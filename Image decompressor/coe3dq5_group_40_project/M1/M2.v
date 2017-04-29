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

module M2 (

	input logic CLOCK_50_I,                   // 50 MHz clock
	input logic resetn, 					  // top level master reset
	input logic M2_start,
	output logic M2_done, 
	// signals for the SRAM
	input logic [15:0] M2_SRAM_read_data,
	output logic [15:0] M2_SRAM_write_data,
	output logic [17:0] M2_SRAM_address,
	output logic M2_SRAM_we_n,

	/////// signals for multipliers in top level
	output logic [31:0] M2_mult_1_in1,
	output logic [31:0] M2_mult_1_in2,
	output logic [31:0] M2_mult_2_in1,
	output logic [31:0] M2_mult_2_in2,
	output logic [31:0] M2_mult_3_in1,
	output logic [31:0] M2_mult_3_in2,

	input logic [63:0] M2_mult_res_1,
	input logic [63:0] M2_mult_res_2,
	input logic [63:0] M2_mult_res_3
);


M2_state_type top_state;




/// multipliers signal in M2 ///////////////////////////////////////////

logic [31:0] mult_op_1, mult_op_2, mult_op_3, mult_op_4, mult_op_5, mult_op_6;
logic [63:0] mult_res_1, mult_res_2, mult_res_3;

assign M2_mult_1_in1 = mult_op_1;
assign M2_mult_1_in2 = mult_op_2;
assign M2_mult_2_in1 = mult_op_3;
assign M2_mult_2_in2 = mult_op_4;
assign M2_mult_3_in1 = mult_op_5;
assign M2_mult_3_in2 = mult_op_6;

assign mult_res_1 = M2_mult_res_1;
assign mult_res_2 = M2_mult_res_2;
assign mult_res_3 = M2_mult_res_3;

////////////////////////////////////////////////////////////////////////

logic start_buf;

//////// M2_signals

always @(posedge CLOCK_50_I or negedge resetn) begin
	if (~resetn) begin
		top_state <= S_M2_IDLE;
		start_buf <= 1'b0;
		M2_done <= 1'b0;

		mult_op_1 <= 32'd0;
		mult_op_2 <= 32'd0;
		mult_op_3 <= 32'd0;
		mult_op_4 <= 32'd0;
		mult_op_5 <= 32'd0;
		mult_op_6 <= 32'd0;

		M2_SRAM_address <= 18'd0;
		M2_SRAM_write_data <= 16'd0;
		M2_SRAM_we_n <= 1'b1;
		

	end else begin

		case (top_state)
		S_M2_IDLE: begin
			if(M2_start && ~start_buf) begin
				top_state <= S_M2_1;
			end 

		end
		//// ADD YOUR CODE HERE
		S_M2_1: begin
			top_state <= S_M2_DONE;
		end
		S_M2_DONE: begin

			M2_done <= 1'b1;
		end

		default: top_state <= S_M2_IDLE;
		endcase
	end
end
endmodule
