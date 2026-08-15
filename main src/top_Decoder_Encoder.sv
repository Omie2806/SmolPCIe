module top_Decoder_Encoder #(
    parameter DATA_WIDTH      = 32, //dw addressable
    parameter TOTAL_DW        = 4
) (
    input logic clk,
    input logic reset,
    input logic TH,
    input logic TD,
    input logic EP,
    input logic [15 : 0] Requester_ID,
    input logic [7 : 0] Message_Code,
    input logic [2 : 0] FMT,
    input logic [4 : 0] TYPE,
    input logic [7 : 0] Bus_Number,
    input logic [4 : 0] Device_ID,
    input logic [2 : 0] Function_Number,
    input logic [7 : 0] Register_Number,
    input logic [3 : 0] Ex_Register_No,
    input logic [1 : 0] Address_type,
    input logic [31 : 0] Address_lower,
    input logic [31 : 0] Address_upper,
    input logic [9 : 0] Length,
    input logic [2 : 0] TC,
    input logic [2 : 0] Attr,
    input logic [3 : 0] F_DW_BYTE_EN,
    input logic [3 : 0] L_DW_BYTE_EN,
    input logic [DATA_WIDTH - 1 : 0] data_in [0 : 1],
    output logic [DATA_WIDTH - 1 : 0] data_out [0 : 1],
    output logic [15 : 0] Requester_ID_Compl,
    output logic [DATA_WIDTH - 1 : 0] TLP_IN [0 : 5],
    output logic [DATA_WIDTH - 1 : 0] TLP_OUT [0 : 5]
);

logic [DATA_WIDTH - 1 : 0] Completion_Header [0 : TOTAL_DW - 1];
logic [DATA_WIDTH - 1 : 0] Completion_Header_decoder [0 : TOTAL_DW - 1];
logic [DATA_WIDTH - 1 : 0] Header [0 : TOTAL_DW - 1];
logic [DATA_WIDTH - 1 : 0] data_in_device [0 : 1];

logic Compl_Read;
logic Compl_Write;
logic mem_write_done;

logic [15 : 0] Completer_ID;
logic [2 : 0]  Compl_status;
logic BCM;
logic [11 : 0] Byte_count;
logic [6 : 0]  Lower_Address;
logic COMPL_W_DATA;
logic COMPL_WO_DATA;
logic [7 : 0] Tag;

    TLP_Header_encoder main_dut (
        .TH(TH),
        .TD(TD),
        .EP(EP),
        .Requester_ID(Requester_ID),
        .Message_Code(Message_Code),
        .FMT(FMT),
        .TYPE(TYPE),
        .Bus_Number(Bus_Number),
        .Device_ID(Device_ID),
        .Function_Number(Function_Number),
        .Register_Number(Register_Number),
        .Ex_Register_No(Ex_Register_No),
        .Address_type(Address_type),
        .Address_lower(Address_lower),
        .Address_upper(Address_upper),
        .Length(Length),
        .TC(TC),
        .Attr(Attr),
        .F_DW_BYTE_EN(F_DW_BYTE_EN),
        .L_DW_BYTE_EN(L_DW_BYTE_EN),
        .Header(Header)
    );

    always_comb begin
        TLP_IN[0] = Header[0];
        TLP_IN[1] = Header[1];
        TLP_IN[2] = Header[2];
        TLP_IN[3] = Header[3];
        TLP_IN[4] = data_in[0];
        TLP_IN[5] = data_in[1];

        data_in_device[0] = TLP_IN[4];
        data_in_device[1] = TLP_IN[5];

        TLP_OUT[0] = Completion_Header[0];
        TLP_OUT[1] = Completion_Header[1];
        TLP_OUT[2] = Completion_Header[2];
        TLP_OUT[3] = Completion_Header[3];
        TLP_OUT[4] = data_out[0];
        TLP_OUT[5] = data_out[1];

        Completion_Header_decoder[0] = TLP_OUT[0];
        Completion_Header_decoder[1] = TLP_OUT[1];
        Completion_Header_decoder[2] = TLP_OUT[2];
        Completion_Header_decoder[3] = TLP_OUT[3];
    end

    top_decoder_device decoder_device_dut (
        .clk(clk),
        .reset(reset),
        .Header(Header),
        .data_in(data_in_device),
        .Completion_Header(Completion_Header),
        .data_out(data_out),
        .Compl_Read(Compl_Read),
        .Compl_Write(Compl_Write),
        .mem_write_done(mem_write_done)
    );

    Completer_Decoder completion_decoder_dut (
        .Completion_Header(Completion_Header_decoder),
        .Completer_ID(Completer_ID),
        .Requester_ID(Requester_ID_Compl),
        .Compl_status(Compl_status),
        .BCM(BCM),
        .Byte_count(Byte_count),
        .Lower_Address(Lower_Address),
        .COMPL_W_DATA(COMPL_W_DATA),
        .COMPL_WO_DATA(COMPL_WO_DATA),
        .Tag(Tag)
    );
endmodule
