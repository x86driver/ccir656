module ccir656(input wire clk27M,
                input wire rst,
                input wire [6:0] imgbtn,
                output reg [7:0] data);

parameter [2:0] First3 = 0;
parameter [2:0] Sec16 = 1;
parameter [2:0] Third244 = 2;
parameter [2:0] Fourth2 = 3;
parameter [2:0] Fifth17 = 4;
parameter [2:0] Sixth243 = 5;

reg [2:0] state = First3;
reg [2:0] preamble_state = 0;
reg [2:0] frame_state = 0;

reg transmit208 = 0;
reg transmit1440 = 0;
reg [10:0] transmit_num = 0;

reg [7:0] count = 0;
reg status_1 = 0;
reg status_2 = 0;

always @(posedge clk27M) begin
        case (state)
        First3: begin
                status_1 = 8'hF1;
                status_2 = 8'hEC;
                frame_state = 1;
                count = count + 1;
                if (count == 3) begin
                        count = 0;
                        state = state + 1;
                end
        end
        Sec16: begin
                status_1 = 8'hB6;
                status_2 = 8'hAB;
                frame_state = 1;
                count = count + 1;
                if (count == 16) begin
                        count = 0;
                        state = state + 1;
                end
        end
        endcase
end

always @(transmit208) begin
        if (transmit208 == 1) begin
                data = {imgbtn, 1'b1};
                transmit_num = transmit_num + 1;
                if (transmit_num == 208) begin
                        transmit208 = 0;
                        transmit_num = 0;
                        frame_state = frame_state + 1;
                end
        end
end

always @(transmit1440) begin
        if (transmit1440 == 1) begin
                data = {imgbtn, 1'b1};
                transmit_num = transmit_num + 1;
                if (transmit_num == 1440) begin
                        transmit1440 = 0;
                        transmit_num = 0;
                        frame_state = 0;
                end
        end
end

always @(frame_state) begin
        case (frame_state)
        0: begin
        end
        1: begin
                preamble_state = 1;
        end
        2: begin
                data = status_1;
                frame_state = frame_state + 1;
        end
        3: begin
                transmit208 = 1;
        end
        4: begin
                preamble_state = 1;
        end
        5: begin
                data = status_2;
                frame_state = frame_state + 1;
        end
        6: begin
                transmit1440 = 1;
        end
        7: begin
        end
        endcase
end

always @(preamble_state) begin
        case (preamble_state)
        0: begin
        end
        1: begin
                data = 8'hFF;
                preamble_state = preamble_state + 1;
        end
        2: begin
                data = 8'h0;
                preamble_state = preamble_state + 1;
        end
        3: begin
                data = 8'h0;
                preamble_state = 0;
                frame_state = frame_state + 1;
        end
        endcase
end

endmodule

