// Interface definition
interface apb_interface(
  input logic pclk,
  input logic preset_n,
  output logic psel,
  output logic penable,
  output logic pwrite,
  output logic [31:0] paddr,
  output logic [31:0] pwdata,
  input logic [31:0] prdata,
  input logic pready
);
endinterface
