module sink (
   input wire clk,
   input wire rst,
   input rready,
   input [10:0] in,
   
   output reg read,
   output reg [10:0] value
);

   always_ff @(posedge clk or posedge rst) begin
      if(rst) begin
         read <= 0;
         value <= 0;
      end
      else begin
         if(read)
            read <= 0;
         else if(rready) begin
            read <= 1;
            value <= in;
         end
      end
   end
endmodule
