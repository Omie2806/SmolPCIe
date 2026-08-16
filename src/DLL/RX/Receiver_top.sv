module Receiver_top #(
    parameter DATA_WIDTH = 32,
    parameter HEADER_DW  = 4,  //max header size
    parameter SEQ_DW     = 1,  // 1 dw sequence number
    parameter PAYLOAD_DW = 2,  // max payload size for simplicity 
    parameter LCRC_DW    = 1  // 32 bit LCRC
) (
    input logic clk,
    input logic reset,
    input logic new_TLP,
    input logic [DATA_WIDTH - 1 : 0] TLP [0 : SEQ_DW + HEADER_DW + PAYLOAD_DW + LCRC_DW - 1],
    output logic [DATA_WIDTH - 1 : 0] TLP_EXTRACT_OUT [0 : HEADER_DW + PAYLOAD_DW - 1], //final TLP to TL
    output logic [31 : 0] DLLP
);

logic error;
logic no_error;
logic [11 : 0] SEQUENCE_NUMBER;
logic [DATA_WIDTH - 1 : 0] TLP_EXTRACT [0 : SEQ_DW + HEADER_DW + PAYLOAD_DW - 1];

DLLP_Encoder DLLP_Encoder_dut (
    .clk(clk),
    .reset(reset),
    .ACK(ACK),
    .NAK(NAK),
    .SEQUENCE_NUMBER(SEQUENCE_NUMBER),
    .DLLP(DLLP)
);

CRC_Checker CRC_Checker_dut (
    .clk(clk),
    .reset(reset),
    .new_TLP(new_TLP),
    .TLP(TLP),
    .error(error),
    .no_error(no_error),
    .TLP_EXTRACT(TLP_EXTRACT)
);

ACK_NAK ACK_NAK_dut (
    .clk(clk),
    .reset(reset),
    .error(error),
    .no_error(no_error),
    .TLP_EXTRACT(TLP_EXTRACT),
    .ACK(ACK),
    .NAK(NAK),
    .SEQUENCE_NUMBER(SEQUENCE_NUMBER),
    .TLP_EXTRACT_OUT(TLP_EXTRACT_OUT)
);
    
endmodule