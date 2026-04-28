
`timescale 1ns / 1ps

module eigen_top #(
    parameter PIXELS = 4096,
              PARALLEL_MACS = 16,
              EIGEN_FACES = 1,
              ACC_WIDTH = 38,
              USER_FACES = 2,
              EUC_DISTANCE_WIDTH = 37
)
(
    input clk, reset, stream_valid,

    // Streaming Ports (Feed 16 elements per cycle)
    input [PARALLEL_MACS*8-1:0] stream_pixels,
    input signed [PARALLEL_MACS*9-1:0] stream_mean,
    input signed [PARALLEL_MACS*16-1:0] stream_eigen_weight,

    // Static Profile Database (The pre-calculated faces you want to check against)
    input signed [(USER_FACES*EIGEN_FACES*16)-1:0] user_db_weights,

    // Result
    output [15 :0] user_id,
    output done
);

    wire sub_out_valid;
    wire [(PARALLEL_MACS*10)-1:0] submod_op_centred_pixels;

    // Subtractor
    eigen_subtract #(.PIXELS_PER_CYCLE(PARALLEL_MACS)) subtract_inst (
        .clk(clk), .reset(reset), .in_valid(stream_valid),
        .pixels(stream_pixels), .mean_pixels(stream_mean),
        .out_valid(sub_out_valid), .centred_pixels(submod_op_centred_pixels)
    );

    // Delay the weights by 1 cycle to match the subtractor's latency
    reg signed [PARALLEL_MACS*16-1:0] delayed_eigen_weight;
    always @(posedge clk or posedge reset) begin
        if(reset) delayed_eigen_weight <= 0;
        else if(stream_valid) delayed_eigen_weight <= stream_eigen_weight;
    end

    wire mac_out_valid;
    wire signed [(EIGEN_FACES*ACC_WIDTH)-1:0] macmod_op_acc;

    // MAC Unit
    eigen_mac #(.PARALLEL_MACS(PARALLEL_MACS), .ACC_WIDTH(ACC_WIDTH), .EIGEN_FACES(EIGEN_FACES)) mac_inst (
        .clk(clk), .reset(reset), .in_valid(sub_out_valid),
        .centred_pixels(submod_op_centred_pixels),
        .weights(delayed_eigen_weight),
        .acc(macmod_op_acc), .out_valid(mac_out_valid)
    );

    // Euclidean Distance
    euclidean_distance #(
        .ACC_WIDTH(ACC_WIDTH),
        .EUC_DISTANCE_WIDTH(EUC_DISTANCE_WIDTH),
        .USER_FACES(USER_FACES),
        .EIGEN_FACES(EIGEN_FACES)
    ) eucd_inst (
        .clk(clk), .reset(reset), .acc(macmod_op_acc),
        .user_db_weights(user_db_weights),
        .mac_out_valid(mac_out_valid),
        .best_match_id(user_id), .dist_done(done)
    );

endmodule
