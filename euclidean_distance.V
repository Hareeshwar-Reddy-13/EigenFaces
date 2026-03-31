module euclidean_distance #(

    parameter EIGEN_FACES=20,
              ACC_WIDTH=10+16+$clog2(4096),
              EUC_DISTANCE_WIDTH= 16 + $clog2(EIGEN_FACES),
              USER_FACES=20

)
(
    input signed [(EIGEN_FACES*ACC_WIDTH)-1:0] acc,
    input signed [15:0] current_face_weights [EIGEN_FACES-1:0],
    input mac_ready,
    output reg [EUC_DISTANCE_WIDTH-1:0] eucd

);

  


endmodule