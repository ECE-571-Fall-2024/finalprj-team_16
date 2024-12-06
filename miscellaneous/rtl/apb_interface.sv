`include "apb_pkg.sv"

interface apb_interface(
  input logic pclk,
  input logic preset_n
);
  import apb_pkg::*;
  
  apb_signals_t signals;

endinterface

