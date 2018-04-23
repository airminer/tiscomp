/*
 * Executes a couple of tests on the student-deviced Rotary Control
 * Based on a design by Vlad Gavrila
 */

`timescale 1ns/1ns

module tb_core
  (
	output logic 		clk,
	output logic 		rst,
	output logic [1:0] 	in,
	output logic [7:0] 	correct,
	output logic [7:0] 	count,
	output logic [3:0] 	pc,
	output logic [10:0]	acc,
	output logic [10:0]	bak
   );

	reg [3:0] pLength = 4'd4;
	 reg [15:0] prog [0:14];
	 
	 initial begin
		$readmemh("mem.txt", prog);
	 end
	 
	 core core0(.clk(clk), .rst(rst), .pLength(pLength), .prog(prog), .pc(pc), .acc(acc), .bak(bak));

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

	// oscilate the clock
	always #5 clk = !clk;
	always @ (numerr) $display(" - ERROR");
	always @ (endtest) begin
		if (numerr == 0) $display("SUCCESS");
		else $display("FAILED with %d errors", numerr);
		$finish();
	end
endmodule
