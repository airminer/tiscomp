module outrow
(
   input wire clk,
   input wire rst,
   input [5:0] length [0:3],
   input signed [10:0] data [0:155],

   input [3:0] rready,
   input [10:0] in [0:3],

   output reg [3:0] read,
   output reg [10:0] value [0:3],
   output reg [5:0] pos [0:3],
   output reg [5:0] errors [0:3],
   output reg [3:0] complete
);

   outstream out0(.clk(clk), .rst(rst), .length(length[0]), .data(data[0:38]), .rready(rready[0]), .read(read[0]), .in(in[0]),
      .value(value[0]), .pos(pos[0]), .errors(errors[0]), .complete(complete[0])
   );
   outstream out1(.clk(clk), .rst(rst), .length(length[1]), .data(data[39:77]), .rready(rready[1]), .read(read[1]), .in(in[1]),
      .value(value[1]), .pos(pos[1]), .errors(errors[1]), .complete(complete[1])
   );
   outstream out2(.clk(clk), .rst(rst), .length(length[2]), .data(data[78:116]), .rready(rready[2]), .read(read[2]), .in(in[2]),
      .value(value[2]), .pos(pos[2]), .errors(errors[2]), .complete(complete[2])
   );
   outstream out3(.clk(clk), .rst(rst), .length(length[3]), .data(data[117:155]), .rready(rready[3]), .read(read[3]), .in(in[3]),
      .value(value[3]), .pos(pos[3]), .errors(errors[3]), .complete(complete[3])
   );

endmodule
