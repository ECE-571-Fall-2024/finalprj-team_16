pb_slave (
  apb_interface.slave apb_intf // Use the slave modport of the interface
);

  // Internal register to store data
  logic [31:0] register;
  localparam logic [31:0] SLAVE_ADDR = 32'hA000;

  // Assign the `pready` signal based on `psel` and `penable`
  assign apb_intf.pready = apb_intf.psel && apb_intf.penable;

  // Write operation: Update register when `pwrite` is asserted
  always_ff @(posedge apb_intf.pclk or negedge apb_intf.preset_n) begin
    if (!apb_intf.preset_n) begin
      register <= 32'b0;
    end else if (apb_intf.psel && apb_intf.penable && apb_intf.pwrite && (apb_intf.paddr == SLAVE_ADDR)) begin
      register <= apb_intf.pwdata;
      $display("Slave: Write operation. Address: 0x%08h, Data: 0x%08h", apb_intf.paddr, apb_intf.pwdata);
    end
  end

  // Read operation: Drive `prdata` when `pwrite` is de-asserted
  always_ff @(posedge apb_intf.pclk or negedge apb_intf.preset_n) begin
    if (!apb_intf.preset_n) begin
      apb_intf.prdata <= 32'b0;
    end else if (apb_intf.psel && apb_intf.penable && !apb_intf.pwrite && (apb_intf.paddr == SLAVE_ADDR)) begin
      apb_intf.prdata <= register;
      $display("Slave: Read operation. Address: 0x%08h, Data: 0x%08h", apb_intf.paddr, register);
    end
  end

endmodule

