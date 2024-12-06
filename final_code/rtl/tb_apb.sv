<<<<<<< HEAD
=======
module tb_apb;
>>>>>>> 99639af3eea546cdca21f90d85c710362b87ba1a

`include "apb_pkg.sv"           // Include the package
`include "apb_top.sv"           // Include the top-level module
`include "apb_interface.sv"     // Include the interface

module tb_apb;
  logic pclk, preset_n;
  logic [1:0] add_i;
  logic [31:0] external_wdata_i;
  logic ready_o;
  logic [31:0] rdata_o;
  logic psel_o, penable_o;

  // Instantiate the DUT
  apb_master_slave_top uut (
    .pclk(pclk),
    .preset_n(preset_n),
    .add_i(add_i),
    .external_wdata_i(external_wdata_i),
    .ready_o(ready_o),
    .rdata_o(rdata_o),
    .psel_o(psel_o),
    .penable_o(penable_o)
  );

  always #10 pclk = ~pclk;

  task reset_system();
    begin
      preset_n = 0;
      add_i = 2'b00;
      external_wdata_i = 32'h0;
      @(negedge pclk);
      preset_n = 1;
      @(negedge pclk);
    end
  endtask

  task perform_write(input logic [31:0] data);
    begin
      external_wdata_i = data;
      add_i = 2'b11;
      @(posedge pclk);
      wait (ready_o); // Wait for slave to assert PREADY
      @(negedge pclk);
<<<<<<< HEAD
      $display("Time: %t, Write Data: 0x%08h", $time, data); // Display the data written
      add_i = 2'b00;  // Go back to idle after the transaction
=======
>>>>>>> 99639af3eea546cdca21f90d85c710362b87ba1a
    end
  endtask
  
  task perform_read();
    begin
      add_i = 2'b01; // Read command
      @(posedge pclk);
<<<<<<< HEAD
      wait (ready_o); // Wait for slave to assert PREADY
      @(posedge pclk); // Extra clock cycle for PRDATA to stabilize
      $display("Time: %t, Read Data: 0x%08h", $time, rdata_o); // Display the data read
      add_i = 2'b00; // Go back to idle
=======
>>>>>>> 99639af3eea546cdca21f90d85c710362b87ba1a
    end
  endtask

  initial begin
    pclk = 0;

    reset_system();

    $display("Performing WRITE operation...");
    perform_write(32'h1234abcd);

    $display("Performing READ operation...");
    perform_read();
    
    $display("Performing another READ operation...");
    perform_read();

    #30;
    reset_system();

    $display("Performing another WRITE operation...");
    perform_write(32'h5678ef01);

    $display("Performing another READ operation...");
    perform_read();
    
    $display("Performing final READ operation...");
    perform_read();

    $stop;
  end
endmodule

