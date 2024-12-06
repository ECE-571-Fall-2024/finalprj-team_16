//TOP MODULE
`include "apb_interface.sv"
module apb_top (
  input logic pclk,
  input logic preset_n,
  
  // Master inputs
  input logic [1:0] add_i,              // 2'b00 - NOP, 2'b01 - READ, 2'b11 - WRITE
  input logic [31:0] external_wdata_i,  // External write data
  
  // Outputs
  output logic ready_o,    // Slave ready signal
  output logic [31:0] rdata_o // Read data from slave
);

  // Declare the APB interface
  apb_interface apb_intf(pclk, preset_n);  // Instantiate the interface

  // Instantiate the APB master
  apb_master u_master (
    .add_i(add_i),
    .external_wdata_i(external_wdata_i),
    .apb_intf(apb_intf)   // Pass the interface instance to the master
  );

  // Instantiate the APB slave
  apb_slave u_slave (
    .apb_intf(apb_intf)   // Pass the interface instance to the slave
  );

  // Connect outputs
  assign ready_o = apb_intf.apb_signals.pready;
  assign rdata_o = apb_intf.apb_signals.prdata;

endmodule


