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
	output logic M2_SRAM_we_n


);
//////////////////////////////////////////////////////////////
M2_state_type top_state;

// #1 added parameters starts here
parameter post_IDCT_address = 18'd0,
            pre_IDCT_address = 18'd76800;
////////////////////////////////////////////////////////////////////////

logic [17:0] h_counter;
logic [17:0] v_counter;
logic [17:0] h_offset;
logic [17:0] hw_offset;
logic [17:0] v_offset;
logic [6:0] rc_counter;
logic [6:0] dc_counter;
logic [6:0] rsp_counter;
logic [6:0] dsp_counter;
logic [6:0] rct_counter;
logic [6:0] dct_counter;
logic [6:0] rs_counter;
logic [6:0] ds_counter;
logic [6:0] rt_counter;
logic [6:0] rf_counter;
logic [6:0] dt_counter;
logic [6:0] df_counter;
logic [6:0] ro_counter;
logic [6:0] do_counter;
logic [6:0] ro1_counter;
logic [6:0] do1_counter;
logic[31:0]T_buff;
logic[31:0]T1_buff;
logic[31:0]S_buff;
logic[31:0]S1_buff;
logic[31:0]f_buff;



logic [17:0] YUV_cnt;
logic [5:0] S_cnt;
logic [5:0] C_cnt;
logic [5:0] P_cnt;
logic [5:0] row_cnt;
logic [5:0] col_cnt;

logic [17:0] write_col_cnt;
logic [17:0] write_row_cnt;
logic [17:0] write_col_offset;
logic [17:0] write_row_offset;
logic flag;
logic U_V_write;

////////////////////////////////////////////////////////////////////////             

/// multipliers signal in M2 ///////////////////////////////////////////
logic signed[63:0] mult_res_1;
logic signed[63:0] mult_res_2;
logic signed[31:0] mult_op_1, mult_op_2, mult_op_3, mult_op_4;
assign mult_res_1 =  mult_op_1 * mult_op_2;
assign mult_res_2 = mult_op_3 * mult_op_4;
////////////////////////////////////////////////////////////////////////



////////////////////////////////////////////////////////////////////////

logic start_buf;


logic [6:0] read_addressa1, write_address,read_addressb1,read_addressa0,read_addressb0;
logic [31:0] write_data_a [1:0];
logic [31:0] write_data_b [1:0];
logic write_enable_a[1:0];
logic write_enable_b [1:0];
logic [31:0] read_data_a [1:0];
logic [31:0] read_data_b [1:0];


// Instantiate RAM1
dual_port_RAM1 dual_port_RAM_inst1 (
	.address_a ( read_addressa1 ),
	.address_b ( read_addressb1 ),
	.clock (CLOCK_50_I ),
	.data_a ( write_data_a[1] ),
	.data_b ( write_data_b[1] ),
	.wren_a ( write_enable_a[1] ),
	.wren_b ( write_enable_b[1] ),
	.q_a ( read_data_a[1] ),
	.q_b ( read_data_b[1] )
	);

// Instantiate RAM0
dual_port_RAM0 dual_port_RAM_inst0 (
	.address_a ( read_addressa0),
	.address_b ( read_addressb0 ),
	.clock ( CLOCK_50_I),
	.data_a (  write_data_a[0] ),
	.data_b ( write_data_b[0] ),
	.wren_a ( write_enable_a[0] ),
	.wren_b ( write_enable_b[0] ),
	.q_a ( read_data_a[0] ),
	.q_b ( read_data_b[0] )
	);


