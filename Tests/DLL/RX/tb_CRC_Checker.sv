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
    logic [DATA_WIDTH - 1 : 0] TLP_EXTRACT [0 : SEQ_DW + HEADER_DW + PAYLOAD_DW - 1];

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
    TLP[0] = 32'h0000_0001;
    TLP[1] = 32'h0000_0000;
    TLP[2] = 32'h0000_0000;
    TLP[3] = 32'h0000_0000;
    TLP[4] = 32'h0000_0000;
    TLP[5] = 32'h0000_0000;
    TLP[6] = 32'h0000_0000;
    TLP[7] = 32'h0B75_3A7E;
    @(posedge clk);
    new_TLP = 1;

    @(posedge clk);
    new_TLP = 0;

    repeat(11)@(posedge clk);


    //new TLP: dont cause error
    TLP[0] = 32'h0000_0002;
    TLP[1] = 32'h0000_0000;
    TLP[2] = 32'h0000_0000;
    TLP[3] = 32'h0000_0000;
    TLP[4] = 32'h0000_0000;
    TLP[5] = 32'h0000_0000;
    TLP[6] = 32'h0000_0000;
    TLP[7] = 32'h2C72_E47C;
    @(posedge clk);
    new_TLP = 1;

    @(posedge clk);
    new_TLP = 0;

    repeat(10)@(posedge clk);

    //DONT CAUSE ERROR
    TLP[0] = 32'h0000_0003;
    TLP[1] = 32'h0000_0000;
    TLP[2] = 32'h0000_0000;
    TLP[3] = 32'h0000_0000;
    TLP[4] = 32'h0000_0000;
    TLP[5] = 32'h0000_0000;
    TLP[6] = 32'h0000_0000;
    TLP[7] = 32'h318F_517D;
    @(posedge clk);
    new_TLP = 1;

    @(posedge clk);
    new_TLP = 0;

    repeat(10)@(posedge clk);

    TLP[0] = 32'h0000_0004;
    TLP[1] = 32'h0000_0000;
    TLP[2] = 32'h0000_0000;
    TLP[3] = 32'h0000_0000;
    TLP[4] = 32'h0000_0000;
    TLP[5] = 32'h0000_0000;
    TLP[6] = 32'h0000_0000;
    TLP[7] = 32'h627C_5879;
    @(posedge clk);
    new_TLP = 1;

    @(posedge clk);
    new_TLP = 0;

    repeat(10)@(posedge clk);

    TLP[0] = 32'h0000_0005;
    TLP[1] = 32'h0000_0000;
    TLP[2] = 32'h0000_0000;
    TLP[3] = 32'h0000_0000;
    TLP[4] = 32'h0000_0000;
    TLP[5] = 32'h0000_0000;
    TLP[6] = 32'h0000_0000;
    TLP[7] = 32'h7F81_ED78;
    @(posedge clk);
    new_TLP = 1;

    @(posedge clk);
    new_TLP = 0;

    repeat(10)@(posedge clk);

    TLP[0] = 32'h0000_0006;
    TLP[1] = 32'h0000_0000;
    TLP[2] = 32'h0000_0000;
    TLP[3] = 32'h0000_0000;
    TLP[4] = 32'h0000_0000;
    TLP[5] = 32'h0000_0000;
    TLP[6] = 32'h0000_0000;
    TLP[7] = 32'h5886_337A;
    @(posedge clk);
    new_TLP = 1;

    @(posedge clk);
    new_TLP = 0;

    repeat(10)@(posedge clk);

    TLP[0] = 32'h0000_0007;
    TLP[1] = 32'h0000_0000;
    TLP[2] = 32'h0000_0000;
    TLP[3] = 32'h0000_0000;
    TLP[4] = 32'h0000_0000;
    TLP[5] = 32'h0000_0000;
    TLP[6] = 32'h0000_0000;
    TLP[7] = 32'h457B_867B;
    @(posedge clk);
    new_TLP = 1;

    @(posedge clk);
    new_TLP = 0;

    repeat(10)@(posedge clk);

    TLP[0] = 32'h0000_0008;
    TLP[1] = 32'h0000_0000;
    TLP[2] = 32'h0000_0000;
    TLP[3] = 32'h0000_0000;
    TLP[4] = 32'h0000_0000;
    TLP[5] = 32'h0000_0000;
    TLP[6] = 32'h0000_0000;
    TLP[7] = 32'hFE60_2072;
    @(posedge clk);
    new_TLP = 1;

    @(posedge clk);
    new_TLP = 0;

    repeat(10)@(posedge clk);

    TLP[0] = 32'h0000_0009;
    TLP[1] = 32'h0000_0000;
    TLP[2] = 32'h0000_0000;
    TLP[3] = 32'h0000_0000;
    TLP[4] = 32'h0000_0000;
    TLP[5] = 32'h0000_0000;
    TLP[6] = 32'h0000_0000;
    TLP[7] = 32'hE39D_9573;
    @(posedge clk);
    new_TLP = 1;

    @(posedge clk);
    new_TLP = 0;

    repeat(10)@(posedge clk);

    TLP[0] = 32'h0000_000A;
    TLP[1] = 32'h0000_0000;
    TLP[2] = 32'h0000_0000;
    TLP[3] = 32'h0000_0000;
    TLP[4] = 32'h0000_0000;
    TLP[5] = 32'h0000_0000;
    TLP[6] = 32'h0000_0000;
    TLP[7] = 32'hC49A_4B71;
    @(posedge clk);
    new_TLP = 1;

    @(posedge clk);
    new_TLP = 0;

    repeat(10)@(posedge clk);

    $finish;
end

endmodule