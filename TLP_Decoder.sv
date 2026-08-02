module TLP_Decoder #(
    parameter DATA_WIDTH      = 32, //dw addressable
    parameter TOTAL_DW        = 4
) (
    input logic [DATA_WIDTH - 1 : 0] Header [0 : TOTAL_DW - 1], //receiving the header
    //Config Requests 
    output logic CONFIG_READ,
    output logic CONFIG_WRITE,
    output logic [7 : 0] Bus_Number,
    output logic [4 : 0] Device_ID,
    output logic [2 : 0] Function_Number,
    output logic [7 : 0] Register_Number,
    //MEM Requets
    output logic DW_3_MEM_READ,
    output logic DW_3_MEM_WRITE,
    output logic DW_4_MEM_READ,
    output logic DW_4_MEM_WRITE,
    output logic [31 : 0] Address_lower, //used for IO too
    output logic [31 : 0] Address_upper, //used for MEM only 
    //IO Requests
    output logic IO_READ,
    output logic IO_WRITE,
    //for completions
    output logic [2 : 0] TC,
    output logic [2 : 0] Attr,
    output logic [9 : 0] Length, //to be used for MEM AND IO too
    output logic [3 : 0] F_DW_BYTE_EN,
    output logic [3 : 0] L_DW_BYTE_EN, //lower address generation
    output logic [15 : 0] Requester_ID,
    output logic [7 : 0] Tag
);

logic [2 : 0] FMT;
logic [4 : 0] TYPE;
logic TH;
logic TD;
logic EP;
logic [1 : 0] Address_type;

//for config requests
logic [15 : 0] Completer_ID;
logic [3 : 0]  Ex_Register_No;

//completion
logic [2 : 0] Compl_status;
logic BCM;
logic [11 : 0] Byte_count;
logic [6 : 0] Lower_Address;
logic COMPL_W_DATA;
logic COMPL_WO_DATA;

//message
logic [7 : 0] Message_Code;
logic MESSAGE_W_DATA;
logic MESSAGE_WO_DATA;

assign FMT           = Header[0][31 : 29];
assign TYPE          = Header[0][28 : 24];
assign TC            = Header[0][22 : 20];
assign Attr[2]       = Header[0][18];
assign TH            = Header[0][16];
assign TD            = Header[0][15];
assign EP            = Header[0][14];
assign Attr[1 : 0]   = Header[0][13 : 12];
assign Address_type  = Header[0][11 : 10];
assign Length        = Header[0][9 : 0]; 
assign L_DW_BYTE_EN  = Header[1][7 : 4];
assign F_DW_BYTE_EN  = Header[1][3 : 0];

always_comb begin
    Requester_ID = 0;
    Tag = 0;
    Address_lower = 0;
    Address_upper = 0;
    Completer_ID = 0;
    Ex_Register_No = 0;
    Register_Number = 0;
    Bus_Number = 0;
    Device_ID = 0;
    Function_Number = 0;
    Compl_status = 0;
    BCM = 0;
    Byte_count = 0;
    Lower_Address = 0;
    Message_Code  = 0;
    IO_READ = 0;
    IO_WRITE = 0;
    DW_3_MEM_READ = 0;
    DW_3_MEM_WRITE = 0;
    DW_4_MEM_READ = 0;
    DW_4_MEM_WRITE = 0;
    CONFIG_READ = 0;
    CONFIG_WRITE = 0;
    COMPL_W_DATA = 0;
    COMPL_WO_DATA = 0;
    MESSAGE_W_DATA = 0;
    MESSAGE_WO_DATA = 0;

    case (TYPE)
        5'b00010: begin //IO request
            Requester_ID           = Header[1][31 : 16];
            Tag                    = Header[1][15 : 8]; 
            // Address_lower[1 : 0]   = 2'b0;
            Address_lower[31 : 0]  = Header[2][31 : 0];
            case (FMT)
                3'b000: IO_READ = 1'b1;
                3'b010: IO_WRITE = 1'b1; 
            endcase
        end 
        5'b00000: begin //MEM Req (not Locked)
            Requester_ID           = Header[1][31 : 16];
            Tag                    = Header[1][15 : 8]; 
            case (FMT)
                3'b000: begin
                    DW_3_MEM_READ = 1; 
                    // Address_lower[1 : 0]   = 2'b0;
                    Address_lower[31 : 0]  = Header[2][31 : 0];
                end
                3'b010: begin
                    DW_3_MEM_WRITE = 1; 
                    // Address_lower[1 : 0]   = 2'b0;
                    Address_lower[31 : 0]  = Header[2][31 : 0];
                end
                3'b001: begin
                    DW_4_MEM_READ = 1;
                    // Address_lower[1 : 0]   = 2'b0;
                    Address_lower[31 : 0]  = Header[3][31 : 0];
                    Address_upper = Header[2];
                    end
                3'b011: begin 
                    DW_4_MEM_WRITE = 1; 
                    // Address_lower[1 : 0]   = 2'b0;
                    Address_lower[31 : 0]  = Header[3][31 : 0];
                    Address_upper = Header[2];
                    end
            endcase            
        end
        5'b00100: begin //Config Type 0
            Requester_ID           = Header[1][31 : 16];
            Tag                    = Header[1][15 : 8]; 
            Bus_Number             = Header[2][31 : 24];
            Device_ID              = Header[2][23 : 19];
            Function_Number        = Header[2][18 : 16];
            Ex_Register_No         = Header[2][11 : 8];
            Register_Number        = Header[2][7 : 2];
            case (FMT)
                3'b000: CONFIG_READ = 1;
                3'b010: CONFIG_WRITE = 1; 
            endcase          
        end
        5'b00101: begin //Config type 1 same as config type 0
            Requester_ID           = Header[1][31 : 16];
            Tag                    = Header[1][15 : 8]; 
            Bus_Number             = Header[2][31 : 24];
            Device_ID              = Header[2][23 : 19];
            Function_Number        = Header[2][18 : 16];
            Ex_Register_No         = Header[2][11 : 8];
            Register_Number        = Header[2][7 : 2];
            case (FMT)
                3'b000: CONFIG_READ = 1;
                3'b010: CONFIG_WRITE = 1; 
            endcase              
        end
        5'b01010: begin  //Completion
            Completer_ID           = Header[1][31 : 16]; 
            Compl_status           = Header[1][15 : 13];
            BCM                    = Header[1][12];
            Byte_count             = Header[1][11 : 0];   
            Requester_ID           = Header[2][31 : 16];
            Tag                    = Header[2][15 : 8];
            Lower_Address          = Header[2][6 : 0]; 
            case (FMT)
                3'b000: COMPL_WO_DATA = 1;
                3'b010: COMPL_W_DATA = 1; 
            endcase            
        end
        5'b10000: begin // messages - implementing 1 type among many 
        //will fix this later
            Requester_ID           = Header[1][31 : 16];
            Tag                    = Header[1][15 : 8]; 
            Message_Code           = Header[1][7 : 0];
            // Address_lower[1 : 0]   = 2'b0;
            Address_lower[31 : 0]  = Header[3][31 : 0];
            Address_upper          = Header[2];
            case (FMT)
                3'b001: MESSAGE_WO_DATA = 1;
                3'b011: MESSAGE_W_DATA  = 1; 
            endcase                        
        end
    endcase
end
endmodule
