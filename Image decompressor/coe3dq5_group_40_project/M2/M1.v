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

module M1 (

    input logic CLOCK_50_I,                   // 50 MHz clock
    input logic resetn,                       // top level master reset
    input logic M1_start,
    output logic M1_done,
    // signals for the SRAM
    input logic [15:0] M1_SRAM_read_data,
    output logic [15:0] M1_SRAM_write_data,
    output logic [17:0] M1_SRAM_address,
    output logic M1_SRAM_we_n,

    /////// signals for multipliers in top level
    output logic [31:0] M1_mult_1_in1,
    output logic [31:0] M1_mult_1_in2,
    output logic [31:0] M1_mult_2_in1,
    output logic [31:0] M1_mult_2_in2,
    output logic [31:0] M1_mult_3_in1,
    output logic [31:0] M1_mult_3_in2,

    input logic [63:0] M1_mult_res_1,
    input logic [63:0] M1_mult_res_2,
    input logic [63:0] M1_mult_res_3
);


M1_state_type top_state;
// #1 added parameters starts here
parameter Y_base_address = 18'd0,
            U_base_address = 18'd38400,
             V_base_address = 18'd57600,
             RGB_base_address = 18'd146944,
        R_rem = 32'd16,
        G_rem = 32'd128,
        B_rem = 32'd128,
		Y_coe = 18'd76284,
        R_U_coe = 18'd0,
        R_V_coe = 18'd104595,
        G_U_coe = 18'd25624,
        G_V_coe = 18'd53281,
        B_U_coe = 18'd132251,
        B_V_coe = 18'd0,
        UV_5_coe = 18'd21,
        UV_3_coe = 18'd52,
        UV_1_coe = 18'd159,
        UV_rem = 18'd128;
// #1 added parameters ends here

/// multipliers signal in M1 ///////////////////////////////////////////

logic [31:0] mult_op_1, mult_op_2, mult_op_3, mult_op_4, mult_op_5, mult_op_6;
logic [63:0] mult_res_1, mult_res_2, mult_res_3;

assign M1_mult_1_in1 = mult_op_1;
assign M1_mult_1_in2 = mult_op_2;
assign M1_mult_2_in1 = mult_op_3;
assign M1_mult_2_in2 = mult_op_4;
assign M1_mult_3_in1 = mult_op_5;
assign M1_mult_3_in2 = mult_op_6;

assign mult_res_1 = M1_mult_res_1;
assign mult_res_2 = M1_mult_res_2;
assign mult_res_3 = M1_mult_res_3;

////////////////////////////////////////////////////////////////////////

// #2 added counters start here, for the convience to track the address
logic [17:0] Y_counter;
logic [17:0] U_counter;
logic [17:0] V_counter;
logic [17:0] RGB_counter;
logic [7:0] ver_counter;
logic [8:0] horz_counter;
logic[2:0] counter;

// #2 added counters ends here

// #3 added buffers starts here
logic [15:0] Y_data; // use to store Y0Y1... data
logic [7:0] U_prime; // use to store U'0... data
logic [7:0] U_buffer; // use to store the U data for later use
logic [7:0] U_jplus5_data;
logic [7:0] U_jplus3_data;
logic [7:0] U_jplus1_data;
logic [7:0] U_jminus1_data;
logic [7:0] U_jminus3_data;
logic [7:0] U_jminus5_data;
logic [7:0] V_prime; // use to store V'0... data
logic [7:0] V_buffer; // use to store the V data for later use
logic [7:0] V_jplus5_data;
logic [7:0] V_jplus3_data;
logic [7:0] V_jplus1_data;
logic [7:0] V_jminus1_data;
logic [7:0] V_jminus3_data;
logic [7:0] V_jminus5_data;
logic [63:0] R_data; // use to store Red value;
logic [63:0] G_data; // use to store Green value;
logic [63:0] B_data; // use to store Blue value;
logic [63:0] Rb_data; // use to store Red value;
logic [63:0] Gb_data; // use to store Green value;
logic [63:0] Bb_data; // use to store Blue value;


// #3 added buffers ends here

logic start_buf;

