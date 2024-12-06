// apb_top.sv
`include "apb_pkg.sv"      // Include the package with the interface struct
`include "apb_master.sv"    // Include the master module
`include "apb_slave.sv"     // Include the slave module
`include "apb_interface.sv" // Include the interface
module apb_master_slave_top (
  input logic pclk,
  input logic preset_n,
  input logic [1:0] add_i,
  input logic [31:0] external_wdata_i,
  
  output logic ready_o,
  output logic [31:0] rdata_o,
  
  // Expose psel and penable for waveform monitoring
  output logic psel_o,
  output logic penable_o
);
  // Internal signals for APB
  logic psel, penable, pwrite;
  logic [31:0] paddr, pwdata, prdata;
  logic pready;
  // Instantiate APB master
  apb_add_master u_master (
    .pclk(pclk),
    .preset_n(preset_n),
    .add_i(add_i),
    .external_wdata_i(external_wdata_i),
    .psel_o(psel),
    .penable_o(penable),
    .paddr_o(paddr),
    .pwrite_o(pwrite),
    .pwdata_o(pwdata),
    .prdata_i(prdata),
    .pready_i(pready)
  );
  // Instantiate APB slave
  apb_add_slave u_slave (
    .pclk(pclk),
    .preset_n(preset_n),
    .psel(psel),
    .penable(penable),
    .paddr(paddr),
    .pwrite(pwrite),
    .pwdata(pwdata),
    .prdata(prdata),
    .pready(pready)
  );
  // Outputs
  assign ready_o = pready;
  assign rdata_o = prdata;
  // For waveform monitoring
  assign psel_o = psel;
  assign penable_o = penable;
endmodule
