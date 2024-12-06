module apb_top (
  input logic pclk,
  input logic preset_n,
  
  input logic [1:0] add_i,
  input logic [31:0] external_wdata_i,
  
  output logic ready_o,
  output logic [31:0] rdata_o
);

  apb_interface apb_intf(pclk, preset_n);

  apb_master u_master (
    .add_i(add_i),
    .external_wdata_i(external_wdata_i),
    .apb_intf(apb_intf)
  );

  apb_slave u_slave (
    .apb_intf(apb_intf)
  );

  assign ready_o = apb_intf.apb_signals.pready;
  assign rdata_o = apb_intf.apb_signals.prdata;

endmodule

