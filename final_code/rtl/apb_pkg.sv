// apb_pkg.sv
package apb_pkg;
  typedef struct packed {
    logic psel;
    logic penable;
    logic pwrite;
    logic [31:0] paddr;
    logic [31:0] pwdata;
    logic [31:0] prdata;
    logic pready;
  } apb_interface_struct_t;
  // Define the slave address for example
  localparam logic [31:0] SLAVE_ADDR = 32'hA000;
endpackage
