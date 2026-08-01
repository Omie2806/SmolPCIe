//type 0 config header
module device_1 #(
    parameter DATA_WIDTH = 32, //byte addressable
    parameter TOTAL_DW   = 16 //in bytes
) (
    //receive the register number for configuration access
    input logic clk,
    input logic reset,
    input logic CONFIG_READ,
    input logic CONFIG_WRITE,
    input logic [4 : 0] Device_ID_Decoder,
    input logic [7 : 0] Register_Number,
    input logic [DATA_WIDTH - 1 : 0]   data_in,
    output logic Function_Number,
    output logic[DATA_WIDTH - 1 : 0]   data_out
);

reg[DATA_WIDTH - 1 : 0] CONFIGURATION_SPACE [0 : TOTAL_DW - 1];
reg[DATA_WIDTH - 1 : 0] WRITE_MASK [0 : TOTAL_DW - 1];

assign Function_Number = 1'b0;

always_ff @(posedge clk) begin
    if(reset) begin
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
    end
end
endmodule