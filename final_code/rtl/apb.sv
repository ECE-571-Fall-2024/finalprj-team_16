`include "apb_pkg.sv"

module apb_master_slave_top (
  input logic pclk,
  input logic preset_n,
  
  // Master inputs
  input logic [1:0] add_i,            // 2'b00 - NOP, 2'b01 - READ, 2'b11 - WRITE
  input logic [31:0] external_wdata_i, // External write data
  
  // Outputs
  output logic ready_o,               // Slave ready signal
  output logic [31:0] rdata_o         // Read data from slave
);

  import apb_pkg::*; // Import the package

  // APB signal struct
  apb_signals_t master_signals, slave_signals;

  // Instantiate the APB master
  apb_add_master u_master (
    .pclk(pclk),
    .preset_n(preset_n),
    .add_i(add_i),
    .external_wdata_i(external_wdata_i),
    .master_signals(master_signals),
    .slave_signals(slave_signals)
  );

  // Instantiate the APB slave
  apb_add_slave u_slave (
    .pclk(pclk),
    .preset_n(preset_n),
    .slave_signals(slave_signals),
    .master_signals(master_signals)
  );

  // Connect outputs
  assign ready_o = slave_signals.pready;
  assign rdata_o = slave_signals.prdata;

endmodule

module apb_add_master (
  input logic pclk,
  input logic preset_n,
  input logic [1:0] add_i,              // 2'b00 - NOP, 2'b01 - READ, 2'b11 - WRITE
  input logic [31:0] external_wdata_i,  // External write data

  output apb_signals_t master_signals,  // APB signals from master
  input apb_signals_t slave_signals     // APB signals from slave
);

  import apb_pkg::*; // Import the package

  apb_state_t state_q, nxt_state;  // State machine
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
        if (slave_signals.pready) nxt_state = ST_IDLE;
      end
    endcase
  end

  assign master_signals.psel = (state_q == ST_SETUP) || (state_q == ST_ACCESS);
  assign master_signals.penable = (state_q == ST_ACCESS);
  assign master_signals.paddr = SLAVE_ADDR;
  assign master_signals.pwrite = pwrite_q;
  assign master_signals.pwdata = external_wdata_i;

endmodule

module apb_add_slave (
  input logic pclk,
  input logic preset_n,
  
  output apb_signals_t slave_signals,  // APB signals from slave
  input apb_signals_t master_signals  // APB signals from master
);

  import apb_pkg::*; // Import the package

  logic [31:0] register;

  assign slave_signals.pready = master_signals.psel && master_signals.penable;

  always_ff @(posedge pclk or negedge preset_n) begin
    if (!preset_n) begin
      register <= 32'b0;
    end else if (master_signals.psel && master_signals.penable && master_signals.pwrite && 
                 (master_signals.paddr == SLAVE_ADDR)) begin
      register <= master_signals.pwdata;
      $display("Slave: Write operation. Address: 0x%08h, Data: 0x%08h", master_signals.paddr, master_signals.pwdata);
    end
  end

  always_ff @(posedge pclk or negedge preset_n) begin
    if (!preset_n) begin
      slave_signals.prdata <= 32'b0;
    end else if (master_signals.psel && master_signals.penable && !master_signals.pwrite && 
                 (master_signals.paddr == SLAVE_ADDR)) begin
      slave_signals.prdata <= register;
      $display("Slave: Read operation. Address: 0x%08h, Data: 0x%08h", master_signals.paddr, register);
    end
  end

endmodule
