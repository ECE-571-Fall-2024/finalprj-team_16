module apb_master (
  input logic pclk,
  input logic preset_n,
  input logic [1:0] add_i,             // Command input: 2'b01 (READ), 2'b11 (WRITE)
  input logic [31:0] external_wdata_i, // Data to be written by the master
  apb_if apb_if                         // Interface port
);

  typedef enum logic [1:0] {ST_IDLE, ST_SETUP, ST_ACCESS} apb_state_t;

  apb_state_t state_q, nxt_state;
  logic nxt_pwrite, pwrite_q;

  always_ff @(posedge pclk or negedge preset_n) begin
    if (!preset_n) begin
      state_q <= ST_IDLE;
      pwrite_q <= 0;
    end else begin
      state_q <= nxt_state;
      pwrite_q <= nxt_pwrite;
    end
  end

  always_comb begin
    nxt_pwrite = pwrite_q;
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
        if (apb_if.slave_signals.pready) nxt_state = ST_IDLE;
      end
    endcase
  end

  assign apb_if.master_signals.psel    = (state_q == ST_SETUP) || (state_q == ST_ACCESS);
  assign apb_if.master_signals.penable = (state_q == ST_ACCESS);
  assign apb_if.master_signals.paddr   = {32{apb_if.master_signals.psel}} & 32'hA000;
  assign apb_if.master_signals.pwrite  = pwrite_q;
  assign apb_if.master_signals.pwdata  = external_wdata_i;

endmodule

