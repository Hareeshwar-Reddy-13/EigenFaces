`timescale 1ns / 1ps
module euclidean_distance #(
    parameter EIGEN_FACES = 1,
              ACC_WIDTH = 38,
              EUC_DISTANCE_WIDTH = 37,
              USER_FACES = 2
)
(
    input clk, reset,
    input signed [(EIGEN_FACES*ACC_WIDTH)-1:0] acc,
    input signed [(USER_FACES*EIGEN_FACES*16)-1:0] user_db_weights,
    input mac_out_valid,

    output reg [15:0] best_match_id,
    output reg dist_done
);
    wire signed [ACC_WIDTH-1:0] acc_reg [EIGEN_FACES-1:0];
    reg signed [15:0] acc_reg_16b [EIGEN_FACES-1:0];
    wire signed [15:0] current_face_weights_wire [EIGEN_FACES-1:0];
    wire signed [31:0] square [EIGEN_FACES-1:0];

    reg [15:0] face_ctr;
    reg processing;

    genvar g;
    generate
        for(g=0; g < EIGEN_FACES; g=g+1) begin : math_logic
            assign acc_reg[g] = acc[g*ACC_WIDTH +: ACC_WIDTH];
            // Extract the correct 16-bit weight for the current face check
            assign current_face_weights_wire[g] = user_db_weights[(face_ctr*EIGEN_FACES*16) + (g*16) +: 16];
            assign square[g] = (current_face_weights_wire[g] - acc_reg_16b[g]) * (current_face_weights_wire[g] - acc_reg_16b[g]);
        end
    endgenerate

    reg [EUC_DISTANCE_WIDTH-1:0] comb_sum;
    integer j;
    always @(*) begin
        comb_sum = 0;
        for(j=0; j < EIGEN_FACES; j=j+1) begin
            comb_sum = comb_sum + square[j];
        end
    end

    reg [EUC_DISTANCE_WIDTH-1:0] min_dist;
    integer i;

    always @(posedge clk or posedge reset) begin
        if(reset) begin
            face_ctr <= 0;
            dist_done <= 0;
            processing <= 0;
            best_match_id <= 0;
            min_dist <= {EUC_DISTANCE_WIDTH{1'b1}}; // Init to max value
            for(i=0; i<EIGEN_FACES; i=i+1) acc_reg_16b[i] <= 0;
        end
        else if(mac_out_valid) begin
            for(i=0; i < EIGEN_FACES; i=i+1) begin
                acc_reg_16b[i] <= acc_reg[i][ACC_WIDTH-1 : ACC_WIDTH-16];
            end
            processing <= 1;
            face_ctr <= 0;
            dist_done <= 0;
            min_dist <= {EUC_DISTANCE_WIDTH{1'b1}};
        end
        else if(processing) begin
            // Track the minimum distance
            if (comb_sum < min_dist) begin
                min_dist <= comb_sum;
                best_match_id <= face_ctr;
            end

            if (face_ctr == USER_FACES - 1) begin
                processing <= 0;
                dist_done <= 1; // Output valid
            end else begin
                face_ctr <= face_ctr + 1;
            end
        end
        else begin
            dist_done <= 0;
        end
    end
endmodule
