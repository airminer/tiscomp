module node (
   input stack,

   input wire clk,
   input wire rst,
   input [3:0] pLength,
   input [15:0] prog [0:14],
   input [3:0] wready,
   input rreadyL,
   input rreadyR,
   input rreadyU,
   input rreadyD,
   input signed [10:0] left,
   input signed [10:0] right,
   input signed [10:0] up,
   input signed [10:0] down,

   output logic signed [10:0] out,
   output logic [3:0] write,
   output logic readL,
   output logic readR,
   output logic readU,
   output logic readD,

   output logic [3:0] pc,
   output logic signed [10:0] acc,
   output logic signed [10:0] bak
);

   logic clkC;

   reg signed [10:0] outC;
   reg [3:0] writeC;
   reg readLC;
   reg readRC;
   reg readUC;
   reg readDC;
   reg [3:0] pcC;
   reg signed [10:0] accC;
   reg signed [10:0] bakC;

   core core0(.clk(clkC), .rst(rst), .pLength(pLength), .prog(prog), .wready(wready),
      .rreadyL(rreadyL), .rreadyR(rreadyR), .rreadyU(rreadyU), .rreadyD(rreadyD),
      .left(left), .right(right), .up(up), .down(down),
      .out(outC), .write(writeC), .readL(readLC), .readR(readRC), .readU(readUC),
      .readD(readDC), .pc(pcC), .acc(accC), .bak(bakC)
   );
   
   logic clkS;
   
   reg signed [10:0] outS;
   reg [3:0] writeS;
   reg readLS;
   reg readRS;
   reg readUS;
   reg readDS;
   
   stack stack0(.clk(clkS), .rst(rst), .wready(wready),
      .rreadyL(rreadyL), .rreadyR(rreadyR), .rreadyU(rreadyU), .rreadyD(rreadyD),
      .left(left), .right(right), .up(up), .down(down),
      .out(outS), .write(writeS), .readL(readLS), .readR(readRS), .readU(readUS),
      .readD(readDS)
   );
   
   always_comb begin
      if(!stack) begin
         clkC = clk;
         clkS = 1'b0;
         
         out = outC;
         write = writeC;
         readL = readLC;
         readR = readRC;
         readU = readUC;
         readD = readDC;
         pc = pcC;
         acc = accC;
         bak = bakC;
      end
      else begin
         clkC = 1'b0;
         clkS = clk;
         
         out = outS;
         write = writeS;
         readL = readLS;
         readR = readRS;
         readU = readUS;
         readD = readDS;
         pc = 4'b0;
         acc = 11'b0;
         bak = 11'b0;
      end
   end

endmodule
