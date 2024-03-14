`default_nettype none

module top(
	   input wire CLK,
	   input wire RST,
	   output wire [4:0] LED,
	   input wire UART_RX,
	   output wire UART_TX
	   );

    assign UART_TX = UART_RX;

    (* keep, mark_debug *) reg [31:0] counter;
    (* keep, mark_debug *) reg [3:0] id;

	reg [6:0] pat;
	assign LED[4] = counter[22];
	assign LED[3] = counter[22] & pat[6];
	assign LED[2] = ! (counter[22] && (pat[5:4] < counter[18:17]));
	assign LED[1] = ! (counter[22] && (pat[3:2] < counter[18:17]));
	assign LED[0] = ! (counter[22] && (pat[1:0] < counter[18:17]));

	always @(id) begin
		case (id)
			4'd0 : pat = 7'b0000000;
			4'd1 : pat = 7'b0010000;
			4'd2 : pat = 7'b0100000;
			4'd3 : pat = 7'b0100100;
			4'd4 : pat = 7'b0101000;
			4'd5 : pat = 7'b0001000;
			4'd6 : pat = 7'b0000010;
			4'd7 : pat = 7'b0100010;
			4'd8 : pat = 7'b0010101;
			4'd9 : pat = 7'b0101010;
			4'd10: pat = 7'b1000000;
			4'd11: pat = 7'b1010000;
			4'd12: pat = 7'b1100100;
			4'd13: pat = 7'b1101000;
			4'd14: pat = 7'b1001000;
			4'd15: pat = 7'b1000010;
			default: pat = 7'b0000000;
		endcase
	end

    always @(posedge CLK) begin
		if(RST) begin
	    	counter <= 0;
		end else begin
	    	counter <= counter + 1;
		end
		id <= `BOARD_ID;
    end

    ila_0 ila_0_i (.clk(CLK),
		   .probe0(id),
		   .probe1(counter)
		   );

endmodule // top
