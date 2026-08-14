module CRC_Checker #(
    parameter DATA_WIDTH = 32,
    parameter HEADER_DW  = 4,  //max header size
    parameter SEQ_DW     = 1,  // 1 dw sequence number
    parameter PAYLOAD_DW = 2,  // max payload size for simplicity 
    parameter LCRC_DW    = 1  // 32 bit LCRC
) (
    input logic clk,
    input logic reset,
    input logic new_TLP,
    input logic [DATA_WIDTH - 1 : 0] TLP [0 : SEQ_DW + HEADER_DW + PAYLOAD_DW + LCRC_DW - 1],
    output logic error,
    output logic no_error,
    output logic [DATA_WIDTH - 1 : 0] TLP_EXTRACT [0 : SEQ_DW + HEADER_DW + PAYLOAD_DW - 1]
);
localparam Counter_Value = HEADER_DW + SEQ_DW + PAYLOAD_DW;

logic [DATA_WIDTH - 1 : 0] LCRC_reg; //extract the LCRC from the received TLP
logic [3 : 0] DW_Counter;

typedef enum logic [1 : 0] {
    IDLE       = 2'b00,
    FIRST_DATA = 2'b01,
    REMAINING  = 2'b10,
    DONE       = 2'b11
} state_t;

state_t state_curr;

logic fd; // First data. 1: SEED is used (initialise and calculate); 0: Previous CRC is used (continue and calculate)
logic nd; // New Data. d  has a valid data. Calculate new CRC
logic rdy;
logic [ 31:0] d; // Data in
logic [ 31:0] o; // Data
logic [ 31:0] c; // CRC
logic [ 31:0] c_out; //after byte level bit reversal 

always_ff @(posedge clk) begin
    case (state_curr)
        IDLE: begin
            error    <= 0;
            no_error <= 0;
            if (new_TLP) begin
                LCRC_reg <= TLP[SEQ_DW + HEADER_DW + PAYLOAD_DW + LCRC_DW - 1]; //LCRC is attached at the end
                for (integer i = 0; i < SEQ_DW + HEADER_DW + PAYLOAD_DW; i++) begin
                    TLP_EXTRACT[i] <= TLP[i]; 
                end
                fd <= 1'b1;
                nd <= 1'b1;
                state_curr <= FIRST_DATA;
                DW_Counter <= 1;
                d <= 32'b0;
            end
        end
        FIRST_DATA: begin
            d  <= TLP_EXTRACT[0];
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
                d          <= TLP_EXTRACT[DW_Counter];
                DW_Counter <= DW_Counter + 1;
            end
        end 
        DONE: begin
            if(c_out == LCRC_reg) begin
                error    <= 0;
                no_error <= 1;
            end
            else if (c_out != LCRC_reg) begin
                error    <= 1;
                no_error <= 0;
            end
            state_curr <= IDLE;
        end
        default: state_curr <= IDLE;
    endcase
end

CRC_Gen CRC_Gen_dut (
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
