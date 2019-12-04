module text_display(
    input clock,
    input [2:0] not_not_selector, colour_logic_selector, colour_selector_1, colour_selector_2,
    input resetn, draw_enable,
    input start, lose, black,
    output writeEn, done_draw, done_draw_black,
    output [2:0] colour, 
    output [8:0] x,
    output [7:0] y
);
    wire draw_notnot, draw_colour_logic, draw_colour1, draw_colour2;
    wire draw_start, draw_lose, draw_black;

    wire done_draw_notnot, done_draw_colour_logic, done_draw_colour1, done_draw_colour2;
    wire done_draw_lose, done_draw_start;
    
    // Done drawing when colour2 is drawn
    assign done_draw = done_draw_colour2;

    control_text_display ctd(
        .clock(clock),
        .resetn(resetn),
        .done_draw_notnot(done_draw_notnot),
        .done_draw_colour_logic(done_draw_colour_logic),
        .done_draw_colour1(done_draw_colour1),
        .done_draw_colour2(done_draw_colour2),
        .draw_enable(draw_enable),
        .start(start),
        .lose(lose),
        .black(black),
        .writeEn(writeEn),
        .draw_notnot(draw_notnot),
        .draw_colour1(draw_colour1),
        .draw_colour_logic(draw_colour_logic),
        .draw_colour2(draw_colour2),
        .draw_start(draw_start),
        .draw_lose(draw_lose),
        .draw_black(draw_black),
        .done_draw_start(done_draw_start),
        .done_draw_lose(done_draw_lose),
        .done_draw_black(done_draw_black)
    );

    datapath_text_display dtd(
        .clock(clock),
        .resetn(resetn),
        .draw_notnot(draw_notnot),
        .draw_colour1(draw_colour1),
        .draw_colour_logic(draw_colour_logic),
        .draw_colour2(draw_colour2),
        .draw_start(draw_start),
        .draw_lose(draw_lose),
        .draw_black(draw_black),
        .not_not_selector(not_not_selector),
        .colour_logic_selector(colour_logic_selector),
        .colour_selector_1(colour_selector_1),
        .colour_selector_2(colour_selector_2),
        .done_draw_notnot(done_draw_notnot),
        .done_draw_colour_logic(done_draw_colour_logic),
        .done_draw_colour1(done_draw_colour1),
        .done_draw_colour2(done_draw_colour2),
        .done_draw_start(done_draw_start),
        .done_draw_lose(done_draw_lose),
        .done_draw_black(done_draw_black),
        .colour(colour),
        .x(x),
        .y(y)
    );
endmodule

