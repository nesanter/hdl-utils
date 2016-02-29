`timescale 1ns / 1ps

module vga_timing_controller #(
    DIV = 0,
    HFP = 0,
    HSP = 0,
    HACT = 0,
    HBP = 0,
    VFP = 0,
    VSP = 0,
    VACT = 0,
    VBP = 0
) (
    input clk,

    output reg vclk,
    output reg hs,
    output reg vs,
    output reg act,
    output reg sync,
    output reg adv
);
    reg [($clog2(DIV)-1):0] div;
    reg [($clog2(HACT)-1):0] h;
    reg [($clog2(VACT)-1):0] v;

    reg [1:0] hmode, vmode;

    always @ (posedge clk)
    begin
        if (div == 0)
        begin
            if (h == 0)
            begin
                case (hm)
                    2'h0: h <= HFP - 1;
                    2'h1: h <= HSP - 1;
                    2'h2: h <= HACT - 1;
                    2'h3:
                    begin
                        h <= HBP - 1;
                        if (v == 0)
                        begin
                            case (vm)
                                2'h0: v <= VFP - 1;
                                2'h1: v <= VSP - 1;
                                2'h2: v <= VACT - 1;
                                2'h3: v <= VBP - 1;
                            endcase
                        end
                        else
                        begin
                            v <= v - 1;
                        end
                    end
                endcase
                hm <= hm + 1;
            end
            else
            begin
                h <= h - 1;
            end

            hs <= (hm == 2'h1);
            vs <= (vm == 2'h1);
            act <= (hm == 2'h2) && (vm == 2'h2);

            adv <= 1'b1;
            vclk <= ~vclk;
        end
        else
        begin
            if (div == (div >> 1))
                vclk <= ~vclk;
            div <= DIV;
            adv <= 1'b0;
        end
    end

endmodule
