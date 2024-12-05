interface apb_if;

  // Struct for APB signals
  typedef struct {
    logic psel;
    logic penable;
    logic pwrite;
    logic [31:0] paddr;
    logic [31:0] pwdata;
    logic [31:0] prdata;
    logic pready;
  } apb_signals_t;

  // Master and slave signal groups
  apb_signals_t master_signals;
  apb_signals_t slave_signals;

endinterface

