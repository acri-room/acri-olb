`default_nettype none

module top(
	   input wire CLK,
	   input wire nRST,
	   output reg [6:0] LED,
	   output wire [7:0] AN,
	   input wire UART_RX,
	   output wire UART_TX
	   );

    assign UART_TX = UART_RX;

    (* keep, mark_debug *) reg [31:0] counter;
    (* keep, mark_debug *) reg [3:0] id;

	assign AN[7:1] = 7'b1111111;
	assign AN[0] = counter[25] | counter[20];

	always @(id) begin
		case (id)
			4'd0 : LED = 7'b1000000;
			4'd1 : LED = 7'b1111001;
			4'd2 : LED = 7'b0100100;
			4'd3 : LED = 7'b0110000;
			4'd4 : LED = 7'b0011001;
			4'd5 : LED = 7'b0010010;
			4'd6 : LED = 7'b0000010;
			4'd7 : LED = 7'b1111000;
			4'd8 : LED = 7'b0000000;
			4'd9 : LED = 7'b0010000;
			4'd10: LED = 7'b0001000;
			4'd11: LED = 7'b0000011;
			4'd12: LED = 7'b1000110;
			4'd13: LED = 7'b0100001;
			4'd14: LED = 7'b0000110;
			4'd15: LED = 7'b0001110;
			default: LED = 7'b1111111;
		endcase
	end

    always @(posedge CLK) begin
		if(nRST == 0) begin
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
