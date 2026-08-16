module tb_LCRC_injector;

    parameter DATA_WIDTH = 32;
    parameter HEADER_DW  = 4; //max header size
    parameter SEQ_DW     = 1;  // 1 dw sequence number
    parameter PAYLOAD_DW = 2;  // max payload size for simplicity 
    parameter LCRC_DW    = 1; // 32 bit LCRC

    logic clk;
    logic reset;
    logic new_TLP_IN;
    logic [DATA_WIDTH - 1 : 0] TLP_FROM_TL [0 : HEADER_DW + PAYLOAD_DW - 1];
    logic new_TLP_REPLAY_BUFFER;
    logic [DATA_WIDTH - 1 : 0] TLP [0 : SEQ_DW + HEADER_DW + PAYLOAD_DW + LCRC_DW - 1];

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    SEQ_and_LCRC_injector_top dut (.*);

    initial begin
        reset = 1;
        repeat(2)@(posedge clk);
        reset = 0;

        TLP_FROM_TL[0] = 32'b0;
        TLP_FROM_TL[1] = 32'b0;
        TLP_FROM_TL[2] = 32'b0;
        TLP_FROM_TL[3] = 32'b0;
        TLP_FROM_TL[4] = 32'b0;
        TLP_FROM_TL[5] = 32'b0;
        @(posedge clk);
        new_TLP_IN = 1;
        @(posedge clk);
        new_TLP_IN = 0;

        repeat(10)@(posedge clk);

        @(posedge clk);
        new_TLP_IN = 1;
        @(posedge clk);
        new_TLP_IN = 0;

        repeat(10)@(posedge clk);

        @(posedge clk);
        new_TLP_IN = 1;
        @(posedge clk);
        new_TLP_IN = 0;

        repeat(10)@(posedge clk);

        @(posedge clk);
        new_TLP_IN = 1;
        @(posedge clk);
        new_TLP_IN = 0;

        repeat(10)@(posedge clk);

        @(posedge clk);
        new_TLP_IN = 1;
        @(posedge clk);
        new_TLP_IN = 0;

        repeat(10)@(posedge clk);

        @(posedge clk);
        new_TLP_IN = 1;
        @(posedge clk);
        new_TLP_IN = 0;

        repeat(10)@(posedge clk);

        @(posedge clk);
        new_TLP_IN = 1;
        @(posedge clk);
        new_TLP_IN = 0;

        repeat(10)@(posedge clk);

        @(posedge clk);
        new_TLP_IN = 1;
        @(posedge clk);
        new_TLP_IN = 0;

        repeat(10)@(posedge clk);


        repeat(5)@(posedge clk);
        $finish;
    end
    
endmodule
