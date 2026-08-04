//type 0 config header
module device_1 #(
    parameter DATA_WIDTH = 32, //byte addressable
    parameter TOTAL_DW   = 16 //in bytes
) (
    input logic clk,
    input logic reset,
    input logic CONFIG_READ,
    input logic CONFIG_WRITE,
    input logic [4 : 0] Device_ID_Decoder,
    input logic [7 : 0] Register_Number,
    input logic [9 : 0] Length, //for multi DW transfers
    input logic DW_3_MEM_READ,
    input logic DW_3_MEM_WRITE,
    input logic DW_4_MEM_READ,
    input logic DW_4_MEM_WRITE,
    input logic [31 : 0] Address_lower,
    input logic [31 : 0] Address_upper,
    input logic IO_READ,
    input logic IO_WRITE,
    output logic Compl_Read,
    output logic Compl_Write,
    output logic mem_write_done,//this isnt a completion but for internal module
    output logic [2 : 0] Completer_Function,
    output logic [4 : 0] Completer_Dev,
    output logic [2 : 0] Compl_status, //completion always completes for now
    output logic [11 : 0] Byte_count, //number of bytes remaining to complete a read request with multiple completions 
    input logic [DATA_WIDTH - 1 : 0] data_in,
    output logic[DATA_WIDTH - 1 : 0] data_out
);
//completion to be issued when counter == length
logic [10 : 0] DW_Counter;
typedef enum logic [1 : 0] {
    SERVE      = 2'B00,
    SERVE_DONE = 2'b01,
    IDLE       = 2'b10
} state_t;

state_t state_curr;

//activate completion only when the edge falls
assign Compl_Read     = (state_curr == SERVE_DONE && (DW_3_MEM_READ || DW_4_MEM_READ)) || (IO_READ || CONFIG_READ);
assign Compl_Write    = CONFIG_WRITE || IO_WRITE;
assign mem_write_done = (state_curr == SERVE_DONE) && (DW_3_MEM_WRITE || DW_4_MEM_WRITE);
assign Compl_status   = 3'b000; //always completes for now
assign Byte_count     = 12'b0; //for now only a single completion is required

logic debug_read;
logic debug_write;
logic debug_read_4;
logic debug_write_4;
logic debug_read_io;
logic debug_write_io;

reg[DATA_WIDTH - 1 : 0] CONFIGURATION_SPACE [0 : TOTAL_DW - 1];
(* ram_style = "block" *) reg[DATA_WIDTH - 1 : 0] MEM_SPACE [0 : 255];
(* ram_style = "block" *) reg[DATA_WIDTH - 1 : 0] IO_SPACE  [0 : 255];
reg[DATA_WIDTH - 1 : 0] WRITE_MASK [0 : TOTAL_DW - 1];

assign Completer_Function = 3'b000;
assign Completer_Dev      = CONFIGURATION_SPACE[0][20 : 16];

//the device knows it's last writable BAR bits 
localparam [31:0] BAR0_LIMIT = 32'd12;
localparam [31:0] BAR1_LIMIT = 32'd26;
localparam [31:0] BAR3_LIMIT = 32'd8;

