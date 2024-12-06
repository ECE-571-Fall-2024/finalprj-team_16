
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

  localparam logic [31:0] SLAVE_ADDR = 32'h0000_a000; // Example slave base address
endpackage
