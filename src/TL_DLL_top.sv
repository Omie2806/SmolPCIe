module TL_DLL_top #(
    parameter DATA_WIDTH = 32, //dw addressable
    parameter TOTAL_DW   = 4,
    parameter HEADER_DW  = 4,  //max header size
    parameter SEQ_DW     = 1,  // 1 dw sequence number
    parameter PAYLOAD_DW = 2,  // max payload size for simplicity 
    parameter LCRC_DW    = 1  // 32 bit LCRC
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

    input logic new_TLP_IN,
    input logic LCRC_Fault,
    input logic Higher_Seq_Fault,
    input logic Duplicate_Ack
);

    logic [DATA_WIDTH - 1 : 0] TLP_IN [0 : 5];
    logic [DATA_WIDTH - 1 : 0] TLP_OUT [0 : 5];
    logic new_TLP_RX;

    top_Decoder_Encoder top_Decoder_Encoder_dut (
        .clk(clk),
        .reset(reset),
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
        .data_in(data_in),
        .data_out(data_out),
        .Requester_ID_Compl(Requester_ID_Compl),
        .TLP_IN(TLP_IN),
        .TLP_OUT(TLP_OUT)
    );

    TX_RX_DLL_top TX_RX_DLL_top_dut (
        .clk(clk),
        .reset(reset),
        .LCRC_Fault(LCRC_Fault),
        .Higher_Seq_Fault(Higher_Seq_Fault),
        .Duplicate_Ack(Duplicate_Ack),
        .new_TLP_IN(new_TLP_IN),
        .TLP_FROM_TL(TLP_IN),
        .TLP_EXTRACT_OUT(TLP_OUT)
    );
    
endmodule