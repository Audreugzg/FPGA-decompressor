`ifndef DEFINE_STATE

// This defines the states
typedef enum logic [2:0] {
	S_IDLE,
	S_ENABLE_UART_RX,
	S_WAIT_UART_RX,

	S_M1,
	S_M2,
	S_M3
}top_state_type;

typedef enum logic [5:0] {
	S_M1_IDLE,
	S_M1_Lead_in_0,
	S_M1_Lead_in_1,
	S_M1_Lead_in_2,
	S_M1_Lead_in_3,
	S_M1_Lead_in_4,
	S_M1_Lead_in_5,
	S_M1_Lead_in_6,
	S_M1_Lead_in_7,
	S_M1_Lead_in_8,
	S_M1_Lead_in_9,
	S_M1_Lead_in_10,
	S_M1_Lead_in_11,

	S_M1_Loop_0,
	S_M1_Loop_1,
	S_M1_Loop_2,
	S_M1_Loop_3,
	S_M1_Loop_4,
	S_M1_Loop_5,
	S_M1_Loop_6,
	S_M1_Loop_7,
	S_M1_Loop_8,
	S_M1_Loop_9,
	S_M1_Loop_10,
	S_M1_Loop_11,
	S_M1_Loop_12,
	S_M1_Loop_13,
	S_M1_Loop_14,
	S_M1_Loop_15,
	S_M1_Loop_16,
	S_M1_Loop_17,
	S_M1_Loop_18,
	S_M1_Loop_19,
	S_M1_Loop_20,
	S_M1_Loop_21,
	S_M1_Loop_22,
	S_M1_Lead_out_0,
	S_M1_Lead_out_1,
	S_M1_Lead_out_2,
	S_M1_Lead_out_3,
	S_M1_Lead_out_4,
	S_M1_Lead_out_5,
	S_M1_Lead_out_6,
	S_M1_Lead_out_7,
	S_M1_Lead_out_8,
	S_M1_Lead_out_9,
	S_M1_Lead_out_10,
	S_M1_Lead_out_11,
	S_M1_Lead_out_12,
	S_M1_Lead_out_13,
	S_M1_Lead_out_14,
	S_M1_Lead_out_15,
	S_M1_Lead_out_16,
	S_M1_Lead_out_17,
	S_M1_Lead_out_18,
	S_M1_Lead_out_19,
	S_M1_Lead_out_20,
	S_M1_Lead_out_21,
	S_M1_Lead_out_22,
	S_M1_Lead_out_23,
	S_M1_1,
	S_M1_DONE
}M1_state_type;

typedef enum logic [2:0] {
	S_M2_IDLE,
	S_M2_1,
	S_M2_DONE
}M2_state_type;

typedef enum logic [2:0] {
	S_M3_IDLE,
	S_M3_1,
	S_M3_DONE
}M3_state_type;


typedef enum logic [1:0] {
	S_RXC_IDLE,
	S_RXC_SYNC,
	S_RXC_ASSEMBLE_DATA,
	S_RXC_STOP_BIT
} RX_Controller_state_type;

typedef enum logic [2:0] {
	S_US_IDLE,
	S_US_STRIP_FILE_HEADER_1,
	S_US_STRIP_FILE_HEADER_2,
	S_US_START_FIRST_BYTE_RECEIVE,
	S_US_WRITE_FIRST_BYTE,
	S_US_START_SECOND_BYTE_RECEIVE,
	S_US_WRITE_SECOND_BYTE
} UART_SRAM_state_type;

typedef enum logic [3:0] {
	S_VS_WAIT_NEW_PIXEL_ROW,
	S_VS_NEW_PIXEL_ROW_DELAY_1,
	S_VS_NEW_PIXEL_ROW_DELAY_2,
	S_VS_NEW_PIXEL_ROW_DELAY_3,
	S_VS_NEW_PIXEL_ROW_DELAY_4,
	S_VS_NEW_PIXEL_ROW_DELAY_5,
	S_VS_FETCH_PIXEL_DATA_0,
	S_VS_FETCH_PIXEL_DATA_1,
	S_VS_FETCH_PIXEL_DATA_2,
	S_VS_FETCH_PIXEL_DATA_3
} VGA_SRAM_state_type;

`define DEFINE_STATE 1
`endif
