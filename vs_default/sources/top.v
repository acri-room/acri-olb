`default_nettype none

module top(
	   input wire CLK,
	   input wire nRST,
	   output wire [3:0] LED,
	   input wire UART_RX,
	   output wire UART_TX
	   );

    assign UART_TX = UART_RX;

    (* keep, debug_mark *) reg [31:0] counter;
    (* keep, debug_mark *) reg [3:0] id;

    assign LED[0] = counter[25] & id[0];
    assign LED[1] = counter[25] & id[1];
    assign LED[2] = counter[25] & id[2];
    assign LED[3] = counter[25] & id[3];

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