always @(posedge CLOCK_50_I or negedge resetn) begin
	if (~resetn) begin
		top_state <= S_M2_IDLE;
		start_buf <= 1'b0;
		M2_done <= 1'b0;

		mult_op_1 <= 32'd0;
		mult_op_2 <= 32'd0;
		mult_op_3 <= 32'd0;
		mult_op_4 <= 32'd0;

		
		M2_SRAM_address <= 18'd0;
		M2_SRAM_write_data <= 16'd0;
		M2_SRAM_we_n <= 1'b1;
		
        read_addressa1 <= 7'd0;
		read_addressb1 <= 7'd0;
		read_addressa0 <= 7'd0;
		read_addressb0 <= 7'd0;
				
		write_enable_b[0] <= 1'b0;
		write_enable_b[1] <= 1'b0;
		write_enable_a[0] <= 1'b0;
		write_enable_a[1] <= 1'b0;

		h_counter <= 18'd0;
		v_counter <= 18'd0;
		h_offset <= 18'd0;
		hw_offset <= 18'd0;
		v_offset <= 18'd0;
		T_buff<=32'd0;
		T1_buff<=32'd0;
		S_buff<=32'd0;
		S1_buff<=32'd0;
		f_buff<=32'd0;
		rc_counter<= 7'd0;
		dc_counter<= 7'd0;
		ro_counter<= 7'd0;
		do_counter<= 7'd0;
		ro1_counter<= 7'd0;
		do1_counter<= 7'd0;
        rsp_counter<= 7'd0;
        dsp_counter<= 7'd0;
		rct_counter<= 7'd0;
		dct_counter<= 7'd0;
        rs_counter<= 7'd0;
        ds_counter<= 7'd0;
		rt_counter<= 7'd0;
		rf_counter<= 7'd0;
        dt_counter<= 7'd0;
		df_counter<= 7'd0;

	end else begin
			start_buf <= M2_start;
		case (top_state)
		S_M2_IDLE: begin
			if(M2_start && ~start_buf) begin
			    M2_SRAM_we_n <= 1'b1;
				
				top_state <= S_M2_0;
			end 
		end
//----------------------------------------------------------------------------//
		S_M2_0: begin
			
			M2_SRAM_address <= pre_IDCT_address + h_counter + (v_counter*18'd320) + (h_offset*18'd8) + (v_offset*18'd8*18'd320); 
		    h_counter<= h_counter + 18'd1;
			top_state <= S_M2_1;
		end
//----------------------------------------------------------------------------//		
		S_M2_1: begin
			M2_SRAM_address <= pre_IDCT_address + h_counter + (v_counter*18'd320) + (h_offset*18'd8) + (v_offset*18'd8*18'd320);
			h_counter<= h_counter + 18'd1;
			
			top_state <= S_M2_2;
		end
//----------------------------------------------------------------------------//		
		S_M2_2: begin
			M2_SRAM_address <= pre_IDCT_address + h_counter + (v_counter*18'd320) + (h_offset*18'd8) + (v_offset*18'd8*18'd320);
			h_counter<= h_counter + 18'd1;
			
			//write
			write_enable_a[0] <= 1'b1;
			top_state <= S_M2_3;
		end
//----------------------------------------------------------------------------//				
		S_M2_3: begin
			M2_SRAM_address <= pre_IDCT_address + h_counter + (v_counter*18'd320) + (h_offset*18'd8) + (v_offset*18'd8*18'd320);
			h_counter<= h_counter + 18'd1;
			//write s'0
			write_data_a[0] =$signed(M2_SRAM_read_data);
			//read_addressa0<=read_addressa0+ 8'd1;
			
			top_state <= S_M2_4;
		end
//----------------------------------------------------------------------------//		
		S_M2_4: begin
			M2_SRAM_address <= pre_IDCT_address + h_counter + (v_counter*18'd320) + (h_offset*18'd8) + (v_offset*18'd8*18'd320);
			h_counter<= h_counter + 18'd1;
			write_data_a[0] =$signed(M2_SRAM_read_data);
			read_addressa0<=read_addressa0+ 8'd1;
			
			top_state <= S_M2_5;
		end
//----------------------------------------------------------------------------//		
		S_M2_5: begin
			M2_SRAM_address <= pre_IDCT_address + h_counter + (v_counter*18'd320) + (h_offset*18'd8) + (v_offset*18'd8*18'd320);
			h_counter<= h_counter + 18'd1;
			write_data_a[0] =$signed(M2_SRAM_read_data);
			read_addressa0<=read_addressa0+ 8'd1;
			
			top_state <= S_M2_6;
		end
//----------------------------------------------------------------------------//		
		S_M2_6: begin
			M2_SRAM_address <= pre_IDCT_address + h_counter + (v_counter*18'd320) + (h_offset*18'd8) + (v_offset*18'd8*18'd320);
			h_counter<= h_counter + 18'd1;
			write_data_a[0] =$signed(M2_SRAM_read_data);
			read_addressa0<=read_addressa0+ 8'd1;
			
			top_state <= S_M2_7;
			
		end
