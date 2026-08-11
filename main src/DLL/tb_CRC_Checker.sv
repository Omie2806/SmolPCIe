module tb_CRC_Checker;
    parameter DATA_WIDTH = 32;
    parameter HEADER_DW  = 4;  //max header size
    parameter SEQ_DW     = 1;  // 1 dw sequence number
    parameter PAYLOAD_DW = 2;  // max payload size for simplicity 
    parameter LCRC_DW    = 1;  // 32 bit LCRC

     logic clk;
     logic reset;
     logic new_TLP;
     logic [DATA_WIDTH - 1 : 0] TLP [0 : SEQ_DW + HEADER_DW + PAYLOAD_DW + LCRC_DW - 1];
     logic error;
     logic no_error;

CRC_Checker tb_dut (.*);   

initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

initial begin
    reset = 1;
    repeat(3)@(posedge clk);
    reset = 0;

    // @(posedge clk);
    // //Clear garbage
    // TLP[0] = 32'h0000_0000;
    // TLP[1] = 32'h0000_0000;
    // TLP[2] = 32'h0000_0000;
    // TLP[3] = 32'h0000_0000;
    // TLP[4] = 32'h0000_0000;
    // TLP[5] = 32'h0000_0000;
    // TLP[6] = 32'h0000_0000;
    // TLP[7] = 32'h0000_0000;
    // @(posedge clk);
    // new_TLP = 1;

    // @(posedge clk);
    // new_TLP = 0;

    repeat(11)@(posedge clk);

    //now start the test
    TLP[0] = 32'hDEAD_BEEF;
    TLP[1] = 32'hABCD_1234;
    TLP[2] = 32'h0000_0000;
    TLP[3] = 32'h0000_0000;
    TLP[4] = 32'h0000_0000;
    TLP[5] = 32'h0000_0000;
    TLP[6] = 32'h0000_0000;
    TLP[7] = 32'hF902_B631;
    @(posedge clk);
    new_TLP = 1;

    @(posedge clk);
    new_TLP = 0;

    repeat(11)@(posedge clk);


    //new TLP: dont cause error
    TLP[0] = 32'hDEAD_BEEF;
    TLP[1] = 32'h0000_0000;
    TLP[2] = 32'h0000_0000;
    TLP[3] = 32'h0000_0000;
    TLP[4] = 32'h0000_0000;
    TLP[5] = 32'h0000_0000;
    TLP[6] = 32'h0000_0000;
    TLP[7] = 32'h62C8_17B9;
    @(posedge clk);
    new_TLP = 1;

    @(posedge clk);
    new_TLP = 0;

    repeat(10)@(posedge clk);

    //new TLP: cause error
    TLP[0] = 32'hDEAD_BEEF;
    TLP[1] = 32'h0000_0000;
    TLP[2] = 32'h0000_0000;
    TLP[3] = 32'h0000_0000;
    TLP[4] = 32'h0000_0000;
    TLP[5] = 32'h0000_0000;
    TLP[6] = 32'h0000_0000;
    TLP[7] = 32'h62C8_17BA;
    @(posedge clk);
    new_TLP = 1;

    @(posedge clk);
    new_TLP = 0;

    repeat(10)@(posedge clk);

    TLP[0] = 32'hDEAD_BEEF;
    TLP[1] = 32'h0000_0000;
    TLP[2] = 32'h0000_0000;
    TLP[3] = 32'h0000_0000;
    TLP[4] = 32'h0000_0000;
    TLP[5] = 32'h0000_0000;
    TLP[6] = 32'h0000_0000;
    TLP[7] = 32'h62C8_17B9;
    @(posedge clk);
    new_TLP = 1;

    @(posedge clk);
    new_TLP = 0;

    repeat(10)@(posedge clk);

    $finish;
end

endmodule