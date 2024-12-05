module apb_add_slave (
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

endmodule

