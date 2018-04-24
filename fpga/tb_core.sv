`timescale 1ns/1ns

module tb_core
  (
   output logic      clk,
   output logic      rst,
   output logic [1:0]   in,
   output logic [7:0]   correct,
   output logic [7:0]   count,
   output logic [10:0] acc0,
   output logic [10:0] acc1
   );

   reg [3:0] pLength [0:13];
   reg [15:0] prog [0:179];

   initial begin
      $readmemh("prog.txt", prog);
      $readmemh("len.txt", pLength);
   end

   reg [3:0] wreg [0:1];
   reg [3:0] rreg [0:1];
   reg [10:0] out [0:1];

   core core0(.clk(clk), .rst(rst), .pLength(pLength[0]), .prog(prog[0:14]), .acc(acc0),
      .write(wreg[0]), .wready(rreg[0]), .out(out[0]),
      .rreadyR(wreg[1][0]), .readR(rreg[1][0]), .right(out[1]));
   stack stack0(.clk(clk), .rst(rst),
      .write(wreg[1]), .wready(rreg[1]), .out(out[1]),
      .rreadyL(wreg[0][1]), .readL(rreg[0][1]), .left(out[0]));

   int numerr;
   bit endtest;

   // initialise clock and generate a reset pulse
   initial begin
      rreg[0] = 0;
      rreg[1] = 0;
      clk = 1;
      rst = 1;
      numerr = 0;
      endtest = 0;
      correct = 0;
      in = 2'b00;
      #20 rst = 0;

      $display("%010t ---------- Start simulation. Counter should be %d, is %d ----------", $time, correct, count);

      //endtest = 1;
   end

   // oscilate the clock
   always #5 clk = !clk;
   always @ (numerr) $display(" - ERROR");
   always @ (endtest) begin
      if (numerr == 0) $display("SUCCESS");
      else $display("FAILED with %d errors", numerr);
      $finish();
   end
endmodule