//combine lower and upper address
//lut cunt will remain high because config_space reads are combinational
logic [2*DATA_WIDTH - 1 : 0] BAR1_Address_64_Bits;
logic [2*DATA_WIDTH - 1 : 0] BAR1_Address_64_Bits_BAR;
logic [2*DATA_WIDTH - 1 : 0] BAR1_Address_64_Bits_BAR_LIMIT;
assign BAR1_Address_64_Bits           = {Address_upper, Address_lower};
assign BAR1_Address_64_Bits_BAR       = {CONFIGURATION_SPACE[6][31 : 0], CONFIGURATION_SPACE[5][31 : 26], 26'b0};
assign BAR1_Address_64_Bits_BAR_LIMIT = BAR1_Address_64_Bits_BAR + (1 << BAR1_LIMIT) - 1; //should have FFFs in LSB

logic [DATA_WIDTH - 1 : 0] BAR0_LIMIT_Address;
logic [DATA_WIDTH - 1 : 0] BAR0_LIMIT_Address_upper;
assign BAR0_LIMIT_Address       = {CONFIGURATION_SPACE[4][31 : 12], 12'b0};
assign BAR0_LIMIT_Address_upper = BAR0_LIMIT_Address + (1 << BAR0_LIMIT) - 1; //should have FFFs in LSB

logic [DATA_WIDTH - 1 : 0] BAR3_LIMIT_Address;
logic [DATA_WIDTH - 1 : 0] BAR3_LIMIT_Address_upper;
assign BAR3_LIMIT_Address       = {CONFIGURATION_SPACE[7][31 : 8], 8'b0};
assign BAR3_LIMIT_Address_upper = BAR3_LIMIT_Address + (1 << BAR3_LIMIT) - 1;

logic[7 : 0] effective_BAR0_Address;
logic[7 : 0] effective_BAR1_Address;
logic[7 : 0] effective_BAR3_Address;

assign effective_BAR0_Address = Address_lower - BAR0_LIMIT_Address + DW_Counter - 1;
assign effective_BAR1_Address = BAR1_Address_64_Bits - BAR1_Address_64_Bits_BAR + DW_Counter - 1;
assign effective_BAR3_Address = Address_lower - BAR3_LIMIT_Address;

always_ff @(posedge clk) begin
    if(reset) begin
        DW_Counter <= 11'd1;
        state_curr <= SERVE;
        debug_read <= 0;
        CONFIGURATION_SPACE[0][15 : 0] <= 16'h01; //defining vendor id

        //will ignore the next 3 lines for now and directly skip to BARS
        //BAR0
        CONFIGURATION_SPACE[4][0]     <= 1'b0; //memory req
        CONFIGURATION_SPACE[4][2 : 1] <= 2'b00; //32 bit decoding
        CONFIGURATION_SPACE[4][3]     <= 1'b0; //non-prefetchable
        //make last writeable bit by software 12
        CONFIGURATION_SPACE[4][11 : 4] <= 7'b0; //hardcoded to 0

        //BAR1
        CONFIGURATION_SPACE[5][0]     <= 1'b0; //memory req
        CONFIGURATION_SPACE[5][2 : 1] <= 2'b10; //64 bit decoding hence now BAR2 will hold upper address bits
        CONFIGURATION_SPACE[5][3]     <= 1'b1; //prefetchable
        //make last writeable bit by software 26
        CONFIGURATION_SPACE[5][25 : 4] <= 22'b0; //hardcoded to 0

        //BAR2 is fully writable by software

        //BAR3
        CONFIGURATION_SPACE[7][0] <= 1'b1; //io req
        CONFIGURATION_SPACE[7][1] <= 1'b0; //reserved
        //last writable bit is 8
        CONFIGURATION_SPACE[7][7 : 2] <= 7'b0; //hardcoded to 0

        //Rest BARS are not used hence 0s
        CONFIGURATION_SPACE[8] <= 32'b0;  
        CONFIGURATION_SPACE[9] <= 32'b0; 

        //add wrte masks
        WRITE_MASK[0] <= 32'hFFFF_0000;
        WRITE_MASK[4] <= 32'hFFFF_F000;
        WRITE_MASK[5] <= 32'b1111_1100_0000_0000_0000_0000_0000_0000;
        WRITE_MASK[6] <= 32'hFFFF_FFFF;
        WRITE_MASK[7] <= 32'hFFFF_FF01;

        for (integer i = 0; i < TOTAL_DW; i++) begin
            if(i != 0 && i != 4 && i != 5 && i != 6 && i != 7) begin
                WRITE_MASK[i] <= 32'hFFFF_FFFF;
            end
        end
    end
    else begin
        if (CONFIG_WRITE) begin
            for (integer i = 0; i < DATA_WIDTH; i++) begin
                if(WRITE_MASK[Register_Number][i]) begin
                    CONFIGURATION_SPACE[Register_Number][i] <= data_in[i];
                end
            end
            CONFIGURATION_SPACE[0][31 : 16] <= Device_ID_Decoder;
        end
        if (CONFIG_READ) begin
            data_out <= CONFIGURATION_SPACE[Register_Number];
        end
        if (DW_3_MEM_READ) begin
            if ((BAR0_LIMIT_Address <= Address_lower) && (Address_lower <= BAR0_LIMIT_Address_upper)) begin
                debug_read <= 1;
                case (state_curr)
                    SERVE: begin
                        if((DW_Counter <= Length) && Length != 11'd0) begin
                            DW_Counter <= DW_Counter + 11'd1;
                            data_out   <= MEM_SPACE[effective_BAR0_Address[7 : 0]];
                        end
                        else if (Length == 11'd0) begin
                            if(DW_Counter <= 11'd1024) begin
                                DW_Counter <= DW_Counter + 11'd1;
                                data_out   <= MEM_SPACE[effective_BAR0_Address[7 : 0]];
                            end
                            else if (DW_Counter > 11'd1024) begin
                                state_curr <= SERVE_DONE;
                            end
                        end
                        else if(DW_Counter > Length) begin
                            state_curr <= SERVE_DONE;
                        end
                    end
                    SERVE_DONE: begin
                        DW_Counter <= 11'd1;
                        state_curr <= SERVE; //issue completion when serve gets over so that it instantly disables DW_3_..
                    end 
                    default: state_curr <= SERVE;
                endcase
            end
        end
        else if (DW_4_MEM_READ) begin
            if ((BAR1_Address_64_Bits_BAR <= BAR1_Address_64_Bits) && (BAR1_Address_64_Bits <= BAR1_Address_64_Bits_BAR_LIMIT)) begin
                debug_read_4 <= 1;
                case (state_curr)
                    SERVE: begin
                        if((DW_Counter <= Length) && Length != 11'd0) begin
                            DW_Counter <= DW_Counter + 11'd1;
                            data_out   <= MEM_SPACE[effective_BAR1_Address[7 : 0]];
                        end
                        else if (Length == 11'd0) begin
                            if(DW_Counter <= 11'd1024) begin
                                DW_Counter <= DW_Counter + 11'd1;
                                data_out   <= MEM_SPACE[effective_BAR1_Address[7 : 0]];
                            end
                            else if (DW_Counter > 11'd1024) begin
                                state_curr <= SERVE_DONE;
                            end
                        end
                        else if(DW_Counter > Length) begin
                            state_curr <= SERVE_DONE;
                        end
                    end
                    SERVE_DONE: begin
                        DW_Counter <= 11'd1;
                        state_curr <= SERVE; //issue completion when serve gets over so that it instantly disables DW_3_..
                    end 
                    default: state_curr <= SERVE;
                endcase
            end
        end
        if (DW_3_MEM_WRITE) begin
            if ((BAR0_LIMIT_Address <= Address_lower) && (Address_lower <= BAR0_LIMIT_Address_upper)) begin
                debug_write <= 1;
                case (state_curr)
                    SERVE: begin
                        if((DW_Counter <= Length) && Length != 11'd0) begin
                            DW_Counter <= DW_Counter + 11'd1;
                            MEM_SPACE[effective_BAR0_Address[7 : 0]] <= data_in;
                        end
                        else if (Length == 11'd0) begin
                            if(DW_Counter <= 11'd1024) begin
                                DW_Counter <= DW_Counter + 11'd1;
                                MEM_SPACE[effective_BAR0_Address[7 : 0]] <= data_in;
                            end
                            else if (DW_Counter > 11'd1024) begin
                                state_curr <= SERVE_DONE;
                            end
                        end
                        else if(DW_Counter > Length) begin
                            state_curr <= SERVE_DONE;
                        end
                    end
                    SERVE_DONE: begin
                        DW_Counter <= 11'd1;
                        state_curr <= SERVE; //issue completion when serve gets over so that it instantly disables DW_3_..
                    end 
                    default: state_curr <= SERVE;
                endcase
            end
        end
        else if (DW_4_MEM_WRITE) begin
            if ((BAR1_Address_64_Bits_BAR <= BAR1_Address_64_Bits) && (BAR1_Address_64_Bits <= BAR1_Address_64_Bits_BAR_LIMIT)) begin
                debug_write_4 <= 1;
                case (state_curr)
                    SERVE: begin
                        if((DW_Counter <= Length) && Length != 11'd0) begin
                            DW_Counter <= DW_Counter + 11'd1;
                            MEM_SPACE[effective_BAR1_Address[7 : 0]] <= data_in;
                        end
                        else if (Length == 11'd0) begin
                            if(DW_Counter <= 11'd1024) begin
                                DW_Counter <= DW_Counter + 11'd1;
                                MEM_SPACE[effective_BAR1_Address[7 : 0]] <= data_in;
                            end
                            else if (DW_Counter > 11'd1024) begin
                                state_curr <= SERVE_DONE;
                            end
                        end
                        else if(DW_Counter > Length) begin
                            state_curr <= SERVE_DONE;
                        end
                    end
                    SERVE_DONE: begin
                        DW_Counter <= 11'd1;
                        state_curr <= SERVE; //issue completion when serve gets over so that it instantly disables DW_3_..
                    end 
                    default: state_curr <= SERVE;
                endcase
            end
        end
        if (IO_READ) begin
            if ((BAR3_LIMIT_Address <= Address_lower) && (Address_lower <= BAR3_LIMIT_Address_upper)) begin
                data_out   <= IO_SPACE[effective_BAR3_Address[7 : 0]];
                debug_read_io <= 1;
            end
        end
        if (IO_WRITE) begin
            if ((BAR3_LIMIT_Address <= Address_lower) && (Address_lower <= BAR3_LIMIT_Address_upper)) begin
                IO_SPACE[effective_BAR3_Address[7 : 0]] <= data_in;
                debug_write_io <= 1;
            end
        end
    end
end
endmodule
