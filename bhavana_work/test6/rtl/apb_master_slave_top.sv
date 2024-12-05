module apb_master_slave_top (
  input logic pclk,
  input logic preset_n,
  input logic [1:0] add_i,             // Master command: 2'b00 - NOP, 2'b01 - READ, 2'b11 - WRITE
  input logic [31:0] external_wdata_i, // Data to be written by the master
  output logic ready_o,                // Slave ready signal
  output logic [31:0] rdata_o          // Data read by the master
);

  // Instantiate the interface
  apb_if apb_if_inst();

  // Outputs from interface
  assign ready_o = apb_if_inst.slave_signals.pready;
  assign rdata_o = apb_if_inst.master_signals.prdata;

  // Instantiate the APB master
  apb_master u_master (
    .pclk(pclk),
    .preset_n(preset_n),
    .add_i(add_i),
    .external_wdata_i(external_wdata_i),
    .apb_if(apb_if_inst)
  );

  // Instantiate the APB slave
  apb_slave u_slave (
    .pclk(pclk),
    .preset_n(preset_n),
    .apb_if(apb_if_inst)
  );

endmodule

