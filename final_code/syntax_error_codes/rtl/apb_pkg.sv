package apb_pkg;
  typedef struct packed {
    logic psel, penable, pwrite;
    logic [31:0] paddr, pwdata, prdata;
    logic pready;
  } apb_signals_t;
endpackage

