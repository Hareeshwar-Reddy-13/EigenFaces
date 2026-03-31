module eigen_mac#(
  
      parameter PARALLEL_MACS=16,
                ACC_WIDTH=9+8+$clog2(4096),
                EIGEN_FACES=20

)
(
    input clk,reset,
    input signed [(PARALLEL_MACS*9)-1:0] centred_pixels ,
    input signed [(PARALLEL_MACS*9)-1:0] weights ,
    input sub_ready,
    output reg mac_free , mac_ready
);
wire [17:0] parallel_products[PARALLEL_MACS-1:0]; //holds centred pixels * weights product doesnt yet stores the sum
reg [ACC_WIDTH-1:0] sops; //holds the sum of the parallel multipliers
reg signed [ACC_WIDTH-1:0] acc[EIGEN_FACES-1:0]; //one accumulator for one eigen face
reg [7:0] acc_counter; // counts which iteration of input is going on , 4096/16=256
reg [$clog2(EIGEN_FACES)+1:0] acc_idx; //accumulator index
genvar g;
integer i,j;

generate
    for(g=0;g<PARALLEL_MACS;g=g+1) begin
       assign parallel_products[g] =$signed(centred_pixels[g*9+:9]) * $signed(weights[g*9+:9]); //16 parallel multipliers
       
            mac_free<=0;

            if(acc_counter < 256) begin

    end
endgenerate

always @(*) begin

    for(j=0;j<PARALLEL_MACS;j=j+1) begin
        sops = sops + parallel_products[j];  //adders in series , very long but will optimise it later
    end
end

always@(posedge clk or posedge reset) begin

    if(reset) begin
        for(i=0;i<EIGEN_FACES;i=i+1) begin
            acc[i] <= 0;
            mac_free <= 1;
            acc_counter <= 0;
            acc_idx <=0;
            mac_ready <= 0;

        end
    end
    else if(sub_ready && mac_free) begin
            mac_free<=0;

            if(acc_counter < 256) begin

        if(acc_idx < EIGEN_FACES) begin

            mac_free<=0;

            if(acc_counter < 256) begin

                acc[acc_idx] <= $signed(acc[acc_idx]) + $signed(sops);
            
            end
            else if(acc_counter == 256) begin
                acc_idx <= acc_idx + 1;
            end
        end

        else if(acc_idx == EIGEN_FACES) begin
            mac_ready <=1;
        end
            


    end
end
endmodule