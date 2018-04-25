module inrow
(
   input wire clk,
   input wire rst,
   input [5:0] length [0:3],
   input signed [10:0] data [0:255],

   input [3:0] wready,

   output reg [3:0] write,
   output reg [10:0] out [0:3]
);

   instream in0(.clk(clk), .rst(rst), .length(length[0]), .data(data[0:63]), .wready(wready[0]), .write(write[0]), .out(out[0]));
   instream in1(.clk(clk), .rst(rst), .length(length[1]), .data(data[64:127]), .wready(wready[1]), .write(write[1]), .out(out[1]));
   instream in2(.clk(clk), .rst(rst), .length(length[2]), .data(data[128:191]), .wready(wready[2]), .write(write[2]), .out(out[2]));
   instream in3(.clk(clk), .rst(rst), .length(length[3]), .data(data[192:255]), .wready(wready[3]), .write(write[3]), .out(out[3]));

endmodule
