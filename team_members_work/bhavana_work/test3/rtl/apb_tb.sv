module apb_tb;

    // Testbench signals
    logic P_clk;
    logic P_rst;
    logic [1:0] add_i;
    logic P_ready;
    logic [31:0] P_rdata;

    // Instantiate the top module
    apb_master_slave_top uut (
        .P_clk(P_clk),
        .P_rst(P_rst),
        .add_i(add_i),
        .P_ready(P_ready),
        .P_rdata(P_rdata)
    );

    // Clock generation
    always #5 P_clk = ~P_clk;

    initial begin
        // Initialize signals
        P_clk = 0;
        P_rst = 1;
        add_i = 2'b00;

        // Print simulation start message
        $display("Starting simulation...");

        // Apply reset
        #10 P_rst = 0;

        // Write operation: add_i = 2'b10
        #10 add_i = 2'b10;   // Start write operation
        $display("Starting write operation...");

        // Wait for transaction completion
        #20 add_i = 2'b00;   // End operation
        #10;

        // Read operation: add_i = 2'b01
        #10 add_i = 2'b01;   // Start read operation
        $display("Starting read operation...");

        // Wait for transaction completion
        #20 add_i = 2'b00;   // End operation

        // End simulation
        #50 $finish;
    end

    // Monitor signals
    always @(posedge P_clk) begin
        $display("Time=%0t | P_clk=%b | P_rst=%b | add_i=%b | P_ready=%b | P_rdata=%h", 
                 $time, P_clk, P_rst, add_i, P_ready, P_rdata);
    end

endmodule

