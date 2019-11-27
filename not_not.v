module not_not(
    input [9:0] SW, 
    input [2:0] KEY,
    input CLOCK_50,
    output [6:0] HEX0, HEX1, HEX4, HEX5,
    output [3:0] LEDR
);
    wire [2:0] not_not_selector, color_logic_selector, color_selector_1, color_selector_2;
    wire [3:0] color_1, color2;
    reg [3:0] color_logic_output, not_not_output;
    wire reset;

    // Temporary assignment
    assign reset = SW[8];
    assign enable = SW[9];

    assign LEDR[3:0] = not_not_output;

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
        .lfsr_out(color_logic_selector)
    );

    lfsr_3bits l2(
        .clock(CLOCK_50),
        .enable(enable),
        .reset(reset),
        .seed(3'b100), // Random seed
        .lfsr_out(color_selector_1)
    );

    lfsr_3bits l3(
        .clock(CLOCK_50),
        .enable(enable),
        .reset(reset),
        .seed(3'b101), // Random seed
        .lfsr_out(color_selector_2)
    );

    // Set color to one of the four switches depending on selector value
    assign color_1 = 1 << color_selector_1[1:0];
    assign color_2 = 1 << color_selector_2[1:0];

    always @(*)
    begin
        case (color_logic_selector[1:0])
            0: color_logic_output = color_1; // <color1>
            1: color_logic_output = color_1 & color_2; // <color1> and <color2>
            2: color_logic_output = color_1 | color_2;// <color1> or <color2>
            3: color_logic_output = color_2; // <color2>
        endcase
    end

    always @(*)
    begin
        case (not_not_selector[1:0])
            0: not_not_output = color_logic_output; // <nothing>
            1: not_not_output = ~color_logic_output; // not
            2: not_not_output = color_logic_output; // not not
            3: not_not_output = ~color_logic_output; // not not not
        endcase
    end

    hex_decoder h1(
        .hex_digit({2'b0, color_selector_1[1:0]),
        .segments(HEX1)
    );

    hex_decoder h0(
        .hex_digit({2'b0, color_selector_2[1:0]),
        .segments(HEX0)
    );

    hex_decoder h4(
        .hex_digit({2'b0, color_logic_selector[1:0]),
        .segments(HEX4)
    );

    hex_decoder h5(
        .hex_digit({2'b0, not_not_selector[1:0]),
        .segments(HEX5)
    );
endmodule

module begin_game()
;endmodule

module game()
;endmodule