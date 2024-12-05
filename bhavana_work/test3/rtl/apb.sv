module apb_master (
    input  logic        P_clk,
    input  logic        P_rst,
    input  logic [1:0]  add_i,
    output logic        P_selx,
    output logic        P_enable,
    output logic [31:0] P_addr,
    output logic        P_write,
    output logic [31:0] P_wdata,
    input  logic [31:0] P_rdata,
    input  logic        P_ready
);

    typedef enum logic [1:0] {
        ST_IDLE    = 2'b00,
        ST_SETUP   = 2'b01,
        ST_ACCESS  = 2'b10
    } state_t;

    state_t present_state, next_state;
    logic [31:0] debug_read_data; // Debugging register for read data
    logic [31:0] read_data;

    // State transition logic (synchronous)
    always_ff @(posedge P_clk or posedge P_rst) begin
        if (P_rst) begin
            present_state <= ST_IDLE;
            debug_read_data <= 32'b0;
        end else begin
            present_state <= next_state;
            //if (P_ready && !add_i[1]) // READ
            //    debug_read_data <= P_rdata;
        end
    end

    // State machine and output logic (combinatorial)
    always_comb begin
        // Default values
        next_state = present_state;
        P_selx = 0;
        P_enable = 0;
        P_write = 0;
        P_addr = 32'hA000;
        P_wdata = 32'b0;

        case (present_state)
            ST_IDLE: begin
                if (add_i != 2'b00) begin
                    next_state = ST_SETUP;
                    P_write = add_i[1];
                end
            end

            ST_SETUP: begin
                P_selx = 1;
                next_state = ST_ACCESS;
            end

            ST_ACCESS: begin
                P_selx = 1;
                P_enable = 1;
                if (P_ready) begin
                    if (!add_i[1])
			read_data = P_rdata;
		    next_state = ST_IDLE;
                end
            end
        endcase
    end

     // Debugging read data
    always_ff @(posedge P_clk or posedge P_rst) begin
        if (P_rst) begin
            read_data <= 32'b0;
        end
    end
endmodule

module apb_slave (
    input  wire        P_clk,
    input  wire        P_resetn,
    input  wire        P_selx,
    input  wire        P_enable,
    input  wire        P_write,
    input  wire [31:0] P_addr,
    input  wire [31:0] P_wdata,
    output reg  [31:0] P_rdata,
    output reg         P_ready
);

    // Internal memory for the slave (32 locations, 32 bits each)
    reg [31:0] mem [0:31];

    always_ff @(posedge P_clk or negedge P_resetn) begin
        if (!P_resetn) begin
            P_ready <= 0;
            P_rdata <= 32'b0;
        end else begin
            if (P_selx && P_enable) begin
                if (P_write) begin
                    // Write operation
                    mem[P_addr[4:0]] <= P_wdata;  // Store data in memory
                    P_ready <= 1;                // Indicate write complete
                end else begin
                    // Read operation
                    P_rdata <= mem[P_addr[4:0]];  // Retrieve data from memory
                    P_ready <= 1;                 // Indicate read complete
                end
            end else begin
                P_ready <= 0; // Deassert ready if no valid transaction
            end
        end
    end
endmodule

module apb_master_slave_top (
    input  logic        P_clk,       // Clock signal
    input  logic        P_rst,       // Reset signal
    input  logic [1:0]  add_i,       // Operation command to master
    output logic        P_ready,     // Ready signal from slave
    output logic [31:0] P_rdata      // Read data from slave
);

    // Internal signals
    logic        P_selx;     // Select signal
    logic        P_enable;   // Enable signal
    logic [31:0] P_addr;     // Address bus
    logic        P_write;    // Write control signal
    logic [31:0] P_wdata;    // Write data bus

    // Instantiate Master
    apb_master master_inst (
        .P_clk    (P_clk),
        .P_rst    (P_rst),
        .add_i    (add_i),
        .P_selx   (P_selx),
        .P_enable (P_enable),
        .P_addr   (P_addr),
        .P_write  (P_write),
        .P_wdata  (P_wdata),
        .P_rdata  (P_rdata),
        .P_ready  (P_ready)
    );

    // Instantiate Slave
    apb_slave slave_inst (
        .P_clk    (P_clk),
        .P_resetn (~P_rst),  // Active-low reset
        .P_selx   (P_selx),
        .P_enable (P_enable),
        .P_addr   (P_addr),
        .P_write  (P_write),
        .P_wdata  (P_wdata),
        .P_rdata  (P_rdata),
        .P_ready  (P_ready)
    );

endmodule

