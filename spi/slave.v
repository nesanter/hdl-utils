`timescale 1ns / 1ps

/* spi_slave.sv
 *
 * Author: Noah Santer (santerkrupp@gmail.com)
 *
 * Ultra-simple RX-only SPI slave
 * Configured for:
 *   8-bit
 *   Capture on rising edge (CPOL = CPHA = 0)
 */

module spi_slave (
    input clk,

    // SPI
    input sck,
    input ss,
    input mosi,

    // output
    output reg [7:0] data,
    output strobe
);

    reg [2:0] counter;
    initial counter = 3'h0;

    reg d_sck;
    reg strobe_sck;
    reg abort_sck;

    initial d_sck = 1'b0;
    initial strobe_sck = 1'b0;
    initial abort_sck = 1'b0;
    
    always @ (posedge sck)
    begin
        if (~ss)
        begin
            if (mosi)
                d_sck <= ~d_sck;
            strobe_sck <= ~strobe_sck;
            abort_sck <= 1'b0;
        end
        else
            abort_sck <= 1'b1;
    end

    reg strobe_gate;
    reg [2:0] strobe_sync, d_sync, abort_sync;

    initial data = 8'h0;
    initial strobe_gate = 1'b0;
    initial strobe_sync = 3'h0;
    initial d_sync <= 3'h0;
    initial abort_sync <= 3'h0;

    always @ (posedge clk)
    begin
        strobe_sync <= {strobe_sync[1:0], strobe_sck};
        d_sync <= {d_sync[1:0], d_sck};
        abort_sync <= {abort_sync[1:0], abort_sck};

        if (abort_sync[2] ^ abort_sync[1])
        begin
            counter <= 3'h0;
            strobe_gate <= 1'b0;
        end 
        else if (strobe_sync[2] ^ strobe_sync[1])
        begin
            data <= {data[6:0], d_sync[2] ^ d_sync[1]};
            counter <= counter + 1;
            if (counter == 3'h7)
                strobe_gate <= 1'b1;
            else
                strobe_gate <= 1'b0;
        end
        else
            strobe_gate <= 1'b0;

        
    end

    assign strobe = strobe_gate;// & (strobe_sync[2] ^ strobe_sync[1]));

endmodule

module spi_slave_tb (
);

    reg clk, sck, ss, mosi;
    initial clk = 1'b0;
    initial sck = 1'b0;
    initial ss = 1'b0;
    initial mosi = 1'b0;

    wire strobe;
    wire [7:0] data;

    spi_slave S (
        .clk(clk),
        .sck(sck),
        .ss(ss),
        .mosi(mosi),
        .data(data),
        .strobe(strobe)
    );

    always #27 sck <= ~sck;
    always #5 clk <= ~clk;

    always @ (posedge clk)
    begin
        if (strobe)
            $display(data);
    end

    always @ (posedge sck)
    begin
        mosi <= ~mosi;
    end

    initial #10000 $finish;

endmodule
