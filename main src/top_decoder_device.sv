module top_decoder_device #(
    parameter DATA_WIDTH      = 32, //dw addressable
    parameter TOTAL_DW        = 4
) (
    input logic clk,
    input logic reset,
    input logic [DATA_WIDTH - 1 : 0] Header [0 : TOTAL_DW - 1],
    input logic [DATA_WIDTH - 1 : 0] data_in,
    output logic[DATA_WIDTH - 1 : 0] Completion_Header[0 : TOTAL_DW - 1],
    output logic[DATA_WIDTH - 1 : 0] data_out,
    output logic Compl_Read,
    output logic Compl_Write,
    output logic mem_write_done
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
logic [2 : 0] Completer_Function;
logic [4 : 0] Completer_Dev;
logic [2 : 0] Compl_status;//completion always completes for now
logic [11 : 0] Byte_count; //number of bytes remaining to complete a read request with multiple completions

logic [2 : 0] TC;
logic [2 : 0] Attr;
logic [9 : 0] Length; //to be used for MEM AND IO too
logic [3 : 0] F_DW_BYTE_EN;
logic [3 : 0] L_DW_BYTE_EN; //lower address generation
logic [15 : 0] Requester_ID;
logic [7 : 0] Tag;

logic[7 : 0] Completer_Bus;
assign Completer_Bus = 8'b0; //for single system

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
    .IO_WRITE(IO_WRITE),
    .TC(TC),
    .Attr(Attr),
    .Length(Length),
    .F_DW_BYTE_EN(F_DW_BYTE_EN),
    .L_DW_BYTE_EN(L_DW_BYTE_EN),
    .Requester_ID(Requester_ID),
    .Tag(Tag)
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
    .Compl_Read(Compl_Read),
    .Compl_Write(Compl_Write),
    .mem_write_done(mem_write_done),
    .Completer_Function(Completer_Function),
    .Completer_Dev(Completer_Dev),
    .Compl_status(Compl_status),
    .Byte_count(Byte_count),
    .Length(Length)
);

completion_gen completion_dut (
    .Compl_Read(Compl_Read),
    .Compl_Write(Compl_Write),
    .TC(TC),
    .Attr(Attr),
    .Length(Length),
    .Byte_count(Byte_count),
    .F_DW_BYTE_EN(F_DW_BYTE_EN),
    .L_DW_BYTE_EN(L_DW_BYTE_EN),
    .Requester_ID(Requester_ID),
    .Tag(Tag),
    .Completer_Bus(Completer_Bus),
    .Completer_Dev(Completer_Dev),
    .Completer_Function(Completer_Function),
    .Compl_status(Compl_status),
    .Address_lower(Address_lower),
    .Completion_Header(Completion_Header)
);
endmodule