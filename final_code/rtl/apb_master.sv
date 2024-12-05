// apb_master.sv
`include "apb_pkg.sv"  // Include the package with the interface struct
`include "apb_interface.sv" // Include the interface
module apb_add_master (
  input logic pclk,
  input logic preset_n,
  input logic [1:0] add_i,
  input logic [31:0] external_wdata_i,
  
  output logic psel_o,
  output logic penable_o,
  output logic [31:0] paddr_o,
  output logic pwrite_o,
  output logic [31:0] pwdata_o,
  input logic [31:0] prdata_i,
  input logic pready_i
);
  import apb_pkg::*;
  
  typedef enum logic [1:0] {ST_IDLE, ST_SETUP, ST_ACCESS} apb_state_t;
  apb_state_t state_q, nxt_state;
  logic nxt_pwrite, pwrite_q;
  logic [31:0] nxt_rdata, rdata_q;
  always_ff @(posedge pclk or negedge preset_n) begin
    if (!preset_n) begin
      state_q <= ST_IDLE;
      pwrite_q <= 0;
      rdata_q <= 32'h0;
    end else begin
      state_q <= nxt_state;
      pwrite_q <= nxt_pwrite;
      rdata_q <= nxt_rdata;
    end
  end
  always_comb begin
    nxt_pwrite = pwrite_q;
    nxt_rdata = rdata_q;
    nxt_state = state_q;
    case (state_q)
      ST_IDLE: begin
        if (add_i[0]) begin
          nxt_state = ST_SETUP;
          nxt_pwrite = add_i[1];
        end
      end
      ST_SETUP: nxt_state = ST_ACCESS;
      ST_ACCESS: begin
        if (pready_i) begin
          if (!pwrite_q) nxt_rdata = prdata_i;
          nxt_state = ST_IDLE;
        end
      end
    endcase
  end
  assign psel_o = (state_q == ST_SETUP) || (state_q == ST_ACCESS);
  assign penable_o = (state_q == ST_ACCESS);
  assign paddr_o = (penable_o) ? 32'hA000 : 32'h0000; // Example slave address
  assign pwrite_o = pwrite_q;
  assign pwdata_o = external_wdata_i;
endmodule
