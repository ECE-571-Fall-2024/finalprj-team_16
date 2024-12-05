module apb_slave (
  input logic pclk,
  input logic preset_n,
  apb_if apb_if // Interface port
);

  logic [31:0] register;

  always_ff @(posedge pclk or negedge preset_n) begin
    if (!preset_n) begin
      register <= 32'b0;
    end else if (apb_if.master_signals.psel && apb_if.master_signals.penable &&
                 apb_if.master_signals.pwrite &&
                 (apb_if.master_signals.paddr == 32'hA000)) begin
      register <= apb_if.master_signals.pwdata;
      $display("Slave: Write operation. Address: 0x%08h, Data: 0x%08h", apb_if.master_signals.paddr, apb_if.master_signals.pwdata);
    end
  end

  always_ff @(posedge pclk or negedge preset_n) begin
    if (!preset_n) begin
      apb_if.slave_signals.prdata <= 32'b0;
    end else if (apb_if.master_signals.psel && apb_if.master_signals.penable &&
                 !apb_if.master_signals.pwrite &&
                 (apb_if.master_signals.paddr == 32'hA000)) begin
      apb_if.slave_signals.prdata <= register;
      $display("Slave: Read operation. Address: 0x%08h, Data: 0x%08h", apb_if.master_signals.paddr, register);
    end
  end

  assign apb_if.slave_signals.pready = apb_if.master_signals.psel && apb_if.master_signals.penable;

endmodule

