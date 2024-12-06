<<<<<<< HEAD
interface apb_interface(
  input logic pclk,
  input logic preset_n
);
  logic psel, penable, pwrite;
  logic [31:0] paddr, pwdata, prdata;
  logic pready;
  logic [31:0] rdata_o;

endinterface
=======
`include "apb_pkg.sv"
>>>>>>> 99639af3eea546cdca21f90d85c710362b87ba1a

module apb_master_slave_top (
  input logic pclk,
  input logic preset_n,
  
  // Master inputs
  input logic [1:0] add_i, // 2'b00 - NOP, 2'b01 - READ, 2'b11 - WRITE
  input logic [31:0] external_wdata_i, // External write data
  
  // Outputs
  output logic ready_o,    // Slave ready signal
  output logic [31:0] rdata_o // Read data from slave
);

<<<<<<< HEAD
=======
  import apb_pkg::*;
  
>>>>>>> 99639af3eea546cdca21f90d85c710362b87ba1a
  // Declare APB interface
  apb_interface apb_intf(pclk, preset_n);

  // Instantiate the APB master
  apb_add_master u_master (
    .add_i(add_i),
    .external_wdata_i(external_wdata_i),
    .apb_intf(apb_intf)
  );

  // Instantiate the APB slave
  apb_add_slave u_slave (
    .apb_intf(apb_intf)
  );

  // Connect outputs
<<<<<<< HEAD
  assign ready_o = apb_intf.pready;
  assign rdata_o = apb_intf.prdata;
=======
  assign ready_o = apb_intf.signals.pready;
  assign rdata_o = apb_intf.signals.prdata;
>>>>>>> 99639af3eea546cdca21f90d85c710362b87ba1a

endmodule


module apb_add_master (
  input logic [1:0] add_i, // 2'b00 - NOP, 2'b01 - READ, 2'b11 - WRITE
  input logic [31:0] external_wdata_i,
  apb_interface apb_intf
);

  import apb_pkg::*;

  typedef enum logic[1:0] {ST_IDLE, ST_SETUP, ST_ACCESS} apb_state_t;
  
  apb_state_t state_q, nxt_state;
  logic nxt_pwrite, pwrite_q;
  logic [31:0] nxt_rdata, rdata_q;

  always_ff @(posedge apb_intf.pclk or negedge apb_intf.preset_n) begin
    if (!apb_intf.preset_n) begin
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
<<<<<<< HEAD
        if (apb_intf.pready) begin
          if (!pwrite_q) nxt_rdata = apb_intf.prdata;
=======
        if (apb_intf.signals.pready) begin
          if (!pwrite_q) nxt_rdata = apb_intf.signals.prdata;
>>>>>>> 99639af3eea546cdca21f90d85c710362b87ba1a
          nxt_state = ST_IDLE;
        end
      end
    endcase
  end

<<<<<<< HEAD
  assign apb_intf.psel = (state_q == ST_SETUP) || (state_q == ST_ACCESS);
  assign apb_intf.penable = (state_q == ST_ACCESS);
  assign apb_intf.paddr = (apb_intf.penable) ? 32'hA000 : 32'h0000;
  assign apb_intf.pwrite = pwrite_q;
  assign apb_intf.pwdata = external_wdata_i;
=======
  assign apb_intf.signals.psel = (state_q == ST_SETUP) || (state_q == ST_ACCESS);
  assign apb_intf.signals.penable = (state_q == ST_ACCESS);
  assign apb_intf.signals.paddr = (apb_intf.signals.penable) ? SLAVE_ADDR : 32'h0000;
  assign apb_intf.signals.pwrite = pwrite_q;
  assign apb_intf.signals.pwdata = external_wdata_i;
>>>>>>> 99639af3eea546cdca21f90d85c710362b87ba1a

endmodule


module apb_add_slave (
  apb_interface apb_intf
);

  import apb_pkg::*;

  logic [31:0] register;

<<<<<<< HEAD
  assign apb_intf.pready = apb_intf.psel && apb_intf.penable;
=======
  assign apb_intf.signals.pready = apb_intf.signals.psel && apb_intf.signals.penable;
>>>>>>> 99639af3eea546cdca21f90d85c710362b87ba1a

  always_ff @(posedge apb_intf.pclk or negedge apb_intf.preset_n) begin
    if (!apb_intf.preset_n) begin
      register <= 32'b0;
<<<<<<< HEAD
    end else if (apb_intf.psel && apb_intf.penable && apb_intf.pwrite && (apb_intf.paddr == SLAVE_ADDR)) begin
      register <= apb_intf.pwdata;
      $display("Slave: Write operation. Address: 0x%08h, Data: 0x%08h", apb_intf.paddr, apb_intf.pwdata);
=======
    end else if (apb_intf.signals.psel && apb_intf.signals.penable && apb_intf.signals.pwrite && (apb_intf.signals.paddr == SLAVE_ADDR)) begin
      register <= apb_intf.signals.pwdata;
      $display("Slave: Write operation. Address: 0x%08h, Data: 0x%08h", apb_intf.signals.paddr, apb_intf.signals.pwdata);
>>>>>>> 99639af3eea546cdca21f90d85c710362b87ba1a
    end
  end

  always_comb begin
<<<<<<< HEAD
    if (apb_intf.psel && apb_intf.penable && !apb_intf.pwrite && (apb_intf.paddr == SLAVE_ADDR)) begin
      apb_intf.prdata = register;
    end else begin
      apb_intf.prdata = 32'b0; // Ensure a default value when not in a valid read transaction
=======
    if (apb_intf.signals.psel && apb_intf.signals.penable && !apb_intf.signals.pwrite && (apb_intf.signals.paddr == SLAVE_ADDR)) begin
      apb_intf.signals.prdata = register;
    end else begin
      apb_intf.signals.prdata = 32'b0; // Default value
>>>>>>> 99639af3eea546cdca21f90d85c710362b87ba1a
    end
  end

endmodule

<<<<<<< HEAD



=======
>>>>>>> 99639af3eea546cdca21f90d85c710362b87ba1a