always @(posedge CLOCK_50_I or negedge resetn) begin
    if (~resetn) begin
        top_state <= S_M1_IDLE;
        start_buf <= 1'b0;
        M1_done <= 1'b0;

        mult_op_1 <= 32'd0;
        mult_op_2 <= 32'd0;
        mult_op_3 <= 32'd0;
        mult_op_4 <= 32'd0;
        mult_op_5 <= 32'd0;
        mult_op_6 <= 32'd0;
        // #2 added counters
        Y_counter <= 18'd0;
        U_counter <= 18'd0;
		V_counter <= 18'd0;
        RGB_counter <= 18'd0;
        ver_counter <= 8'd0;
		horz_counter <= 9'd0;
		counter<=2'd0;
        // #3 added buffers
        Y_data <= 16'd0;
        U_prime <= 8'd0;
        U_buffer <= 8'd0;
        U_jplus5_data <= 8'd0;
        U_jplus3_data <= 8'd0;
        U_jplus1_data <= 8'd0;
        U_jminus1_data <= 8'd0;
        U_jminus3_data <= 8'd0;
        U_jminus5_data <= 8'd0;
        V_prime <= 8'd0;
        V_buffer <= 8'd0;
        V_jplus5_data <= 8'd0;
        V_jplus3_data <= 8'd0;
        V_jplus1_data <= 8'd0;
        V_jminus1_data <= 8'd0;
        V_jminus3_data <= 8'd0;
        V_jminus5_data <= 8'd0;

        R_data <= 8'd0;
        G_data <= 8'd0;
        B_data <= 8'd0;
		
		
		Rb_data <= 8'd0;
        Gb_data <= 8'd0;
        Bb_data <= 8'd0;
		
		

        M1_SRAM_address <= 18'd0;
        M1_SRAM_write_data <= 16'd0;
        M1_SRAM_we_n <= 1'b1;

    end else begin
			start_buf <= M1_start;
        case (top_state)

        S_M1_IDLE: begin
            if(M1_start && ~start_buf) begin
			M1_SRAM_we_n <= 1'b1;
			M1_SRAM_address <= U_base_address + U_counter;//u0u1
            
			U_counter<=U_counter+18'd1;
            top_state <= S_M1_Lead_in_0;
            end
		end
		S_M1_Lead_in_0: begin
		     M1_SRAM_address <= U_base_address + U_counter;//u2u3
            top_state <= S_M1_Lead_in_1;
        end	
		S_M1_Lead_in_1: begin
            M1_SRAM_address<=V_base_address+V_counter;//v0v1
			V_counter<=V_counter+18'd1;
            top_state <= S_M1_Lead_in_2;
        end
		
		S_M1_Lead_in_2: begin
            M1_SRAM_address<=V_base_address+V_counter;//V2V3
			U_prime <= M1_SRAM_read_data[15:8]; // store U0 as U'0

            // for calculating U'1
            U_jplus1_data <= M1_SRAM_read_data[7:0]; // store U1 as U[(j+1)/2]
            U_jminus1_data <= M1_SRAM_read_data[15:8]; // store U0 as U[(j-1)/2]
            U_jminus3_data <= M1_SRAM_read_data[15:8]; // store U0 as U[(j-3)/2]
            U_jminus5_data <= M1_SRAM_read_data[15:8]; // store U0 as U[(j-5)/2]
			
            top_state <= S_M1_Lead_in_3;
        end
        S_M1_Lead_in_3: begin
		    M1_SRAM_address <= Y_base_address + Y_counter;//y0y1
			// for calculating U'1
            U_jplus5_data <= M1_SRAM_read_data[7:0]; // store U3 as U[(j+5)/2]
            U_jplus3_data <= M1_SRAM_read_data[15:8]; // store U2 as U[(j+3)/2]
			 
			
           
			 U_counter<=U_counter+18'd1;

            top_state <= S_M1_Lead_in_4;
        end
		S_M1_Lead_in_4: begin
		    //U_prime<=(mult_res_1-mult_res_2+mult_res_3+UV_rem+U_prime)>>8;//U1'
			
		    V_prime <= M1_SRAM_read_data[15:8]; // store V0 as V'0
		   // for calculating V'1
            V_jplus1_data <= M1_SRAM_read_data[7:0]; // store V1 as V[(j+1)/2]
            V_jminus1_data <= M1_SRAM_read_data[15:8]; // store V0 as V[(j-1)/2]
            V_jminus3_data <= M1_SRAM_read_data[15:8]; // store V0 as V[(j-3)/2]
            V_jminus5_data <= M1_SRAM_read_data[15:8]; // store V0 as V[(j-5)/2]
			
			
			// assign mults to calculate U'1
            mult_op_1 <= UV_5_coe;
            mult_op_2 <= U_jplus5_data + U_jminus5_data;
            mult_op_3 <= UV_3_coe;
            mult_op_4 <= U_jplus3_data + U_jminus3_data;
            mult_op_5 <= UV_1_coe;
            mult_op_6 <= U_jplus1_data + U_jminus1_data;

            
			
			M1_SRAM_address <= U_base_address + U_counter;//u4u5
			V_counter<=V_counter+18'd1;
			top_state <= S_M1_Lead_in_5;
        end
 
		
		 S_M1_Lead_in_5: begin
		    // for calculating V'1
            V_jplus5_data <= M1_SRAM_read_data[7:0]; // store V3 as V[(j+5)/2]
            V_jplus3_data <= M1_SRAM_read_data[15:8]; // store V2 as V[(j+3)/2]
			// get mults results for U'1
            U_prime <= (mult_res_1 - mult_res_2 + mult_res_3 + UV_rem) >> 8;
			
			// assign mults to calculate V'1
            mult_op_1 <= UV_5_coe;
            mult_op_2 <= M1_SRAM_read_data[7:0] + V_jminus5_data;
            mult_op_3 <= UV_3_coe;
            mult_op_4 <= M1_SRAM_read_data[15:8] + V_jminus3_data;
            mult_op_5 <= UV_1_coe;
            mult_op_6 <= V_jplus1_data + V_jminus1_data;

			M1_SRAM_address<=V_base_address+V_counter;//V4V5
            top_state <= S_M1_Lead_in_6;
        end
		
		S_M1_Lead_in_6: begin
            Y_data <= M1_SRAM_read_data; // store Y0 Y1 data to register Y_data
      
			
            // get mults results for V'1
            V_prime <= (mult_res_1 - mult_res_2 + mult_res_3 + UV_rem) >> 8;
			
            // assign mults to calculate R0
            mult_op_1 <= Y_coe;
            mult_op_2 <= (M1_SRAM_read_data[15:8]- R_rem);//y0
            mult_op_3 <= R_U_coe;
            mult_op_4 <= (U_jminus5_data- G_rem);//u0
            mult_op_5 <= R_V_coe;
            mult_op_6 <= (V_jminus5_data- B_rem);//v0
        

            top_state <= S_M1_Lead_in_7;
        end
		
		S_M1_Lead_in_7: begin
		
		   // get mults results to calculate R0
            R_data <= (mult_res_1 + mult_res_3 );
			
			
			 // assign mults to calculate G0
			mult_op_1 <= Y_coe;
            mult_op_2 <= (Y_data[15:8]- R_rem);//y0
            mult_op_3 <= G_U_coe;
			mult_op_4 <= (U_jminus5_data-G_rem);//u0
            mult_op_5 <= G_V_coe;
			mult_op_6 <=( V_jminus5_data- B_rem);//vo

            M1_SRAM_we_n <= 1'b1;

            U_buffer <= M1_SRAM_read_data[7:0]; // store U5 for later use
            U_jplus5_data <= M1_SRAM_read_data[15:8]; // store U4 as U[(j+5)/2]
            U_jplus3_data <= U_jplus5_data; // store U3 as U[(j+3)/2]
            U_jplus1_data <= U_jplus3_data; // store U2 as U[(j+1)/2]
            U_jminus1_data <= U_jplus1_data; // store U1 as U[(j-1)/2]
            U_jminus3_data <= U_jminus1_data;
            U_jminus5_data <= U_jminus3_data;

            top_state <= S_M1_Lead_in_8;
        end
