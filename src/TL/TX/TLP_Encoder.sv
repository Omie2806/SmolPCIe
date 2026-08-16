module TLP_Header_encoder #(
    parameter DATA_WIDTH      = 32, //dw addressable
    parameter TOTAL_DW        = 4
) (
    //will be received by the device core 
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
    output logic [DATA_WIDTH - 1 : 0] Header [0 : TOTAL_DW - 1]
);
//tag will be generated internally 
logic [7 : 0] Tag;
assign Tag = 8'b0; //because i use single request and that too only after completion 

assign Header[0][31 : 29] = FMT;
assign Header[0][28 : 24] = TYPE;
assign Header[0][23]      = 1'b0;
assign Header[0][22 : 20] = TC;
assign Header[0][19]      = 1'h0;
assign Header[0][18]      = Attr[2];
assign Header[0][17]      = 1'h0;
assign Header[0][16]      = TH;
assign Header[0][15]      = TD;
assign Header[0][14]      = EP;
assign Header[0][13 : 12] = Attr[1 : 0];
assign Header[0][11 : 10] = Address_type;
assign Header[0][9 : 0]   = Length; 
assign Header[1][7 : 4]   = L_DW_BYTE_EN;
assign Header[1][3 : 0]   = F_DW_BYTE_EN;

always_comb begin
    case (TYPE)
        5'b00010: begin //IO request
            Header[1][31 : 16]     = Requester_ID;
            Header[1][15 : 8]      = Tag; 
            Header[2]              = Address_lower;
            Header[3]              = 32'b0;
        end 
        5'b00000: begin //MEM Req (not Locked)
            Header[1][31 : 16]     = Requester_ID;
            Header[1][15 : 8]      = Tag; 
            case (FMT)
                3'b000: begin
                    Header[2]      = Address_lower;
                    Header[3]      = 32'b0;
                end
                3'b010: begin
                    Header[2]      = Address_lower;
                    Header[3]      = 32'b0;
                end
                3'b001: begin
                    Header[3]      = Address_lower;
                    Header[2]      = Address_upper;
                    end
                3'b011: begin 
                    Header[3]      = Address_lower;
                    Header[2]      = Address_upper;
                    end
            endcase            
        end
        5'b00100: begin //Config Type 0
            Header[1][31 : 16]     = Requester_ID;
            Header[1][15 : 8]      = Tag; 
            Header[2][31 : 24]     = Bus_Number;
            Header[2][23 : 19]     = Device_ID;
            Header[2][18 : 16]     = Function_Number;
            Header[2][15 : 12]     = 4'b0000;
            Header[2][11 : 8]      = Ex_Register_No;
            Header[2][7 : 2]       = Register_Number; 
            Header[2][1 : 0]       = 2'b00; 
            Header[3]              = 32'b0;       
        end
        5'b00101: begin //Config type 1 same as config type 0
            Header[1][31 : 16]     = Requester_ID;
            Header[1][15 : 8]      = Tag; 
            Header[2][31 : 24]     = Bus_Number;
            Header[2][23 : 19]     = Device_ID;
            Header[2][18 : 16]     = Function_Number;
            Header[2][15 : 12]     = 4'b0000;
            Header[2][11 : 8]      = Ex_Register_No;
            Header[2][7 : 2]       = Register_Number;     
            Header[2][1 : 0]       = 2'b00;  
            Header[3]              = 32'b0;          
        end
        5'b10000: begin // messages - implementing 1 type among many 
        //will fix this later
            Header[1][31 : 16]     = Requester_ID;
            Header[1][15 : 8]      = Tag; 
            Header[1][7 : 0]       = Message_Code;
            Header[3]              = Address_lower;
            Header[2]              = Address_upper;     
            Header[2][1 : 0]       = 2'b00;                      
        end
        default: begin
            Header[0] = 32'b0;
            Header[1] = 32'b0;
            Header[2] = 32'b0;
            Header[3] = 32'b0;
        end
    endcase
end
endmodule
