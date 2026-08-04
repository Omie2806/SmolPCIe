module tb_TLP_Decoder;

parameter DATA_WIDTH      = 32; //dw addressable
parameter TOTAL_DW        = 4;

    logic clk;
    logic reset;
    logic [DATA_WIDTH - 1 : 0] Header [0 : TOTAL_DW - 1]; //receiving the header 
    logic [DATA_WIDTH - 1 : 0] data_in;
    logic [DATA_WIDTH - 1 : 0] Completion_Header [0 : TOTAL_DW - 1];
    logic [DATA_WIDTH - 1 : 0] data_out;
    logic Compl_Read;
    logic Compl_Write;
    logic mem_write_done;

top_decoder_device dut (.*);

initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

initial begin
    reset = 1;
    repeat(2)@(posedge clk);
    reset = 0;

    Header[0] = 32'b000_00100_0_000_0_0_0_0_1_0_00_00_0000000001; //config read on BAR 0
    Header[1] = 32'h00_01_00_0_f;
    Header[2] = 32'b0000_0000_0000_0000_0000_0000_0001_0000;
    repeat(3)@(posedge clk);

    Header[0] = 32'b010_00100_0_000_0_0_0_0_1_0_00_00_0000000001; //config write on BAR 0 all 1s
    Header[1] = 32'h00_01_00_0_f;
    Header[2] = 32'b0000_0000_0000_0000_0000_0000_0001_0000;
    data_in   = 32'hFFFF_FFFF;
    repeat(2)@(posedge clk);

    Header[0] = 32'b000_00100_0_000_0_0_0_0_1_0_00_00_0000000001; //config read on BAR 0 read the last writeable
    Header[1] = 32'h00_01_00_0_f;
    Header[2] = 32'b0000_0000_0000_0000_0000_0000_0001_0000;
    repeat(3)@(posedge clk);

    //now write the starting address
    Header[0] = 32'b010_00100_0_000_0_0_0_0_1_0_00_00_0000000001; //config write on BAR 0 address
    Header[1] = 32'h00_01_00_0_f;
    Header[2] = 32'b0000_0000_0000_0000_0000_0000_0001_0000;
    data_in   = 32'h0000_0001;
    repeat(2)@(posedge clk);

    Header[0] = 32'b000_00100_0_000_0_0_0_0_1_0_00_00_0000000001; //config read on BAR 0 read the written address
    Header[1] = 32'h00_01_00_0_f;
    Header[2] = 32'b0000_0000_0000_0000_0000_0000_0001_0000;
    repeat(3)@(posedge clk);


    //now do the same for IO and memory BARS
    Header[0] = 32'b000_00100_0_000_0_0_0_0_1_0_00_00_0000000001; //config read on BAR 1
    Header[1] = 32'h00_01_00_0_f;
    Header[2] = 32'b0000_0000_0000_0000_0000_0000_0001_0100;
    repeat(3)@(posedge clk);

    Header[0] = 32'b010_00100_0_000_0_0_0_0_1_0_00_00_0000000001; //config write on BAR 1 
    Header[1] = 32'h00_01_00_0_f;
    Header[2] = 32'b0000_0000_0000_0000_0000_0000_0001_0100;
    data_in   = 32'hFFFF_FFFF;
    repeat(3)@(posedge clk); //delay next data in by a cycle
    Header[0] = 32'b010_00100_0_000_0_0_0_0_1_0_00_00_0000000001; //config write on BAR 2 all 1s
    Header[1] = 32'h00_01_00_0_f;
    Header[2] = 32'b0000_0000_0000_0000_0000_0000_0001_1000;
    @(posedge clk);
    data_in   = 32'hFFFF_FFFF;
    repeat(2)@(posedge clk);


    Header[0] = 32'b000_00100_0_000_0_0_0_0_1_0_00_00_0000000001; //config read on BAR 1 read the last writeable
    Header[1] = 32'h00_01_00_0_f;
    Header[2] = 32'b0000_0000_0000_0000_0000_0000_0001_0100;
    repeat(2)@(posedge clk);
    Header[0] = 32'b000_00100_0_000_0_0_0_0_1_0_00_00_0000000001; //config read on BAR 2 read the last writeable
    Header[1] = 32'h00_01_00_0_f;
    Header[2] = 32'b0000_0000_0000_0000_0000_0000_0001_1000;
    repeat(3)@(posedge clk);

    //now write the starting address
    Header[0] = 32'b010_00100_0_000_0_0_0_0_1_0_00_00_0000000001; //config write on BAR 1 address
    Header[1] = 32'h00_01_00_0_f;
    Header[2] = 32'b0000_0000_0000_0000_0000_0000_0001_0100;
    data_in   = 32'h4000_0000;
    repeat(3)@(posedge clk); //delay next data in by a cycle
    Header[0] = 32'b010_00100_0_000_0_0_0_0_1_0_00_00_0000000001; //config write on BAR 2 address
    Header[1] = 32'h00_01_00_0_f;
    Header[2] = 32'b0000_0000_0000_0000_0000_0000_0001_1000;
    @(posedge clk);
    data_in   = 32'h0000_0002;
    repeat(2)@(posedge clk);

    Header[0] = 32'b000_00100_0_000_0_0_0_0_1_0_00_00_0000000001; //config read on BAR 2 read the written address
    Header[1] = 32'h00_01_00_0_f;
    Header[2] = 32'b0000_0000_0000_0000_0000_0000_0001_0100;
    repeat(3)@(posedge clk);
    Header[0] = 32'b000_00100_0_000_0_0_0_0_1_0_00_00_0000000001; //config read on BAR 2 read the written address
    Header[1] = 32'h00_01_00_0_f;
    Header[2] = 32'b0000_0000_0000_0000_0000_0000_0001_1000;
    repeat(3)@(posedge clk);

    //IO Request BAR
    Header[0] = 32'b000_00100_0_000_0_0_0_0_1_0_00_00_0000000001; //config read on BAR 3
    Header[1] = 32'h00_01_00_0_f;
    Header[2] = 32'b0000_0000_0000_0000_0000_0000_0001_1100;
    repeat(3)@(posedge clk);

    Header[0] = 32'b010_00100_0_000_0_0_0_0_1_0_00_00_0000000001; //config write on BAR 3 all 1s
    Header[1] = 32'h00_01_00_0_f;
    Header[2] = 32'b0000_0000_0000_0000_0000_0000_0001_1100;
    data_in   = 32'hFFFF_FFFF;
    repeat(2)@(posedge clk);

    Header[0] = 32'b000_00100_0_000_0_0_0_0_1_0_00_00_0000000001; //config read on BAR 3 read the last writeable
    Header[1] = 32'h00_01_00_0_f;
    Header[2] = 32'b0000_0000_0000_0000_0000_0000_0001_1100;
    repeat(3)@(posedge clk);

    //now write the starting address
    Header[0] = 32'b010_00100_0_000_0_0_0_0_1_0_00_00_0000000001; //config write on BAR 3 address
    Header[1] = 32'h00_01_00_0_f;
    Header[2] = 32'b0000_0000_0000_0000_0000_0000_0001_1100;
    data_in   = 32'h0000_0040;
    repeat(2)@(posedge clk);

    Header[0] = 32'b000_00100_0_000_0_0_0_0_1_0_00_00_0000000001; //config read on BAR 3 read the written address
    Header[1] = 32'h00_01_00_0_f;
    Header[2] = 32'b0000_0000_0000_0000_0000_0000_0001_1100;
    repeat(3)@(posedge clk);

