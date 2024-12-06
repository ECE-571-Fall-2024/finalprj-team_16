//INTERFACE ADDED

interface apb_interface(
  input logic pclk,           // Clock signal
  input logic preset_n        // Active low reset signal
);
  // Declare the APB control signals
  
  logic psel;                 // Select signal
  logic penable;              // Enable signal
  logic pwrite;               // Write control signal
  logic [31:0] paddr;         // Address bus
  logic [31:0] pwdata;        // Write data bus
  logic [31:0] prdata;        // Read data bus
  logic pready;               // Ready signal

  // Use packed struct to define the APB signals for convenience
  apb_pkg::apb_signals_t apb_signals;

  // Update the signals in the interface
  always_ff @(posedge pclk or negedge preset_n) begin
    if (!preset_n) begin
      apb_signals.psel   <= 1'b0;
      apb_signals.penable <= 1'b0;
      apb_signals.pwrite  <= 1'b0;
      apb_signals.paddr   <= 32'h0;
      apb_signals.pwdata  <= 32'h0;
      apb_signals.prdata  <= 32'h0;
      apb_signals.pready  <= 1'b0;
    end else begin
      apb_signals.psel    <= psel;
      apb_signals.penable <= penable;
      apb_signals.pwrite  <= pwrite;
      apb_signals.paddr   <= paddr;
      apb_signals.pwdata  <= pwdata;
      apb_signals.prdata  <= prdata;
      apb_signals.pready  <= pready;
    end
  end

endinterface

