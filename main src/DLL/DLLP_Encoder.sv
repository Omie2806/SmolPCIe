module DLLP_Encoder #(
    parameter DATA_WIDTH = 32,
    parameter HEADER_DW  = 4,  //max header size
    parameter SEQ_DW     = 1,  // 1 dw sequence number
    parameter PAYLOAD_DW = 2,  // max payload size for simplicity 
    parameter LCRC_DW    = 1  // 32 bit LCRC
) (
    input logic ACK,
    input logic NAK,
    input logic  [11 : 0] SEQUENCE_NUMBER,
    output logic [31 : 0] DLLP //ill not add DLLP error checking for now
);

assign DLLP[31 : 20] = SEQUENCE_NUMBER;
assign DLLP[19 : 8]  = 'b0;
assign DLLP[7 : 0]   = ACK ? 8'h00 : (NAK ? 8'h10 : 8'h11); //11 will be used for idle in this case
    
endmodule