//----------------------------------------------------------------------------//
        S_M1_Lead_in_8: begin
		   // get the mults result for G0
            G_data <= (mult_res_1 - mult_res_2 - mult_res_3 );
			Rb_data<= R_data ;
			
			
			// assign the mults to calculate B0
			mult_op_1 <= Y_coe;
            mult_op_2 <= (Y_data[15:8]- R_rem);//y0
            mult_op_3 <= B_U_coe;
			mult_op_4 <= (U_jminus5_data- B_rem);//U0
            mult_op_5 <= B_V_coe;
			mult_op_6 <= (V_jminus5_data- B_rem);//v0
			
			V_buffer <= M1_SRAM_read_data[7:0]; // store V5 for later use
            V_jplus5_data <= M1_SRAM_read_data[15:8]; // store V4 as V[(j+5)/2]
            V_jplus3_data <= V_jplus5_data; // store V3 as V[(j+3)/2]
            V_jplus1_data <= V_jplus3_data; // store V2 as V[(j+1)/2]
            V_jminus1_data <= V_jplus1_data; // store V1 as V[(j-1)/2]
            V_jminus3_data <= V_jminus1_data;
            V_jminus5_data <= V_jminus3_data;
      
            top_state <= S_M1_Lead_in_9;
        end
		
		S_M1_Lead_in_9: begin
		// get the mults result for B0
            B_data <= (mult_res_1 + mult_res_2 );
			Gb_data <=G_data;
			// assign mults to calculate R1
            mult_op_1 <= Y_coe;
            mult_op_2 <= (Y_data[7:0]- R_rem);//y1
            mult_op_3 <= R_U_coe;
            mult_op_4 <= (U_prime- G_rem);//u1'
            mult_op_5 <= R_V_coe;
            mult_op_6 <= (V_prime- B_rem);//v1'
			
			Y_counter <= Y_counter + 18'd1;
            top_state <= S_M1_Lead_in_10;
        end
	    S_M1_Lead_in_10: begin
		    Bb_data <=B_data;
			// get mults results to calculate R1
            R_data <= (mult_res_1 + mult_res_3 );
			
			// assign mults to calculate G1
			mult_op_1 <= Y_coe;
            mult_op_2 <= (Y_data[7:0]- R_rem);//y1
            mult_op_3 <= G_U_coe;
			mult_op_4 <= (U_prime-G_rem);//u1'
            mult_op_5 <= G_V_coe;
			mult_op_6 <=( V_prime- B_rem);//v1'
			
			M1_SRAM_address <= Y_base_address + Y_counter;//y2y3
            top_state <= S_M1_Lead_in_11;
        end	
	    S_M1_Lead_in_11: begin
		    // get the mults result for G1
            G_data <= (mult_res_1 - mult_res_2 - mult_res_3 );
			
			// assign the mults to calculate B1
			mult_op_1 <= Y_coe;
            mult_op_2 <= (Y_data[7:0]- R_rem);//y1
            mult_op_3 <= B_U_coe;
			mult_op_4 <= (U_prime- B_rem);//U1'
            mult_op_5 <= B_V_coe;
			mult_op_6 <= (V_prime- B_rem);//v1'
			
	         
			
			
            top_state <= S_M1_Loop_0;
        end	
		
		
		 
		
		 S_M1_Loop_0: begin
		  
           
		 // get the mults result for B1
            B_data <= (mult_res_1 + mult_res_2 );

            M1_SRAM_address <= RGB_base_address + RGB_counter;
            M1_SRAM_we_n <= 1'b0;
			horz_counter <= horz_counter+9'd1;

            // write R0 G0

            M1_SRAM_write_data[15:8] <= (Rb_data[31] == 1'b1)?8'b0:((|Rb_data[30:24])?8'd255:Rb_data[23:16]);
            M1_SRAM_write_data[7:0] <= (Gb_data[31] == 1'b1)?8'b0:((|Gb_data[30:24])?8'd255:Gb_data[23:16]);;
			RGB_counter <= RGB_counter + 18'd1;
			// assign mults to calculate U'3
            mult_op_1 <= UV_5_coe;
            mult_op_2 <= U_jplus5_data + U_jminus5_data;
            mult_op_3 <= UV_3_coe;
            mult_op_4 <= U_jplus3_data + U_jminus3_data;
            mult_op_5 <= UV_1_coe;
            mult_op_6 <= U_jplus1_data + U_jminus1_data;
            top_state <= S_M1_Loop_1;
        end
		
		 S_M1_Loop_1: begin
           M1_SRAM_address <= RGB_base_address + RGB_counter;
            M1_SRAM_we_n <= 1'b0;

           // write B0 R1
            M1_SRAM_write_data[15:8] <= (Bb_data[31] == 1'b1)?8'b0:((|Bb_data[30:24])?8'd255:Bb_data[23:16]);;
            M1_SRAM_write_data[7:0] <= (R_data[31] == 1'b1)?8'b0:((|R_data[30:24])?8'd255:R_data[23:16]);;
            RGB_counter <= RGB_counter + 18'd1;
           // get mults results to calculate U'3
            U_prime<= (mult_res_1 - mult_res_2 + mult_res_3 + UV_rem) >> 8;
			 Y_data <= M1_SRAM_read_data; // Y2 Y3
            // assign mults to calculate V'3
			mult_op_1 <= UV_5_coe;
            mult_op_2 <= V_jplus5_data + V_jminus5_data;
			mult_op_3 <= UV_3_coe;
            mult_op_4 <= V_jplus3_data + V_jminus3_data;
			mult_op_5 <= UV_1_coe;
            mult_op_6 <= V_jplus1_data + V_jminus1_data;
            top_state <= S_M1_Loop_2;
			
        end
		
		
		 S_M1_Loop_2: begin
		   
            M1_SRAM_address <= RGB_base_address + RGB_counter;
            M1_SRAM_we_n <= 1'b0;
            horz_counter <= horz_counter+9'd1;
           // write G1 B1
            M1_SRAM_write_data[15:8] <= (G_data[31] == 1'b1)?8'b0:((|G_data[30:24])?8'd255:G_data[23:16]);;
            M1_SRAM_write_data[7:0] <= (B_data[31] == 1'b1)?8'b0:((|B_data[30:24])?8'd255:B_data[23:16]);;
           // get mults result to calculate V'3
            V_prime <= (mult_res_1 - mult_res_2 + mult_res_3 + UV_rem) >> 8;
            // assign mults to calculate R2
            mult_op_1 <= Y_coe;
            mult_op_2 <=( Y_data[15:8]- R_rem);
            mult_op_3 <= R_U_coe;
            mult_op_4 <= (U_jminus1_data- G_rem);
            mult_op_5 <= R_V_coe;
            mult_op_6 <= (V_jminus1_data-B_rem);
		   
			
            top_state <= S_M1_Loop_3;
        end
		
		 
		
		
		S_M1_Loop_3: begin
		    M1_SRAM_we_n <= 1'b1;
            // get mults results to calculate R2
            R_data <= (mult_res_1 + mult_res_3 );
			// assign mults to calculate G2
            mult_op_1 <= Y_coe;
            mult_op_2 <=( Y_data[15:8]- R_rem);
            mult_op_3 <= G_U_coe;
            mult_op_4 <= (U_jminus1_data- G_rem);
            mult_op_5 <= G_V_coe;
            mult_op_6 <= (V_jminus1_data-B_rem);
            
           
            top_state <= S_M1_Loop_4;
        end
		
		
		S_M1_Loop_4: begin
            // get mults results to calculate G2
            G_data <= (mult_res_1 - mult_res_2 - mult_res_3 );
			Rb_data<= R_data ;
            // assign mults to calculate B2
            mult_op_1 <= Y_coe;
            mult_op_2 <=( Y_data[15:8]- R_rem);
            mult_op_3 <= B_U_coe;
            mult_op_4 <= (U_jminus1_data- G_rem);
            mult_op_5 <= B_V_coe;
            mult_op_6 <= (V_jminus1_data-B_rem);
			
           if (horz_counter==9'd314) begin
		        RGB_counter <= RGB_counter + 18'd1;
				U_jplus5_data <= U_jplus3_data;

				V_jplus5_data <= V_jplus3_data;
               
				Y_counter <= Y_counter + 18'd1;
				horz_counter<=9'd0;
                top_state <= S_M1_Lead_out_0;
            end else begin
                top_state <= S_M1_Loop_5;
				end
        end
		
		
		S_M1_Loop_5: begin
            // get mults results to calculate B2
            B_data <= (mult_res_1 + mult_res_2 );
			Gb_data<= G_data ;
			// assign mults to calculate R3
            mult_op_1 <= Y_coe;
            mult_op_2 <= (Y_data[7:0]- R_rem);
            mult_op_3 <= R_U_coe;
            mult_op_4 <= (U_prime- G_rem);
            mult_op_5 <= R_V_coe;
            mult_op_6 <= (V_prime-B_rem);
            
            top_state <= S_M1_Loop_6;
        end
		
		
		S_M1_Loop_6: begin
            // get mults results to calculate R3
            R_data <= (mult_res_1 + mult_res_3 );
			Bb_data<= B_data ;
			// assign mults to calculate G3
            mult_op_1 <= Y_coe;
            mult_op_2 <= (Y_data[7:0]- R_rem);
            mult_op_3 <= G_U_coe;
            mult_op_4 <= (U_prime- G_rem);
            mult_op_5 <= G_V_coe;
            mult_op_6 <= (V_prime-B_rem);
           Y_counter <= Y_counter + 18'd1;
            top_state <= S_M1_Loop_7;
        end
		
		
		S_M1_Loop_7: begin
            // get mults results to calculate G3
            G_data <= (mult_res_1 - mult_res_2 - mult_res_3 );
            // assign mults to calculate B3
            mult_op_1 <= Y_coe;
            mult_op_2 <= (Y_data[7:0]- R_rem);
            mult_op_3 <= B_U_coe;
            mult_op_4 <= (U_prime- G_rem);
            mult_op_5 <= B_V_coe;
            mult_op_6 <= (V_prime-B_rem);
		   //Y_counter <= Y_counter + 18'd1;
		   M1_SRAM_address <= Y_base_address + Y_counter;//y4y5
		   RGB_counter <= RGB_counter + 18'd1;
		   
		   
            top_state <= S_M1_Loop_8;
        end
		
		S_M1_Loop_8: begin
		// get the mults result for B3
           B_data <= (mult_res_1 + mult_res_2 );
           M1_SRAM_address <= RGB_base_address + RGB_counter;
            M1_SRAM_we_n <= 1'b0;
            horz_counter <= horz_counter+9'd1;
            // write R2 G2

            M1_SRAM_write_data[15:8] <= (Rb_data[31] == 1'b1)?8'b0:((|Rb_data[30:24])?8'd255:Rb_data[23:16]);
            M1_SRAM_write_data[7:0] <= (Gb_data[31] == 1'b1)?8'b0:((|Gb_data[30:24])?8'd255:Gb_data[23:16]);;
			RGB_counter <= RGB_counter + 18'd1;
			
			U_jplus5_data <= U_buffer;//U5
            U_jplus3_data <= U_jplus5_data; // store U4 as U[(j+3)/2]
            U_jplus1_data <= U_jplus3_data; // store U3as U[(j+1)/2]
            U_jminus1_data <= U_jplus1_data; // store U2 as U[(j-1)/2]
            U_jminus3_data <= U_jminus1_data;//u1
            U_jminus5_data <= U_jminus3_data;//u0
            top_state <= S_M1_Loop_9;
        end
		
		S_M1_Loop_9: begin
            M1_SRAM_address <= RGB_base_address + RGB_counter;
            M1_SRAM_we_n <= 1'b0;
			
			 // assign mults to calculate U'5
            mult_op_1 <= UV_5_coe;
            mult_op_2 <= U_jplus5_data + U_jminus5_data;
            mult_op_3 <= UV_3_coe;
            mult_op_4 <= U_jplus3_data + U_jminus3_data;
            mult_op_5 <= UV_1_coe;
            mult_op_6 <= U_jplus1_data + U_jminus1_data;

           // write B2 R3
            M1_SRAM_write_data[15:8] <= (Bb_data[31] == 1'b1)?8'b0:((|Bb_data[30:24])?8'd255:Bb_data[23:16]);;
            M1_SRAM_write_data[7:0] <= (R_data[31] == 1'b1)?8'b0:((|R_data[30:24])?8'd255:R_data[23:16]);;
			V_jplus5_data <= V_buffer;
            V_jplus3_data <= V_jplus5_data;
            V_jplus1_data <= V_jplus3_data;
            V_jminus1_data <= V_jplus1_data;
            V_jminus3_data <= V_jminus1_data;
            V_jminus5_data <= V_jminus3_data;
			
            RGB_counter <= RGB_counter + 18'd1;
            top_state <= S_M1_Loop_10;
        end
		S_M1_Loop_10: begin
		    Y_data <= M1_SRAM_read_data; // Y4 Y5
			// get mults results to calculate U'5
            U_prime<= (mult_res_1 - mult_res_2 + mult_res_3 + UV_rem) >> 8;
            M1_SRAM_address <= RGB_base_address + RGB_counter;
            M1_SRAM_we_n <= 1'b0;
			horz_counter <= horz_counter+9'd1;
            // write G3B3
            M1_SRAM_write_data[15:8] <= (G_data[31] == 1'b1)?8'b0:((|G_data[30:24])?8'd255:G_data[23:16]);;
            M1_SRAM_write_data[7:0] <= (B_data[31] == 1'b1)?8'b0:((|B_data[30:24])?8'd255:B_data[23:16]);;
			
			// assign mults to calculate V'5
			mult_op_1 <= UV_5_coe;
            mult_op_2 <= V_jplus5_data + V_jminus5_data;
			mult_op_3 <= UV_3_coe;
            mult_op_4 <= V_jplus3_data + V_jminus3_data;
			mult_op_5 <= UV_1_coe;
            mult_op_6 <= V_jplus1_data + V_jminus1_data;
			U_counter<=U_counter+18'd1;
            top_state <= S_M1_Loop_11;
        end
		S_M1_Loop_11: begin
           M1_SRAM_we_n <= 1'b1;
		   M1_SRAM_address <= U_base_address + U_counter;//u6u7
		   V_counter<=V_counter+18'd1;
		   // get mults result to calculate V'5
            V_prime <= (mult_res_1 - mult_res_2 + mult_res_3 + UV_rem) >> 8;
			
			// assign mults to calculate R4
            mult_op_1 <= Y_coe;
            mult_op_2 <=( Y_data[15:8]- R_rem);
            mult_op_3 <= R_U_coe;
            mult_op_4 <= (U_jminus1_data- G_rem);
            mult_op_5 <= R_V_coe;
            mult_op_6 <= (V_jminus1_data-B_rem);
           
            top_state <= S_M1_Loop_12;
        end
		S_M1_Loop_12: begin
		    // get mults results to calculate R4
            R_data <= (mult_res_1 + mult_res_3 );
			// assign mults to calculate G4
            mult_op_1 <= Y_coe;
            mult_op_2 <=( Y_data[15:8]- R_rem);
            mult_op_3 <= G_U_coe;
            mult_op_4 <= (U_jminus1_data- G_rem);
            mult_op_5 <= G_V_coe;
            mult_op_6 <= (V_jminus1_data-B_rem);
            M1_SRAM_address <= V_base_address + V_counter;//V6V7
            top_state <= S_M1_Loop_13;
        end
		S_M1_Loop_13: begin
		   // get mults results to calculate G4
            G_data <= (mult_res_1 - mult_res_2 - mult_res_3 );
			Rb_data<= R_data ;
            // assign mults to calculate B4
            mult_op_1 <= Y_coe;
            mult_op_2 <=( Y_data[15:8]- R_rem);
            mult_op_3 <= B_U_coe;
            mult_op_4 <= (U_jminus1_data- G_rem);
            mult_op_5 <= B_V_coe;
            mult_op_6 <= (V_jminus1_data-B_rem);
           
            top_state <= S_M1_Loop_14;
        end
		S_M1_Loop_14: begin
		   // get mults results to calculate B4
            B_data <= (mult_res_1 + mult_res_2 );
			Gb_data<= G_data ;
			// assign mults to calculate R5
            mult_op_1 <= Y_coe;
            mult_op_2 <= (Y_data[7:0]- R_rem);
            mult_op_3 <= R_U_coe;
            mult_op_4 <= (U_prime- G_rem);
            mult_op_5 <= R_V_coe;
            mult_op_6 <= (V_prime-B_rem);
			
			 M1_SRAM_we_n <= 1'b1;

            U_buffer <= M1_SRAM_read_data[7:0]; // store U7for later use
            U_jplus5_data <= M1_SRAM_read_data[15:8]; // store U6 as U[(j+5)/2]
            U_jplus3_data <= U_jplus5_data; // store U5 as U[(j+3)/2]
            U_jplus1_data <= U_jplus3_data; // store U4 as U[(j+1)/2]
            U_jminus1_data <= U_jplus1_data; // store U3as U[(j-1)/2]
            U_jminus3_data <= U_jminus1_data;//u2
            U_jminus5_data <= U_jminus3_data;//u1
            
            
	        Y_counter <= Y_counter + 18'd1;
            top_state <= S_M1_Loop_15;
			
        end
		S_M1_Loop_15: begin
           // get mults results to calculate R5
            R_data <= (mult_res_1 + mult_res_3 );
			Bb_data<= B_data ;
			// assign mults to calculate G5
            mult_op_1 <= Y_coe;
            mult_op_2 <= (Y_data[7:0]- R_rem);
            mult_op_3 <= G_U_coe;
            mult_op_4 <= (U_prime- G_rem);
            mult_op_5 <= G_V_coe;
            mult_op_6 <= (V_prime-B_rem);
			
			V_buffer <= M1_SRAM_read_data[7:0]; // store V7 for later use
            V_jplus5_data <= M1_SRAM_read_data[15:8]; // store V6 as V[(j+5)/2]
            V_jplus3_data <= V_jplus5_data; // store V5 as V[(j+3)/2]
            V_jplus1_data <= V_jplus3_data; // store V4 as V[(j+1)/2]
            V_jminus1_data <= V_jplus1_data; // store V3 as V[(j-1)/2]
            V_jminus3_data <= V_jminus1_data;//V2
            V_jminus5_data <= V_jminus3_data;//V1
			
			M1_SRAM_address <= Y_base_address + Y_counter;//y2y3
			
            top_state <= S_M1_Loop_16;
			
        end
		S_M1_Loop_16: begin
           // get mults results to calculate G5
            G_data <= (mult_res_1 - mult_res_2 - mult_res_3 );
            // assign mults to calculate B5
            mult_op_1 <= Y_coe;
            mult_op_2 <= (Y_data[7:0]- R_rem);
            mult_op_3 <= B_U_coe;
            mult_op_4 <= (U_prime- G_rem);
            mult_op_5 <= B_V_coe;
            mult_op_6 <= (V_prime-B_rem);
			RGB_counter <= RGB_counter + 18'd1;
		
			counter<=1'd0;
            top_state <= S_M1_Loop_0;;
			
        end
		
		
		
		S_M1_Lead_out_0: begin
		    //Y_counter <= Y_counter + 18'd1;
            // get mults results to calculate B314
            B_data <= (mult_res_1 + mult_res_2 );
			// assign mults to calculate U'315
            mult_op_1 <= UV_5_coe;
            mult_op_2 <= U_jplus5_data + U_jminus5_data;
            mult_op_3 <= UV_3_coe;
            mult_op_4 <= U_jplus3_data + U_jminus3_data;
            mult_op_5 <= UV_1_coe;
            mult_op_6 <= U_jplus1_data + U_jminus1_data;
			
			M1_SRAM_address <= RGB_base_address + RGB_counter;
            M1_SRAM_we_n <= 1'b0;
            // write R314 G314
            M1_SRAM_write_data[15:8] <= (R_data[31] == 1'b1)?8'b0:((|R_data[30:24])?8'd255:R_data[23:16]);;
            M1_SRAM_write_data[7:0] <= (G_data[31] == 1'b1)?8'b0:((|G_data[30:24])?8'd255:G_data[23:16]);;
			
		  top_state <= S_M1_Lead_out_1;
        end
		
		S_M1_Lead_out_1: begin
		 M1_SRAM_we_n <= 1'b1;
		  // get mults results to calculate U'315
          U_prime <= (mult_res_1 - mult_res_2 + mult_res_3 + UV_rem) >> 8;
		  // assign mults to calculate V'315
          mult_op_2 <= V_jplus5_data + V_jminus5_data;
          mult_op_4 <= V_jplus3_data + V_jminus3_data;
          mult_op_6 <= V_jplus1_data + V_jminus1_data;
		  M1_SRAM_address <= Y_base_address + Y_counter;
		  
         
            top_state <= S_M1_Lead_out_2;
        end
		
		S_M1_Lead_out_2: begin
          // get mults results to calculate V'315
          V_prime <= (mult_res_1 - mult_res_2 + mult_res_3 + UV_rem) >> 8;
		  // assign mults to calculate R315
           mult_op_1 <= Y_coe;
           mult_op_2 <= (Y_data[7:0]-R_rem);
           mult_op_3 <= R_U_coe;
           mult_op_4 <=(U_prime-G_rem);
           mult_op_5 <= R_V_coe;
           mult_op_6 <= (((mult_res_1 - mult_res_2 + mult_res_3 + UV_rem) >> 8)-B_rem);
		   
		   RGB_counter <= RGB_counter + 18'd1;
           top_state <= S_M1_Lead_out_3;
        end
		
		S_M1_Lead_out_3: begin
           // get mults results to calculate R315
           R_data <= (mult_res_1 + mult_res_3);
		   // assign mults to calculate G315
		   
            mult_op_3 <= G_U_coe;
            
            mult_op_5 <= G_V_coe;
          
		   Y_data <= M1_SRAM_read_data; // Y316 Y317
           top_state <= S_M1_Lead_out_4;
        end
		
		S_M1_Lead_out_4: begin
		   M1_SRAM_address <= RGB_base_address + RGB_counter;
		   M1_SRAM_we_n <= 1'b0;
		   
           // write B314 R315
           M1_SRAM_write_data[15:8] <= (B_data[31] == 1'b1)?8'b0:((|B_data[30:24])?8'd255:B_data[23:16]);;
           M1_SRAM_write_data[7:0] <= (R_data[31] == 1'b1)?8'b0:((|R_data[30:24])?8'd255:R_data[23:16]);;
		   //M1_SRAM_we_n <= 1'b1;
           // get mults results to calculate G315
            G_data <= (mult_res_1 - mult_res_2 - mult_res_3 );
			
			
            Y_data <= M1_SRAM_read_data; // Y316 Y317
           // assign mults to calculate B315
            
            mult_op_3 <= B_U_coe;
            
            mult_op_5 <= B_V_coe;
          
           top_state <= S_M1_Lead_out_5;
        end
		
		S_M1_Lead_out_5: begin
		   M1_SRAM_we_n <= 1'b1;
           // get mults results to calculate B315
            B_data <= (mult_res_1 + mult_res_2 );
			RGB_counter <= RGB_counter + 18'd1;
			// assign mults to calculate R316
            mult_op_1 <= Y_coe;
            mult_op_2 <=( Y_data[15:8]- R_rem);
            mult_op_3 <= R_U_coe;
            mult_op_4 <= (U_jplus1_data- G_rem);
            mult_op_5 <= R_V_coe;
            mult_op_6 <= (V_jplus1_data-B_rem);
            top_state <= S_M1_Lead_out_6;
        end
		
		S_M1_Lead_out_6: begin
            // get mults results to calculate R316
            R_data <= (mult_res_1 + mult_res_3 );
			// assign mults to calculate G316
            mult_op_1 <= Y_coe;
            mult_op_2 <=( Y_data[15:8]- R_rem);
            mult_op_3 <= G_U_coe;
            mult_op_4 <= (U_jplus1_data- G_rem);
            mult_op_5 <= G_V_coe;
            mult_op_6 <= (V_jplus1_data-B_rem);
			M1_SRAM_address <= RGB_base_address + RGB_counter;
			
            M1_SRAM_we_n <= 1'b0;
            // write G315 B315
            M1_SRAM_write_data[15:8] <= (G_data[31] == 1'b1)?8'b0:((|G_data[30:24])?8'd255:G_data[23:16]);;
            M1_SRAM_write_data[7:0] <= (B_data[31] == 1'b1)?8'b0:((|B_data[30:24])?8'd255:B_data[23:16]);;
            top_state <= S_M1_Lead_out_7;
        end
		
		S_M1_Lead_out_7: begin
            M1_SRAM_we_n <= 1'b1;
			// get mults results to calculate G316
            G_data <= (mult_res_1 - mult_res_2 - mult_res_3 );
            // assign mults to calculate B316
            mult_op_1 <= Y_coe;
            mult_op_2 <=( Y_data[15:8]- R_rem);
            mult_op_3 <= B_U_coe;
            mult_op_4 <= (U_jplus1_data- G_rem);
            mult_op_5 <= B_V_coe;
            mult_op_6 <= (V_jplus1_data-B_rem);
			
			//U_jplus5_data <= U_jplus3_data;
            U_jplus3_data <= U_jplus5_data;
		    //V_jplus5_data <= V_jplus3_data;
			V_jplus3_data <= V_jplus5_data;
            U_jplus1_data <= U_jplus3_data;
            U_jminus1_data <= U_jplus1_data;
            U_jminus3_data <= U_jminus1_data;
            U_jminus5_data <= U_jminus3_data;
			
			V_jplus1_data <= V_jplus3_data;
            V_jminus1_data <= V_jplus1_data;
            V_jminus3_data <= V_jminus1_data;
            V_jminus5_data <= V_jminus3_data;
			
			if (counter==2'd2) begin
		        
			   counter<=1'd0;
			   //ver_counter<=1'd0;
               //U_counter=U_counter+18'd1;
			   RGB_counter <= RGB_counter + 18'd1;
               top_state <= S_M1_Lead_out_8;				
            end else begin
			  RGB_counter <= RGB_counter + 18'd1;
			  counter<=counter+1'd1;
		       Y_counter <= Y_counter + 18'd1;
               top_state <= S_M1_Lead_out_0;
			end
			
          
        end
		S_M1_Lead_out_8: begin
		    M1_SRAM_address <= U_base_address + U_counter;
			 if (ver_counter== 8'd239) begin
			    ver_counter=1'd0;
                top_state <= S_M1_1;
             end else begin
			    ver_counter=ver_counter+1'd1;
				//M1_SRAM_address <= U_base_address + U_counter;
				M1_SRAM_we_n <= 1'b1;
			    U_counter=U_counter+18'd1;
                top_state <= S_M1_Lead_in_0;
             end
			
           
        end
		
  
		
		
		
		
    S_M1_1: begin
            top_state <= S_M1_DONE;
        end
//----------------------------------------------------------------------------//
        S_M1_DONE: begin

            M1_done <= 1'b1;
        end

        default: top_state <= S_M1_IDLE;

        endcase
    end
end

endmodule
