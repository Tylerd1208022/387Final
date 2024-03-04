module FIR_COMPLEX#(
    parameter TAP_COUNT = 32,
    parameter DATA_WIDTH = 32,
    parameter MULT_PER_CYCLE = 1,
    parameter DECIMATION_FACTOR = 1
)(
    input logic [DATA_WIDTH-1:0]                Iin,
    input logic [DATA_WIDTH-1:0]                Qin,
    input logic                                 clock,
    input logic                                 reset,
    input logic                                 newDataAvailible,
    input logic [TAP_COUNT-1:0][DATA_WIDTH-1:0]                hReal,
    input logic [TAP_COUNT-1:0][DATA_WIDTH-1:0]                hImage,
    output logic [DATA_WIDTH-1:0]         Iout,
    output logic [DATA_WIDTH-1:0]         Qout,
    output logic                          Done
);

typedef enum logic[1:0] { shifting, multiplying,subDequant ,done } FIR_COMPLEX_STATE;

localparam MULT_CYCLE_COUNT = TAP_COUNT/MULT_PER_CYCLE;
FIR_COMPLEX_STATE state_s, state_c;

logic [TAP_COUNT - 1 :0][DATA_WIDTH-1:0] IBuffNow, IBuffNext, QBuffNow, QBuffNext;
logic [7:0] shiftCounter_c, shiftCounter_s, multCounter_c, multCounter_s;

logic [MULT_PER_CYCLE - 1 : 0][DATA_WIDTH - 1:0] subOps1, subOps2;
logic [DATA_WIDTH - 1 : 0] Op1_c, Op1_s, Op2_c, Op2_s, Op3_c, Op3_s, Op4_c, Op4_s, Qout_c, Iout_c;
int i;


always_comb begin

    state_c = state_s;
    IBuffNext = IBuffNow;
    QBuffNext = QBuffNow;
    shiftCounter_c = shiftCounter_s;
    multCounter_c = multCounter_s;
    Op1_c = Op1_s;
    Op2_c = Op2_s;
    Op3_c = Op3_s;
    Op4_c = Op4_s;
    Qout_c = Qout;
    Iout_c = Iout;
    done = 0;
    case (state_s)
    shifting: begin
        done = 1;
        if (newDataAvailible == 1b'1) begin
            shiftCounter_c = shiftCounter_s + 1;
            IBuffNext[TAP_COUNT - 1 : 1] = IBuffNow[TAP_COUNT - 2 : 0];
            IBuffNext[0] = Iin;
            QBuffNext[TAP_COUNT - 1 : 1] = QBuffNow[TAP_COUNT - 2 : 0];
            QBuffNext[0] = Qin;
            if (shiftCounter_s == DECIMATION_FACTOR) begin
                state_c = multiplying;
                multCounter_c = 0;
                shiftCounter_c = 0;
                Qout_c = 0;
                Iout_c = 0;
            end
        end
    end
    multiplying: begin
        if (multCounter_s % 2 == 0) begin
            for (i = 0; i < MULT_PER_CYCLE) begin
                subOps1[i] = hReal[multCounter_s * MULT_PER_CYCLE + i] * QBuffNow[multCounter_s * MULT_PER_CYCLE + i];
                subOps2[i] = hImage[multCounter_s * MULT_PER_CYCLE + i] * IBuffNow[multCounter_s * MULT_PER_CYCLE + i];
            end
            for (i = 0; i < MULT_PER_CYCLE) begin
                Op1_c += subOps1[i];
                Op2_c += subOps2[i];
            end
        end else begin
            for (i = 0; i < MULT_PER_CYCLE) begin
                subOps1[i] = hReal[multCounter_s * MULT_PER_CYCLE + i] * IBuffNow[multCounter_s * MULT_PER_CYCLE + i];
                subOps2[i] = hImage[multCounter_s * MULT_PER_CYCLE + i] * QBuffNow[multCounter_s * MULT_PER_CYCLE + i];
            end
            for (i = 0; i < MULT_PER_CYCLE) begin
                Op3_c += subOps1[i];
                Op4_c += subOps2[i];
            end
            state_c = subDequant;
        end
    end
    subDequant: begin
        Qout_c = Qout + $signed($signed(Op1_s - Op2_s) / $signed(32'h00000400));
        Iout_c = Iout + $signed($signed(Op3_s - Op3_s) / $signed(32'h00000400));
        if (multCounter_s == MULT_CYCLE_COUNT - 1) begin
            multCounter_c = 0;
            state_c = done;
        end else begin
            multCounter_c = multCounter_s + 1;
            state_c = multiplying;
        end
    end
    done: begin
        done = 1;
        state_c = shifting;
        multCounter_c = 0;
        shiftCounter_c = 0;
    end
    endcase

end

always_ff @(posedge clock or posedge reset) begin
    if (reset == 1'b1) begin
        state_s <= idle;
        shiftCounter_s <= 0;
        multCounter_s <= 0;
        IBuffNow <= 0;
        QBuffNow <= 0;
        Op1_s <= 0;
        Op2_s <= 0;
        Op3_s <= 0;
        Op4_s <= 0;
        Iout <= 0;
        Qout <= 0;
    end else begin
        state_s <= state_c;
        shiftCounter_s <= shiftCounter_c;
        multCounter_s <= multCounter_c;
        IBuffNow <= IBuffNext;
        QBuffNow <= QBuffNext;
        Op1_s <= Op1_c;
        Op2_s <= Op2_c;
        Op3_s <= Op3_c;
        Op4_s <= Op4_c;
        Iout <= Iout_c;
        Qout <= Qout_c;
    end

end

endmodule