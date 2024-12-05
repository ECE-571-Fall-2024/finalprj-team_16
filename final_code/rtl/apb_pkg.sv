package apb_pkg;

  // APB State Definitions
  typedef enum logic [1:0] {
    ST_IDLE,   // Idle state
    ST_SETUP,  // Setup state
    ST_ACCESS  // Access state
  } apb_state_t;

  // APB Signal Struct
  typedef struct packed {
    logic psel;        // Select signal
    logic penable;     // Enable signal
    logic pwrite;      // Write control signal
    logic [31:0] paddr; // Address bus
    logic [31:0] pwdata; // Write data bus
    logic [31:0] prdata; // Read data bus
    logic pready;      // Ready signal
  } apb_signals_t;

  // Slave Address Definition
  localparam logic [31:0] SLAVE_ADDR = 32'hA000;

endpackage