module control_text_display(
    input clock, resetn,
    input done_draw_notnot, done_draw_colour_logic, done_draw_colour1, done_draw_colour2, draw_enable,
    input done_draw_start, done_draw_lose, done_draw_black,
    input start, lose, black,
    output reg writeEn,
    output reg draw_notnot, draw_colour1, draw_colour_logic, draw_colour2,
    output reg draw_start, draw_lose, draw_black
);

    reg [2:0] current_state, next_state;

    localparam
        S_WAIT = 3'd0,
        S_DRAW_NOTNOT = 3'd1,
        S_DRAW_COLOUR1 = 3'd2,
        S_DRAW_COLOUR_LOGIC = 3'd3,
        S_DRAW_COLOUR2 = 3'd4,
        S_DRAW_START = 3'd5,
        S_DRAW_LOSE = 3'd6,
        S_DRAW_BLACK = 3'd7;

    // State table
    always@(*)
    begin: state_table
        case (current_state)
            S_WAIT: begin
                if (draw_enable)
                    next_state = S_DRAW_NOTNOT;
                else if (lose)
                    next_state = S_DRAW_LOSE;
                else if (start)
                    next_state = S_DRAW_START;
                else if (black)
                    next_state = S_DRAW_BLACK;
                else
                    next_state = S_WAIT;
            end
            S_DRAW_NOTNOT: next_state = done_draw_notnot? S_DRAW_COLOUR1 : S_DRAW_NOTNOT;
            S_DRAW_COLOUR1: next_state = done_draw_colour1? S_DRAW_COLOUR_LOGIC : S_DRAW_COLOUR1;
            S_DRAW_COLOUR_LOGIC: next_state = done_draw_colour_logic? S_DRAW_COLOUR2 : S_DRAW_COLOUR_LOGIC;
            S_DRAW_COLOUR2: next_state = done_draw_colour2? S_WAIT: S_DRAW_COLOUR2;
            S_DRAW_START: next_state = done_draw_start ? S_WAIT : S_DRAW_START;
            S_DRAW_LOSE: next_state = done_draw_lose? S_WAIT : S_DRAW_LOSE;
            S_DRAW_BLACK: next_state = done_draw_black ? S_WAIT : S_DRAW_BLACK;
            default: next_state = S_WAIT;
        endcase
    end // state_table

    // Enable registers
    always @(*) begin: enable_signals
        // By default: all signals 0
        draw_notnot = 1'b0;
        draw_colour1 = 1'b0;
        draw_colour_logic = 1'b0;
        draw_colour2 = 1'b0;
        draw_start = 1'b0;
        draw_lose = 1'b0;
        draw_black = 1'b0;
        writeEn = 1'b0;
        
        case (current_state)
            S_DRAW_NOTNOT : begin 
                draw_notnot = 1'b1;
                writeEn = 1'b1;
                end
            S_DRAW_COLOUR1 : begin 
                draw_colour1 = 1'b1;
                writeEn = 1'b1;
                end
            S_DRAW_COLOUR_LOGIC : begin
                draw_colour_logic = 1'b1;
                writeEn = 1'b1;
                end
            S_DRAW_COLOUR2 : begin
                draw_colour2 = 1'b1;
                writeEn = 1'b1;
                end
            S_DRAW_START : begin
                draw_start = 1'b1;
                writeEn = 1'b1;
                end
            S_DRAW_LOSE : begin
                draw_lose = 1'b1;
                writeEn = 1'b1;
                end
            S_DRAW_BLACK : begin
                draw_black = 1'b1;
                writeEn = 1'b1;
                end
        endcase
    end

    // State registers
    always @(posedge clock)
    begin: state_FFs
        if (resetn == 0)
            current_state <= S_WAIT;
        else
            current_state <= next_state;
    end
endmodule


