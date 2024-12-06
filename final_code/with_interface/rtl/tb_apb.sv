`include "apb_pkg.sv"

module tb_apb_master_slave;

  import apb_pkg::*;

  logic pclk, preset_n;
  logic [1:0] add_i;
  logic [31:0] external_wdata_i;
  logic ready_o;
  logic [31:0] rdata_o;

  // Declare the APB interface
  apb_interface apb_intf(pclk, preset_n);

  // Instantiate the DUT
  apb_master_slave_top uut (
    .pclk(pclk),
    .preset_n(preset_n),
    .add_i(add_i),
    .external_wdata_i(external_wdata_i),
    .ready_o(ready_o),
    .rdata_o(rdata_o)
  );

  // Clock generation
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
      wait (ready_o);
      @(negedge pclk);
      $display("Write Data: 0x%08h", data);
      add_i = 2'b00;
    end
  endtask
  
  task perform_read();
    begin
      add_i = 2'b01;
      @(posedge pclk);
      wait (ready_o);
      @(posedge pclk);
      $display("Read Data: 0x%08h", rdata_o);
      add_i = 2'b00;
    end
  endtask

  initial begin
    pclk = 0;
    reset_system();

    $display("Performing WRITE operation...");
    perform_write(32'h1234abcd);

    $display("Performing READ operation...");
    perform_read();

    $display("Performing READ operation...");
    perform_read();

    #30;
    $stop;
  end

  initial begin
    $dumpfile("apb.vcd");
    $dumpvars(2, tb_apb_master_slave);
  end
endmodule

