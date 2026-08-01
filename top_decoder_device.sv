module top_decoder_device #(
    parameter DATA_WIDTH      = 32, //dw addressable
    parameter TOTAL_DW        = 4
) (
    input logic clk,
    input logic reset,
    input logic [DATA_WIDTH - 1 : 0] Header [0 : TOTAL_DW - 1],
    input logic[DATA_WIDTH - 1 : 0] data_in,
    output logic[DATA_WIDTH - 1 : 0] data_out
);

logic CONFIG_READ;
logic CONFIG_WRITE;
logic [7 : 0] Bus_Number;
logic [4 : 0] Device_ID;
logic [2 : 0] Function_Number;
logic [7 : 0] Register_Number;
logic DW_3_MEM_READ;
logic DW_3_MEM_WRITE;
logic DW_4_MEM_READ;
logic DW_4_MEM_WRITE;
logic [31 : 0] Address_lower; //used for IO too
logic [31 : 0] Address_upper; //used for MEM only 
    //IO Requests
logic IO_READ;
logic IO_WRITE;
logic debug_read;

TLP_Decoder TLP_dut (
    .Header(Header),
    .CONFIG_READ(CONFIG_READ),
    .CONFIG_WRITE(CONFIG_WRITE),
    .Bus_Number(Bus_Number),
    .Device_ID(Device_ID),
    .Function_Number(Function_Number),
    .Register_Number(Register_Number),
    .DW_3_MEM_READ(DW_3_MEM_READ),
    .DW_3_MEM_WRITE(DW_3_MEM_WRITE),
    .DW_4_MEM_READ(DW_4_MEM_READ),
    .DW_4_MEM_WRITE(DW_4_MEM_WRITE),
    .Address_lower(Address_lower),
    .Address_upper(Address_upper),
    .IO_READ(IO_READ),
    .IO_WRITE(IO_WRITE)
);

device_1 device_dut (
    .clk(clk),
    .reset(reset),
    .CONFIG_READ(CONFIG_READ),
    .CONFIG_WRITE(CONFIG_WRITE),
    .Device_ID_Decoder(Device_ID),
    .Register_Number(Register_Number),
    .data_in(data_in),
    .data_out(data_out),
    .DW_3_MEM_READ(DW_3_MEM_READ),
    .DW_3_MEM_WRITE(DW_3_MEM_WRITE),
    .DW_4_MEM_READ(DW_4_MEM_READ),
    .DW_4_MEM_WRITE(DW_4_MEM_WRITE),
    .Address_lower(Address_lower),
    .Address_upper(Address_upper),
    .IO_READ(IO_READ),
    .IO_WRITE(IO_WRITE),
    .debug_read(debug_read)
);
endmodule