//change addresses to verify out of bounds address ranges are not written or read.
//ive already verified

    //send a memory request
    Header[0] = 32'b010_00000_0_000_0_0_0_0_1_0_00_00_0000000010; //mem write 3 dw on 000f onwards
    Header[1] = 32'h00_01_00_f_f;
    Header[2] = 32'h0000_000F;
    Header[3] = 32'h0;
    @(posedge clk);
    data_in   = 32'h0000_4002;
    @(posedge clk); //it doesn't matter if multiple writes happen to the same address with the same data
    data_in   = 32'h0000_4001;
    do
        @(posedge clk);
    while (!mem_write_done);

    //send a memory request
    Header[0] = 32'b000_00000_0_000_0_0_0_0_1_0_00_00_0000000010; //mem read 3 dw on 000f onwards
    Header[1] = 32'h00_01_00_f_f;
    Header[2] = 32'h0000_000F;
    Header[3] = 32'h0;
    do
        @(posedge clk);
    while (!(Compl_Read || Compl_Write));


    Header[0] = 32'b010_00010_0_000_0_0_0_0_1_0_00_00_0000000001; //io write request
    Header[1] = 32'h00_01_00_f_f;
    Header[2] = 32'h0000_0041;
    Header[3] = 32'h0;
    data_in   = 32'h0000_400F;
    do
        @(posedge clk);
    while (!(Compl_Read || Compl_Write));


    Header[0] = 32'b000_00010_0_000_0_0_0_0_1_0_00_00_0000000001; //io read request shouldnt take place
    Header[1] = 32'h00_01_00_f_f;
    Header[2] = 32'h0000_01FF;
    Header[3] = 32'h0;
    repeat(2)@(posedge clk);

    Header[0] = 32'b000_00010_0_000_0_0_0_0_1_0_00_00_0000000001; //io read request should take place
    Header[1] = 32'h00_01_00_f_f;
    Header[2] = 32'h0000_0041;
    Header[3] = 32'h0;
    do
        @(posedge clk);
    while (!(Compl_Read || Compl_Write));

    repeat(2)@(posedge clk);

    $finish; 
end

endmodule