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

TLP_Decoder TLP_dut (
    .Header(Header),
    .CONFIG_READ(CONFIG_READ),
    .CONFIG_WRITE(CONFIG_WRITE),
    .Bus_Number(Bus_Number),
    .Device_ID(Device_ID),
    .Function_Number(Function_Number),
    .Register_Number(Register_Number)
);

device_1 device_dut (
    .clk(clk),
    .reset(reset),
    .CONFIG_READ(CONFIG_READ),
    .CONFIG_WRITE(CONFIG_WRITE),
    .Device_ID_Decoder(Device_ID),
    .Register_Number(Register_Number),
    .Function_Number(Function_Number),
    .data_in(data_in),
    .data_out(data_out)
);
endmodule