//----------------------------------------------------------------------------//		
		S_M2_7: begin
			M2_SRAM_address <= pre_IDCT_address + h_counter + (v_counter*18'd320) + (h_offset*18'd8) + (v_offset*18'd8*18'd320);
			h_counter<= 18'd0;
			write_data_a[0] =$signed(M2_SRAM_read_data);
			read_addressa0<=read_addressa0+ 8'd1;
			
			top_state <= S_M2_8;
			
		end
//----------------------------------------------------------------------------//		
		S_M2_8: begin
		     write_data_a[0] =$signed(M2_SRAM_read_data);
			read_addressa0<=read_addressa0+ 8'd1;
			
			top_state <= S_M2_9;
		end
//----------------------------------------------------------------------------//		
		S_M2_9: begin
			write_data_a[0] =$signed(M2_SRAM_read_data);
			read_addressa0<=read_addressa0+ 8'd1;
			
			top_state <= S_M2_10;
		end
//----------------------------------------------------------------------------//		
		S_M2_10: begin
		    
			read_addressa0<=read_addressa0+ 8'd1;
			top_state <= S_M2_11;
			
		    
		end
//----------------------------------------------------------------------------//		
//----------------------------------------------------------------------------//		
//----------------------------------------------------------------------------//		
		S_M2_11: begin
		    write_enable_a[0] <= 1'b0;
			if(v_counter==18'd7)begin 
			v_counter<=18'd0;
			read_addressb1<= 7'd64+(rc_counter*7'd2)+(dc_counter*7'd8);
			read_addressb0 <= 7'd65+(rc_counter*7'd2)+(dc_counter*7'd8);
			read_addressa0 <= 7'd0+ rsp_counter+(dsp_counter*7'd8);
			write_enable_a[0] <= 1'b0;
			write_enable_b[0] <= 1'b0;
			write_enable_b[1] <= 1'b0;
			dc_counter<=dc_counter+7'd1;
			rsp_counter<=rsp_counter+7'd1;
			top_state <= S_M2_12;
			end else begin
			v_counter<=v_counter+18'd1;
			read_addressa0<=read_addressa0+ 8'd1;
			M2_SRAM_we_n <= 1'b1;
			top_state <= S_M2_0;
			
			end
			//top_state <= S_M2_12;
		end
//----------------------------------------------------------------------------//		
		S_M2_12: begin
		    read_addressb1<= 7'd64+(rc_counter*7'd2)+(dc_counter*7'd8);
			read_addressb0<= 7'd65+(rc_counter*7'd2)+(dc_counter*7'd8);
			read_addressa0<= 7'd0+ rsp_counter+(dsp_counter*7'd8);
			dc_counter<=dc_counter+7'd1;
			rsp_counter<=rsp_counter+7'd1;

			
			top_state <= S_M2_13;
		end
//----------------------------------------------------------------------------//		
		S_M2_13: begin
		    read_addressb1<= 7'd64+(rc_counter*7'd2)+(dc_counter*7'd8);
			read_addressb0<= 7'd65+(rc_counter*7'd2)+(dc_counter*7'd8);
			read_addressa0<= 7'd0+ rsp_counter+(dsp_counter*7'd8);
			dc_counter<=dc_counter+7'd1;
			rsp_counter<=rsp_counter+7'd1;
			mult_op_1 <= $signed(read_data_a[0]);
            mult_op_2 <=$signed(read_data_b[0]);
            mult_op_3 <= $signed(read_data_a[0]);
            mult_op_4 <= $signed(read_data_b[1]);
			
			top_state <= S_M2_14;
		end
//----------------------------------------------------------------------------//		
		S_M2_14: begin
		    read_addressb1<= 7'd64+(rc_counter*7'd2)+(dc_counter*7'd8);
			read_addressb0<= 7'd65+(rc_counter*7'd2)+(dc_counter*7'd8);
			read_addressa0<= 7'd0+ rsp_counter+(dsp_counter*7'd8);
			
			dc_counter<=dc_counter+7'd1;
			rsp_counter<=rsp_counter+7'd1;
			
			
			T_buff<=($signed((mult_res_1)))>>>8;
			T1_buff<=($signed((mult_res_2)))>>>8;
			mult_op_1 <= $signed(read_data_a[0]);
            mult_op_2 <=$signed(read_data_b[0]);
            mult_op_3 <= $signed(read_data_a[0]);
            mult_op_4 <= $signed(read_data_b[1]);
			top_state <= S_M2_15;
		end
