//SLAVE MODULE
`include "apb_interface.sv"
module apb_slave (
   apb_interface apb_intf          // Accept the interface as input
);

  logic [31:0] register;
  localparam logic [31:0] SLAVE_ADDR = 32'hA000;

  assign apb_intf.apb_signals.pready = apb_intf.apb_signals.psel && apb_intf.apb_signals.penable;

  always_ff @(posedge apb_intf.pclk or negedge apb_intf.preset_n) begin
    if (!apb_intf.preset_n) begin
      register <= 32'b0;
     else if (apb_intf.apb_signals.psel && apb_intf.apb_signals.penable && apb_intf.apb_signals.pwrite && (apb_intf.apb_signals.paddr == SLAVE_ADDR)) begin
      register <= apb_intf.apb_signals.pwdata;
      $display("Slave: Write operation. Address: 0x%08h, Data: 0x%08h", apb_intf.apb_signals.paddr, apb_intf.apb_signals.pwdata);
    
  

  always_ff @(posedge apb_intf.pclk or negedge apb_intf.preset_n) begin
    if (!apb_intf.preset_n) begin
      apb_intf.apb_signals.prdata <= 32'b0;
     else if (apb_intf.apb_signals.psel && apb_intf.apb_signals.penable && !apb_intf.apb_signals.pwrite && (apb_intf.apb_signals.paddr == SLAVE_ADDR)) begin
      apb_intf.apb_signals.prdata <= register;
      $display("Slave: Read operation. Address: 0x%08h, Data: 0x%08h", apb_intf.apb_signals.paddr, register);
    
  

endmodule


