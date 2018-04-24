module corecomplex
(
   input wire clk,
   input wire rst,
   input [3:0] pLength [0:11],
   input [15:0] prog [0:179],
   
   input [10:0] up [0:3],
   input [10:0] down [0:3],
   input [3:0] rreadyU,
   input [3:0] rreadyD,
   input [3:0] wreadyU,
   input [3:0] wreadyD,

   output reg [3:0] writeU,
   output reg [3:0] writeD,
   output reg [10:0] outU [0:3],
   output reg [10:0] outD [0:3],
   output reg [3:0] readU,
   output reg [3:0] readD,
   output reg [10:0] acc [0:11]
);

   reg [3:0] wregU [0:1];
   reg [3:0] wregD [0:1];
   reg [3:0] rregU [0:1];
   reg [3:0] rregD [0:1];
   reg [10:0] cval [0:3];

   row row0(.clk(clk), .rst(rst), .pLength(pLength[0:3]), .prog(prog[0:59]), .acc(acc[0:3]),
      .rreadyU(rreadyU), .readU(readU), .wreadyU(wreadyU), .writeU(writeU), .up(up), .out(outU),
      .rreadyD(wregU[0]), .readD(rregD[0]), .wreadyD(rregU[0]), .writeD(wregD[0]), .down(cval)
   );
   row row1(.clk(clk), .rst(rst), .pLength(pLength[4:7]), .prog(prog[60:119]), .acc(acc[4:7]),
      .rreadyU(wregD[0]), .readU(rregU[0]), .wreadyU(rregD[0]), .writeU(wregU[0]), .up(outU), .out(cval),
      .rreadyD(wregU[1]), .readD(rregD[1]), .wreadyD(rregU[1]), .writeD(wregD[1]), .down(outD)
   );
   row row2(.clk(clk), .rst(rst), .pLength(pLength[8:11]), .prog(prog[120:179]), .acc(acc[8:11]),
      .rreadyU(wregD[1]), .readU(rregU[1]), .wreadyU(rregD[1]), .writeU(wregU[1]), .up(cval), .out(outD),
      .rreadyD(rreadyD), .readD(readD), .wreadyD(wreadyD), .writeD(writeD), .down(down)
   );

endmodule