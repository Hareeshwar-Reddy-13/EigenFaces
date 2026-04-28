`timescale 1ns / 1ps

module eigen_subtract #(
    parameter PIXELS_PER_CYCLE = 16
)
(
    input clk, reset, in_valid,
    input [PIXELS_PER_CYCLE*8-1:0] pixels,
    input signed [PIXELS_PER_CYCLE*9-1:0] mean_pixels,
    output reg out_valid,
    output reg [(PIXELS_PER_CYCLE*10)-1:0] centred_pixels
);
    wire signed [9:0] difference [PIXELS_PER_CYCLE-1:0];

    genvar g;
    generate
        for(g=0; g < PIXELS_PER_CYCLE; g=g+1) begin : sub_logic
            assign difference[g] = $signed({2'b0, pixels[g*8 +: 8]}) - $signed(mean_pixels[g*9 +: 9]);
        end
    endgenerate

    integer i;
    always @ (posedge clk or posedge reset) begin
        if(reset) begin
            centred_pixels <= 0;
            out_valid <= 0;
        end
        else if(in_valid) begin
            for(i= 0; i < PIXELS_PER_CYCLE; i = i+1) begin
                centred_pixels[i*10 +: 10] <= difference[i];
            end
            out_valid <= 1;
        end
        else begin
            out_valid <= 0;
        end
    end
endmodule
