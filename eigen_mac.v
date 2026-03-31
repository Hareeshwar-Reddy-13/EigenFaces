module eigen_mac#(
  
      parameter PARALLEL_MACS=16,
                ACC_WIDTH=10+16+$clog2(4096),
                EIGEN_FACES=20

)
(
    input clk,reset,
    input signed [(PARALLEL_MACS*10)-1:0] centred_pixels ,
    input signed [(PARALLEL_MACS*16)-1:0] weights ,
    //input sub_ready, -> no need continuous pipeline
    output signed [(EIGEN_FACES*ACC_WIDTH)-1:0] acc,
    output reg   mac_ready
);
wire signed [25:0] parallel_products[PARALLEL_MACS-1:0]; //holds centred pixels * weights product doesnt yet stores the sum
reg signed [ACC_WIDTH-1:0] sops; //holds the sum of the parallel multipliers
reg signed [ACC_WIDTH-1:0] acc_reg[EIGEN_FACES-1:0]; //one accumulator for one eigen face
reg [8:0] acc_counter; // counts which iteration of input is going on , 4096/16=256
reg [$clog2(EIGEN_FACES):0] acc_idx; //accumulator index

//------EDGE DECTECTION LOGIC--------//

/*reg sub_ready_d1;

always @(posedge clk) begin
    sub_ready_d1 <= sub_ready;
end

wire sub_ready_edge = sub_ready && !sub_ready_d1; 
*/
/*WHY DO WE NEED THIS??
[(EIGEN_FACES*16)-1:0]
if sub_ready=high and the clock edge arrives it increments acc_count , we need to consider the input 
only when sub_ready goes from low to high , only at that instant. So it accepts input only once
and increments once , or else if we latch it up we will get the ssame input multiple times

*/

genvar g,k;
integer i,j;

generate
    for(g=0;g<PARALLEL_MACS;g=g+1) begin
       assign parallel_products[g] =$signed(centred_pixels[g*10+:10]) * $signed(weights[g*16+:16]); //16 parallel multipliers
       
    end
    for(k=0 ; k < EIGEN_FACES ; k=k+1) begin
        assign acc[k*ACC_WIDTH +: ACC_WIDTH] = acc_reg[k]; //flattening the 2D accumalators to one 1D acc output
    end
endgenerate

always @(*) begin

    sops=0;

    for(j=0;j<PARALLEL_MACS;j=j+1) begin
        sops = sops + parallel_products[j];  //adders in series , very long but will optimise it later
    end
end


always@(posedge clk or posedge reset) begin

    if(reset) begin   //reset controls th10+16+$clog2(4096),e flag (mac_ready) which will act as an flag for the mac

        mac_ready <= 0;
        acc_counter <= 0;
        acc_idx <=0;
        for(i=0;i<EIGEN_FACES;i=i+1) begin
            acc_reg[i] <= 0;
        end
        
    end
    else if( acc_idx < EIGEN_FACES) begin
    
     if(/*sub_ready_edge*/  !mac_ready) begin   //sub_ready_edge is edged not latched , input gets accpeted only once

             if(acc_counter == 4096/PARALLEL_MACS -1) begin  //when acc_counter == 255 one eigen faces has been completed
                acc_reg[acc_idx] <= acc_reg[acc_idx] + sops; // adding the last 16 multiplications
                acc_idx <= acc_idx + 1;
                acc_counter <=0; //should start from zero for the next eigen face
            end

             else if(acc_counter < 4096/PARALLEL_MACS) begin

                acc_reg[acc_idx] <= $signed(acc_reg[acc_idx]) + $signed(sops); //acc loops and adds the sops continuosly
                acc_counter <= acc_counter +1;
            
            end
            
        end
    end

    else if(acc_idx == EIGEN_FACES) begin
            mac_ready <=1;
            
        end
            


    end

endmodule