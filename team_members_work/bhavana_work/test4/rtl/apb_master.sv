module apb_add_master (
  input logic pclk,
  input logic preset_n,   // Active low reset
 
  input logic [1:0] add_i,     // 2'b00 - NOP, 2'b01 - READ, 2'b11 - WRITE
  
  output logic psel_o,
  output logic penable_o,
  output logic [31:0] paddr_o,
  output logic pwrite_o,
  output logic [31:0] pwdata_o,
  input  logic [31:0] prdata_i,
  input  logic pready_i
);
  
  typedef enum logic[1:0] {ST_IDLE, ST_SETUP, ST_ACCESS} apb_state_t;
  
  apb_state_t state_q;      // Current state
  apb_state_t nxt_state;    // Next state
  
  logic nxt_pwrite;
  logic pwrite_q;
  
  logic [31:0] nxt_rdata;
  logic [31:0] rdata_q;

  // State transition logic
  always_ff @(posedge pclk or negedge preset_n) begin
    if (~preset_n)
      state_q <= ST_IDLE;
    else
      state_q <= nxt_state;
  end
  
  // Next state logic
  always_comb begin
    nxt_pwrite = pwrite_q;
    nxt_rdata = rdata_q;
    case (state_q)
      ST_IDLE: begin
        if (add_i[0]) begin
          nxt_state = ST_SETUP;
          nxt_pwrite = add_i[1];
        end else begin
          nxt_state = ST_IDLE;
        end
      end
      ST_SETUP: nxt_state = ST_ACCESS; // Transition to ACCESS after setup
      ST_ACCESS: begin
        if (pready_i && ~pwrite_q) begin
          if (~pwrite_q)
            nxt_rdata = prdata_i; // Capture read data
          nxt_state = ST_IDLE; // Return to IDLE after transaction
        end else begin
          nxt_state = ST_ACCESS; // Stay in ACCESS until ready
        end
      end
      default: nxt_state = ST_IDLE;
    endcase
  end

  // Output logic for APB signals
  assign psel_o = (state_q == ST_SETUP) || (state_q == ST_ACCESS);
  assign penable_o = (state_q == ST_ACCESS); // Enable asserted only in ACCESS phase
  assign paddr_o = (state_q != ST_IDLE) ? 32'hA000 : 32'h0; // Address set during transaction
  assign pwrite_o = pwrite_q;
  assign pwdata_o = rdata_q + 32'h1; // Incremented data for WRITE operation

  // State data updates
  always_ff @(posedge pclk or negedge preset_n) begin
    if (~preset_n) begin
      pwrite_q <= 1'b0;
      rdata_q <= 32'h0;
    end else begin
      pwrite_q <= nxt_pwrite;
      rdata_q <= nxt_rdata;
    end
  end

endmodule

/*module apb_add_slave (
  input  logic         pclk,
  input  logic         preset_n,   // Active low reset

  input  logic         psel_i,     // Select signal from master
  input  logic         penable_i,  // Enable signal from master
  input  logic [31:0]  paddr_i,    // Address signal from master
  input  logic         pwrite_i,   // Write control signal from master
  input  logic [31:0]  pwdata_i,   // Write data from master
  
  output logic [31:0]  prdata_o,   // Read data to master
  output logic         pready_o    // Ready signal to master
);

  // Internal registers
  logic [31:0] register;  // Single internal register for simplicity

  // Address map for slave (use 0xA000 for the register)
  localparam logic [31:0] SLAVE_ADDR = 32'hA000;

  // Ready signal generation
  always_ff @(posedge pclk or negedge preset_n) begin
    if (~preset_n) 
      pready_o <= 1'b0;
    else if (psel_i && penable_i)
      pready_o <= 1'b1;  // Ready when select and enable are asserted
    else
      pready_o <= 1'b0;  // Otherwise, not ready
  end

  // Register read/write logic
  always_ff @(posedge pclk or negedge preset_n) begin
    if (~preset_n) begin
      register <= 32'b0;  // Reset internal register
    end else if (psel_i && penable_i) begin
      if (pwrite_i && (paddr_i == SLAVE_ADDR)) begin
        register <= pwdata_i;  // Write operation
      end
    end
  end

  // Read operation
  always_comb begin
    if (psel_i && ~pwrite_i && (paddr_i == SLAVE_ADDR)) begin
      prdata_o = register;  // Send register value to master
    end else begin
      prdata_o = 32'b0;  // Default read data
    end
  end

endmodule */

