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
    output logic [DATA_WIDTH - 1 : 0] TLP_EXTRACT [0 : SEQ_DW + HEADER_DW + PAYLOAD_DW - 1] //final TLP to TL
    //i can also output ack/nak dllps from here itself
    //or i can keep the DLLP generation seperate
);
    //there are cases: 
    //if LCRC Check failed then error goes high and we schedule a NAK
    //else we check the sequence number,
    //if higher than expected then NAK,
    //if lower than expected then ACK,
    //if same as expected then wait to latnecy timer to run out 
    //increment expected seq val

localparam MAX_TIME = 7'd127;
logic [6 : 0]  ACK_LAT_TIMER; //estimated using timer equation as payload size is 2
logic [11 : 0] NEXT_RCV_SEQ;

logic [11 : 0] RECEIVED_SEQ;

assign RECEIVED_SEQ = TLP_EXTRACT[6][11 : 0];

always_ff @(posedge clk) begin
    if (reset) begin
        ACK_LAT_TIMER <= 7'd0;
        NEXT_RCV_SEQ  <= 12'd0;
    end
    else if (!reset) begin
        ACK_LAT_TIMER <= ACK_LAT_TIMER + 1;
    end
end

typedef enum logic [2 : 0] {
    IDLE            = 3'b000,
    TIMER_RUN_OUT   = 3'b001,
    ACKNOWLEDGE     = 3'b010,
    NEG_ACKNOWLEDGE = 3'b011
} state_t;

state_t state_curr;

always_ff @(posedge clk) begin
    if (reset) begin
        state_curr <= IDLE;
    end
    else begin
        case (state_curr)
        //i might not need ACKNOWLEDGE and TIMER_RUN_OUT states
        //or maybe i could use those states to make ACK and NAK DLLPs
            IDLE: begin
                if (error) begin
                    state_curr <= NEG_ACKNOWLEDGE; //immediate NAK
                    NAK        <= 1'b1;
                    ACK        <= 1'b0;
                end
                else if (no_error) begin
                    if (NEXT_RCV_SEQ == RECEIVED_SEQ) begin
                        if (ACK_LAT_TIMER == MAX_TIME) begin
                            state_curr <= ACKNOWLEDGE;
                            //first send ACK then process new TLP
                            //or i think i can send ACK and continue processing TLPs
                        end
                        else if (ACK_LAT_TIMER < MAX_TIME) begin
                            //can process new TLP
                        end 
                    end
                    else if (RECEIVED_SEQ < NEXT_RCV_SEQ) begin //duplicate
                        state_curr <= ACKNOWLEDGE;
                        ACK        <= 1'b1;
                        NAK        <= 1'b0;
                        //send acknowledge and continue receiving new TLPs
                        //and clear NAK 
                    end
                    else if (RECEIVED_SEQ > NEXT_RCV_SEQ) begin //missed TLP somewhere
                        state_curr <= NEG_ACKNOWLEDGE;
                        ACK        <= 1'b0;
                        NAK        <= 1'b1;
                    end
                end
                else if (ACK_LAT_TIMER == MAX_TIME) begin
                    state_curr <= ACKNOWLEDGE;
                    NAK        <= 1'b0;
                    ACK        <= 1'b1;
                end
            end
            TIMER_RUN_OUT: begin
                
            end
            default: state_curr <= IDLE; 
        endcase
    end
end
endmodule
