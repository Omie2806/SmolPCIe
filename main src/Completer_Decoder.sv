module Completer_Decoder #(
    parameter DATA_WIDTH      = 32, //dw addressable
    parameter TOTAL_DW        = 4
) (
    input  logic [DATA_WIDTH - 1 : 0] Completion_Header [0 : TOTAL_DW - 1],
    output logic [15 : 0] Completer_ID,
    output logic [15 : 0] Requester_ID,
    output logic [2 : 0]  Compl_status,
    output logic BCM,
    output logic [11 : 0] Byte_count,
    output logic [6 : 0]  Lower_Address,
    output logic COMPL_W_DATA,
    output logic COMPL_WO_DATA,
    output logic [7 : 0] Tag
);

logic [2 : 0] FMT;
logic [4 : 0] TYPE;

assign FMT           = Completion_Header[0][31 : 29];
assign TYPE          = Completion_Header[0][28 : 24];

always_comb begin
    case (TYPE)
        5'b01010: begin  //Completion
            Completer_ID           = Completion_Header[1][31 : 16]; 
            Compl_status           = Completion_Header[1][15 : 13];
            BCM                    = Completion_Header[1][12];
            Byte_count             = Completion_Header[1][11 : 0];   
            Requester_ID           = Completion_Header[2][31 : 16];
            Tag                    = Completion_Header[2][15 : 8];
            Lower_Address          = Completion_Header[2][6 : 0]; 
            case (FMT)
                3'b000: COMPL_WO_DATA = 1;
                3'b010: COMPL_W_DATA  = 1; 
            endcase            
        end
        default: begin
            COMPL_W_DATA  = 0;
            COMPL_WO_DATA = 0;
            Completer_ID  = 16'b0;
            Requester_ID  = 16'b0;
            Compl_status  = 3'b0;
            BCM           = 1'b0;
            Byte_count    = 12'b0;
            Lower_Address = 7'b0;
            COMPL_W_DATA  = 1'b0;
            COMPL_WO_DATA = 1'b0;
        end
    endcase
    
end
endmodule