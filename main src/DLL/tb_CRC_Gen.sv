module tb_CRC_Gen;

	 logic clk;
	 logic reset;
	 logic fd; // First data. 1: SEED is used (initialise and calculate); 0: Previous CRC is used (continue and calculate)
	 logic nd; // New Data. d  has a valid data. Calculate new CRC
	 logic rdy;
	 logic [ 31:0] d; // Data in
	 logic [ 31:0] o; // Data
	 logic [ 31:0] c; // CRC
     logic [ 31:0] c_out; //after byte level bit reversal 
    
    CRC_Gen dut (.*);

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        reset = 1;
        repeat(3)@(posedge clk);
        reset = 0;

        @(posedge clk);

        //test with new TLP
        fd = 1;
        nd = 1;
        d  = 32'hDEAD_BEEF;
        @(posedge clk);
        //continuation of the TLP
        fd = 0;
        nd = 1;
        d  = 32'hABCD_1234;
        @(posedge clk);

        //continuation of the TLP
        fd = 0;
        nd = 1;
        d  = 32'h0000_0000;
        @(posedge clk);

        //continuation of the TLP
        fd = 0;
        nd = 1;
        d  = 32'h0000_0000;
        @(posedge clk);

        //continuation of the TLP
        fd = 0;
        nd = 1;
        d  = 32'h0000_0000;
        @(posedge clk);

        //continuation of the TLP
        fd = 0;
        nd = 1;
        d  = 32'h0000_0000;
        @(posedge clk);

        //continuation of the TLP
        fd = 0;
        nd = 1;
        d  = 32'h0000_0000;
        @(posedge clk);

        //TLP Over
        fd = 0;
        nd = 0;
        d  = 32'h0000_0000;
        @(posedge clk);

        //new TLP 
        //test with new TLP
        fd = 1;
        nd = 1;
        d  = 32'hDEAD_BEEF;
        @(posedge clk);
        //continuation of the TLP

        fd = 0;
        nd = 1;
        d  = 32'h0000_0000;
        @(posedge clk);

        //continuation of the TLP
        fd = 0;
        nd = 1;
        d  = 32'h0000_0000;
        @(posedge clk);

        //continuation of the TLP
        fd = 0;
        nd = 1;
        d  = 32'h0000_0000;
        @(posedge clk);

        //continuation of the TLP
        fd = 0;
        nd = 1;
        d  = 32'h0000_0000;
        @(posedge clk);

        //continuation of the TLP
        fd = 0;
        nd = 1;
        d  = 32'h0000_0000;
        @(posedge clk);

        //continuation of the TLP
        fd = 0;
        nd = 1;
        d  = 32'h0000_0000;
        @(posedge clk);

        //TLP Over
        fd = 0;
        nd = 0;
        d  = 32'h0000_0000;
        @(posedge clk);

        repeat(2)@(posedge clk);
        $finish;
    end
endmodule