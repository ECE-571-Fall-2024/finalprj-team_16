//Simple 4bit Linear regression module
//Venkatesh Patil
//Takes input X, with weighted coeff of w and Bias b
// Y = wX + b 

module lrm(X, w, b, clk, rst, Y);
    input [3:0] X;
    input [3:0] w;
    input [3:0] b;
    input clk, rst;
    output [3:0] Y;
    reg [3:0] Y;
    reg [3:0] dot;
    integer i;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            Y <= 4'b0000;
            dot <= 4'b0000;
        end else begin
            for (i = 0; i < 4; i = i + 1) begin
                dot[i] <= dot[i] + X[i] * w[i];
            end
            Y <= dot + b;
        end
    end
endmodule   

