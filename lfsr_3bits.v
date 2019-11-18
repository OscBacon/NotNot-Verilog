// Adapted from: https://www.nandland.com/vhdl/modules/lfsr-linear-feedback-shift-register.html
module lfsr_3bits(
    input clock, enable, reset, 
    input [2:0] seed, 
    output reg [2:0] lfsr_out
);
    wire xnor_wire = lfsr_out[2] ^~ lfsr_out[1];

    always @(posedge clock)
    begin
        if (enable == 1'b1)
            begin
                if (reset == 1'b1 || lfs_out == 3'b111)
                    lfsr_out <= seed;
                else
                    lfsr_out <= {lfsr_out[1:0], xnor_wire};
            end
    end
endmodule