module DLLP_Encoder #(
    parameter DATA_WIDTH = 32,
    parameter HEADER_DW  = 4,  //max header size
    parameter SEQ_DW     = 1,  // 1 dw sequence number
    parameter PAYLOAD_DW = 2,  // max payload size for simplicity 
    parameter LCRC_DW    = 1  // 32 bit LCRC
) (
    input logic clk,
    input logic reset,
    input logic ACK,
    input logic NAK,
    input logic  [11 : 0] SEQUENCE_NUMBER,
    output logic [31 : 0] DLLP //ill not add DLLP error checking for now
);
logic NAK_out;
logic extra_clk;

logic ACK_out;
logic extra_clk_ack;

always_ff @(posedge clk) begin
    if (reset) begin
        NAK_out <= 0;
        extra_clk <= 0;

        ACK_out <= 0;
        extra_clk_ack <= 0;
    end
    else begin
        if (NAK && !NAK_out && !extra_clk) begin
            NAK_out <= 1;
            extra_clk <= 0;
        end
        else if (NAK_out && NAK && !extra_clk) begin
            NAK_out <= 0;
            extra_clk <= 1;
        end
        else if (!NAK) begin
            NAK_out <= 0;
            extra_clk <= 0;
        end
    end
end
assign DLLP[31 : 20] = SEQUENCE_NUMBER;
assign DLLP[19 : 8]  = 'b0;
assign DLLP[7 : 0]   = ACK ? 8'h00 : (NAK_out ? 8'h10 : 8'h11); //11 will be used for idle in this case
    
endmodule