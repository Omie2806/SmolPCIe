module sequence_injector #(
    parameter DATA_WIDTH = 32,
    parameter HEADER_DW  = 4,  //max header size
    parameter SEQ_DW     = 1,  // 1 dw sequence number
    parameter PAYLOAD_DW = 2,  // max payload size for simplicity 
    parameter LCRC_DW    = 1  // 32 bit LCRC
) (
    input logic clk,
    input logic reset,
    input logic new_TLP_IN,
    input logic  [DATA_WIDTH - 1 : 0] TLP_FROM_TL [0 : HEADER_DW + PAYLOAD_DW - 1],
    output logic new_TLP_LCRC,
    output logic [DATA_WIDTH - 1 : 0] TLP_WITH_SEQ [0 : SEQ_DW + HEADER_DW + PAYLOAD_DW - 1] 
);
//now im ready to design the transmitter
logic[11 : 0] NEXT_SEQUENCE_GEN;

always_ff @(posedge clk) begin
    if (reset) begin
        NEXT_SEQUENCE_GEN <= 12'd1;
    end
    else if (new_TLP_IN) begin
        TLP_WITH_SEQ[0][11 : 0]  <= NEXT_SEQUENCE_GEN;
        TLP_WITH_SEQ[0][31 : 12] <= 'b0;
        TLP_WITH_SEQ[1]          <= TLP_FROM_TL[0];
        TLP_WITH_SEQ[2]          <= TLP_FROM_TL[1];
        TLP_WITH_SEQ[3]          <= TLP_FROM_TL[2];
        TLP_WITH_SEQ[4]          <= TLP_FROM_TL[3];
        TLP_WITH_SEQ[5]          <= TLP_FROM_TL[4];
        TLP_WITH_SEQ[6]          <= TLP_FROM_TL[5];
        NEXT_SEQUENCE_GEN        <= NEXT_SEQUENCE_GEN + 1; 
        new_TLP_LCRC             <= 1'b1;
    end
    else if (!new_TLP_IN) begin
        new_TLP_LCRC             <= 1'b0;
    end
end
    
endmodule