//----------------------------------------------------------------------------//		
		S_M2_15: begin
		    read_addressb1<= 7'd64+(rc_counter*7'd2)+(dc_counter*7'd8);
			read_addressb0<= 7'd65+(rc_counter*7'd2)+(dc_counter*7'd8);
			read_addressa0<= 7'd0+ rsp_counter+(dsp_counter*7'd8);
			dc_counter<=dc_counter+7'd1;
			rsp_counter<=rsp_counter+7'd1;
			T_buff<=$signed(T_buff+(($signed((mult_res_1)))>>>8));
			T1_buff<=$signed(T1_buff+(($signed((mult_res_2)))>>>8));
			mult_op_1 <= $signed(read_data_a[0]);
            mult_op_2 <=$signed(read_data_b[0]);
            mult_op_3 <= $signed(read_data_a[0]);
            mult_op_4 <= $signed(read_data_b[1]);
			top_state <= S_M2_16;
		end
//----------------------------------------------------------------------------//		
		S_M2_16: begin
		    read_addressb1<= 7'd64+(rc_counter*7'd2)+(dc_counter*7'd8);
			read_addressb0<= 7'd65+(rc_counter*7'd2)+(dc_counter*7'd8);
			read_addressa0<= 7'd0+ rsp_counter+(dsp_counter*7'd8);
		    dc_counter<=dc_counter+7'd1;
		    rsp_counter<=rsp_counter+7'd1;
			T_buff<=$signed(T_buff+(($signed((mult_res_1)))>>>8));
			T1_buff<=$signed(T1_buff+(($signed((mult_res_2)))>>>8));
			mult_op_1 <= $signed(read_data_a[0]);
            mult_op_2 <=$signed(read_data_b[0]);
            mult_op_3 <= $signed(read_data_a[0]);
            mult_op_4 <= $signed(read_data_b[1]);
			top_state <= S_M2_17;
		end
