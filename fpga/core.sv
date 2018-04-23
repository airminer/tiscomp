`define NIL 11'd1000
`define ACC 11'd1001
`define ANY 11'd1002
`define LAST 11'd1003
`define LEFT 11'd1004
`define RIGHT 11'd1005
`define UP 11'd1006
`define DOWN 11'd1007

module core (
   input wire clk,
   input wire rst,
   input reg [3:0] pLength,
   input reg [15:0] prog [0:14],
   input reg wreadyL,
   input reg wreadyR,
   input reg wreadyU,
   input reg wreadyD,
   input reg rreadyL,
   input reg rreadyR,
   input reg rreadyU,
   input reg rreadyD,
   input reg signed [10:0] left,
   input reg signed [10:0] right,
   input reg signed [10:0] up,
   input reg signed [10:0] down,

   output reg signed [10:0] out,
   output reg writeL,
   output reg writeR,
   output reg writeU,
   output reg writeD,
   output reg readL,
   output reg readR,
   output reg readU,
   output reg readD,

   output reg [3:0] pc,
   output reg signed [10:0] acc,
   output reg signed [10:0] bak
   );

   //REGISTERS

   reg [10:0] last;

   always_ff @(posedge clk or posedge rst) begin
      if (rst) begin
         pc <= 0;
         acc <= 0;
         bak <= 0;
         last <= `NIL;
      end
      else begin
         readL <= 0;
         readR <= 0;
         readU <= 0;
         readD <= 0;

         if(pc == pLength-1)
            pc <= 0;
         else
            pc <= pc+1;

         if(!prog[pc][14]) begin //MOV

         end
         else begin
            case(prog[pc][13:11])
               3'b100: //ADD
                  if(signed'(prog[pc][10:0]) > 11'sd999) begin
                     if(prog[pc][10:0] == `ACC ) begin //ACC
                        if((acc + acc) > 12'sd999) acc <= 11'sd999;
                        else if((acc + acc) < -12'sd999) acc <= -11'sd999;
                        else acc <= acc + acc;
                     end
                     else if((prog[pc][10:0] == `LEFT) || ((prog[pc][10:0] == `ANY) && ((last == `NIL) || (last == `DOWN))) || ((prog[pc][10:0] == `LAST) && (last == `LEFT))) begin //LEFT
                        if(rreadyL) begin
                           readL <= 1;
                           if((acc + left) > 12'sd999) acc <= 11'sd999;
                           else if((acc + left) < -12'sd999) acc <= -11'sd999;
                           else acc <= acc + left;
                        end
                        else begin
                           pc <= pc;
                        end
                        if(prog[pc][10:0] == `ANY)
                           last <= `LEFT;
                     end
                     else if((prog[pc][10:0] == `RIGHT) || ((prog[pc][10:0] == `ANY) && (last == `LEFT)) || ((prog[pc][10:0] == `LAST) && (last == `RIGHT))) begin //RIGHT
                        if(rreadyR) begin
                           readR <= 1;
                           if((acc + right) > 12'sd999) acc <= 11'sd999;
                           else if((acc + right) < -12'sd999) acc <= -11'sd999;
                           else acc <= acc + right;
                        end
                        else begin
                           pc <= pc;
                        end
                        if(prog[pc][10:0] == `ANY)
                           last <= `RIGHT;
                     end
                     else if((prog[pc][10:0] == `UP) || ((prog[pc][10:0] == `ANY) && (last == `RIGHT)) || ((prog[pc][10:0] == `LAST) && (last == `UP))) begin //UP
                        if(rreadyU) begin
                           readU <= 1;
                           if((acc + up) > 12'sd999) acc <= 11'sd999;
                           else if((acc + up) < -12'sd999) acc <= -11'sd999;
                           else acc <= acc + up;
                        end
                        else begin
                           pc <= pc;
                        end
                        if(prog[pc][10:0] == `ANY)
                           last <= `UP;
                     end
                     else if((prog[pc][10:0] == `DOWN) || ((prog[pc][10:0] == `ANY) && (last == `UP)) || ((prog[pc][10:0] == `LAST) && (last == `DOWN))) begin //DOWN
                        if(rreadyD) begin
                           readD <= 1;
                           if((acc + down) > 12'sd999) acc <= 11'sd999;
                           else if((acc + down) < -12'sd999) acc <= -11'sd999;
                           else acc <= acc + down;
                        end
                        else begin
                           pc <= pc;
                        end
                        if(prog[pc][10:0] == `ANY)
                           last <= `DOWN;
                     end
                  end
                  else begin
                     if(acc + signed'(prog[pc][10:0]) > 12'sd999) acc <= 11'sd999;
                     else if(acc + signed'(prog[pc][10:0]) < -12'sd999) acc <= -11'sd999;
                     else acc <= acc + signed'(prog[pc][10:0]);
                  end
               3'b101: //SUB
                  if(acc - signed'(prog[pc][10:0]) > 12'sd999) acc <= 11'sd999;
                  else if(acc - signed'(prog[pc][10:0]) < -12'sd999) acc <= -11'sd999;
                  else acc <= acc - signed'(prog[pc][10:0]);
               3'b110: //JRO
                  if(signed'(5'(pc)) + signed'(prog[pc][10:0]) > signed'(5'(pLength-1))) pc <= pLength-1;
                  else if(signed'(5'(pc)) + signed'(prog[pc][10:0]) < 5'sd0) pc <= 0;
                  else pc <= signed'(5'(pc)) + signed'(prog[pc][10:0]);
               3'b111:
                  case(prog[pc][10:4])
                     7'b1111010: //JMP
                        pc <= prog[pc][3:0];
                     7'b1111011: //JEZ
                        if(acc == 11'sb0) pc <= prog[pc][3:0];
                     7'b1111100: //JNZ
                        if(acc != 11'sb0) pc <= prog[pc][3:0];
                     7'b1111101: //JGZ
                        if(acc > 11'sb0) pc <= prog[pc][3:0];
                     7'b1111110: //JLZ
                        if(acc < 11'sb0) pc <= prog[pc][3:0];
                     7'b1111111:
                        case(prog[pc][3:0])
                           4'b1100: //SWP
                              begin
                                 acc <= bak;
                                 bak <= acc;
                              end
                           4'b1101: //SAV
                              bak <= acc;
                           4'b1110: //NEG
                             acc <= -acc;
                           4'b1111: //NOP
                              ;
                        endcase
                  endcase
            endcase
         end
      end
   end
endmodule
