module eigen_subtract # (

    parameter PIXELS_PER_CYCLE = 16
)

(
    input clk,reset,
    input [127:0] pixels,
    input signed  [143:0] mean_pixels,
   
    output reg [159:0] centred_pixels //10 bits wide , as mean is 9 bits and pixels are 8 , subtraction increases 1 bit
    //output reg sub_ready //flag will go up when the subtraction has been done after new input
);

wire signed [9:0] difference[PIXELS_PER_CYCLE-1:0];

genvar g;
integer i;
generate
    for(g=0 ; g<PIXELS_PER_CYCLE ; g=g+1) begin
        
        assign difference[g] = $signed({2'b00,pixels[g*8+:8]})- $signed(mean_pixels[g*9+:9]);

    end
endgenerate

always @ (posedge clk or posedge reset) begin

    if(reset)begin
        
            centred_pixels <= 0;
        
    end
    else begin
        for(i= 0 ; i < PIXELS_PER_CYCLE ; i = i+1) begin
            centred_pixels[i*10+:10] <= difference[i];
        end
        
        
    end
end
endmodule
