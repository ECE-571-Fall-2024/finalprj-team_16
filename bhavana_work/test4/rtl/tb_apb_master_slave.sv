module tb_apb_master_slave;

  // Clock and reset
  logic pclk;
  logic preset_n;

  // Inputs to the top module
  logic [1:0] add_i; // Command input for master

  // Outputs from the top module
  logic ready_o;     // Ready signal from slave
  logic [31:0] rdata_o; // Read data from slave

  // Instantiate the top module
  apb_master_slave_top uut (
    .pclk(pclk),
    .preset_n(preset_n),
    .add_i(add_i),
    .ready_o(ready_o),
    .rdata_o(rdata_o)
  );

  // Clock generation (50 MHz clock)
  always #10 pclk = ~pclk;

  // Task to initialize signals
  task reset_system();
    begin
      preset_n = 0;
      add_i = 2'b00; // NOP
      @(negedge pclk);
      preset_n = 1;
      @(negedge pclk);
    end
  endtask

  // Task to perform a write operation
  task perform_write();
    begin
      add_i = 2'b11; // Write operation
      wait (ready_o); // Wait for slave to be ready
      @(negedge pclk);
      add_i = 2'b00; // NOP after the operation
    end
  endtask

  // Task to perform a read operation
  task perform_read();
    begin
      add_i = 2'b01; // Read operation
      wait (ready_o); // Wait for slave to be ready
      @(negedge pclk);
      $display("Read Data: 0x%h", rdata_o);
      add_i = 2'b00; // NOP after the operation
    end
  endtask

  // Main testbench procedure
  initial begin
    // Initialize clock
    pclk = 0;

    // Reset the system
    reset_system();

    // Perform a write operation (Write an incremented value to 0xA000)
    $display("Performing WRITE operation...");
    perform_write();

    // Perform a read operation (Read the value from 0xA000)
    $display("Performing READ operation...");
    perform_read();

    // Perform another write operation (Write a new incremented value to 0xA000)
    $display("Performing another WRITE operation...");
    perform_write();

    // Perform another read operation (Read the updated value from 0xA000)
    $display("Performing another READ operation...");
    perform_read();

    // Finish simulation
    $stop;
  end

endmodule

