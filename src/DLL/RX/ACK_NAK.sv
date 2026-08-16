    //there are cases: 
    //if LCRC Check failed then error goes high and we schedule a NAK
    //else we check the sequence number,
    //if higher than expected then NAK,
    //if lower than expected then ACK,
    //if same as expected then wait to latnecy timer to run out 
    //increment expected seq val
module ACK_NAK #(
    parameter DATA_WIDTH = 32,
    parameter HEADER_DW  = 4,  //max header size
    parameter SEQ_DW     = 1,  // 1 dw sequence number
    parameter PAYLOAD_DW = 2,  // max payload size for simplicity 
    parameter LCRC_DW    = 1  // 32 bit LCRC
) (
    input logic clk,
    input logic reset,
    input logic error,
    input logic no_error,
    input logic [DATA_WIDTH - 1 : 0] TLP_EXTRACT [0 : SEQ_DW + HEADER_DW + PAYLOAD_DW - 1],
    output logic ACK,
    output logic NAK,
    output logic [11 : 0] SEQUENCE_NUMBER,
    output logic [DATA_WIDTH - 1 : 0] TLP_EXTRACT_OUT [0 : HEADER_DW + PAYLOAD_DW - 1] //final TLP to TL
);
localparam MAX_TIME = 7'd127;
logic [6 : 0]  ACK_LAT_TIMER; //estimated using timer equation as payload size is 2
logic [11 : 0] NEXT_RCV_SEQ;

logic [11 : 0] RECEIVED_SEQ;

always_ff @(posedge clk) begin
    if (reset) begin
        ACK_LAT_TIMER <= 7'd0;
        NEXT_RCV_SEQ  <= 12'd1;
        RECEIVED_SEQ  <= 'b1;
    end
    else if (!reset) begin
        if (!NAK && !ACK) begin
           ACK_LAT_TIMER <= ACK_LAT_TIMER + 1; 
        end
        else if (NAK || ACK) begin
            ACK_LAT_TIMER <= 7'd0;
        end
    end
    RECEIVED_SEQ <= TLP_EXTRACT[0][11 : 0];
end

always_ff @(posedge clk) begin
    if (ACK) begin
        ACK <= 0;
    end
    if (reset) begin
        ACK             <= 1'b0;
        NAK             <= 1'b0;
        SEQUENCE_NUMBER <= 'b0;
    end
    else begin
        if (error) begin
            NAK             <= 1'b1;
            ACK             <= 1'b0;
            SEQUENCE_NUMBER <= NEXT_RCV_SEQ - 1; //last good TLP
         end
        else if (no_error) begin
            if (NEXT_RCV_SEQ == RECEIVED_SEQ) begin
                if (ACK_LAT_TIMER == MAX_TIME) begin
                    NEXT_RCV_SEQ    <= RECEIVED_SEQ + 1;
                    ACK             <= 1'b1;
                    NAK             <= 1'b0;
                    SEQUENCE_NUMBER <= NEXT_RCV_SEQ - 1;

                    TLP_EXTRACT_OUT[0] <= TLP_EXTRACT[1];
                    TLP_EXTRACT_OUT[1] <= TLP_EXTRACT[2];
                    TLP_EXTRACT_OUT[2] <= TLP_EXTRACT[3];
                    TLP_EXTRACT_OUT[3] <= TLP_EXTRACT[4];
                    TLP_EXTRACT_OUT[4] <= TLP_EXTRACT[5];
                    TLP_EXTRACT_OUT[5] <= TLP_EXTRACT[6];
                end
                else if (ACK_LAT_TIMER < MAX_TIME) begin
                    //continue working no action required
                    NEXT_RCV_SEQ <= RECEIVED_SEQ + 1;
                    ACK          <= 1'b0;
                    NAK          <= 1'b0;

                    TLP_EXTRACT_OUT[0] <= TLP_EXTRACT[1];
                    TLP_EXTRACT_OUT[1] <= TLP_EXTRACT[2];
                    TLP_EXTRACT_OUT[2] <= TLP_EXTRACT[3];
                    TLP_EXTRACT_OUT[3] <= TLP_EXTRACT[4];
                    TLP_EXTRACT_OUT[4] <= TLP_EXTRACT[5];
                    TLP_EXTRACT_OUT[5] <= TLP_EXTRACT[6];
                end 
            end
            else if (RECEIVED_SEQ < NEXT_RCV_SEQ) begin //duplicate so no need to output again
                ACK             <= 1'b1;
                NAK             <= 1'b0;
                SEQUENCE_NUMBER <= NEXT_RCV_SEQ - 1;
            end
            else if (RECEIVED_SEQ > NEXT_RCV_SEQ) begin //missed TLP somewhere
                ACK             <= 1'b0;
                NAK             <= 1'b1;
                SEQUENCE_NUMBER <= NEXT_RCV_SEQ - 1;
            end
        end
        else if (ACK_LAT_TIMER == MAX_TIME) begin //no new TLP
            NAK             <= 1'b0;
            ACK             <= 1'b1;
            SEQUENCE_NUMBER <= NEXT_RCV_SEQ - 1;
        end
    end
end
endmodule