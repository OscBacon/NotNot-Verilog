module not_not(
    input [9:0] SW, 
    input [2:0] KEY,
    input CLOCK_50,
    output [6:0] HEX0, HEX1, HEX4, HEX5,
    output [3:0] LED,
);

    wire [2:0] not_not_selector, color_logic_selector, color_selector_1, color_selector_2;
    reg [3:0] color_1, color_2, color_logic_output, not_not_output;
    wire reset;

    // Temporary assignment
    assign reset = SW[8];

    lfsr_3bits l0(
        .clock(CLOCK_50),
        .enable(SW[9]),
        .reset(KEY[3]),
        .seed(3'b001), // Random seed
        .lfrs_out(not_not_selector)
    );

    lfsr_3bits l1(
        .clock(CLOCK_50),
        .enable(SW[9]),
        .reset(KEY[3]),
        .seed(3'b010), // Random seed
        .lfrs_out(color_logic_selector)
    );

    lfsr_3bits l2(
        .clock(CLOCK_50),
        .enable(SW[9]),
        .reset(KEY[3]),
        .seed(3'b100), // Random seed
        .lfrs_out(color_selector_1)
    );

    lfsr_3bits l3(
        .clock(CLOCK_50),
        .enable(SW[9]),
        .reset(KEY[3]),
        .seed(3'b101), // Random seed
        .lfrs_out(color_selector_2)
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
    end

    always @(*)
    begin
        case (not_not_selector[1:0])
            0: not_not_output = color_logic_output; // <nothing>
            1: not_not_output = ~color_logic_output; // not
            2: not_not_output = color_logic_output; // not not
            3: not_not_output = ~color_logic_output; // not not not
    end

    hex_decoder h1(
        .hex_digit(color_selector_1),
        .segments(HEX1)
    );

    hex_decoder h0(
        .hex_digit(color_selector_2),
        .segments(HEX0)
    );

    hex_decoder h4(
        .hex_digit(),
        .segments(HEX4)
    );

    hex_decoder h5(
        .hex_digit(),
        .segments(HEX5)
    );
endmodule