// rotary decoder template

module rotary
  (
	input  wire clk,
	input  wire rst,
	input  wire [1:0] rotary_in,
	output logic [7:0] rotary_pos,
        output logic rot_cw,
        output logic rot_ccw
   );

   wire [1:0] debounced_in;
   debounce debounce0(.clk(clk), .rst(rst), .bouncy_in(rotary_in[0]), .clean_out(debounced_in[0]));
   debounce debounce1(.clk(clk), .rst(rst), .bouncy_in(rotary_in[1]), .clean_out(debounced_in[1]));

   reg [1:0] prev_in;

   always_ff @(posedge clk or posedge rst) begin
      if (rst) begin
         rotary_pos <= 0;
         rot_cw <= 0;
         rot_ccw <= 0;
      end else begin
         prev_in <= debounced_in;
			case({prev_in,debounced_in})
            4'b1000:
               begin
                  rotary_pos <= rotary_pos+1;
                  rot_cw <= 1;
                  rot_ccw <= 0;
               end
            4'b0100:
               begin
                  rotary_pos <= rotary_pos-1;
                  rot_cw <= 0;
                  rot_ccw <= 1;
               end
            default:
               begin
                  rot_cw <= 0;
                  rot_ccw <= 0;
               end
         endcase
		end
   end

endmodule // rotarydecoder
