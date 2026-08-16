module LCRC_injector #(
    parameter DATA_WIDTH = 32,
    parameter HEADER_DW  = 4,  //max header size
    parameter SEQ_DW     = 1,  // 1 dw sequence number
    parameter PAYLOAD_DW = 2,  // max payload size for simplicity 
    parameter LCRC_DW    = 1  // 32 bit LCRC
) (
    input logic clk,
    input logic reset,
    input logic new_TLP_LCRC,
    input logic [DATA_WIDTH - 1 : 0] TLP_WITH_SEQ [0 : SEQ_DW + HEADER_DW + PAYLOAD_DW - 1],
    output logic new_TLP_REPLAY_BUFFER,
    output logic [DATA_WIDTH - 1 : 0] TLP [0 : SEQ_DW + HEADER_DW + PAYLOAD_DW + LCRC_DW - 1]
);

localparam Counter_Value = SEQ_DW + HEADER_DW + PAYLOAD_DW;
logic [3 : 0] DW_Counter;

logic fd; // First data. 1: SEED is used (initialise and calculate); 0: Previous CRC is used (continue and calculate)
logic nd; // New Data. d  has a valid data. Calculate new CRC
logic rdy;
logic [ 31:0] d; // Data in
logic [ 31:0] o; // Data
logic [ 31:0] c; // CRC
logic [ 31:0] c_out; //after byte level bit reversal 

typedef enum logic [1 : 0] {
    IDLE       = 2'b00,
    FIRST_DATA = 2'b01,
    REMAINING  = 2'b10,
    DONE       = 2'b11
} state_t;

state_t state_curr;

always_ff @(posedge clk) begin
    case (state_curr)
        IDLE: begin
            if (new_TLP_LCRC) begin
                fd <= 1'b1;
                nd <= 1'b1;
                state_curr <= FIRST_DATA;
                DW_Counter <= 1;
                d <= 32'b0;
            end
            new_TLP_REPLAY_BUFFER <= 1'b0;
        end
        FIRST_DATA: begin
            d  <= TLP_WITH_SEQ[0];
            state_curr <= REMAINING;
        end
        REMAINING: begin
            fd <= 1'b0;
            if (DW_Counter > Counter_Value) begin
                state_curr <= DONE;
            end
            else if (DW_Counter == Counter_Value) begin
                DW_Counter <= DW_Counter + 1;
                nd         <= 0;
            end
            else if (DW_Counter != Counter_Value) begin
                d          <= TLP_WITH_SEQ[DW_Counter];
                DW_Counter <= DW_Counter + 1;
            end
        end 
        DONE: begin
            TLP[0]     <= TLP_WITH_SEQ[0];
            TLP[1]     <= TLP_WITH_SEQ[1];
            TLP[2]     <= TLP_WITH_SEQ[2];
            TLP[3]     <= TLP_WITH_SEQ[3];
            TLP[4]     <= TLP_WITH_SEQ[4];
            TLP[5]     <= TLP_WITH_SEQ[5];
            TLP[6]     <= TLP_WITH_SEQ[6];
            TLP[7]     <= c_out;
            state_curr <= IDLE;

            new_TLP_REPLAY_BUFFER <= 1'b1;
        end
        default: state_curr <= IDLE;
    endcase
end

CRC_Gen CRC_Gen_TX_dut (
    .clk(clk),
    .reset(reset),
    .fd(fd),
    .nd(nd),
    .rdy(rdy),
    .d(d),
    .o(o),
    .c(c),
    .c_out(c_out)
);
    
endmodule