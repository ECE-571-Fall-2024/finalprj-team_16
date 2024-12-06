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
<<<<<<< HEAD
  // Define the slave address for example
=======

>>>>>>> 99639af3eea546cdca21f90d85c710362b87ba1a
  localparam logic [31:0] SLAVE_ADDR = 32'hA000;
endpackage
