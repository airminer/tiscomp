`define NIL 11'd1000
`define ACC 11'd1001
`define ANY 11'd1002
`define LAST 11'd1003
`define LEFT 11'd1004
`define RIGHT 11'd1005
`define UP 11'd1006
`define DOWN 11'd1007

`define DNIL 3'd0
`define DACC 3'd1
`define DANY 3'd2
`define DLAST 3'd3
`define DLEFT 3'd4
`define DRIGHT 3'd5
`define DUP 3'd6
`define DDOWN 3'd7

module core (
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

   output reg signed [10:0] out,
   output reg [3:0] write,
   output reg readL,
   output reg readR,
   output reg readU,
   output reg readD,

   output logic [3:0] pc,
   output reg signed [10:0] acc,
   output reg signed [10:0] bak
   );

   reg [2:0] last;
   reg [3:0] lastwrite;
   reg [3:0] pcReg;

   always_comb
      if(((write | lastwrite) & wready) != 0)
         if(pcReg == pLength-1)
            pc = 0;
         else
            pc = pcReg+1;
      else
         pc = pcReg;

   always_ff @(posedge clk or posedge rst) begin
      if (rst) begin
         pcReg <= 0;
         acc <= 0;
         bak <= 0;
         last <= `DNIL;
         lastwrite <= 0;
         out <= 0;
         write <= 0;
         readL <= 0;
         readR <= 0;
         readU <= 0;
         readD <= 0;
      end
      else if(pLength != 0) begin
         readL <= 0;
         readR <= 0;
         readU <= 0;
         readD <= 0;

         if(((write | lastwrite) != 0) && (((write | lastwrite) & wready) == 0)) begin
            if(write != 0) begin
               if(prog[pc][13:11] == `DANY) begin
                  case(write)
                     4'b0001: last <= `DLEFT;
                     4'b0010: last <= `DRIGHT;
                     4'b0100: last <= `DUP;
                     4'b1000: last <= `DDOWN;
                  endcase
               end
               lastwrite <= write;
               write <= 0;
            end
            else begin
               if(prog[pc][13:11] == `DANY) begin
                  case(lastwrite)
                     4'b0001: write <= 4'b0010;
                     4'b0010: write <= 4'b1000;
                     4'b0100: write <= 4'b0001;
                     4'b1000: write <= 4'b0100;
                  endcase
               end
               else begin
                  write <= lastwrite;
               end
               lastwrite <= 0;
            end
         end
         else begin
            write <= 0;
            lastwrite <= 0;
            if(pc == pLength-1)
               pcReg <= 0;
            else
               pcReg <= pc+1;

            if(!prog[pc][14]) begin //MOV
               if(signed'(prog[pc][10:0]) > 11'sd999) begin
                  if(prog[pc][10:0] == `NIL) begin
                     if(prog[pc][13:11] == `DACC)
                        acc <= 0;
                     else if((prog[pc][13:11] != `DNIL) && ((prog[pc][13:11] != `DLAST) || (last != `DNIL))) begin
                        out <= 0;
                        pcReg <= pc;
                        if(prog[pc][13:11] == `DANY)
                           write[2] <= 1; //UP
                        else if(prog[pc][13:11] == `DLAST)
                           write[last[1:0]] <= 1;
                        else
                           write[prog[pc][12:11]] <= 1;
                     end
                  end
                  else if(prog[pc][10:0] == `ACC) begin //ACC
                     if((prog[pc][13:11] != `DACC) && (prog[pc][13:11] != `DNIL) && ((prog[pc][13:11] != `DLAST) || (last != `DNIL))) begin
                        out <= acc;
                        pcReg <= pc;
                        if(prog[pc][13:11] == `DANY)
                           write[2] <= 1; //UP
                        else if(prog[pc][13:11] == `DLAST)
                           write[last[1:0]] <= 1;
                        else
                           write[prog[pc][12:11]] <= 1;
                     end
                  end
                  else if((prog[pc][10:0] == `LEFT) || ((prog[pc][10:0] == `ANY) && rreadyL) || ((prog[pc][10:0] == `LAST) && (last == `DLEFT))) begin //LEFT
                     if(rreadyL) begin
                        readL <= 1;
                        if(prog[pc][10:0] == `ANY)
                            last <= `DLEFT;
                        if(prog[pc][13:11] == `DACC)
                           acc <= left;
                        else if((prog[pc][13:11] != `DNIL) && ((prog[pc][13:11] != `DLAST) || (last != `DNIL))) begin
                           out <= left;
                           pcReg <= pc;
                           if(prog[pc][13:11] == `DANY)
                              write[2] <= 1; //UP
                           else if(prog[pc][13:11] == `DLAST)
                              write[last[1:0]] <= 1;
                           else
                              write[prog[pc][12:11]] <= 1;
                        end
                     end
                     else begin
                        pcReg <= pc;
                     end
                  end
                  else if((prog[pc][10:0] == `RIGHT) || ((prog[pc][10:0] == `ANY) && rreadyR) || ((prog[pc][10:0] == `LAST) && (last == `DRIGHT))) begin //RIGHT
                     if(rreadyR) begin
                        readR <= 1;
                        if(prog[pc][10:0] == `ANY)
                            last <= `DRIGHT;
                        if(prog[pc][13:11] == `DACC)
                           acc <= right;
                        else if((prog[pc][13:11] != `DNIL) && ((prog[pc][13:11] != `DLAST) || (last != `DNIL))) begin
                           out <= right;
                           pcReg <= pc;
                           if(prog[pc][13:11] == `DANY)
                              write[2] <= 1; //UP
                           else if(prog[pc][13:11] == `DLAST)
                              write[last[1:0]] <= 1;
                           else
                              write[prog[pc][12:11]] <= 1;
                        end
                     end
                     else begin
                        pcReg <= pc;
                     end
                  end
                  else if((prog[pc][10:0] == `UP) || ((prog[pc][10:0] == `ANY) && rreadyU) || ((prog[pc][10:0] == `LAST) && (last == `DUP))) begin //UP
                     if(rreadyU) begin
                        readU <= 1;
                        if(prog[pc][10:0] == `ANY)
                            last <= `DUP;
                        if(prog[pc][13:11] == `DACC)
                           acc <= up;
                        else if((prog[pc][13:11] != `DNIL) && ((prog[pc][13:11] != `DLAST) || (last != `DNIL))) begin
                           out <= up;
                           pcReg <= pc;
                           if(prog[pc][13:11] == `DANY)
                              write[2] <= 1; //UP
                           else if(prog[pc][13:11] == `DLAST)
                              write[last[1:0]] <= 1;
                           else
                              write[prog[pc][12:11]] <= 1;
                        end
                     end
                     else begin
                        pcReg <= pc;
                     end
                  end
                  else if((prog[pc][10:0] == `DOWN) || (prog[pc][10:0] == `ANY) || ((prog[pc][10:0] == `LAST) && (last == `DDOWN))) begin //DOWN
                     if(rreadyD) begin
                        readD <= 1;
                        if(prog[pc][10:0] == `ANY)
                            last <= `DDOWN;
                        if(prog[pc][13:11] == `DACC)
                           acc <= down;
                        else if((prog[pc][13:11] != `DNIL) && ((prog[pc][13:11] != `DLAST) || (last != `DNIL))) begin
                           out <= down;
                           pcReg <= pc;
                           if(prog[pc][13:11] == `DANY)
                              write[2] <= 1; //UP
                           else if(prog[pc][13:11] == `DLAST)
                              write[last[1:0]] <= 1;
                           else
                              write[prog[pc][12:11]] <= 1;
                        end
                     end
                     else begin
                        pcReg <= pc;
                     end
                  end
               end
               else begin //LITERAL
                  if(prog[pc][13:11] == `DACC)
                        acc <= signed'(prog[pc][10:0]);
                     else if((prog[pc][13:11] != `DNIL) && ((prog[pc][13:11] != `DLAST) || (last != `DNIL))) begin
                        out <= signed'(prog[pc][10:0]);
                        pcReg <= pc;
                        if(prog[pc][13:11] == `DANY)
                           write[2] <= 1; //UP
                        else if(prog[pc][13:11] == `DLAST)
                           write[last[1:0]] <= 1;
                        else
                           write[prog[pc][12:11]] <= 1;
                     end
               end
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
                        else if((prog[pc][10:0] == `LEFT) || ((prog[pc][10:0] == `ANY) && rreadyL) || ((prog[pc][10:0] == `LAST) && (last == `DLEFT))) begin //LEFT
                           if(rreadyL) begin
                              readL <= 1;
                              if((acc + left) > 12'sd999) acc <= 11'sd999;
                              else if((acc + left) < -12'sd999) acc <= -11'sd999;
                              else acc <= acc + left;
                              if(prog[pc][10:0] == `ANY)
                                  last <= `DLEFT;
                           end
                           else begin
                              pcReg <= pc;
                           end
                        end
                        else if((prog[pc][10:0] == `RIGHT) || ((prog[pc][10:0] == `ANY) && rreadyR) || ((prog[pc][10:0] == `LAST) && (last == `DRIGHT))) begin //RIGHT
                           if(rreadyR) begin
                              readR <= 1;
                              if((acc + right) > 12'sd999) acc <= 11'sd999;
                              else if((acc + right) < -12'sd999) acc <= -11'sd999;
                              else acc <= acc + right;
                              if(prog[pc][10:0] == `ANY)
                                  last <= `DRIGHT;
                           end
                           else begin
                              pcReg <= pc;
                           end
                        end
                        else if((prog[pc][10:0] == `UP) || ((prog[pc][10:0] == `ANY) && rreadyU) || ((prog[pc][10:0] == `LAST) && (last == `DUP))) begin //UP
                           if(rreadyU) begin
                              readU <= 1;
                              if((acc + up) > 12'sd999) acc <= 11'sd999;
                              else if((acc + up) < -12'sd999) acc <= -11'sd999;
                              else acc <= acc + up;
                              if(prog[pc][10:0] == `ANY)
                                  last <= `DUP;
                           end
                           else begin
                              pcReg <= pc;
                           end
                        end
                        else if((prog[pc][10:0] == `DOWN) || (prog[pc][10:0] == `ANY) || ((prog[pc][10:0] == `LAST) && (last == `DDOWN))) begin //DOWN
                           if(rreadyD) begin
                              readD <= 1;
                              if((acc + down) > 12'sd999) acc <= 11'sd999;
                              else if((acc + down) < -12'sd999) acc <= -11'sd999;
                              else acc <= acc + down;
                              if(prog[pc][10:0] == `ANY)
                                  last <= `DDOWN;
                           end
                           else begin
                              pcReg <= pc;
                           end
                        end
                     end
                     else begin
                        if(acc + signed'(prog[pc][10:0]) > 12'sd999) acc <= 11'sd999;
                        else if(acc + signed'(prog[pc][10:0]) < -12'sd999) acc <= -11'sd999;
                        else acc <= acc + signed'(prog[pc][10:0]);
                     end
                  3'b101: //SUB
                     if(signed'(prog[pc][10:0]) > 11'sd999) begin
                        if(prog[pc][10:0] == `ACC ) begin //ACC
                           acc <= 0;
                        end
                        else if((prog[pc][10:0] == `LEFT) || ((prog[pc][10:0] == `ANY) && rreadyL) || ((prog[pc][10:0] == `LAST) && (last == `DLEFT))) begin //LEFT
                           if(rreadyL) begin
                              readL <= 1;
                              if((acc - left) > 12'sd999) acc <= 11'sd999;
                              else if((acc - left) < -12'sd999) acc <= -11'sd999;
                              else acc <= acc - left;
                              if(prog[pc][10:0] == `ANY)
                                  last <= `DLEFT;
                           end
                           else begin
                              pcReg <= pc;
                           end
                        end
                        else if((prog[pc][10:0] == `RIGHT) || ((prog[pc][10:0] == `ANY) && rreadyR) || ((prog[pc][10:0] == `LAST) && (last == `DRIGHT))) begin //RIGHT
                           if(rreadyR) begin
                              readR <= 1;
                              if((acc - right) > 12'sd999) acc <= 11'sd999;
                              else if((acc - right) < -12'sd999) acc <= -11'sd999;
                              else acc <= acc - right;
                              if(prog[pc][10:0] == `ANY)
                                  last <= `DRIGHT;
                           end
                           else begin
                              pcReg <= pc;
                           end
                        end
                        else if((prog[pc][10:0] == `UP) || ((prog[pc][10:0] == `ANY) && rreadyU) || ((prog[pc][10:0] == `LAST) && (last == `DUP))) begin //UP
                           if(rreadyU) begin
                              readU <= 1;
                              if((acc - up) > 12'sd999) acc <= 11'sd999;
                              else if((acc - up) < -12'sd999) acc <= -11'sd999;
                              else acc <= acc - up;
                              if(prog[pc][10:0] == `ANY)
                                  last <= `DUP;
                           end
                           else begin
                              pcReg <= pc;
                           end
                        end
                        else if((prog[pc][10:0] == `DOWN) || (prog[pc][10:0] == `ANY) || ((prog[pc][10:0] == `LAST) && (last == `DDOWN))) begin //DOWN
                           if(rreadyD) begin
                              readD <= 1;
                              if((acc - down) > 12'sd999) acc <= 11'sd999;
                              else if((acc - down) < -12'sd999) acc <= -11'sd999;
                              else acc <= acc - down;
                              if(prog[pc][10:0] == `ANY)
                                  last <= `DDOWN;
                           end
                           else begin
                              pcReg <= pc;
                           end
                        end
                     end
                     else begin
                        if(acc - signed'(prog[pc][10:0]) > 12'sd999) acc <= 11'sd999;
                        else if(acc - signed'(prog[pc][10:0]) < -12'sd999) acc <= -11'sd999;
                        else acc <= acc - signed'(prog[pc][10:0]);
                     end
                  3'b110: //JRO
                     if(signed'(prog[pc][10:0]) > 11'sd999) begin
                        if(prog[pc][10:0] == `NIL ) begin //NIL
                           pcReg <= 0;
                        end
                        else if(prog[pc][10:0] == `ACC ) begin //ACC
                           if((signed'(5'(pc)) + acc) > signed'(5'(pLength-1))) pcReg <= pLength-1;
                           else if((signed'(5'(pc)) + acc) < 5'sd0) pcReg <= 0;
                           else pcReg <= signed'(5'(pc)) + acc;
                        end
                        else if((prog[pc][10:0] == `LEFT) || ((prog[pc][10:0] == `ANY) && rreadyL) || ((prog[pc][10:0] == `LAST) && (last == `DLEFT))) begin //LEFT
                           if(rreadyL) begin
                              readL <= 1;
                              if((signed'(5'(pc)) + left) > signed'(5'(pLength-1))) pcReg <= pLength-1;
                              else if((signed'(5'(pc)) + left) < 5'sd0) pcReg <= 0;
                              else pcReg <= signed'(5'(pc)) + left;
                              if(prog[pc][10:0] == `ANY)
                                  last <= `DLEFT;
                           end
                           else begin
                              pcReg <= pc;
                           end
                        end
                        else if((prog[pc][10:0] == `RIGHT) || ((prog[pc][10:0] == `ANY) && rreadyR) || ((prog[pc][10:0] == `LAST) && (last == `DRIGHT))) begin //RIGHT
                           if(rreadyR) begin
                              readR <= 1;
                              if((signed'(5'(pc)) + right) > signed'(5'(pLength-1))) pcReg <= pLength-1;
                              else if((signed'(5'(pc)) + right) < 5'sd0) pcReg <= 0;
                              else pcReg <= signed'(5'(pc)) + right;
                              if(prog[pc][10:0] == `ANY)
                                  last <= `DRIGHT;
                           end
                           else begin
                              pcReg <= pc;
                           end
                        end
                        else if((prog[pc][10:0] == `UP) || ((prog[pc][10:0] == `ANY) && rreadyU) || ((prog[pc][10:0] == `LAST) && (last == `DUP))) begin //UP
                           if(rreadyU) begin
                              readU <= 1;
                              if((signed'(5'(pc)) + up) > signed'(5'(pLength-1))) pcReg <= pLength-1;
                              else if((signed'(5'(pc)) + up) < 5'sd0) pcReg <= 0;
                              else pcReg <= signed'(5'(pc)) + up;
                              if(prog[pc][10:0] == `ANY)
                                  last <= `DUP;
                           end
                           else begin
                              pcReg <= pc;
                           end
                        end
                        else if((prog[pc][10:0] == `DOWN) || (prog[pc][10:0] == `ANY) || ((prog[pc][10:0] == `LAST) && (last == `DDOWN))) begin //DOWN
                           if(rreadyD) begin
                              readD <= 1;
                              if((signed'(5'(pc)) + down) > signed'(5'(pLength-1))) pcReg <= pLength-1;
                              else if((signed'(5'(pc)) + down) < 5'sd0) pcReg <= 0;
                              else pcReg <= signed'(5'(pc)) + down;
                              if(prog[pc][10:0] == `ANY)
                                  last <= `DDOWN;
                           end
                           else begin
                              pcReg <= pc;
                           end
                        end
                     end
                     else begin
                        if(signed'(5'(pc)) + signed'(prog[pc][10:0]) > signed'(5'(pLength-1))) pcReg <= pLength-1;
                        else if(signed'(5'(pc)) + signed'(prog[pc][10:0]) < 5'sd0) pcReg <= 0;
                        else pcReg <= signed'(5'(pc)) + signed'(prog[pc][10:0]);
                     end
                  3'b111:
                     case(prog[pc][10:4])
                        7'b1111010: //JMP
                           pcReg <= prog[pc][3:0];
                        7'b1111011: //JEZ
                           if(acc == 11'sb0) pcReg <= prog[pc][3:0];
                        7'b1111100: //JNZ
                           if(acc != 11'sb0) pcReg <= prog[pc][3:0];
                        7'b1111101: //JGZ
                           if(acc > 11'sb0) pcReg <= prog[pc][3:0];
                        7'b1111110: //JLZ
                           if(acc < 11'sb0) pcReg <= prog[pc][3:0];
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
   end
endmodule
