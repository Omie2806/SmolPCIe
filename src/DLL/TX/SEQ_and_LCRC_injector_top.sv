module SEQ_and_LCRC_injector_top #(
    parameter DATA_WIDTH = 32,
    parameter HEADER_DW  = 4,   //max header size
    parameter SEQ_DW     = 1,  // 1 dw sequence number
    parameter PAYLOAD_DW = 2,  // max payload size for simplicity 
    parameter LCRC_DW    = 1   // 32 bit LCRC
) (
    input logic clk,
    input logic reset,
    input logic new_TLP_IN,
    input logic  [DATA_WIDTH - 1 : 0] TLP_FROM_TL [0 : HEADER_DW + PAYLOAD_DW - 1],
    output logic new_TLP_REPLAY_BUFFER,
    output logic [DATA_WIDTH - 1 : 0] TLP [0 : SEQ_DW + HEADER_DW + PAYLOAD_DW + LCRC_DW - 1]
);
    logic new_TLP_LCRC;
    logic [DATA_WIDTH - 1 : 0] TLP_WITH_SEQ [0 : SEQ_DW + HEADER_DW + PAYLOAD_DW - 1];

    sequence_injector dut_1 (
        .clk(clk),
        .reset(reset),
        .new_TLP_IN(new_TLP_IN),
        .TLP_FROM_TL(TLP_FROM_TL),
        .new_TLP_LCRC(new_TLP_LCRC),
        .TLP_WITH_SEQ(TLP_WITH_SEQ)
    );

    LCRC_injector dut_2 (
        .clk(clk),
        .reset(reset),
        .new_TLP_LCRC(new_TLP_LCRC),
        .new_TLP_REPLAY_BUFFER(new_TLP_REPLAY_BUFFER),
        .TLP_WITH_SEQ(TLP_WITH_SEQ),
        .TLP(TLP)
    );

endmodule