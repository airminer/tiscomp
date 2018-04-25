`timescale 1ns/1ns

module tb_ccx
  (
   output logic      clk,
   output logic      rst,
   output logic [1:0]   in,
   output logic [7:0]   correct,
   output logic [7:0]   count,
   output logic [10:0] acc [0:11]
   );

   reg [3:0] pLength [0:11];
   reg [15:0] prog [0:179];
   reg stack [0:11];

   reg [5:0] inLength [0:3];
   reg signed [10:0] inData [0:255];

   initial begin
      $readmemh("prog.txt", prog);
      $readmemh("len.txt", pLength);
      $readmemb("stack.txt", stack);
      inLength[0] = 6'd5;
      for(int i=1; i<4; i++) inLength[i] = 0;
      for(int i=0; i<5; i++) inData[i] = i;
   end

   logic [3:0] rreadyU;
   logic [3:0] readU;
   logic [10:0] up [0:3];

   inrow inrow0(.clk(clk), .rst(rst), .length(inLength), .data(inData), .wready(readU), .write(rreadyU), .out(up));
   corecomplex ccx(.clk(clk), .rst(rst), .pLength(pLength), .prog(prog), .acc(acc), .stack(stack),
   .rreadyU(rreadyU), .readU(readU), .up(up),
   .wreadyU('{4'b0, 4'b0, 4'b0, 4'b0}), .wreadyD('{4'b0, 4'b0, 4'b0, 4'b0}));

   //reg [10:0] value;
   
   //core core0(.clk(clk), .rst(rst), .pLength(pLength), .prog(prog[0:14]), .acc(acc0),
   //   .write(wreg), .wready(rreg), .out(out));
   //sink sink0(.clk(clk), .rst(rst), .rready(wreg[1]), .read(rreg[1]), .in(out), .value(value));
   
   int numerr;
   bit endtest;

   // initialise clock and generate a reset pulse
   initial begin
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

   //always @ (posedge rreg[1]) begin
   //   $display("%d", value);
   //end
   
   // oscilate the clock
   always #5 clk = !clk;
   always @ (numerr) $display(" - ERROR");
   always @ (endtest) begin
      if (numerr == 0) $display("SUCCESS");
      else $display("FAILED with %d errors", numerr);
      $finish();
   end
endmodule
