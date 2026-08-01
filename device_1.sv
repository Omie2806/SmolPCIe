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
    input logic DW_3_MEM_READ,
    input logic DW_3_MEM_WRITE,
    input logic DW_4_MEM_READ,
    input logic DW_4_MEM_WRITE,
    input logic [31 : 0] Address_lower,
    input logic [31 : 0] Address_upper,
    input logic IO_READ,
    input logic IO_WRITE,
    input logic [DATA_WIDTH - 1 : 0]   data_in,
    output logic[DATA_WIDTH - 1 : 0]   data_out,

    output logic debug_read,
    output logic debug_write,
    output logic debug_read_4,
    output logic debug_write_4,
    output logic debug_read_io,
    output logic debug_write_io
);

reg[DATA_WIDTH - 1 : 0] CONFIGURATION_SPACE [0 : TOTAL_DW - 1];
reg[DATA_WIDTH - 1 : 0] MEM_SPACE [0 : 65536];
reg[DATA_WIDTH - 1 : 0] IO_SPACE  [0 : 65536];
reg[DATA_WIDTH - 1 : 0] WRITE_MASK [0 : TOTAL_DW - 1];

assign Function_Number = 1'b0;

//the device knows it's last writable BAR bits 
logic [31 : 0] BAR0_LIMIT;
logic [31 : 0] BAR1_LIMIT;
logic [31 : 0] BAR3_LIMIT;

assign BAR0_LIMIT = 32'd12;
assign BAR1_LIMIT = 32'd26;
assign BAR3_LIMIT = 32'd8;

//combine lower and upper address
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

always_ff @(posedge clk) begin
    if(reset) begin
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
                data_out   <= MEM_SPACE[Address_lower];
                debug_read <= 1;
            end
        end
        if (DW_3_MEM_WRITE) begin
            if ((BAR0_LIMIT_Address <= Address_lower) && (Address_lower <= BAR0_LIMIT_Address_upper)) begin
                MEM_SPACE[Address_lower] <= data_in;
                debug_write <= 1;
            end
        end
        if (DW_4_MEM_READ) begin
            if ((BAR1_Address_64_Bits_BAR <= BAR1_Address_64_Bits) && (BAR1_Address_64_Bits <= BAR1_Address_64_Bits_BAR_LIMIT)) begin
                data_out   <= MEM_SPACE[BAR1_Address_64_Bits];
                debug_read_4 <= 1;
            end
        end
        if (DW_4_MEM_WRITE) begin
            if ((BAR1_Address_64_Bits_BAR <= BAR1_Address_64_Bits) && (BAR1_Address_64_Bits <= BAR1_Address_64_Bits_BAR_LIMIT)) begin
                MEM_SPACE[BAR1_Address_64_Bits] <= data_in;
                debug_write_4 <= 1;
            end
        end
        if (IO_READ) begin
            if ((BAR3_LIMIT_Address <= Address_lower) && (Address_lower <= BAR3_LIMIT_Address_upper)) begin
                data_out   <= IO_SPACE[Address_lower];
                debug_read_io <= 1;
            end
        end
        if (IO_WRITE) begin
            if ((BAR3_LIMIT_Address <= Address_lower) && (Address_lower <= BAR3_LIMIT_Address_upper)) begin
                IO_SPACE[Address_lower] <= data_in;
                debug_write_io <= 1;
            end
        end
    end
end
endmodule
