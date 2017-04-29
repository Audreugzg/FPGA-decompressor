

# add waves to waveform
add wave Clock_50
add wave -divider {some label for my divider}
add wave uut/top_state
add wave uut/M1_unit/top_state
#add wave uut/M2_unit/top_state
#add wave uut/M3_unit/top_state
add wave uut/SRAM_we_n
add wave -decimal uut/SRAM_write_data
add wave -decimal uut/SRAM_read_data
add wave -hexadecimal uut/SRAM_address

add wave -decimal uut/M1_unit/R_data
add wave -decimal uut/M1_unit/G_data
add wave -decimal uut/M1_unit/B_data

add wave -divider

add wave -decimal uut/M1_unit/mult_op_1
add wave -decimal uut/M1_unit/mult_op_2
add wave -decimal uut/M1_unit/mult_op_3
add wave -decimal uut/M1_unit/mult_op_4
add wave -decimal uut/M1_unit/mult_op_5
add wave -decimal uut/M1_unit/mult_op_6
add wave -decimal uut/M1_unit/mult_res_1
add wave -decimal uut/M1_unit/mult_res_2
add wave -decimal uut/M1_unit/mult_res_3

add wave -decimal uut/M1_unit/Y_data
add wave -decimal uut/M1_unit/U_prime
add wave -decimal uut/M1_unit/U_buffer
add wave -decimal uut/M1_unit/U_jplus5_data
add wave -decimal uut/M1_unit/U_jplus3_data
add wave -decimal uut/M1_unit/U_jplus1_data
add wave -decimal uut/M1_unit/U_jminus1_data
add wave -decimal uut/M1_unit/U_jminus3_data
add wave -decimal uut/M1_unit/U_jminus5_data
add wave -decimal uut/M1_unit/V_prime
add wave -decimal uut/M1_unit/V_buffer
add wave -decimal uut/M1_unit/V_jplus5_data
add wave -decimal uut/M1_unit/V_jplus3_data
add wave -decimal uut/M1_unit/V_jplus1_data
add wave -decimal uut/M1_unit/V_jminus1_data
add wave -decimal uut/M1_unit/V_jminus3_data
add wave -decimal uut/M1_unit/V_jminus5_data
add wave -decimal uut/M1_unit/R_data
add wave -decimal uut/M1_unit/G_data
add wave -decimal uut/M1_unit/B_data
add wave -decimal uut/M1_unit/Rb_data
add wave -decimal uut/M1_unit/Gb_data
add wave -decimal uut/M1_unit/Bb_data
add wave -decimal uut/M1_unit/ver_counter
add wave -decimal uut/M1_unit/horz_counter