module tb_Receiver_top;

    parameter DATA_WIDTH = 32;
    parameter HEADER_DW  = 4;  //max header size
    parameter SEQ_DW     = 1;  // 1 dw sequence number
    parameter PAYLOAD_DW = 2;  // max payload size for simplicity 
    parameter LCRC_DW    = 1;  // 32 bit LCRC

    logic clk;
    logic reset;
    logic new_TLP;
    logic [DATA_WIDTH - 1 : 0] TLP [0 : SEQ_DW + HEADER_DW + PAYLOAD_DW + LCRC_DW - 1];
    logic [DATA_WIDTH - 1 : 0] TLP_EXTRACT_OUT [0 : HEADER_DW + PAYLOAD_DW - 1]; //final TLP to TL
    logic [31 : 0] DLLP;
    
initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

Receiver_top dut (.*);

initial begin
    reset = 1;
    repeat(2)@(posedge clk);
    reset = 0;

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

    repeat(15)@(posedge clk);

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

    repeat(15)@(posedge clk);

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

    repeat(15)@(posedge clk);

    //should send an ACK
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

    repeat(15)@(posedge clk);

    //clear the ACK
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

    repeat(15)@(posedge clk);

    //cause a NAK
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

    repeat(15)@(posedge clk);

    //clear NAK
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

    repeat(15)@(posedge clk);

    //continue normal ops
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

    repeat(15)@(posedge clk);

    //ANOTHER NAK
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

    repeat(15)@(posedge clk);

    //resolve the nak
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

    repeat(15)@(posedge clk);

    //error in LCRC
    TLP[0] = 32'h0000_0009;
    TLP[1] = 32'h0000_0000;
    TLP[2] = 32'h0000_0000;
    TLP[3] = 32'h0000_0000;
    TLP[4] = 32'h0000_0000;
    TLP[5] = 32'h0000_0000;
    TLP[6] = 32'h0000_0000;
    TLP[7] = 32'hE39D_9574;//4 instrad of 3 in LSB
    @(posedge clk);
    new_TLP = 1;

    @(posedge clk);
    new_TLP = 0;

    repeat(15)@(posedge clk);

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

    repeat(15)@(posedge clk);


    repeat(5)@(posedge clk);

    $finish;
end
endmodule