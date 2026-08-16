module tb_ACK_NAK;
    parameter DATA_WIDTH = 32;
    parameter HEADER_DW  = 4;  //max header size
    parameter SEQ_DW     = 1;  // 1 dw sequence number
    parameter PAYLOAD_DW = 2;  // max payload size for simplicity 
    parameter LCRC_DW    = 1;  // 32 bit LCRC

    logic clk;
    logic reset;
    logic error;
    logic no_error;
    logic [DATA_WIDTH - 1 : 0] TLP_EXTRACT [0 : SEQ_DW + HEADER_DW + PAYLOAD_DW - 1];
    logic ACK;
    logic NAK;
    logic [11 : 0] SEQUENCE_NUMBER;
    logic [DATA_WIDTH - 1 : 0] TLP_EXTRACT_OUT [0 : SEQ_DW + HEADER_DW + PAYLOAD_DW - 1]; //final TLP to TL

    ACK_NAK dut (.*);

initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

initial begin
    reset = 1;
    repeat(2)@(posedge clk);
    reset = 0;

    TLP_EXTRACT[0] = 32'h0;
    @(posedge clk);
    no_error = 1;
    @(posedge clk);
    no_error = 0;
    @(posedge clk);
    no_error = 0;

    @(posedge clk);

    TLP_EXTRACT[0] = 32'h1;
    @(posedge clk);
    no_error = 1;
    @(posedge clk);
    no_error = 0;
    @(posedge clk);
    no_error = 0;

    @(posedge clk);

    TLP_EXTRACT[0] = 32'h2;
    @(posedge clk);
    no_error = 1;
    @(posedge clk);
    no_error = 0;
    @(posedge clk);
    no_error = 0;

    repeat(2)@(posedge clk);

    //ACK send
    TLP_EXTRACT[0] = 32'h1;
    @(posedge clk);
    no_error = 1;
    @(posedge clk);
    no_error = 0;
    @(posedge clk);
    no_error = 0;

    repeat(2)@(posedge clk);

    //continue normal ops
    TLP_EXTRACT[0] = 32'h3;
    @(posedge clk);
    no_error = 1;
    @(posedge clk);
    no_error = 0;
    @(posedge clk);
    no_error = 0;

    repeat(2)@(posedge clk);

    TLP_EXTRACT[0] = 32'h4;
    @(posedge clk);
    no_error = 1;
    @(posedge clk);
    no_error = 0;
    @(posedge clk);
    no_error = 0;

    repeat(2)@(posedge clk);

    //force nak with wrong seq 
    TLP_EXTRACT[0] = 32'h6;
    @(posedge clk);
    no_error = 1;
    @(posedge clk);
    no_error = 0;
    @(posedge clk);
    no_error = 0;

    repeat(2)@(posedge clk);

    //resolve NAK
    TLP_EXTRACT[0] = 32'h5;
    @(posedge clk);
    no_error = 1;
    @(posedge clk);
    no_error = 0;
    @(posedge clk);
    no_error = 0;

    repeat(2)@(posedge clk);

    //error
    TLP_EXTRACT[0] = 32'h6;
    @(posedge clk);
    error = 1;
    @(posedge clk);
    error = 0;
    @(posedge clk);
    no_error = 0;

    repeat(2)@(posedge clk);

    //fix the error
    TLP_EXTRACT[0] = 32'h6;
    @(posedge clk);
    no_error = 1;
    @(posedge clk);
    no_error = 0;
    @(posedge clk);
    no_error = 0;

    repeat(2)@(posedge clk);

    //multiple NAKs
    TLP_EXTRACT[0] = 32'h8;
    @(posedge clk);
    no_error = 1;
    @(posedge clk);
    no_error = 0;
    @(posedge clk);
    no_error = 0;

    repeat(2)@(posedge clk);

    TLP_EXTRACT[0] = 32'h9;
    @(posedge clk);
    no_error = 1;
    @(posedge clk);
    no_error = 0;
    @(posedge clk);
    no_error = 0;

    repeat(2)@(posedge clk);

    //fix ghe NAKs
    TLP_EXTRACT[0] = 32'h7;
    @(posedge clk);
    no_error = 1;
    @(posedge clk);
    no_error = 0;
    @(posedge clk);
    no_error = 0;

    repeat(2)@(posedge clk);


    repeat(5)@(posedge clk);
    $finish;
end

endmodule
