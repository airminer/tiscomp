module outstream (
   input wire clk,
   input wire rst,
   input rready,
   input [5:0] length,
   input [10:0] data [0:38],
   input [10:0] in,

   output reg read,
   output reg [10:0] value,
   output reg [5:0] pos,
   output reg [5:0] errors,
   output reg complete
);

   always_ff @(posedge clk or posedge rst) begin
      if(rst) begin
         read <= 0;
         value <= 0;
         pos <= 0;
         errors <= 0;
			complete <= 0;
      end
      else begin
         if(read)
            read <= 0;
         else if(pos == length) 
			   complete <= errors == 0;
			else if(rready) begin
            read <= 1;
            value <= in;
            if(in != data[pos])
               errors = errors + 1;
            else if(pos == length-1)
               complete <= errors == 0;
            pos <= pos+1;
         end
      end
   end
endmodule