//----------------------------------------------------------------------------//		
		S_M2_17: begin
		    read_addressb1<= 7'd64+(rc_counter*7'd2)+(dc_counter*7'd8);
			read_addressb0<= 7'd65+(rc_counter*7'd2)+(dc_counter*7'd8);
			read_addressa0<= 7'd0+ rsp_counter+(dsp_counter*7'd8);
			dc_counter<=dc_counter+7'd1;
		    rsp_counter<=rsp_counter+7'd1;
			T_buff<=$signed(T_buff+(($signed((mult_res_1)))>>>8));
			T1_buff<=$signed(T1_buff+(($signed((mult_res_2)))>>>8));
			mult_op_1 <= $signed(read_data_a[0]);
            mult_op_2 <=$signed(read_data_b[0]);
            mult_op_3 <= $signed(read_data_a[0]);
            mult_op_4 <= $signed(read_data_b[1]);
			top_state <= S_M2_18;
		end

		S_M2_18: begin
			read_addressb1<= 7'd64+(rc_counter*7'd2)+(dc_counter*7'd8);
			read_addressb0<= 7'd65+(rc_counter*7'd2)+(dc_counter*7'd8);
			read_addressa0<= 7'd0+ rsp_counter+(dsp_counter*7'd8);
			T_buff<=$signed(T_buff+(($signed((mult_res_1)))>>>8));
			T1_buff<=$signed(T1_buff+(($signed((mult_res_2)))>>>8));
			mult_op_1 <= $signed(read_data_a[0]);
            mult_op_2 <=$signed(read_data_b[0]);
            mult_op_3 <= $signed(read_data_a[0]);
            mult_op_4 <= $signed(read_data_b[1]);
			top_state <= S_M2_19;
		end
        S_M2_19: begin
			T_buff<=$signed(T_buff+(($signed((mult_res_1)))>>>8));
			T1_buff<=$signed(T1_buff+(($signed((mult_res_2)))>>>8));
			mult_op_1 <= $signed(read_data_a[0]);
            mult_op_2 <=$signed(read_data_b[0]);
            mult_op_3 <= $signed(read_data_a[0]);
            mult_op_4 <= $signed(read_data_b[1]);
			top_state <= S_M2_20;
		end
		S_M2_20: begin
			T_buff<=$signed(T_buff+(($signed((mult_res_1)))>>>8));
			T1_buff<=$signed(T1_buff+(($signed((mult_res_2)))>>>8));
			mult_op_1 <= $signed(read_data_a[0]);
            mult_op_2 <=$signed(read_data_b[0]);
            mult_op_3 <= $signed(read_data_a[0]);
            mult_op_4 <= $signed(read_data_b[1]);
			write_enable_a[1] <= 1'b1;
			top_state <= S_M2_21;
		end
		S_M2_21: begin
		    T_buff<=$signed(T_buff+(($signed((mult_res_1)))>>>8));
			write_data_a[1]<=$signed(T1_buff+(($signed((mult_res_2)))>>>8));
			rt_counter<=rt_counter+7'd1;
			read_addressa1<= 7'd0+ rt_counter+(dt_counter*7'd8);
			dc_counter<=7'd0;
		    rsp_counter<=7'd0;
			top_state <= S_M2_22;
		
		end
		
		S_M2_22: begin
			
			read_addressa1<= 7'd0+ rt_counter+(dt_counter*7'd8);
			write_data_a[1] <=$signed(T_buff);
			if(rc_counter==7'd3)begin
			  rc_counter<=7'd0;
			  rt_counter<=7'd0;
			  top_state <= S_M2_23;
			end else begin
			write_enable_a[1] <= 1'b0;
			v_counter<=18'd7;
			rt_counter<=rt_counter+7'd1;
			rc_counter<=rc_counter+7'd1;
			top_state <= S_M2_11;
			end
			
		end
		
		S_M2_23: begin
			if(dsp_counter==7'd7)begin
			  dsp_counter<=7'd0;
			  dt_counter<=7'd0;
			  top_state <= S_M2_24;
			end else begin
	        v_counter<=18'd7;
			dt_counter<=dt_counter+7'd1;
			dsp_counter<=dsp_counter+7'd1;
			top_state <= S_M2_11;
			end
		end
		S_M2_24: begin
			
			read_addressb1<= 7'd64+(rct_counter*7'd8)+(dct_counter*2);
			read_addressb0 <= 7'd65+(rct_counter*7'd8)+(dct_counter*2);
			read_addressa1 <= 7'd0+ rs_counter+(ds_counter*7'd8);
			write_enable_a[1] <= 1'b0;
			write_enable_b[0] <= 1'b0;
			write_enable_b[1] <= 1'b0;	
			rct_counter<=rct_counter+7'd1;
			ds_counter<=ds_counter+7'd1;
			top_state <= S_M2_25;
		end
//----------------------------------------------------------------------------//		
		S_M2_25: begin
		   read_addressb1<= 7'd64+(rct_counter*7'd8)+(dct_counter*2);
			read_addressb0 <= 7'd65+(rct_counter*7'd8)+(dct_counter*2);
			read_addressa1 <= 7'd0+ rs_counter+(ds_counter*7'd8);
			rct_counter<=rct_counter+7'd1;
			ds_counter<=ds_counter+7'd1;

			
			top_state <= S_M2_26;
		end
//----------------------------------------------------------------------------//		
		S_M2_26: begin
		    read_addressb1<= 7'd64+(rct_counter*7'd8)+(dct_counter*2);
			read_addressb0 <= 7'd65+(rct_counter*7'd8)+(dct_counter*2);
			read_addressa1 <= 7'd0+ rs_counter+(ds_counter*7'd8);
			rct_counter<=rct_counter+7'd1;
			ds_counter<=ds_counter+7'd1;
			mult_op_1 <= read_data_a[1];
            mult_op_2 <= read_data_b[0];
            mult_op_3 <= read_data_a[1];
            mult_op_4 <= read_data_b[1];
			
			top_state <= S_M2_27;
		end
