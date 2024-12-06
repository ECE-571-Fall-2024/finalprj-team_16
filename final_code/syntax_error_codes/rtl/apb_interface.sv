interface apb_interface(
  input logic pclk,
  input logic preset_n
);
  logic psel, penable, pwrite;
  logic [31:0] paddr, pwdata, prdata;
  logic pready;

  modport master (
    input pclk, preset_n, pready, prdata,
    output psel, penable, pwrite, paddr, pwdata
  );

  modport slave (
    input pclk, preset_n, psel, penable, pwrite, paddr, pwdata,
    output pready, prdata
  );
endinterface

