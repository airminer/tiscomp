module stack (
   input wire clk,
   input wire rst,
   input [3:0] wready,
   input rreadyL,
   input rreadyR,
   input rreadyU,
   input rreadyD,
   input signed [10:0] left,
   input signed [10:0] right,
   input signed [10:0] up,
   input signed [10:0] down,

   output reg signed [10:0] out,
   output reg [3:0] write,
   output reg readL,
   output reg readR,
   output reg readU,
   output reg readD
);

   reg [10:0] stack [0:14];
   reg [3:0] depth;
   
   reg [3:0] lastwrite;
   
   always_ff @(posedge clk or posedge rst) begin
      if (rst) begin
         out <= 0;
         write <= 0;
         readL <= 0;
         readR <= 0;
         readU <= 0;
         readD <= 0;
         depth <= 0;
         lastwrite <= 4'b0100; //UP
      end
      else begin
         readL <= 0;
         readR <= 0;
         readU <= 0;
         readD <= 0;
         if(depth != 0 && write == 0) begin
            if((wready & lastwrite) != 0) begin
               out <= stack[depth-1];
               lastwrite <= 4'b0100; //UP
               depth <= depth-1;
            end 
            else begin
               case(lastwrite)
                  4'b0001: write <= 4'b0010;
                  4'b0010: write <= 4'b1000;
                  4'b0100: write <= 4'b0001;
                  4'b1000: write <= 4'b0100;
               endcase
               if(depth != 15) begin
                  if(rreadyL) begin
                     readL <= 1;
                     out <= left;
                     stack[depth] <= left;
                     depth <= depth + 1;
                  end
                  else if(rreadyR) begin
                     readR <= 1;
                     out <= right;
                     stack[depth] <= right;
                     depth <= depth + 1;
                  end
                  else if(rreadyU) begin
                     readU <= 1;
                     out <= up;
                     stack[depth] <= up;
                     depth <= depth + 1;
                  end
                  else if(rreadyD) begin
                     readD <= 1;
                     out <= down;
                     stack[depth] <= down;
                     depth <= depth + 1;
                  end
               end
            end
         end
         else begin
            if(write != 0) begin
               lastwrite <= write;
               write <= 0;
            end
            if(depth != 15) begin
               if(rreadyL) begin
                  readL <= 1;
                  out <= left;
                  stack[depth] <= left;
                  depth <= depth + 1;
               end
               else if(rreadyR) begin
                  readR <= 1;
                  out <= right;
                  stack[depth] <= right;
                  depth <= depth + 1;
               end
               else if(rreadyU) begin
                  readU <= 1;
                  out <= up;
                  stack[depth] <= up;
                  depth <= depth + 1;
               end
               else if(rreadyD) begin
                  readD <= 1;
                  out <= down;
                  stack[depth] <= down;
                  depth <= depth + 1;
               end
            end
         end
      end
   end

endmodule
