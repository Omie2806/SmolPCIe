module tb_Header_Encoder;

parameter DATA_WIDTH      = 32; //dw addressable
parameter TOTAL_DW        = 4;

    logic clk;
    logic reset;
    logic TH;
    logic TD;
    logic EP;
    logic [DATA_WIDTH - 1 : 0] data_in;
    logic [15 : 0] Requester_ID;
    logic [7 : 0] Message_Code;
    logic [2 : 0] FMT;
    logic [4 : 0] TYPE;
    logic [7 : 0] Bus_Number;
    logic [4 : 0] Device_ID;
    logic [2 : 0] Function_Number;
    logic [7 : 0] Register_Number;
    logic [3 : 0] Ex_Register_No;
    logic [1 : 0] Address_type;
    logic [31 : 0] Address_lower;
    logic [31 : 0] Address_upper;
    logic [9 : 0] Length;
    logic [2 : 0] TC;
    logic [2 : 0] Attr;
    logic [3 : 0] F_DW_BYTE_EN;
    logic [3 : 0] L_DW_BYTE_EN;
    logic [DATA_WIDTH - 1 : 0] data_out;
    logic [15 : 0] Requester_ID_Compl;

    top_Decoder_Encoder D_E_dut (.*);

initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

initial begin

    reset = 1;
    repeat(2)@(posedge clk);
    reset = 0;
    repeat(2)@(posedge clk);
    //config read BAR0
    FMT  = 3'b000;
    TYPE = 5'b00100;
    TC   = 3'b000;
    Attr = 3'b000;
    TH   = 1'b0;
    TD   = 1'b1;
    EP   = 1'b0;
    Address_type = 2'b00;
    Length = 10'b1;
    Requester_ID = 16'h1;
    L_DW_BYTE_EN = 4'h0;
    F_DW_BYTE_EN = 4'hF; 
    Bus_Number   = 8'h0;
    Device_ID    = 5'h0;
    Function_Number = 3'h0;
    Ex_Register_No  = 4'h0;
    Register_Number = 8'h04;
    Address_lower   = 32'h0;
    Address_upper   = 32'h0;
    data_in         = 32'h0;
    Message_Code    = 8'h0;
    repeat(2)@(posedge clk);

    //config write BAR0
    FMT  = 3'b010;
    TYPE = 5'b00100;
    TC   = 3'b000;
    Attr = 3'b000;
    TH   = 1'b0;
    TD   = 1'b1;
    EP   = 1'b0;
    Address_type = 2'b00;
    Length = 10'b1;
    Requester_ID = 16'h1;
    L_DW_BYTE_EN = 4'h0;
    F_DW_BYTE_EN = 4'hF; 
    Bus_Number   = 8'h0;
    Device_ID    = 5'h0;
    Function_Number = 3'h0;
    Ex_Register_No  = 4'h0;
    Register_Number = 8'h04;
    Address_lower   = 32'h0;
    Address_upper   = 32'h0;
    data_in         = 32'hFFFF_FFFF;
    Message_Code    = 8'h0;
    repeat(2)@(posedge clk);  

    //config read BAR0
    FMT  = 3'b000;
    TYPE = 5'b00100;
    TC   = 3'b000;
    Attr = 3'b000;
    TH   = 1'b0;
    TD   = 1'b1;
    EP   = 1'b0;
    Address_type = 2'b00;
    Length = 10'b1;
    Requester_ID = 16'h1;
    L_DW_BYTE_EN = 4'h0;
    F_DW_BYTE_EN = 4'hF; 
    Bus_Number   = 8'h0;
    Device_ID    = 5'h0;
    Function_Number = 3'h0;
    Ex_Register_No  = 4'h0;
    Register_Number = 8'h04;
    Address_lower   = 32'h0;
    Address_upper   = 32'h0;
    data_in         = 32'h0000_0001;
    Message_Code    = 8'h0;
    repeat(2)@(posedge clk); 

    //config write BAR0
    FMT  = 3'b010;
    TYPE = 5'b00100;
    TC   = 3'b000;
    Attr = 3'b000;
    TH   = 1'b0;
    TD   = 1'b1;
    EP   = 1'b0;
    Address_type = 2'b00;
    Length       = 10'b1;
    Requester_ID = 16'h1;
    L_DW_BYTE_EN = 4'h0;
    F_DW_BYTE_EN = 4'hF; 
    Bus_Number   = 8'h0;
    Device_ID    = 5'h0;
    Function_Number = 3'h0;
    Ex_Register_No  = 4'h0;
    Register_Number = 8'h04;
    Address_lower   = 32'h0;
    Address_upper   = 32'h0;
    data_in         = 32'h0000_0001;
    Message_Code    = 8'h0;
    repeat(2)@(posedge clk); 

    //config read bar1
    FMT  = 3'b000;
    TYPE = 5'b00100;
    TC   = 3'b000;
    Attr = 3'b000;
    TH   = 1'b0;
    TD   = 1'b1;
    EP   = 1'b0;
    Address_type = 2'b00;
    Length       = 10'b1;
    Requester_ID = 16'h1;
    L_DW_BYTE_EN = 4'h0;
    F_DW_BYTE_EN = 4'hF; 
    Bus_Number   = 8'h0;
    Device_ID    = 5'h0;
    Function_Number = 3'h0;
    Ex_Register_No  = 4'h0;
    Register_Number = 8'h04;
    Address_lower   = 32'h0;
    Address_upper   = 32'h0;
    // data_in         = 32'hFFFF_FFFF;
    Message_Code    = 8'h0;

    repeat(2)@(posedge clk);

    //config write BAR1
    FMT  = 3'b010;
    TYPE = 5'b00100;
    TC   = 3'b000;
    Attr = 3'b000;
    TH   = 1'b0;
    TD   = 1'b1;
    EP   = 1'b0;
    Address_type = 2'b00;
    Length = 10'b1;
    Requester_ID = 16'h1;
    L_DW_BYTE_EN = 4'h0;
    F_DW_BYTE_EN = 4'hF; 
    Bus_Number   = 8'h0;
    Device_ID    = 5'h0;
    Function_Number = 3'h0;
    Ex_Register_No  = 4'h0;
    Register_Number = 8'h05;
    Address_lower   = 32'h0;
    Address_upper   = 32'h0;
    data_in         = 32'hFFFF_FFFF;
    Message_Code    = 8'h0;

    repeat(2)@(posedge clk); 

    //config read BAR2
    FMT  = 3'b000;
    TYPE = 5'b00100;
    TC   = 3'b000;
    Attr = 3'b000;
    TH   = 1'b0;
    TD   = 1'b1;
    EP   = 1'b0;
    Address_type = 2'b00;
    Length = 10'b1;
    Requester_ID = 16'h1;
    L_DW_BYTE_EN = 4'h0;
    F_DW_BYTE_EN = 4'hF; 
    Bus_Number   = 8'h0;
    Device_ID    = 5'h0;
    Function_Number = 3'h0;
    Ex_Register_No  = 4'h0;
    Register_Number = 8'h06;
    Address_lower   = 32'h0;
    Address_upper   = 32'h0;
    // data_in         = 32'hFFFF_FFFF;
    Message_Code    = 8'h0;

    repeat(2)@(posedge clk); 

    //config write BAR2
    FMT  = 3'b010;
    TYPE = 5'b00100;
    TC   = 3'b000;
    Attr = 3'b000;
    TH   = 1'b0;
    TD   = 1'b1;
    EP   = 1'b0;
    Address_type = 2'b00;
    Length = 10'b1;
    Requester_ID = 16'h1;
    L_DW_BYTE_EN = 4'h0;
    F_DW_BYTE_EN = 4'hF; 
    Bus_Number   = 8'h0;
    Device_ID    = 5'h0;
    Function_Number = 3'h0;
    Ex_Register_No  = 4'h0;
    Register_Number = 8'h06;
    Address_lower   = 32'h0;
    Address_upper   = 32'h0;
    data_in         = 32'hFFFF_FFFF;
    Message_Code    = 8'h0;

    repeat(2)@(posedge clk); 

    //config read BAR2
    FMT  = 3'b000;
    TYPE = 5'b00100;
    TC   = 3'b000;
    Attr = 3'b000;
    TH   = 1'b0;
    TD   = 1'b1;
    EP   = 1'b0;
    Address_type = 2'b00;
    Length = 10'b1;
    Requester_ID = 16'h1;
    L_DW_BYTE_EN = 4'h0;
    F_DW_BYTE_EN = 4'hF; 
    Bus_Number   = 8'h0;
    Device_ID    = 5'h0;
    Function_Number = 3'h0;
    Ex_Register_No  = 4'h0;
    Register_Number = 8'h06;
    Address_lower   = 32'h0;
    Address_upper   = 32'h0;
    // data_in         = 32'hFFFF_FFFF;
    Message_Code    = 8'h0;

    repeat(2)@(posedge clk); 

    //config write BAR1
    FMT  = 3'b010;
    TYPE = 5'b00100;
    TC   = 3'b000;
    Attr = 3'b000;
    TH   = 1'b0;
    TD   = 1'b1;
    EP   = 1'b0;
    Address_type = 2'b00;
    Length = 10'b1;
    Requester_ID = 16'h1;
    L_DW_BYTE_EN = 4'h0;
    F_DW_BYTE_EN = 4'hF; 
    Bus_Number   = 8'h0;
    Device_ID    = 5'h0;
    Function_Number = 3'h0;
    Ex_Register_No  = 4'h0;
    Register_Number = 8'h05;
    Address_lower   = 32'h0;
    Address_upper   = 32'h0;
    Message_Code    = 8'h0;
    data_in         = 32'h4000_0000;

    repeat(2)@(posedge clk); 

    //config write BAR2
    FMT  = 3'b010;
    TYPE = 5'b00100;
    TC   = 3'b000;
    Attr = 3'b000;
    TH   = 1'b0;
    TD   = 1'b1;
    EP   = 1'b0;
    Address_type = 2'b00;
    Length = 10'b1;
    Requester_ID = 16'h1;
    L_DW_BYTE_EN = 4'h0;
    F_DW_BYTE_EN = 4'hF; 
    Bus_Number   = 8'h0;
    Device_ID    = 5'h0;
    Function_Number = 3'h0;
    Ex_Register_No  = 4'h0;
    Register_Number = 8'h06;
    Address_lower   = 32'h0;
    Address_upper   = 32'h0;
    Message_Code    = 8'h0;
    @(posedge clk);
    data_in         = 32'h0000_0002;

    repeat(2)@(posedge clk); 

    //config read BAR3
    FMT  = 3'b010;
    TYPE = 5'b00100;
    TC   = 3'b000;
    Attr = 3'b000;
    TH   = 1'b0;
    TD   = 1'b1;
    EP   = 1'b0;
    Address_type = 2'b00;
    Length = 10'b1;
    Requester_ID = 16'h1;
    L_DW_BYTE_EN = 4'h0;
    F_DW_BYTE_EN = 4'hF; 
    Bus_Number   = 8'h0;
    Device_ID    = 5'h0;
    Function_Number = 3'h0;
    Ex_Register_No  = 4'h0;
    Register_Number = 8'h07;
    Address_lower   = 32'h0;
    Address_upper   = 32'h0;
    // data_in         = 32'hFFFF_FFFF;
    Message_Code    = 8'h0;

    repeat(2)@(posedge clk); 

    //config write BAR3
    FMT  = 3'b010;
    TYPE = 5'b00100;
    TC   = 3'b000;
    Attr = 3'b000;
    TH   = 1'b0;
    TD   = 1'b1;
    EP   = 1'b0;
    Address_type = 2'b00;
    Length = 10'b1;
    Requester_ID = 16'h1;
    L_DW_BYTE_EN = 4'h0;
    F_DW_BYTE_EN = 4'hF; 
    Bus_Number   = 8'h0;
    Device_ID    = 5'h0;
    Function_Number = 3'h0;
    Ex_Register_No  = 4'h0;
    Register_Number = 8'h07;
    Address_lower   = 32'h0;
    Address_upper   = 32'h0;
    Message_Code    = 8'h0;
    data_in         = 32'hFFFF_FFFF;

    repeat(2)@(posedge clk); 

    //config read BAR3
    FMT  = 3'b010;
    TYPE = 5'b00100;
    TC   = 3'b000;
    Attr = 3'b000;
    TH   = 1'b0;
    TD   = 1'b1;
    EP   = 1'b0;
    Address_type = 2'b00;
    Length = 10'b1;
    Requester_ID = 16'h1;
    L_DW_BYTE_EN = 4'h0;
    F_DW_BYTE_EN = 4'hF; 
    Bus_Number   = 8'h0;
    Device_ID    = 5'h0;
    Function_Number = 3'h0;
    Ex_Register_No  = 4'h0;
    Register_Number = 8'h07;
    Address_lower   = 32'h0;
    Address_upper   = 32'h0;
    // data_in         = 32'hFFFF_FFFF;
    Message_Code    = 8'h0;

    repeat(2)@(posedge clk); 

    //config write BAR3
    FMT  = 3'b010;
    TYPE = 5'b00100;
    TC   = 3'b000;
    Attr = 3'b000;
    TH   = 1'b0;
    TD   = 1'b1;
    EP   = 1'b0;
    Address_type = 2'b00;
    Length = 10'b1;
    Requester_ID = 16'h1;
    L_DW_BYTE_EN = 4'h0;
    F_DW_BYTE_EN = 4'hF; 
    Bus_Number   = 8'h0;
    Device_ID    = 5'h0;
    Function_Number = 3'h0;
    Ex_Register_No  = 4'h0;
    Register_Number = 8'h07;
    Address_lower   = 32'h0;
    Address_upper   = 32'h0;
    Message_Code    = 8'h0;
    data_in         = 32'h0000_0040;

    repeat(2)@(posedge clk); 

   //config read BAR3
    FMT  = 3'b000;
    TYPE = 5'b00100;
    TC   = 3'b000;
    Attr = 3'b000;
    TH   = 1'b0;
    TD   = 1'b1;
    EP   = 1'b0;
    Address_type = 2'b00;
    Length = 10'b1;
    Requester_ID = 16'h1;
    L_DW_BYTE_EN = 4'h0;
    F_DW_BYTE_EN = 4'hF; 
    Bus_Number   = 8'h0;
    Device_ID    = 5'h0;
    Function_Number = 3'h0;
    Ex_Register_No  = 4'h0;
    Register_Number = 8'h07;
    Address_lower   = 32'h0;
    Address_upper   = 32'h0;
    // data_in         = 32'hFFFF_FFFF;
    Message_Code    = 8'h0;

    repeat(2)@(posedge clk); 


    //mem req
    FMT  = 3'b010;
    TYPE = 5'b00000;
    TC   = 3'b000;
    Attr = 3'b000;
    TH   = 1'b0;
    TD   = 1'b1;
    EP   = 1'b0;
    Address_type = 2'b00;
    Length = 10'd2;
    Requester_ID = 16'h1;
    L_DW_BYTE_EN = 4'hF;
    F_DW_BYTE_EN = 4'hF; 
    Bus_Number   = 8'h0;
    Device_ID    = 5'h0;
    Function_Number = 3'h0;
    Ex_Register_No  = 4'h0;
    Register_Number = 8'h05;
    Address_lower   = 32'h0000_0041;
    Address_upper   = 32'h0;
    Message_Code    = 8'h0;
    @(posedge clk);
    data_in         = 32'hFFFF_FFFB;
    @(posedge clk);
    data_in         = 32'hFFFF_000A;
    repeat(2)@(posedge clk);

    //mem req
    FMT  = 3'b000;
    TYPE = 5'b00000;
    TC   = 3'b000;
    Attr = 3'b000;
    TH   = 1'b0;
    TD   = 1'b1;
    EP   = 1'b0;
    Address_type = 2'b00;
    Length = 10'd2;
    Requester_ID = 16'h1;
    L_DW_BYTE_EN = 4'hF;
    F_DW_BYTE_EN = 4'hF; 
    Bus_Number   = 8'h0;
    Device_ID    = 5'h0;
    Function_Number = 3'h0;
    Ex_Register_No  = 4'h0;
    Register_Number = 8'h05;
    Address_lower   = 32'h0000_0041;
    Address_upper   = 32'h0;
    Message_Code    = 8'h0;
    repeat(4)@(posedge clk);

   //mem req out of range req
    FMT  = 3'b000;
    TYPE = 5'b00000;
    TC   = 3'b000;
    Attr = 3'b000;
    TH   = 1'b0;
    TD   = 1'b1;
    EP   = 1'b0;
    Address_type = 2'b00;
    Length = 10'd2;
    Requester_ID = 16'h1;
    L_DW_BYTE_EN = 4'hF;
    F_DW_BYTE_EN = 4'hF; 
    Bus_Number   = 8'h0;
    Device_ID    = 5'h0;
    Function_Number = 3'h0;
    Ex_Register_No  = 4'h0;
    Register_Number = 8'h05;
    Address_lower   = 32'hF000_0041;
    Address_upper   = 32'h0;
    Message_Code    = 8'h0;
    repeat(4)@(posedge clk);

    //io req
    FMT  = 3'b010;
    TYPE = 5'b00010;
    TC   = 3'b000;
    Attr = 3'b000;
    TH   = 1'b0;
    TD   = 1'b1;
    EP   = 1'b0;
    Address_type = 2'b00;
    Length = 10'd1;
    Requester_ID = 16'h1;
    L_DW_BYTE_EN = 4'hF;
    F_DW_BYTE_EN = 4'hF; 
    Bus_Number   = 8'h0;
    Device_ID    = 5'h0;
    Function_Number = 3'h0;
    Ex_Register_No  = 4'h0;
    Register_Number = 8'h05;
    Address_lower   = 32'h0000_000F;
    Address_upper   = 32'h0;
    Message_Code    = 8'h0;
    data_in         = 32'hFFFF_ACBE;
    repeat(2)@(posedge clk);

    //io req
    FMT  = 3'b000;
    TYPE = 5'b00010;
    TC   = 3'b000;
    Attr = 3'b000;
    TH   = 1'b0;
    TD   = 1'b1;
    EP   = 1'b0;
    Address_type = 2'b00;
    Length = 10'd1;
    Requester_ID = 16'h1;
    L_DW_BYTE_EN = 4'hF;
    F_DW_BYTE_EN = 4'hF; 
    Bus_Number   = 8'h0;
    Device_ID    = 5'h0;
    Function_Number = 3'h0;
    Ex_Register_No  = 4'h0;
    Register_Number = 8'h05;
    Address_lower   = 32'h0000_000F;
    Address_upper   = 32'h0;
    Message_Code    = 8'h0;
    repeat(2)@(posedge clk);

    $finish;
end

endmodule
