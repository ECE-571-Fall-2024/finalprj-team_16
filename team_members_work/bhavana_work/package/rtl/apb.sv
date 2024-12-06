`include "apb_pkg.sv"

// Interface definition
interface apb_interface(
  input logic pclk,
  input logic preset_n,

  output logic psel,
  output logic penable,
  output logic pwrite,
  output logic [31:0] paddr,
  output logic [31:0] pwdata,
  input logic [31:0] prdata,
  input logic pready
);
endinterface

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
    
    .psel_o(psel),
    .penable_o(penable),
    .paddr_o(paddr),
    .pwrite_o(pwrite),
    .pwdata_o(pwdata),
    .prdata_i(prdata),
    .pready_i(pready),
    .external_wdata_i(external_wdata_i)
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
  assign paddr_o = (penable_o) ? 32'h0000a000 : 32'h0000_0000; // Example slave address
  assign pwrite_o = pwrite_q;
  assign pwdata_o = external_wdata_i;
endmodule

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
