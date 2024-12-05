module apb_add_master (
  input apb_interface.master apb_if, // Declare interface port with master modport
  input logic [1:0] add_i,           // 2'b00 - NOP, 2'b01 - READ, 2'b11 - WRITE
  input logic [31:0] external_wdata_i
);

  typedef enum logic[1:0] {ST_IDLE, ST_SETUP, ST_ACCESS} apb_state_t;

  apb_state_t state_q, nxt_state;
  logic nxt_pwrite, pwrite_q;
  logic [31:0] nxt_rdata, rdata_q;

  always_ff @(posedge apb_if.pclk or negedge apb_if.preset_n) begin
    if (!apb_if.preset_n) begin
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
        if (apb_if.pready) begin
          if (!pwrite_q) nxt_rdata = apb_if.prdata;
          nxt_state = ST_IDLE;
        end
      end
    endcase
  end

  assign apb_if.psel = (state_q == ST_SETUP) || (state_q == ST_ACCESS);
  assign apb_if.penable = (state_q == ST_ACCESS);
  assign apb_if.paddr = {32{apb_if.psel}} & 32'hA000;
  assign apb_if.pwrite = pwrite_q;
  assign apb_if.pwdata = external_wdata_i;

endmodule

