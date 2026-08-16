module TX_RX_DLL_top #(
    parameter DATA_WIDTH = 32,
    parameter HEADER_DW  = 4,  //max header size
    parameter SEQ_DW     = 1,  // 1 dw sequence number
    parameter PAYLOAD_DW = 2,  // max payload size for simplicity 
    parameter LCRC_DW    = 1  // 32 bit LCRC
) (
    input logic clk,
    input logic reset,
    input logic LCRC_Fault,
    input logic Higher_Seq_Fault,
    input logic Duplicate_Ack,
    input logic new_TLP_IN,
    input logic [DATA_WIDTH - 1 : 0] TLP_FROM_TL [0 : HEADER_DW + PAYLOAD_DW - 1],
    output logic new_TLP_RX,
    output logic [DATA_WIDTH - 1 : 0] TLP_EXTRACT_OUT [0 : HEADER_DW + PAYLOAD_DW - 1] //final TLP to TL
);
    
    logic [31 : 0] DLLP;
    logic [DATA_WIDTH - 1 : 0] TLP [0 : SEQ_DW + HEADER_DW + PAYLOAD_DW + LCRC_DW - 1];
    logic [DATA_WIDTH - 1 : 0] TLP_OUT [0 : SEQ_DW + HEADER_DW + PAYLOAD_DW + LCRC_DW - 1];

    logic [DATA_WIDTH - 1 : 0] TLP_OUT_FAULT [0 : SEQ_DW + HEADER_DW + PAYLOAD_DW + LCRC_DW - 1];

    Transmitter_top Transmitter_top_DLL_dut (
        .clk(clk),
        .reset(reset),
        .new_TLP_IN(new_TLP_IN),
        .TLP_FROM_TL(TLP_FROM_TL),
        .DLLP(DLLP),
        .new_TLP_RX(new_TLP_RX),
        .TLP_OUT(TLP_OUT)
    );

    fault_injector fault_injector_dut (
        .LCRC_Fault(LCRC_Fault),
        .Higher_Seq_Fault(Higher_Seq_Fault),
        .Duplicate_Ack(Duplicate_Ack),
        .TLP_OUT(TLP_OUT),
        .TLP_OUT_FAULT(TLP_OUT_FAULT)
    );

    Receiver_top Receiver_top_DLL_dut (
        .clk(clk),
        .reset(reset),
        .new_TLP(new_TLP_RX),
        .TLP(TLP_OUT_FAULT),
        .TLP_EXTRACT_OUT(TLP_EXTRACT_OUT),
        .DLLP(DLLP)
    );

endmodule