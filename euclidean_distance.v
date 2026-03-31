module euclidean_distance #(

    parameter EIGEN_FACES=20,
              ACC_WIDTH=10+16+$clog2(4096),
              EUC_DISTANCE_WIDTH= 17 + $clog2(EIGEN_FACES),
              USER_FACES=20

)
(
    input clk , reset,
    input signed [(EIGEN_FACES*ACC_WIDTH)-1:0] acc, //flattened current image weights
    input signed  [(EIGEN_FACES*16)-1:0] current_face_weights , //the current one face weights will be given , will be changed 20 times
    input mac_ready,
    output reg [EUC_DISTANCE_WIDTH-1:0] eucd //the output flattened distance

);

wire signed [ACC_WIDTH-1:0] acc_reg[EIGEN_FACES-1:0];  //for capturing the deflattened array of the mac outputs
reg signed [15:0] acc_reg_16b[EIGEN_FACES-1 :0];
reg [$clog2(USER_FACES)-1:0] face_ctr;
wire signed [15:0] current_face_weights_wire [EIGEN_FACES-1 : 0] ; // need to deflatten the weights array
reg signed [EUC_DISTANCE_WIDTH -1:0] euc_dist_reg [USER_FACES-1 : 0]; // stores the eucledean distance wrt to each user
reg signed [EUC_DISTANCE_WIDTH -1:0] euc_dist_hold; //holds the euc dis of one user after the arithematics
wire signed [33 : 0] square [EIGEN_FACES-1:0]; // sqaures before truncating
wire signed [15 : 0] square_trunc_16b [EIGEN_FACES-1 :0]; //will store the truncated multiplied value
reg load, dist_done;
genvar g;
integer i,j;
generate
    for(g=0 ; g< EIGEN_FACES ; g=g+1) begin
        
     assign acc_reg[g] = acc[g*ACC_WIDTH+:ACC_WIDTH];  // deflattening the 1D to an 2D array
     assign current_face_weights_wire[g] = current_face_weights [g*16 +: 16]; //holds weights as an array
     assign square [g] = (current_face_weights_wire[g] - acc_reg_16b[g])
        
                                                     * (current_face_weights_wire[g] - acc_reg_16b[g]);
     assign square_trunc_16b[g] = square[g][33 : 18];
    
    end
endgenerate


always @ (*) begin

    euc_dist_hold =0;
    for(j=0 ; j < EIGEN_FACES ; j=j+1) begin


        euc_dist_hold = $signed(euc_dist_hold) + square_trunc_16b[j];  // does the sqaring and accumulation
        


    end
    


end
    
    


always@(posedge clk or posedge reset) begin
    
    if(reset) begin

        face_ctr <= 0; //counts which face
        load <=0;
        dist_done <= 0;
        

    end
    else if( face_ctr < USER_FACES) begin
        
   
        if(!load && mac_ready) begin //for loading them into a 16bit register 1 clcok cycle wasted ahahha
            for(i=0 ; i<EIGEN_FACES ; i=i+1) begin 

                acc_reg_16b[i] <= acc_reg [i][ACC_WIDTH-1 : ACC_WIDTH-16]; //truncating the acc into 16 bits FPGA friendly~

            end

            load <=1; // if load is 1 , truncating is done ready for calculating the distance
            

        end
        else if( mac_ready && !dist_done) begin

            eucd <= euc_dist_hold;
            face_ctr <= face_ctr +1;
            load <= 0;

        end
    end
    else begin
        
        dist_done <=1;
        
    end

end
endmodule