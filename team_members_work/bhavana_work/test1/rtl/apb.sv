module apb(
    input logic P_clk,          // Use logic instead of reg
    input logic P_rst,          // Use logic instead of reg
    input logic [31:0] P_addr, // Use logic for the address
    input logic P_selx,         // Use logic for select line
    input logic P_enable,       // Use logic for enable signal
    input logic P_write,        // Use logic for write signal
    input logic [31:0] P_wdata, // Use logic for write data
    output logic P_ready,       // Use logic for ready signal
    output logic P_slverr,      // Use logic for slave error signal
    output logic [31:0] P_rdata // Use logic for read data
);

    // Memory declaration (no change needed)
    logic [31:0] mem[31:0];

    // State declaration (parameterized)
    typedef enum logic [1:0] {
        idle    = 2'b00,
        setup   = 2'b01,
        access  = 2'b10
    } state_t;

    state_t present_state, next_state;

    // State transition logic (synchronous)
    always_ff @(posedge P_clk or posedge P_rst) begin
        if (P_rst)
            present_state <= idle;
        else
            present_state <= next_state;
    end

    // State machine and output logic (combinatorial)
    always_comb begin
        next_state = present_state; // Default to the current state
        P_ready = 0;                // Default to ready being 0
        P_slverr = 0;               // Default to no error
        P_rdata = 32'b0;            // Default to zero read data

        case (present_state)
            idle: begin
                if (P_selx && !P_enable)
                    next_state = setup;
            end

            setup: begin
                if (!P_enable || !P_selx)
                    next_state = idle;
                else begin
                    next_state = access;
                    if (P_write) begin
                        mem[P_addr] = P_wdata;
                        P_ready = 1;
                    end else begin
                        P_rdata = mem[P_addr];
                        P_ready = 1;
                    end
                end
            end

            access: begin
                if (!P_enable || !P_selx) begin
                    next_state = idle;
                    P_ready = 0;
                end
            end
        endcase
    end

endmodule

