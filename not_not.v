`include "hex_decoder.v"
`include "lfsr_3bits.v"
`include "text_display.v"
module not_not(
    input [9:0] SW, 
    input [2:0] KEY,
    input CLOCK_50,
    output [6:0] HEX0, HEX1, HEX4, HEX5,
    output [3:0] LEDR,
    output VGA_CLK,   	//	VGA Clock
	output VGA_HS,		//	VGA H_SYNC
	output VGA_VS,		//	VGA V_SYNC
	output VGA_BLANK_N,	//	VGA BLANK
	output VGA_SYNC_N,	//	VGA SYNC
	output [9:0] VGA_R, //	VGA Red[9:0]
	output [9:0] VGA_G, //	VGA Green[9:0]
	output [9:0] VGA_B //	VGA Blue[9:0]
);
    wire [2:0] not_not_selector, colour_logic_selector, colour_selector_1, colour_selector_2;
    wire [3:0] colour_1, colour_2;
    reg [3:0] colour_logic_output, not_not_output;
    wire enable, debug, reset;
    wire reset_vga, done_draw;

    // Temporary assignment
    assign reset_vga = SW[6];
    assign reset = SW[8];
    assign enable = SW[9];
    assign debug = SW[7];

    assign LEDR[3:0] = debug? not_not_output : 4'b0000;
	
	// Create the colour, x, y and writeEn wires that are inputs to the controller.
	wire [2:0] colour;
	wire [8:0] x;
	wire [7:0] y;
	wire writeEn, draw_enable;

    wire start = SW[0];
    wire lose = SW[1];
    assign draw_enable = SW[2];

    text_display td0(
        .clock(CLOCK_50),
        .not_not_selector(not_not_selector),
        .colour_logic_selector(colour_logic_selector),
        .colour_selector_1(colour_selector_1),
        .colour_selector_2(colour_selector_2),
        .resetn(reset),
        .draw_enable(draw_enable),
        .start(start),
        .lose(lose),
        .writeEn(writeEn),
        .done_draw(done_draw),
        .colour(colour),
        .x(x),
        .y(y)
    );

    // Create an Instance of a VGA controller - there can be only one!
	// Define the number of colours as well as the initial background
	// image file (.MIF) for the controller.
	vga_adapter VGA(
			.resetn(reset_vga),
			.clock(CLOCK_50),
			.colour(colour),
			.x(x),
			.y(y),
			.plot(writeEn),
			/* Signals for the DAC to drive the monitor. */
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK_N),
			.VGA_SYNC(VGA_SYNC_N),
			.VGA_CLK(VGA_CLK));
    defparam VGA.RESOLUTION = "320x240";
    defparam VGA.MONOCHROME = "FALSE";
    defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
    defparam VGA.BACKGROUND_IMAGE = "black.mif";

    lfsr_3bits l0(
        .clock(CLOCK_50),
        .enable(enable),
        .reset(reset),
        .seed(3'b001), // Random seed
        .lfsr_out(not_not_selector)
    );

    lfsr_3bits l1(
        .clock(CLOCK_50),
        .enable(enable),
        .reset(reset),
        .seed(3'b010), // Random seed
        .lfsr_out(colour_logic_selector)
    );

    lfsr_3bits l2(
        .clock(CLOCK_50),
        .enable(enable),
        .reset(reset),
        .seed(3'b100), // Random seed
        .lfsr_out(colour_selector_1)
    );

    lfsr_3bits l3(
        .clock(CLOCK_50),
        .enable(enable),
        .reset(reset),
        .seed(3'b101), // Random seed
        .lfsr_out(colour_selector_2)
    );

    // Set colour to one of the four switches depending on selector value
    assign colour_1 = 1 << colour_selector_1[1:0];
    assign colour_2 = 1 << colour_selector_2[1:0];

    always @(*)
    begin
        case (colour_logic_selector[1:0])
            0: colour_logic_output = colour_1; // <colour1>
            1: colour_logic_output = colour_1 & colour_2; // <colour1> and <colour2>
            2: colour_logic_output = colour_1 | colour_2;// <colour1> or <colour2>
            3: colour_logic_output = colour_1; // <colour1>
        endcase
    end

    always @(*)
    begin
        case (not_not_selector[1:0])
            0: not_not_output = colour_logic_output; // <nothing>
            1: not_not_output = ~colour_logic_output; // not
            2: not_not_output = colour_logic_output; // not not
            3: not_not_output = ~colour_logic_output; // not not not
        endcase
    end

    hex_decoder h1(
        .hex_digit({2'b0, colour_selector_1[1:0]}),
        .segments(HEX1)
    );

    hex_decoder h0(
        .hex_digit({2'b0, colour_selector_2[1:0]}),
        .segments(HEX0)
    );

    hex_decoder h4(
        .hex_digit({2'b0, colour_logic_selector[1:0]}),
        .segments(HEX4)
    );

    hex_decoder h5(
        .hex_digit({2'b0, not_not_selector[1:0]}),
        .segments(HEX5)
    );
endmodule

module begin_game()
;endmodule

module game()
;endmodule