module datapath_text_display(
    input clock, resetn,
    input draw_notnot, draw_colour1, draw_colour_logic, draw_colour2,
    input draw_start, draw_lose, draw_black,
    input [2:0] not_not_selector, colour_logic_selector, colour_selector_1, colour_selector_2,
    output reg done_draw_notnot, done_draw_colour_logic, done_draw_colour1, done_draw_colour2,
    output reg done_draw_start, done_draw_lose, done_draw_black,
    output reg [2:0] colour,
    output reg [8:0] x,
    output reg [7:0] y
);
    wire [7:0] ynotnot = 8'd20;
    wire [7:0] ycolour1 = 8'd75;
    wire [7:0] ycolour_logic = 8'd130;
    wire [7:0] ycolour2 = 8'd185;

    wire [2:0] blank_colour, not_colour, notnot_colour, notnotnot_colour;
    wire [2:0] red_colour, green_colour, blue_colour, yellow_colour;
    wire [2:0] and_colour, or_colour;
    wire [2:0] start_out, lose_out, black_out;
    reg [13:0] colour_address;

    reg[16:0] start_address, lose_address, black_address;

    blankROM n0(
        .address(colour_address),
        .clock(clock),
        .q(blank_colour)
    );

    notROM n1(
        .address(colour_address),
        .clock(clock),
        .q(not_colour)
    );

    notnotROM n2(
        .address(colour_address),
        .clock(clock),
        .q(notnot_colour)
    );

    notnotnotROM n3(
        .address(colour_address),
        .clock(clock),
        .q(notnotnot_colour)
    );

    redROM r0(
        .address(colour_address),
        .clock(clock),
        .q(red_colour)
    );

    greenROM g0(
        .address(colour_address),
        .clock(clock),
        .q(green_colour)
    );

    blueROM b0(
        .address(colour_address),
        .clock(clock),
        .q(blue_colour)
    );

    yellowROM y0(
        .address(colour_address),
        .clock(clock),
        .q(yellow_colour)
    );

    andROM a0(
        .address(colour_address),
        .clock(clock),
        .q(and_colour)
    );

    orROM o0(
        .address(colour_address),
        .clock(clock),
        .q(or_colour)
    );

    startROM s0(
        .address(start_address),
        .clock(clock),
        .q(start_out)
    );

    loseROM l0(
        .address(lose_address),
        .clock(clock),
        .q(lose_out)
    );

    blackROM bl0(
        .address(black_address),
        .clock(clock),
        .q(black_out)
    );

    always @(posedge clock)
    begin
        if (resetn == 0)
        begin
            done_draw_notnot <= 1'b0;
            done_draw_colour1 <= 1'b0;
            done_draw_colour_logic <= 1'b0;
            done_draw_colour2 <= 1'b0;
            done_draw_start <= 1'b0;
            done_draw_lose <= 1'b0;
            done_draw_black <= 1'b0;
            colour_address <= 14'b0;
            start_address <= 17'b0;
            lose_address <= 17'b0;
            black_address <= 17'b0;
            colour <= 3'b0;
            x <= 9'b0;
            y <= 8'b0;
        end
        else begin
            if (draw_notnot) begin
                done_draw_colour2 <= 1'b0;
                done_draw_start <= 1'b0;
                done_draw_lose <= 1'b0;
                done_draw_black <= 1'b0;

                case (not_not_selector[1:0])
                    0: colour <= blank_colour;
                    1: colour <= not_colour;
                    2: colour <= notnot_colour;
                    3: colour <= notnotnot_colour;
                endcase

                x <= colour_address % 320;
                y <= ynotnot + colour_address / 320;

                colour_address <= colour_address + 1;

                if (colour_address == 14'd16000) 
                begin
                    done_draw_notnot <= 1'b1;
                    colour_address <= 14'd0;
                end
            end
            
            if (draw_colour1) begin
                done_draw_notnot <= 1'b0;

                case (colour_selector_1[1:0])
                    0: colour <= red_colour;
                    1: colour <= green_colour;
                    2: colour <= blue_colour;
                    3: colour <= yellow_colour;
                endcase

                x <= colour_address % 320;
                y <= ycolour1 + colour_address / 320;

                colour_address <= colour_address + 1;

                if (colour_address == 14'd16000)
                begin
                    done_draw_colour1 <= 1'b1;
                    colour_address <= 14'd0;
                end
            end 
            
            if (draw_colour_logic) begin
                done_draw_colour1 <= 1'b0;

                case (colour_logic_selector[1:0])
                    0: colour <= blank_colour;
                    1: colour <= and_colour;
                    2: colour <= or_colour;
                    3: colour <= blank_colour;
                endcase

                x <= colour_address % 320;
                y <= ycolour_logic + colour_address / 320;

                colour_address <= colour_address + 1;

                if (colour_address == 14'd16000)
                begin
                    done_draw_colour_logic <= 1'b1;
                    colour_address <= 14'd0;
                end
            end
            
            if (draw_colour2) begin
                done_draw_colour_logic <= 1'b0;

                // If the logic only has one colour, just display a blank
                if (colour_logic_selector[1:0] == 2'd0 || colour_logic_selector[1:0] == 2'd3)
                    colour <= blank_colour; 
                else begin
                    case (colour_selector_2[1:0])
                        0: colour <= red_colour;
                        1: colour <= green_colour;
                        2: colour <= blue_colour;
                        3: colour <= yellow_colour;
                    endcase
                end

                x <= colour_address % 320;
                y <= ycolour2 + colour_address / 320;

                colour_address <= colour_address + 1;

                if (colour_address == 14'd16000)
                begin
                    done_draw_colour2 <= 1'b1;
                    colour_address <= 14'd0;
                end
            end 
            
            if (draw_start) begin
                colour <= start_out;
                x <= start_address % 320;
                y <= start_address / 320;

                start_address <= start_address + 1;

                if (start_address == 17'd76800)
                begin
                    done_draw_start <= 1'b1;
                    start_address <= 17'd0;
                end
            end 
            
            if (draw_lose) begin
                colour <= lose_out;
                x <= lose_address % 320;
                y <= lose_address / 320;

                lose_address <= lose_address + 1;

                if (lose_address == 17'd76800)
                begin
                    done_draw_lose <= 1'b1;
                    lose_address <= 17'd0;
                end
            end

            if (draw_black) begin
                colour <= black_out;
                x <= black_address % 320;
                y <= black_address / 320;

                black_address <= black_address + 1;

                if (black_address == 17'd76800)
                begin
                    done_draw_black <= 1'b1;
                    black_address <= 17'd0;
                end
            end
        end
    end    
endmodule