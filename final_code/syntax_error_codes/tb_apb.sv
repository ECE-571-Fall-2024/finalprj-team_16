module tb_apb;

  logic pclk, preset_n;
  logic [1:0] add_i;
  logic [31:0] external_wdata_i;
  logic ready_o;
  logic [31:0] rdata_o;

  apb_top uut (
    .pclk(pclk),
    .preset_n(preset_n),
    .add_i(add_i),
    .external_wdata_i(external_wdata_i),
    .ready_o(ready_o),
    .rdata_o(rdata_o)
  );

  always #10 pclk = ~pclk;

  task reset_system();
    begin
      preset_n = 0;
      add_i = 2'b00;
      external_wdata_i = 32'h0;
      @(negedge pclk);
      preset_n = 1;
      @(negedge pclk);
    end
  endtask

  task perform_write(input logic [31:0] data);
    begin
      external_wdata_i = data;
      add_i = 2'b11;
      @(posedge pclk);
      wait (ready_o);
      @(posedge pclk);
      add_i = 2'b00;
    end
  endtask

  task perform_read();
    begin
      add_i = 2'b01;
      @(posedge pclk);
      wait (ready_o);
      @(posedge pclk);
      add_i = 2'b00;
    end
  endtask

  initial begin
    $dumpfile("tb_apb.vcd");
    $dumpvars(0, tb_apb);

    pclk = 0;
    reset_system();

    perform_write(32'hDEADBEEF);
    perform_read();
    $display("Data read from slave: 0x%08h", rdata_o);

    #100 $finish;
  end

endmodule

