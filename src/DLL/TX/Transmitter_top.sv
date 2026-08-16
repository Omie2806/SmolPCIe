module Transmitter_top #(
    parameter DATA_WIDTH = 32,
    parameter HEADER_DW  = 4,   //max header size
    parameter SEQ_DW     = 1,  // 1 dw sequence number
    parameter PAYLOAD_DW = 2,  // max payload size for simplicity 
    parameter LCRC_DW    = 1   // 32 bit LCRC
) (
    input logic clk,
    input logic reset,
    input logic new_TLP_IN,
    input logic [DATA_WIDTH - 1 : 0] TLP_FROM_TL [0 : HEADER_DW + PAYLOAD_DW - 1],
    input logic [31 : 0] DLLP,
    output logic new_TLP_RX,
    output logic [DATA_WIDTH - 1 : 0] TLP_OUT [0 : SEQ_DW + HEADER_DW + PAYLOAD_DW + LCRC_DW - 1]
);
    
    logic ACK;
    logic NAK;
    logic [11 : 0] SEQUENCE_NUMBER;
    logic new_TLP_REPLAY_BUFFER;
    logic [DATA_WIDTH - 1 : 0] TLP [0 : SEQ_DW + HEADER_DW + PAYLOAD_DW + LCRC_DW - 1];

    SEQ_and_LCRC_injector_top SEQ_and_LCRC_injector_top_dut (
        .clk(clk),
        .reset(reset),
        .new_TLP_IN(new_TLP_IN),
        .TLP_FROM_TL(TLP_FROM_TL),
        .new_TLP_REPLAY_BUFFER(new_TLP_REPLAY_BUFFER),
        .TLP(TLP)
    );

    Replay_Buffer Replay_Buffer_dut (
        .clk(clk),
        .reset(reset),
        .new_TLP_REPLAY_BUFFER(new_TLP_REPLAY_BUFFER),
        .TLP(TLP),
        .ACK(ACK),
        .NAK(NAK),
        .SEQ_NUM(SEQUENCE_NUMBER),
        .new_TLP_RX(new_TLP_RX),
        .TLP_OUT(TLP_OUT)
    );

    DLLP_Decoder DLLP_Decoder_dut (
        .DLLP(DLLP),
        .ACK(ACK),
        .NAK(NAK),
        .SEQUENCE_NUMBER(SEQUENCE_NUMBER)
    );
endmodule