//----------------------------------------------------------------------------//		
		S_M2_27: begin
		    read_addressb1<= 7'd64+(rct_counter*7'd8)+(dct_counter*2);
			read_addressb0 <= 7'd65+(rct_counter*7'd8)+(dct_counter*2);
			read_addressa1 <= 7'd0+ rs_counter+(ds_counter*7'd8);
			
			rct_counter<=rct_counter+7'd1;
			ds_counter<=ds_counter+7'd1;
			
			
			S_buff<=mult_res_1;
			S1_buff<=mult_res_2;
			mult_op_1 <= read_data_a[1];
            mult_op_2 <= read_data_b[0];
            mult_op_3 <= read_data_a[1];
            mult_op_4 <= read_data_b[1];
			top_state <= S_M2_28;
		end
//----------------------------------------------------------------------------//		
		S_M2_28: begin
		    read_addressb1<= 7'd64+(rct_counter*7'd8)+(dct_counter*2);
			read_addressb0 <= 7'd65+(rct_counter*7'd8)+(dct_counter*2);
			read_addressa1 <= 7'd0+ rs_counter+(ds_counter*7'd8);
			rct_counter<=rct_counter+7'd1;
			ds_counter<=ds_counter+7'd1;
			S_buff<=(S_buff+mult_res_1);
			S1_buff<=(S1_buff+mult_res_2);
			mult_op_1 <= read_data_a[1];
            mult_op_2 <= read_data_b[0];
            mult_op_3 <= read_data_a[1];
            mult_op_4 <= read_data_b[1];
			top_state <= S_M2_29;
		end
//----------------------------------------------------------------------------//		
		S_M2_29: begin
		    read_addressb1<= 7'd64+(rct_counter*7'd8)+(dct_counter*2);
			read_addressb0 <= 7'd65+(rct_counter*7'd8)+(dct_counter*2);
			read_addressa1 <= 7'd0+ rs_counter+(ds_counter*7'd8);
		    rct_counter<=rct_counter+7'd1;
			ds_counter<=ds_counter+7'd1;
			S_buff<=(S_buff+mult_res_1);
			S1_buff<=(S1_buff+mult_res_2);
			mult_op_1 <= read_data_a[1];
            mult_op_2 <= read_data_b[0];
            mult_op_3 <= read_data_a[1];
            mult_op_4 <= read_data_b[1];
			top_state <= S_M2_30;
		end
