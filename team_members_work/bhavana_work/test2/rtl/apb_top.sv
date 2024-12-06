module apb_master_slave_top (
  input  logic         pclk,
  input  logic         preset_n,
  input  logic [1:0]   add_i,       // Operation command to master
  output logic         ready_o,     // Ready signal from slave
  output logic [31:0]  rdata_o      // Read data from slave
);

  // Internal signals for master-slave connection
  logic        psel;       // Select signal
  logic        penable;    // Enable signal
  logic [31:0] paddr;      // Address bus
  logic        pwrite;     // Write control signal
  logic [31:0] pwdata;     // Write data bus
  logic [31:0] prdata;     // Read data bus
  logic        pready;     // Ready signal

  // Instantiate the APB Master
  apb_add_master u_master (
    .pclk       (pclk),
    .preset_n   (preset_n),
    .add_i      (add_i),
    .psel_o     (psel),
    .penable_o  (penable),
    .paddr_o    (paddr),
    .pwrite_o   (pwrite),
    .pwdata_o   (pwdata),
    .prdata_i   (prdata),
    .pready_i   (pready)
  );

  // Instantiate the APB Slave
  apb_add_slave u_slave (
    .pclk       (pclk),
    .preset_n   (preset_n),
    .psel_i     (psel),
    .penable_i  (penable),
    .paddr_i    (paddr),
    .pwrite_i   (pwrite),
    .pwdata_i   (pwdata),
    .prdata_o   (prdata),
    .pready_o   (pready)
  );

  // Connect output signals for monitoring
  assign ready_o = pready;
  assign rdata_o = prdata;

endmodule

