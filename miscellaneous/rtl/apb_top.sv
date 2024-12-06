module apb_master_slave_top (
  input logic pclk,
  input logic preset_n,
  
  // Master inputs
  input logic [1:0] add_i,         // 2'b00 - NOP, 2'b01 - READ, 2'b11 - WRITE
  input logic [31:0] external_wdata_i, // External write data
  
  // Outputs
  output logic ready_o,            // Slave ready signal
  output logic [31:0] rdata_o      // Read data from slave
);

  // APB Interface instantiation
  apb_interface apb_if();

  // Connect clock and reset
  assign apb_if.pclk = pclk;
  assign apb_if.preset_n = preset_n;

  // Instantiate the APB master
  apb_add_master u_master (
    .apb_if(apb_if),               // Pass the entire interface
    .add_i(add_i),
    .external_wdata_i(external_wdata_i)
  );

  // Instantiate the APB slave
  apb_add_slave u_slave (
    .apb_if(apb_if)                // Pass the entire interface
  );

  // Connect outputs
  assign ready_o = apb_if.pready;
  assign rdata_o = apb_if.prdata;

endmodule

