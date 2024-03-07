module FIR_COMPLEX#(
    parameter TAP_COUNT = 20,
    parameter DATA_WIDTH = 32,
    parameter MULT_PER_CYCLE = 1,
    parameter DECIMATION_FACTOR = 1
)(
    input logic [DATA_WIDTH-1:0]                Iin,
    input logic [DATA_WIDTH-1:0]                Qin,
    input logic                                 clock,
    input logic                                 reset,
    input logic                                 newDataAvailible,
    input logic                                 out_rd_en,
    output logic                          in_rd_en,
    output logic [DATA_WIDTH-1:0]         Iout,
    output logic [DATA_WIDTH-1:0]         Qout,
    output logic                          Done
);

typedef enum logic[1:0] { shifting, multiplying,subDequant ,done } FIR_COMPLEX_STATE;

localparam MULT_CYCLE_COUNT = TAP_COUNT/MULT_PER_CYCLE;

//logic [TAP_COUNT-1:0][DATA_WIDTH-1:0] hReal = {8,7,6,5,4,3,2,1};
//logic [TAP_COUNT-1:0][DATA_WIDTH-1:0] hImage = {17,16,15,14,13,12,11,10};
logic [DATA_WIDTH-1:0]hImage[TAP_COUNT] = '{32'h00000000, 32'h00000000, 32'h00000000, 32'h00000000, 32'h00000000, 32'h00000000, 32'h00000000, 32'h00000000, 32'h00000000, 32'h00000000, 32'h00000000, 32'h00000000, 32'h00000000, 32'h00000000, 32'h00000000, 32'h00000000, 32'h00000000, 32'h00000000, 32'h00000000, 32'h00000000};
logic [DATA_WIDTH-1:0]hReal[TAP_COUNT] = '{32'h00000001, 32'h00000008, 32'hfffffff3, 32'h00000009, 32'h0000000b, 32'hffffffd3, 32'h00000045, 32'hffffffd3,32'hffffffb1, 32'h00000257, 32'h00000257, 32'hffffffb1, 32'hffffffd3, 32'h00000045, 32'hffffffd3, 32'h0000000b, 32'h00000009, 32'hfffffff3, 32'h00000008, 32'h00000001};
FIR_COMPLEX_STATE state_s, state_c;

logic [TAP_COUNT - 1 :0][DATA_WIDTH-1:0] IBuffNow, IBuffNext, QBuffNow, QBuffNext;
logic [7:0] shiftCounter_c, shiftCounter_s, multCounter_c, multCounter_s;
logic [MULT_PER_CYCLE - 1 : 0][DATA_WIDTH - 1:0] subOps1, subOps2;
logic [DATA_WIDTH - 1 : 0] Op1_c, Op1_s, Op2_c, Op2_s, Op3_c, Op3_s, Op4_c, Op4_s, Qout_c, Iout_c;
logic multState_s, multState_c;
logic Done_c;
int i;


always_comb begin
    multState_c = multState_s;
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
    Done_c = 0;
    in_rd_en = 0;
    case (state_s)
    shifting: begin
        in_rd_en = 1;
        if (newDataAvailible == 1'b1) begin
                shiftCounter_c = shiftCounter_s + 1;
                IBuffNext[TAP_COUNT - 1 : 1] = IBuffNow[TAP_COUNT - 2 : 0];
                IBuffNext[0] = Iin;
                QBuffNext[TAP_COUNT - 1 : 1] = QBuffNow[TAP_COUNT - 2 : 0];
                QBuffNext[0] = Qin;
                if (shiftCounter_s >= DECIMATION_FACTOR - 1) begin
                    state_c = multiplying;
                    Qout_c = 0;
                    Iout_c = 0;
                    multCounter_c = 0;
                    shiftCounter_c = 0; 
            end 
        end
    end
    multiplying: begin
        if (multState_s == 0) begin
            for (i = 0; i < MULT_PER_CYCLE; i = i + 1) begin
                subOps1[i] = hReal[multCounter_s * MULT_PER_CYCLE + i] * QBuffNow[multCounter_s * MULT_PER_CYCLE + i];
                subOps2[i] = hImage[multCounter_s * MULT_PER_CYCLE + i] * IBuffNow[multCounter_s * MULT_PER_CYCLE + i];
            end
            for (i = 0; i < MULT_PER_CYCLE; i = i + 1) begin
                Op1_c += subOps1[i];
                Op2_c += subOps2[i];
            end
            multState_c = 1;
        end else begin
            for (i = 0; i < MULT_PER_CYCLE; i = i + 1) begin
                subOps1[i] = hReal[multCounter_s * MULT_PER_CYCLE + i] * IBuffNow[multCounter_s * MULT_PER_CYCLE + i];
                subOps2[i] = hImage[multCounter_s * MULT_PER_CYCLE + i] * QBuffNow[multCounter_s * MULT_PER_CYCLE + i];
            end
            for (i = 0; i < MULT_PER_CYCLE; i = i + 1) begin
                Op3_c += subOps1[i];
                Op4_c += subOps2[i];
            end
            state_c = subDequant;
            multState_c = 0;
        end
    end
    subDequant: begin
        Qout_c = Qout + $signed($signed(Op1_s - Op2_s) / $signed(32'h00000400));
        Iout_c = Iout + $signed($signed(Op3_s - Op4_s) / $signed(32'h00000400));
        Op1_c = 0;
        Op2_c = 0;
        Op3_c = 0;
        Op4_c = 0;
        if (multCounter_s == MULT_CYCLE_COUNT - 1) begin
            multCounter_c = 0;
            state_c = shifting;
            Done_c = 1;
        end else begin
            multCounter_c = multCounter_s + 1;
            state_c = multiplying;
        end
    end
    endcase

end

always_ff @(posedge clock or posedge reset) begin
    if (reset == 1'b1) begin
        state_s <= shifting;
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
        multCounter_s <= 0;
        multState_s <= 0;
        Done <= 0;
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
        multState_s <= multState_c;
        Done <= Done_c;
    end

end
endmodule