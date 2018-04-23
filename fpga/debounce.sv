module synchroniser(
    input clk,
    input async,
    output reg sync);

    reg metastable;
    always_ff @(posedge clk) begin
        metastable <= async;
        sync <= metastable;
    end
endmodule

// debounce template

module debounce
  (
	input wire       clk,       // 50MHz clock input
	input wire       rst,       // reset input (positive)
	input wire       bouncy_in, // bouncy asynchronous input
	output reg 		 clean_out  // clean debounced output
   );

   reg prev_syncbouncy;
   reg [15:0] counter; //12 or 13 for first test
   wire counterAtMax = &counter;
   wire syncbouncy;
   synchroniser dosync(.clk(clk), .async(bouncy_in), .sync(syncbouncy));

   always_ff @(posedge clk or posedge rst)
      if (rst) begin
         counter <= 0;
         prev_syncbouncy <= 0;
         clean_out <= 0;
      end else begin
         prev_syncbouncy <= syncbouncy;
         if (prev_syncbouncy == syncbouncy) begin
            if(counterAtMax)
               clean_out <= syncbouncy;
            else
               counter <= counter+1;
         end else
            counter <= 0;
      end
endmodule // debounce