//----------------------------------------------------------------------------//		
		S_M2_30: begin
		    read_addressb1<= 7'd64+(rct_counter*7'd8)+(dct_counter*2);
			read_addressb0 <= 7'd65+(rct_counter*7'd8)+(dct_counter*2);
			read_addressa1 <= 7'd0+ rs_counter+(ds_counter*7'd8);
			rct_counter<=rct_counter+7'd1;
			ds_counter<=ds_counter+7'd1;
			S_buff<=(S_buff+mult_res_1);
			S1_buff<=(S1_buff+mult_res_2);
			mult_op_1 <= read_data_a[1];
            mult_op_2 <= read_data_b[0];
            mult_op_3 <= read_data_a[1];
            mult_op_4 <= read_data_b[1];
			top_state <= S_M2_31;
		end

		S_M2_31: begin
			read_addressb1<= 7'd64+(rct_counter*7'd8)+(dct_counter*2);
			read_addressb0 <= 7'd65+(rct_counter*7'd8)+(dct_counter*2);
			read_addressa1 <= 7'd0+ rs_counter+(ds_counter*7'd8);
			S_buff<=(S_buff+mult_res_1);
			S1_buff<=(S1_buff+mult_res_2);
			mult_op_1 <= read_data_a[1];
            mult_op_2 <= read_data_b[0];
            mult_op_3 <= read_data_a[1];
            mult_op_4 <= read_data_b[1];
			top_state <= S_M2_32;
		end
        S_M2_32: begin
			S_buff<=(S_buff+mult_res_1);
			S1_buff<=(S1_buff+mult_res_2);
			mult_op_1 <= read_data_a[1];
            mult_op_2 <= read_data_b[0];
            mult_op_3 <= read_data_a[1];
            mult_op_4 <= read_data_b[1];
			top_state <= S_M2_33;
		end
		S_M2_33: begin
			S_buff<=(S_buff+mult_res_1);
			S1_buff<=(S1_buff+mult_res_2);
			mult_op_1 <= read_data_a[1];
            mult_op_2 <= read_data_b[0];
            mult_op_3 <= read_data_a[1];
            mult_op_4 <= read_data_b[1];
			write_enable_a[0] <= 1'b1;
			top_state <= S_M2_34;
		end
		S_M2_34: begin
		    S_buff<=(S_buff+mult_res_1);
			//S1_buff<=(S1_buff+mult_res_2);
			write_data_a[0]<=(S1_buff+mult_res_2);
			df_counter<=df_counter+7'd1;
			read_addressa0<= 7'd0+ rf_counter+(df_counter*7'd8);
			rct_counter<=7'd0;
		    ds_counter<=7'd0;
			top_state <= S_M2_35;
		end
		S_M2_35: begin
			
			read_addressa0<= 7'd0+ rf_counter+(df_counter*7'd8);
			write_data_a[0] =S_buff;
			if(dct_counter==7'd3)begin
			  dct_counter<=7'd0;
			  df_counter<=7'd0;
			  top_state <= S_M2_36;
			end else begin
			write_enable_a[0] <= 1'b0;
			df_counter<=df_counter+7'd1;
			dct_counter<=dct_counter+7'd1;
			top_state <= S_M2_24;
			end
			
		end
		S_M2_36: begin
			if(rs_counter==7'd7)begin
			  rs_counter<=7'd0;
			  rf_counter<=7'd0;
			  ro_counter<=7'd0;
			  write_enable_a[0] <= 1'b0;
			  top_state <= S_M2_37;
			end else begin
			rs_counter<=rs_counter+7'd1;
			rf_counter<=rf_counter+7'd1;
			top_state <= S_M2_24;
			end
		end
		
		S_M2_37: begin
			  read_addressa0 <= 7'd0+ ro_counter+(do_counter*7'd8);//0
			  ro_counter<=ro_counter+7'd1;
			  //M2_SRAM_address<=18'd0+ ro1_counter+(do1_counter*8'd160)+(hw_offset*18'd4);//01
			  //ro1_counter<=ro1_counter+7'd1;
			 top_state <= S_M2_38;

		end
		S_M2_38: begin
		    
			read_addressa0 <= 7'd0+ ro_counter+(do_counter*7'd8);//1
			ro_counter<=ro_counter+7'd1;
			top_state <= S_M2_39;

		end
		S_M2_39: begin
		     
		    f_buff<=read_data_a[0];//b0
			read_addressa0 <= 7'd0+ ro_counter+(do_counter*7'd8);//2
			ro_counter<=ro_counter+7'd1;
			
         top_state <= S_M2_40;
		end
		S_M2_40: begin
		    read_addressa0 <= 7'd0+ ro_counter+(do_counter*7'd8);//3
			ro_counter<=ro_counter+7'd1;
			M2_SRAM_address<=18'd0+ ro1_counter+(do1_counter*8'd160)+(hw_offset*18'd4);//2,3
			ro1_counter<=ro1_counter+7'd1;
			M2_SRAM_we_n <= 1'b0;
			M2_SRAM_write_data[15:8] <= (f_buff[31] == 1'b1)?8'b0:((|f_buff[30:24])?8'd255:f_buff[23:16]);
            M2_SRAM_write_data[7:0] <= (read_data_a[0][31] == 1'b1)?8'b0:((|read_data_a[0][30:24])?8'd255:read_data_a[0][23:16]);;//0,1
			top_state <= S_M2_41;

		end
		S_M2_41: begin
		    M2_SRAM_we_n <= 1'b1;
		    
		    f_buff<=read_data_a[0];//b2
			
			read_addressa0 <= 7'd0+ ro_counter+(do_counter*7'd8);//4
			ro_counter<=ro_counter+7'd1;
			top_state <= S_M2_42;

		end
		S_M2_42: begin
		    M2_SRAM_address<=18'd0+ ro1_counter+(do1_counter*8'd160)+(hw_offset*18'd4);//4,5
			ro1_counter<=ro1_counter+7'd1;
		    M2_SRAM_we_n <= 1'b0;
		    M2_SRAM_write_data[15:8] <= (f_buff[31] == 1'b1)?8'b0:((|f_buff[30:24])?8'd255:f_buff[23:16]);
            M2_SRAM_write_data[7:0] <= (read_data_a[0][31] == 1'b1)?8'b0:((|read_data_a[0][30:24])?8'd255:read_data_a[0][23:16]);;//2,3
			//M2_SRAM_address<=18'd0+ ro1_counter+(do1_counter*7'd160);
			read_addressa0 <= 7'd0+ ro_counter+(do_counter*7'd8);//5
			ro_counter<=ro_counter+7'd1;
			top_state <= S_M2_43;

		end
		S_M2_43: begin
		    M2_SRAM_we_n <= 1'b1;
		    

		    f_buff<=read_data_a[0];//b4
			read_addressa0 <= 7'd0+ ro_counter+(do_counter*8'd8);//6
			ro_counter<=ro_counter+7'd1;
			top_state <= S_M2_44;

		end
		S_M2_44: begin
		    M2_SRAM_address<=18'd0+ ro1_counter+(do1_counter*8'd160)+(hw_offset*18'd4);//6,7
			ro1_counter<=ro1_counter+7'd1;
		    M2_SRAM_we_n <= 1'b0;
		    M2_SRAM_write_data[15:8] <= (f_buff[31] == 1'b1)?8'b0:((|f_buff[30:24])?8'd255:f_buff[23:16]);
            M2_SRAM_write_data[7:0] <= (read_data_a[0][31] == 1'b1)?8'b0:((|read_data_a[0][30:24])?8'd255:read_data_a[0][23:16]);;//4,5
			read_addressa0 <= 7'd0+ ro_counter+(do_counter*7'd8);//7
			
			top_state <= S_M2_45;

		end
		S_M2_45: begin
		    M2_SRAM_we_n <= 1'b1;
			f_buff<=read_data_a[0];//b6
			
			top_state <= S_M2_46;

		end
		S_M2_46: begin
		    M2_SRAM_we_n <= 1'b0;
			M2_SRAM_address<=18'd0+ ro1_counter+(do1_counter*8'd160)+(hw_offset*18'd4);;
			M2_SRAM_write_data[15:8] <= (f_buff[31] == 1'b1)?8'b0:((|f_buff[30:24])?8'd255:f_buff[23:16]);
            M2_SRAM_write_data[7:0] <= (read_data_a[0][31] == 1'b1)?8'b0:((|read_data_a[0][30:24])?8'd255:read_data_a[0][23:16]);;//6,7
			top_state <= S_M2_47;

		end
		S_M2_47: begin
		     M2_SRAM_we_n <= 1'b1;
			if(ro1_counter==7'd3)begin
			ro1_counter<=7'd0;
			ro_counter<=7'd0;
			top_state <= S_M2_48;
			end else begin
			ro_counter<=ro_counter+7'd1;
			ro1_counter<=ro1_counter+7'd1;
			top_state <= S_M2_37;
            end
		end
		S_M2_48: begin
		   if(do1_counter==7'd7)begin
			do1_counter<=7'd0;
			do_counter<=7'd0;
			top_state <= S_M2_DONE;
			end else begin
			do_counter<=do_counter+7'd1;
			do1_counter<=do1_counter+7'd1;
			top_state <= S_M2_37;
			end

		end
		/*
		S_M2_49: begin
			if(h_offset==18'd39)begin
			h_offset<=18'd0;
			//hw_offset<=18'd0;
			top_state <= S_M2_50;
			end else begin
			h_offset<=h_offset+18'd1;
			hw_offset<=hw_offset+18'd1;
			M2_SRAM_we_n <= 1'b1;
			read_addressa1 <= 7'd0;
		    read_addressb1 <= 7'd0;
		    read_addressa0 <= 7'd0;
		    read_addressb0 <= 7'd0;
			top_state <= S_M2_0;
			end

		end
		S_M2_50: begin
			if(v_offset==18'd1)begin
			v_offset<=18'd0;
			hw_offset<=18'd0;
			top_state <= S_M2_DONE;
			end else begin
			v_offset<=v_offset+18'd1;
			hw_offset<=hw_offset+18'd1;
			M2_SRAM_we_n <= 1'b1;
			read_addressa1 <= 7'd0;
		    read_addressb1 <= 7'd0;
		    read_addressa0 <= 7'd0;
		    read_addressb0 <= 7'd0;
			top_state <= S_M2_0;
			end

		end
		
		*/
		
		S_M2_DONE: begin

			M2_done <= 1'b1;
		end

		default: top_state <= S_M2_IDLE;
		endcase
	end
end

endmodule




