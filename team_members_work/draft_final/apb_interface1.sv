nterface apb_interface(
  input logic pclk,
  input logic preset_n
);
  logic psel, penable, pwrite;
  logic [31:0] paddr, pwdata, prdata;
  logic pready;

  modport master (
    output psel, penable, pwrite, paddr, pwdata,
    input  prdata, pready
  );

  modport slave (
    input  psel, penable, pwrite, paddr, pwdata,
    output prdata, pready
  );
endinterface

