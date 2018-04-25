module instream (
   input wire clk,
   input wire rst,
   input wready,
   input [5:0] length,
   input signed [10:0] data [0:63],
   
   output reg write,
   output reg [10:0] out
);

   reg [5:0] pos;

   always_ff @(posedge clk or posedge rst) begin
      if(rst) begin
         write <= 0;
         pos <= 0;
         out <= data[6'b0];
      end
      else begin
         if(write)
            write <= 0;
         else if (length != 0 && pos != length-6'd1) begin
            write <= 1;
            if(wready) begin
               pos <= pos + 6'd1;
               out <= data[pos + 6'd1];
            end
         end
      end
   end
endmodule
