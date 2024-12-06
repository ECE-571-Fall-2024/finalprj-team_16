ude "apb_interface.sv"
module apb_master (
  input logic [1:0] add_i,            // 2'b00 - NOP, 2'b01 - READ, 2'b11 - WRITE
  input logic [31:0] external_wdata_i,
  apb_interface.master apb_intf        // Correct interface instantiation
);

   

  typedef enum logic[1:0] {ST_IDLE, ST_SETUP, ST_ACCESS} apb_state_t;
  
  apb_state_t state_q, nxt_state;
  logic nxt_pwrite, pwrite_q;
  logic [31:0] nxt_rdata, rdata_q;

  always_ff @(posedge apb_intf.apb_signals.pclk or negedge apb_intf.apb_signals.preset_n) begin
    if (!apb_intf.apb_signals.preset_n) begin
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
        if (apb_intf.apb_signals.pready) begin
          if (!pwrite_q) nxt_rdata = apb_intf.apb_signals.prdata;
          nxt_state = ST_IDLE;
        end
      end
    endcase
  end

  // Assign values to the interface signals
  assign apb_intf.apb_signals.psel = (state_q == ST_SETUP) || (state_q == ST_ACCESS);
  assign apb_intf.apb_signals.penable = (state_q == ST_ACCESS);
  assign apb_intf.apb_signals.paddr = (apb_intf.apb_signals.penable) ? 32'hA000 : 32'h0000;
  assign apb_intf.apb_signals.pwrite = pwrite_q;
  assign apb_intf.apb_signals.pwdata = external_wdata_i;

endmodule



