module apb_tb;
  // Input configuration
  reg P_clk;
  reg P_rst;
  reg [31:0] P_addr;
  reg P_selx;
  reg P_enable;
  reg P_write;
  reg [31:0] P_wdata;

  // Output configuration
  wire P_ready;
  wire P_slverr;
  wire [31:0] P_rdata;

  // Instantiation of the DUT (Device Under Test)
  apb dut1 (
    .P_clk(P_clk),
    .P_rst(P_rst),
    .P_addr(P_addr),
    .P_selx(P_selx),
    .P_enable(P_enable),
    .P_write(P_write),
    .P_wdata(P_wdata),
    .P_ready(P_ready),
    .P_slverr(P_slverr),
    .P_rdata(P_rdata)
  );
  
  // Clock generation
  always #5 P_clk = ~P_clk;
  
  // Task for initialization
  task initialization;
    begin
      P_clk = 0;
      P_rst = 0;
      P_addr = 0;
      P_selx = 0;
      P_enable = 0;
      P_write = 0;
    end
  endtask
  
  // Task for reset
  task reset;
    begin
      P_rst = 1;
      #10 P_rst = 0;
    end
  endtask
  
  // Task for writing stimulus
  task write_stimulus;
    begin
      @(posedge P_clk);
      P_selx = 1;
      P_write = 1;
      P_wdata = $random % 10;
      P_addr = P_addr + 1;
     
      @(posedge P_clk);
      P_enable = 1;
      P_selx = 1;
      @(posedge P_clk);
      P_enable = 0;
      P_selx = 0;
      
      @(posedge P_clk);
      $strobe ("Writing data into memory: data_in=%0d, address_in=%0d", P_wdata, P_addr);
    end
  endtask
  
  // Task for reading stimulus
  task read_stimulus;
    begin
      @(posedge P_clk);
      P_write = 0;
      P_selx = 1;
      P_enable = 0;
      
      @(posedge P_clk); 
      P_enable = 1;
      P_selx = 1;
      P_addr <= P_addr + 1;
      @(posedge P_clk); 
      P_enable = 0;
      P_selx = 0;
      
      @(posedge P_clk);
      $strobe("Reading data from memory: data_out=%0d, address_out=%0d", P_rdata, P_addr);
    end
  endtask
  
  // Task for both read and write operations
  task read_write;
    begin
      repeat(2) begin 
        write_stimulus;
      end
      #1;
      P_addr = 0;
      repeat(3) begin 
        read_stimulus;
      end
    end
  endtask
  
  // Testbench stimulus
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
    initialization; // Initialize input values
    reset;          // Generate reset signal
    read_write;     // Perform read-write cycle
    #80; $finish;   // End the simulation after some time
  end

endmodule

