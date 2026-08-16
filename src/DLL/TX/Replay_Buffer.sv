module Replay_Buffer #(
    parameter DATA_WIDTH = 32,
    parameter HEADER_DW  = 4,   //max header size
    parameter SEQ_DW     = 1,  // 1 dw sequence number
    parameter PAYLOAD_DW = 2,  // max payload size for simplicity 
    parameter LCRC_DW    = 1   // 32 bit LCRC
) (
    input logic clk,
    input logic reset,
    input logic new_TLP_REPLAY_BUFFER,
    input logic [DATA_WIDTH - 1 : 0] TLP [0 : SEQ_DW + HEADER_DW + PAYLOAD_DW + LCRC_DW - 1],
    input logic ACK,
    input logic NAK,
    input logic [11 : 0] SEQ_NUM,
    output logic new_TLP_RX,
    output logic [DATA_WIDTH - 1 : 0] TLP_OUT [0 : SEQ_DW + HEADER_DW + PAYLOAD_DW + LCRC_DW - 1]
);
//i'll have to wait for a few cycles before sending a new TLP i cannot send a new one every cycle as 
//i don't have a receiver buffer

reg [DATA_WIDTH - 1 : 0] REPLAY_BUFFER_SEQ       [0 : 63];
reg [DATA_WIDTH - 1 : 0] REPLAY_BUFFER_HEADER_0  [0 : 63];
reg [DATA_WIDTH - 1 : 0] REPLAY_BUFFER_HEADER_1  [0 : 63];
reg [DATA_WIDTH - 1 : 0] REPLAY_BUFFER_HEADER_2  [0 : 63];
reg [DATA_WIDTH - 1 : 0] REPLAY_BUFFER_HEADER_3  [0 : 63];
reg [DATA_WIDTH - 1 : 0] REPLAY_BUFFER_PAYLOAD_0 [0 : 63];
reg [DATA_WIDTH - 1 : 0] REPLAY_BUFFER_PAYLOAD_1 [0 : 63];
reg [DATA_WIDTH - 1 : 0] REPLAY_BUFFER_LCRC      [0 : 63];

localparam MAX_TIME = 9'd383;

localparam TIME_BEFORE_NEXT_TLP = 15; //15 clk cycles for now
logic [4 : 0] Counter_TLP;

logic [8 : 0]  replay_timer; //3*ack_lat_timer
logic [1 : 0]  replay_num;

logic [11 : 0] ACKD_SEQ;

logic [11 : 0] replay_buffer_pointer_read;
logic [11 : 0] replay_buffer_pointer_write;

typedef enum logic [1 : 0] {
    SEND_TLP  = 2'b00,
    WAIT      = 2'b01,
    DEAL_ACK  = 2'b10,
    DEAL_NAK  = 2'b11
} state_t;

state_t state_curr;

