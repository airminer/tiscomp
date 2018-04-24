module row
(
   input wire clk,
   input wire rst,
   input [3:0] pLength [0:3],
   input [15:0] prog [0:59],
   
   input [10:0] up [0:3],
   input [10:0] down [0:3],
   input [3:0] rreadyU,
   input [3:0] rreadyD,
   input [3:0] wreadyU,
   input [3:0] wreadyD,

   output reg [3:0] writeU,
   output reg [3:0] writeD,
   output reg [10:0] out [0:3],
   output reg [3:0] readU,
   output reg [3:0] readD,
   output reg [10:0] acc [0:3]
);

   reg [1:0] wreg [0:3];
   reg [1:0] rreg [0:3];
   
   initial begin
      for(int i=0; i<4; i++) rreg[i] = 0;
   end
   
   core core0(.clk(clk), .rst(rst), .pLength(pLength[0]), .prog(prog[0:14]), .acc(acc[0]),
      .write({writeD[0], writeU[0], wreg[0]}), .wready({wreadyD[0], wreadyU[0], rreg[0]}), .out(out[0]),
      .rreadyR(wreg[1][0]), .readR(rreg[1][0]), .right(out[1]),
      .rreadyU(rreadyU[0]), .readU(readU[0]), .up(up[0]),
      .rreadyD(rreadyD[0]), .readD(readD[0]), .down(down[0])
   );
   core core1(.clk(clk), .rst(rst), .pLength(pLength[1]), .prog(prog[15:29]), .acc(acc[1]),
      .write({writeD[1], writeU[1], wreg[1]}), .wready({wreadyD[1], wreadyU[1], rreg[1]}), .out(out[1]),
      .rreadyL(wreg[0][1]), .readL(rreg[0][1]), .left(out[0]),
      .rreadyR(wreg[2][0]), .readR(rreg[2][0]), .right(out[2]),
      .rreadyU(rreadyU[1]), .readU(readU[1]), .up(up[1]),
      .rreadyD(rreadyD[1]), .readD(readD[1]), .down(down[1])
   );
   core core2(.clk(clk), .rst(rst), .pLength(pLength[2]), .prog(prog[30:44]), .acc(acc[2]),
      .write({writeD[2], writeU[2], wreg[2]}), .wready({wreadyD[2], wreadyU[2], rreg[2]}), .out(out[2]),
      .rreadyL(wreg[1][1]), .readL(rreg[1][1]), .left(out[1]),
      .rreadyR(wreg[3][0]), .readR(rreg[3][0]), .right(out[3]),
      .rreadyU(rreadyU[2]), .readU(readU[2]), .up(up[2]),
      .rreadyD(rreadyD[2]), .readD(readD[2]), .down(down[2])
   );
   core core3(.clk(clk), .rst(rst), .pLength(pLength[3]), .prog(prog[45:59]), .acc(acc[3]),
      .write({writeD[3], writeU[3], wreg[3]}), .wready({wreadyD[3], wreadyU[3], rreg[3]}), .out(out[3]),
      .rreadyL(wreg[2][1]), .readL(rreg[2][1]), .left(out[2]),
      .rreadyU(rreadyU[3]), .readU(readU[3]), .up(up[3]),
      .rreadyD(rreadyD[3]), .readD(readD[3]), .down(down[3])
   );

endmodule
