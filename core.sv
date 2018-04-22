module core (
	input wire clk,
	input wire rst,
	input logic [3:0] pLength,
	input logic [15:0] prog [14:0],
	output reg [3:0] pc,
	output reg signed [10:0] acc,
	output reg signed [10:0] bak
	);
	
	always_ff @(posedge clk or posedge rst) begin
      if (rst) begin
         pc <= 0;
			acc <= 0;
         bak <= 0;
      end else begin
			if(pc == pLength-1)
				pc <= 0;
			else
				pc <= pc+1;
			
			if(!prog[pc][14]) begin
				//MOV
			end else begin
				case(prog[pc][13:11])
					3'b100: //ADD
						if(acc + signed'(prog[pc][10:0]) > 11'sd999) acc <= 11'sd999;
						else if(acc + signed'(prog[pc][10:0]) < -11'sd999) acc <= -11'sd999;
						else acc <= acc + signed'(prog[pc][10:0]);
					3'b101: //SUB
						if(acc - signed'(prog[pc][10:0]) > 11'sd999) acc <= 11'sd999;
						else if(acc - signed'(prog[pc][10:0]) < -11'sd999) acc <= -11'sd999;
						else acc <= acc - signed'(prog[pc][10:0]);
					3'b110: //JRO
						if(pc + signed'(prog[pc][10:0]) > signed'(pLength-1)) pc <= pLength-1;
						else if(pc + signed'(prog[pc][10:0]) < 4'sd0) pc <= 0;
						else pc <= pc + signed'(prog[pc][10:0]);
					3'b111:
						case(prog[pc][10:4])
							7'b1111011: //JEZ
								if(acc == 11'b0) pc <= prog[pc][3:0];
							7'b1111100: //JNZ
								if(acc != 11'b0) pc <= prog[pc][3:0];
							7'b1111101: //JGZ
								if(acc > 11'b0) pc <= prog[pc][3:0];
							7'b1111110: //JLZ
								if(acc < 11'b0) pc <= prog[pc][3:0];
							7'b1111111:
								case(prog[pc][3:0])
									4'b1100: //SWP
										begin
											acc <= bak;
											bak <= acc;
										end
									4'b1100: //SAV
										bak <= acc;
									4'b1100: //NEG
										acc <= -acc;
									4'b1100: //HCF
										;
								endcase
						endcase
				endcase
			end
		end
   end
	
endmodule
