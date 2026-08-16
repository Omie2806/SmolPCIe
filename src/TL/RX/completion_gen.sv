module completion_gen #(
    parameter DATA_WIDTH      = 32, //dw addressable
    parameter TOTAL_DW        = 4
) (
    input logic Compl_Read,
    input logic Compl_Write,
    input logic [2 : 0] TC,
    input logic [2 : 0] Attr,
    input logic [9 : 0] Length, //depends on byte en of requester (byte_count) +1 for every byte en 0
    input logic [11 : 0] Byte_count,
    input logic [3 : 0] F_DW_BYTE_EN,
    input logic [3 : 0] L_DW_BYTE_EN, //for lower address calc
    input logic [15 : 0] Requester_ID,
    input logic [7 : 0] Tag,
    input logic [7 : 0] Completer_Bus, //will come from switch/root hence ignore for now
    input logic [4 : 0] Completer_Dev,
    input logic [2 : 0] Completer_Function,
    input logic [2 : 0] Compl_status,
    input logic [31 : 0] Address_lower,
    output logic[DATA_WIDTH - 1 : 0] Completion_Header [0 : TOTAL_DW - 1]
);

logic [2 : 0] FMT;
logic [4 : 0] TYPE;
logic TH;
logic TD;
logic EP;
logic [1 : 0] Address_type;
logic [15 : 0] Completer_ID;
logic BCM;
logic [6 : 0] Lower_Address;

assign TH           = 1'b0; //reserved
assign TD           = 1'b1; //digest field at the end of TLP (should come for the device but lets see)
assign BCM          = 1'b0; //only used for PCI-X hence disabled for now
assign Address_type = 2'b00; //always be 0
assign EP           = 1'b0; //no poisoning for now

assign FMT          = Compl_Read ? 3'b010 : (Compl_Write ? 3'b000 : 3'b010);
assign TYPE         = 5'b01010;
assign Completer_ID = {Completer_Bus, Completer_Dev, Completer_Function};
assign Lower_Address = Address_lower[6 : 0];
//might require byte ens later

assign Completion_Header[0][31 : 29] = FMT;
assign Completion_Header[0][28 : 24] = TYPE;
assign Completion_Header[0][23]      = 1'b0;
assign Completion_Header[0][22 : 20] = TC;
assign Completion_Header[0][19]      = 1'b0;
assign Completion_Header[0][18]      = Attr[2];
assign Completion_Header[0][17]      = 1'b0;
assign Completion_Header[0][16]      = TH;
assign Completion_Header[0][15]      = TD;
assign Completion_Header[0][14]      = EP;
assign Completion_Header[0][13 : 12] = Attr[1 : 0];
assign Completion_Header[0][11 : 10] = Address_type;
assign Completion_Header[0][9 : 0]   = Length;
assign Completion_Header[1][31 : 16] = Completer_ID; 
assign Completion_Header[1][15 : 13] = Compl_status;
assign Completion_Header[1][12]      = BCM;
assign Completion_Header[1][11 : 0]  = Byte_count;
assign Completion_Header[2][31 : 16] = Requester_ID;
assign Completion_Header[2][15 : 8]  = Tag;
assign Completion_Header[2][7]       = 1'b0; //reserved
//lower addresses will always be data aligned and byte enable will always be 0000 or 1111 as memory is DW bits
assign Completion_Header[2][6 : 0]   = Lower_Address;
assign Completion_Header[3]          = 32'b0;
    
endmodule