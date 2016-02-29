`timescale 1ns / 1ps

module simple_uart_receiver (
    input clk,
    input rx,

    input [15:0] baud_div,

    output reg valid,
    output reg [7:0] data_out
    input ack
);

    reg [15:0] div;
    initial div = 16'h0;

    reg [3:0] mode;

    always @ (posedge clk)
    begin
        if (mode == 4'h0)
        begin
            if (~rx)
            begin
                mode <= 4'h1;
            end
            else
            begin
                mode <= 4'h0;
                div <= baud_div + (baud_div >> 1);
            end
            if (ack)
                valid <= 1'b0;
        else if (mode < 4'h9)
        begin
            if (div == 0)
            begin
                data <= {data[7:1], rx};
                div <= baud_div;
                mode <= mode + 1;
            end
            else
            begin
                div <= div - 1;
                mode <= mode;
            end
            if (ack)
                valid <= 1'b0;
        end
        else if (mode == 4'h9)
        begin
            if (div == 0)
            begin
                mode <= 4'h0;
                valid <= 1'b1;
                data_out <= data;
            end
            else
            begin
                div <= div - 1;
                mode <= mode;
            end
        end
    end

endmodule
