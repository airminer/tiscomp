module row
(
   input wire clk,
   input wire rst,
   input [3:0] pLength [0:3],
   input [15:0] prog [0:59],
   //input reg [3:0] wready,
   //input reg rreadyL,
   //input reg rreadyR,
   //input reg rreadyU [0:3],
   //input reg rreadyD [0:3],
   //input reg signed [10:0] left,
   //input reg signed [10:0] right,
   //input reg signed [10:0] up [0:3],
   //input reg signed [10:0] down [0:3],

   //output reg signed [10:0] out,
   //output reg [3:0] write,
   //output reg readL,
   //output reg readR,
   //output reg readU [0:3],
   //output reg readD [0:3],
   
   output reg [10:0] acc [0:3]
);

   reg [3:0] wreg [0:3];
   reg [3:0] rreg [0:3];
   reg [10:0] out [0:3];
   
   initial begin
      for(int i=0; i<4; i++) rreg[i] = 0;
   end
   
   core core0(.clk(clk), .rst(rst), .pLength(pLength[0]), .prog(prog[0:14]), .acc(acc[0]),
      .write(wreg[0]), .wready(rreg[0]), .out(out[0]),
      .rreadyR(wreg[1][0]), .readR(rreg[1][0]), .right(out[1]));
   core core1(.clk(clk), .rst(rst), .pLength(pLength[1]), .prog(prog[15:29]), .acc(acc[1]),
      .write(wreg[1]), .wready(rreg[1]), .out(out[1]),
      .rreadyL(wreg[0][1]), .readL(rreg[0][1]), .left(out[0]),
      .rreadyR(wreg[2][0]), .readR(rreg[2][0]), .right(out[2]));
   core core2(.clk(clk), .rst(rst), .pLength(pLength[2]), .prog(prog[30:44]), .acc(acc[2]),
      .write(wreg[2]), .wready(rreg[2]), .out(out[2]),
      .rreadyL(wreg[1][1]), .readL(rreg[1][1]), .left(out[1]),
      .rreadyR(wreg[3][0]), .readR(rreg[3][0]), .right(out[3]));
   core core3(.clk(clk), .rst(rst), .pLength(pLength[3]), .prog(prog[45:59]), .acc(acc[3]),
      .write(wreg[3]), .wready(rreg[3]), .out(out[3]),
      .rreadyL(wreg[2][1]), .readL(rreg[2][1]), .left(out[2]));

endmodule
