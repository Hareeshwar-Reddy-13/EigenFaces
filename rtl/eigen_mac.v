`timescale 1ns / 1ps

module eigen_mac#(
      parameter PARALLEL_MACS = 16,
                ACC_WIDTH = 38,
                EIGEN_FACES = 1
)
(
    input clk, reset, in_valid,
    input signed [(PARALLEL_MACS*10)-1:0] centred_pixels,
    input signed [(PARALLEL_MACS*16)-1:0] weights,
    output signed [(EIGEN_FACES*ACC_WIDTH)-1:0] acc,
    output reg out_valid
);
    wire signed [25:0] parallel_products [PARALLEL_MACS-1:0];
    reg signed [ACC_WIDTH-1:0] sops;
    reg signed [ACC_WIDTH-1:0] acc_reg [EIGEN_FACES-1:0];

    reg [11:0] acc_counter;
    reg [15:0] acc_idx;

    genvar g, k;
    generate
        for(g=0; g<PARALLEL_MACS; g=g+1) begin : mult_gen
           assign parallel_products[g] = $signed(centred_pixels[g*10+:10]) * $signed(weights[g*16+:16]);
        end
        for(k=0; k < EIGEN_FACES; k=k+1) begin : flatten_gen
            assign acc[k*ACC_WIDTH +: ACC_WIDTH] = acc_reg[k];
        end
    endgenerate

    integer j;
    always @(*) begin
        sops = 0;
        for(j=0; j<PARALLEL_MACS; j=j+1) begin
            sops = sops + parallel_products[j];
        end
    end

    integer i;
    always @(posedge clk or posedge reset) begin
        if(reset) begin
            out_valid <= 0;
            acc_counter <= 0;
            acc_idx <= 0;
            for(i=0; i<EIGEN_FACES; i=i+1) acc_reg[i] <= 0;
        end
        else if(in_valid) begin
            if(acc_counter == 0) begin
                acc_reg[acc_idx] <= sops; // First cycle overwrite
            end else begin
                acc_reg[acc_idx] <= acc_reg[acc_idx] + sops; // Accumulate
            end

            if(acc_counter == (4096/PARALLEL_MACS) - 1) begin
                acc_counter <= 0;
                if(acc_idx == EIGEN_FACES - 1) begin
                    out_valid <= 1; // All faces done
                    acc_idx <= 0;
                end else begin
                    acc_idx <= acc_idx + 1;
                    out_valid <= 0;
                end
            end
            else begin
                acc_counter <= acc_counter + 1;
                out_valid <= 0;
            end
        end
        else begin
            out_valid <= 0;
        end
    end
endmodule
