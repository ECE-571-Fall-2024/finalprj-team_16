// apb_slave.sv
`include "apb_pkg.sv"  // Include the package with the interface struct
`include "apb_interface.sv" // Include the interface
module apb_add_slave (
  input logic pclk,
  input logic preset_n,
  input logic psel,
  input logic penable,
  input logic [31:0] paddr,
  input logic pwrite,
  input logic [31:0] pwdata,
  output logic [31:0] prdata,
  output logic pready
);
  import apb_pkg::*;
  
  logic [31:0] register;
  assign pready = psel && penable;
  always_ff @(posedge pclk or negedge preset_n) begin
    if (!preset_n) begin
      register <= 32'b0;
    end else if (psel && penable && pwrite && (paddr == 32'h0000_0000)) begin
      register <= pwdata;
    end
  end
  always_comb begin
    if (psel && penable && !pwrite && (paddr == 32'h0000_0000)) begin
      prdata = register;
    end else begin
      prdata = 32'b0;
    end
  end
endmodule
