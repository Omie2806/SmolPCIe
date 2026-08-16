module fault_injector #(
    parameter DATA_WIDTH = 32,
    parameter HEADER_DW  = 4,  //max header size
    parameter SEQ_DW     = 1,  // 1 dw sequence number
    parameter PAYLOAD_DW = 2,  // max payload size for simplicity 
    parameter LCRC_DW    = 1  // 32 bit LCRC
) ( 
    input logic LCRC_Fault,
    input logic Higher_Seq_Fault,
    input logic Duplicate_Ack,
    input logic [DATA_WIDTH - 1 : 0] TLP_OUT [0 : SEQ_DW + HEADER_DW + PAYLOAD_DW + LCRC_DW - 1],
    output logic [DATA_WIDTH - 1 : 0] TLP_OUT_FAULT [0 : SEQ_DW + HEADER_DW + PAYLOAD_DW + LCRC_DW - 1]
);
    always_comb begin 
        //i have to time the fault when new_TLP_RX goes high
        if (LCRC_Fault) begin
            TLP_OUT_FAULT[7] = TLP_OUT[7] ^ 32'h0000_0001;
            TLP_OUT_FAULT[0] = TLP_OUT[0];
        end
        else if (Higher_Seq_Fault) begin
            TLP_OUT_FAULT[0] = TLP_OUT[0] + 32'h0000_0004;
            TLP_OUT_FAULT[7] = TLP_OUT[7];
        end
        else if (Duplicate_Ack) begin
            TLP_OUT_FAULT[0] = TLP_OUT[0] - 32'h0000_0001;
            TLP_OUT_FAULT[7] = TLP_OUT[7];
        end
        // if (!LCRC_Fault) begin
        //     TLP_OUT_FAULT[0] = TLP_OUT[0];
        // end
        if (!Higher_Seq_Fault && !Duplicate_Ack && !LCRC_Fault) begin
            TLP_OUT_FAULT[7] = TLP_OUT[7];
            TLP_OUT_FAULT[0] = TLP_OUT[0];
        end
    end

    assign TLP_OUT_FAULT[1] = TLP_OUT[1];
    assign TLP_OUT_FAULT[2] = TLP_OUT[2];
    assign TLP_OUT_FAULT[3] = TLP_OUT[3];
    assign TLP_OUT_FAULT[4] = TLP_OUT[4];
    assign TLP_OUT_FAULT[5] = TLP_OUT[5];
    assign TLP_OUT_FAULT[6] = TLP_OUT[6];

endmodule