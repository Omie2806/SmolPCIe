module DLLP_Decoder #(
    parameter DATA_WIDTH = 32,
    parameter HEADER_DW  = 4,  //max header size
    parameter SEQ_DW     = 1,  // 1 dw sequence number
    parameter PAYLOAD_DW = 2,  // max payload size for simplicity 
    parameter LCRC_DW    = 1  // 32 bit LCRC
) (
    input logic [31 : 0] DLLP,
    output logic ACK,
    output logic NAK,
    output logic  [11 : 0] SEQUENCE_NUMBER
);

assign SEQUENCE_NUMBER = DLLP[31 : 20];
    
always_comb begin 
    ACK = 0;
    NAK = 0;
    if (DLLP[7 : 0] == 8'h00) begin
        ACK = 1;
    end
    if (DLLP[7 : 0] == 8'h10) begin
        NAK = 1;
    end
end
endmodule
