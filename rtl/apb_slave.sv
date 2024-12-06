module apb_add_slave (
  input apb_interface apb_if  // Pass the entire interface
);

  logic [31:0] register;
  localparam logic [31:0] SLAVE_ADDR = 32'hA000;

  assign apb_if.pready = apb_if.psel && apb_if.penable;

  always_ff @(posedge apb_if.pclk or negedge apb_if.preset_n) begin
    if (!apb_if.preset_n) begin
      register <= 32'b0;
    end else if (apb_if.psel && apb_if.penable && apb_if.pwrite && (apb_if.paddr == SLAVE_ADDR)) begin
      register <= apb_if.pwdata;
      $display("Slave: Write operation. Address: 0x%08h, Data: 0x%08h", apb_if.paddr, apb_if.pwdata);
    end
  end

  always_ff @(posedge apb_if.pclk or negedge apb_if.preset_n) begin
    if (!apb_if.preset_n) begin
      apb_if.prdata <= 32'b0;
    end else if (apb_if.psel && apb_if.penable && !apb_if.pwrite && (apb_if.paddr == SLAVE_ADDR)) begin
      apb_if.prdata <= register;
      $display("Slave: Read operation. Address: 0x%08h, Data: 0x%08h", apb_if.paddr, register);
    end
  end

endmodule

