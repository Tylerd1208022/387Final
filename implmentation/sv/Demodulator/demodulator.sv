module demodulator#(
    parameter DATA_WIDTH = 32
) (
    input logic                         clock,
    input logic                         reset,
    input logic                         start,
    input logic [DATA_WIDTH - 1 : 0]    x,
    input logic [DATA_WIDTH - 1 : 0]    y,
    input logic [DATA_WIDTH - 1 : 0]    gain,
    output logic                        done,
    output logic                        fir_cmplx_rd_en,
    output logic [DATA_WIDTH - 1 : 0]   demod
);

    logic start_atan, atan_done;
    logic [DATA_WIDTH-1:0] angle, angle_c, angle_s;

    

    logic [DATA_WIDTH-1:0] lastX_c, lastX_s, lastY_s, lastY_c;
    logic [DATA_WIDTH-1:0] op1_c, op1_s , op2_c, op2_s, op3_c, op3_s, op4_c, op4_s;
    logic [DATA_WIDTH-1:0] dop1_c, dop1_s, dop2_c, dop2_s, dop3_c, dop3_s, dop4_c, dop4_s, r_c, r_s, i_c, i_s;

    typedef enum logic[1:0] {idle, dequantize, atancalc, doneCalc} demodstate;
    demodstate state_c, state_s;

    arctan #(
        .DATA_WIDTH(DATA_WIDTH)
    ) atan_inst (
        .clock(clock),
        .reset(reset),
        .start(start_atan),
        .x(r_c),
        .y(i_c),
        .angle(angle),
        .done(atan_done)
    );

    always_comb begin
        fir_cmplx_rd_en = 0;
        op1_c = op1_s;
        op2_c = op2_s;
        op3_c = op3_s;
        op4_c = op4_s;
        dop1_c = dop1_s;
        dop2_c = dop2_s;
        dop3_c = dop3_s;
        dop4_c = dop4_s;
        angle_c = angle_s;
        lastX_c = lastX_s;
        lastY_c = lastY_s;
        r_c = r_s;
        i_c = i_s;
        start_atan = 0;
        done = 0;
        state_c = state_s;
        case (state_s)
        idle:begin
            fir_cmplx_rd_en = 1;
            op1_c = lastX_s * x;
            op2_c = -1 * lastY_s * y;
            op3_c = lastX_s * y;
            op4_c = -1 * lastY_s * x;
            if (start == 1'b1) begin
                state_c = dequantize;
                lastX_c = x;
                lastY_c = y;
            end
        end
        dequantize: begin
            dop1_c = $signed(op1_s)/$signed(32'h00000400);
            dop2_c = $signed(op2_s)/$signed(32'h00000400);
            dop3_c = $signed(op3_s)/$signed(32'h00000400);
            dop4_c = $signed(op4_s)/$signed(32'h00000400);
            r_c = dop1_c - dop2_c;
            i_c = dop3_c + dop4_c;
            start_atan = 1;
            state_c = atancalc;
        end
        atancalc: begin
            if (atan_done == 1'b1) begin
                angle_c = angle;
                state_c = doneCalc;
            end
        end
        doneCalc: begin
            done = 1;
            demod = $signed(gain * angle_s) / $signed(32'h00000400);
            state_c = idle;
        end
        endcase
    end

    always_ff @(posedge clock or posedge reset) begin

        if (reset == 1'b1) begin
            state_s <= idle;
            op1_s <= 0;
            op2_s <= 0;
            op3_s <= 0;
            op4_s <= 0;
            dop1_s <= 0;
            dop2_s <= 0;
            dop3_s <= 0;
            dop4_s <= 0;
            angle_s <= 0;
            lastX_s <= 0;
            lastY_s <= 0;
            i_s <= 0;
            r_s <= 0;
        end else begin
            state_s <= state_c;
            op1_s <= op1_c;
            op2_s <= op2_c;
            op3_s <= op3_c;
            op4_s <= op4_c;
            dop1_s <= dop1_c;
            dop2_s <= dop2_c;
            dop3_s <= dop3_c;
            dop4_s <= dop4_c;
            angle_s <= angle_c;
            lastX_s <= lastX_c;
            lastY_s <= lastY_c;
            r_s <= r_c;
            i_s <= i_c;
        end

    end


endmodule