always_ff @(posedge clk) begin
    replay_timer <= replay_timer + 1; //always increment
    if (reset) begin
        for (integer i = 0; i < 64; i++) begin
            REPLAY_BUFFER_SEQ[i] <= 32'hFFFF_FFFF; //ill not use this sequence number and will be treated as empty
            REPLAY_BUFFER_HEADER_0[i] <= 0;
            REPLAY_BUFFER_HEADER_2[i] <= 0;
            REPLAY_BUFFER_HEADER_1[i] <= 0;
            REPLAY_BUFFER_HEADER_3[i] <= 0;
            REPLAY_BUFFER_PAYLOAD_0[i] <= 0;
            REPLAY_BUFFER_PAYLOAD_1[i] <= 0;
            REPLAY_BUFFER_LCRC[i] <= 0;
        end
        new_TLP_RX <= 1'b0;
        for (integer i = 0; i < 8; i++) begin
            TLP_OUT[i] <= 0;
        end
        Counter_TLP <= 0;
        replay_timer <= 0;
        replay_num <= 0;
        ACKD_SEQ <= 12'h0;
        replay_buffer_pointer_read <= 0;
        replay_buffer_pointer_write <= 0;
    end
    else begin
        case (state_curr)
            SEND_TLP: begin
                if (REPLAY_BUFFER_SEQ[replay_buffer_pointer_read] != 32'hFFFF_FFFF) begin
                    new_TLP_RX <= 1;
                    TLP_OUT[0] <= REPLAY_BUFFER_SEQ[replay_buffer_pointer_read];
                    TLP_OUT[1] <= REPLAY_BUFFER_HEADER_0[replay_buffer_pointer_read];
                    TLP_OUT[2] <= REPLAY_BUFFER_HEADER_1[replay_buffer_pointer_read];
                    TLP_OUT[3] <= REPLAY_BUFFER_HEADER_2[replay_buffer_pointer_read];
                    TLP_OUT[4] <= REPLAY_BUFFER_HEADER_3[replay_buffer_pointer_read];
                    TLP_OUT[5] <= REPLAY_BUFFER_PAYLOAD_0[replay_buffer_pointer_read];
                    TLP_OUT[6] <= REPLAY_BUFFER_PAYLOAD_1[replay_buffer_pointer_read];
                    TLP_OUT[7] <= REPLAY_BUFFER_LCRC[replay_buffer_pointer_read];

                    replay_buffer_pointer_read <= replay_buffer_pointer_read + 1;
                    state_curr <= WAIT;
                    Counter_TLP <= TIME_BEFORE_NEXT_TLP; 
                end
                if (ACK) begin
                    state_curr <= DEAL_ACK;
                end
                if (NAK) begin
                    state_curr <= DEAL_NAK;
                end
            end 
            WAIT: begin
                new_TLP_RX <= 0;
                if (Counter_TLP == 0) begin
                    state_curr <= SEND_TLP;
                end
                else if (Counter_TLP > 0) begin
                    Counter_TLP <= Counter_TLP - 1;
                end
                if (ACK) begin
                    state_curr <= DEAL_ACK;
                end
                if (NAK) begin
                    state_curr <= DEAL_NAK;
                end
            end
            DEAL_ACK: begin
                new_TLP_RX <= 0;
                for (integer i = 0; i < 64; i++) begin
                    if ((REPLAY_BUFFER_SEQ[i][11 : 0] <= SEQ_NUM) && (REPLAY_BUFFER_SEQ[i] != 32'hFFFF_FFFF)) begin
                        REPLAY_BUFFER_SEQ[i] <= 32'hFFFF_FFFF;
                    end
                end
                ACKD_SEQ <= SEQ_NUM;
                state_curr <= WAIT;
                replay_timer <= 0;
                replay_num <= 0;

                //i dont need this, instead if ack comes at WAIT, then go back and let the TLP finish
                // if (SEQ_NUM < TLP_OUT[0]) begin
                //    replay_buffer_pointer_read <= replay_buffer_pointer_read - 1; //TLP ack hence go to next
                // end
            end
            DEAL_NAK: begin
                new_TLP_RX <= 0;
                for (integer i = 0; i < 64; i++) begin
                    if ((REPLAY_BUFFER_SEQ[i][11 : 0] <= SEQ_NUM) && (REPLAY_BUFFER_SEQ[i] != 32'hFFFF_FFFF) && SEQ_NUM > ACKD_SEQ) begin
                        REPLAY_BUFFER_SEQ[i] <= 32'hFFFF_FFFF;
                        replay_buffer_pointer_read <= i + 1;
                    end
                end 
                Counter_TLP <= TIME_BEFORE_NEXT_TLP;
                new_TLP_RX <= 1;
                ACKD_SEQ <= SEQ_NUM;
                state_curr <= WAIT;
                replay_timer <= 0;
                replay_num <= 0;               
            end
            default: begin
               state_curr <= SEND_TLP; 
               new_TLP_RX <= 0;
            end
        endcase
    end
    if (new_TLP_REPLAY_BUFFER && (REPLAY_BUFFER_SEQ[replay_buffer_pointer_write] == 32'hFFFF_FFFF)) begin
        REPLAY_BUFFER_SEQ[replay_buffer_pointer_write] <= TLP[0]; //ill not use this sequence number and will be treated as empty
        REPLAY_BUFFER_HEADER_0[replay_buffer_pointer_write] <= TLP[1];
        REPLAY_BUFFER_HEADER_1[replay_buffer_pointer_write] <= TLP[2];
        REPLAY_BUFFER_HEADER_2[replay_buffer_pointer_write] <= TLP[3];
        REPLAY_BUFFER_HEADER_3[replay_buffer_pointer_write] <= TLP[4];
        REPLAY_BUFFER_PAYLOAD_0[replay_buffer_pointer_write] <= TLP[5];
        REPLAY_BUFFER_PAYLOAD_1[replay_buffer_pointer_write] <= TLP[6];
        REPLAY_BUFFER_LCRC[replay_buffer_pointer_write] <= TLP[7];
        replay_buffer_pointer_write <= replay_buffer_pointer_write + 1;
    end
end
endmodule