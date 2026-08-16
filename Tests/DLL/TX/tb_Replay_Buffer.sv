module tb_Replay_Buffer;

    parameter DATA_WIDTH = 32;
    parameter HEADER_DW  = 4;   //max header size
    parameter SEQ_DW     = 1;  // 1 dw sequence number
    parameter PAYLOAD_DW = 2;  // max payload size for simplicity 
    parameter LCRC_DW    = 1;  // 32 bit LCRC
    
     logic clk;
     logic reset;
     logic new_TLP_REPLAY_BUFFER;
     logic [DATA_WIDTH - 1 : 0] TLP [0 : SEQ_DW + HEADER_DW + PAYLOAD_DW + LCRC_DW - 1];
     logic ACK;
     logic NAK;
     logic new_TLP_RX;
     logic [11 : 0] SEQ_NUM;
     logic [DATA_WIDTH - 1 : 0] TLP_OUT [0 : SEQ_DW + HEADER_DW + PAYLOAD_DW + LCRC_DW - 1];

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    Replay_Buffer dut (.*);

    initial begin
        reset = 1;
        repeat(2)@(posedge clk);
        reset = 0;

        TLP[0] = 32'h0000_0001;
        TLP[1] = 0;
        TLP[2] = 0;
        TLP[3] = 0;
        TLP[4] = 0;
        TLP[5] = 0;
        TLP[6] = 0;
        TLP[7] = 0;
        new_TLP_REPLAY_BUFFER = 1;
        @(posedge clk);
        new_TLP_REPLAY_BUFFER = 0;

        TLP[0] = 32'h0000_0002;
        TLP[1] = 0;
        TLP[2] = 0;
        TLP[3] = 0;
        TLP[4] = 0;
        TLP[5] = 0;
        TLP[6] = 0;
        TLP[7] = 0;
        new_TLP_REPLAY_BUFFER = 1;
        @(posedge clk);
        new_TLP_REPLAY_BUFFER = 0;

        TLP[0] = 32'h0000_0003;
        TLP[1] = 0;
        TLP[2] = 0;
        TLP[3] = 0;
        TLP[4] = 0;
        TLP[5] = 0;
        TLP[6] = 0;
        TLP[7] = 0;
        new_TLP_REPLAY_BUFFER = 1;
        @(posedge clk);
        new_TLP_REPLAY_BUFFER = 0;

        repeat(25)@(posedge clk);

        ACK = 1;
        SEQ_NUM = 12'h001;
        @(posedge clk);
        ACK = 0;

        repeat(3)@(posedge clk);

        ACK = 1;
        SEQ_NUM = 12'h002;
        @(posedge clk);
        ACK = 0;

        repeat(30)@(posedge clk);

        TLP[0] = 32'h0000_0004;
        TLP[1] = 0;
        TLP[2] = 0;
        TLP[3] = 0;
        TLP[4] = 0;
        TLP[5] = 0;
        TLP[6] = 0;
        TLP[7] = 0;
        new_TLP_REPLAY_BUFFER = 1;
        @(posedge clk);
        new_TLP_REPLAY_BUFFER = 0;

        TLP[0] = 32'h0000_0005;
        TLP[1] = 0;
        TLP[2] = 0;
        TLP[3] = 0;
        TLP[4] = 0;
        TLP[5] = 0;
        TLP[6] = 0;
        TLP[7] = 0;
        new_TLP_REPLAY_BUFFER = 1;
        @(posedge clk);
        new_TLP_REPLAY_BUFFER = 0;

        TLP[0] = 32'h0000_0006;
        TLP[1] = 0;
        TLP[2] = 0;
        TLP[3] = 0;
        TLP[4] = 0;
        TLP[5] = 0;
        TLP[6] = 0;
        TLP[7] = 0;
        new_TLP_REPLAY_BUFFER = 1;
        @(posedge clk);
        new_TLP_REPLAY_BUFFER = 0;

        TLP[0] = 32'h0000_0007;
        TLP[1] = 0;
        TLP[2] = 0;
        TLP[3] = 0;
        TLP[4] = 0;
        TLP[5] = 0;
        TLP[6] = 0;
        TLP[7] = 0;
        new_TLP_REPLAY_BUFFER = 1;
        @(posedge clk);
        new_TLP_REPLAY_BUFFER = 0;

        TLP[0] = 32'h0000_0008;
        TLP[1] = 0;
        TLP[2] = 0;
        TLP[3] = 0;
        TLP[4] = 0;
        TLP[5] = 0;
        TLP[6] = 0;
        TLP[7] = 0;
        new_TLP_REPLAY_BUFFER = 1;
        @(posedge clk);
        new_TLP_REPLAY_BUFFER = 0;

        TLP[0] = 32'h0000_0009;
        TLP[1] = 0;
        TLP[2] = 0;
        TLP[3] = 0;
        TLP[4] = 0;
        TLP[5] = 0;
        TLP[6] = 0;
        TLP[7] = 0;
        new_TLP_REPLAY_BUFFER = 1;
        @(posedge clk);
        new_TLP_REPLAY_BUFFER = 0;

        repeat(40)@(posedge clk);

        //perform replay
        NAK = 1;
        SEQ_NUM = 12'h004;
        @(posedge clk);
        NAK = 0;

        repeat(30)@(posedge clk);

        repeat(150)@(posedge clk);
        //clear all
        ACK = 1;
        SEQ_NUM = 12'h009;
        @(posedge clk);
        ACK = 0;

        repeat(5)@(posedge clk);

        //start again
        TLP[0] = 32'h0000_000A;
        TLP[1] = 0;
        TLP[2] = 0;
        TLP[3] = 0;
        TLP[4] = 0;
        TLP[5] = 0;
        TLP[6] = 0;
        TLP[7] = 0;
        new_TLP_REPLAY_BUFFER = 1;
        @(posedge clk);
        new_TLP_REPLAY_BUFFER = 0;

        TLP[0] = 32'h0000_000B;
        TLP[1] = 0;
        TLP[2] = 0;
        TLP[3] = 0;
        TLP[4] = 0;
        TLP[5] = 0;
        TLP[6] = 0;
        TLP[7] = 0;
        new_TLP_REPLAY_BUFFER = 1;
        @(posedge clk);
        new_TLP_REPLAY_BUFFER = 0;

        TLP[0] = 32'h0000_000C;
        TLP[1] = 0;
        TLP[2] = 0;
        TLP[3] = 0;
        TLP[4] = 0;
        TLP[5] = 0;
        TLP[6] = 0;
        TLP[7] = 0;
        new_TLP_REPLAY_BUFFER = 1;
        @(posedge clk);
        new_TLP_REPLAY_BUFFER = 0;

        repeat(40)@(posedge clk);
        $finish;
    end

endmodule