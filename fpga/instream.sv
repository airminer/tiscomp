module instream (
   input wire clk,
   input wire rst,
   input wready,
   input [5:0] length,
   input signed [10:0] data [0:38],
   
   output reg write,
   output reg [10:0] out,
   output reg [5:0] pos
);

   always_ff @(posedge clk or posedge rst) begin
      if(rst) begin
         write <= 0;
         pos <= 0;
         out <= data[6'b0];
      end
      else begin
         if(write)
            write <= 0;
         else if (length != pos) begin
            if(wready) begin
               pos <= pos + 6'd1;
               if(pos != length-1) begin
                  out <= data[pos + 6'd1];
                  write <= 1;
               end
            end
            else
               write <= 1;
         end
      end
   end
endmodule
