module arctan#(
    parameter DATA_WIDTH = 32
)(
    input logic                              clock,
    input logic                              reset,
    input logic                              start,
    input logic [DATA_WIDTH - 1 : 0]         x,
    input logic [DATA_WIDTH - 1 : 0]         y,
    output logic [DATA_WIDTH - 1: 0]         angle,
    output logic                             done
);

    localparam FIRSTQUADRANT = 32'h00000324;
    localparam THIRDQUADRANT = 32'h0000096C;
    localparam logic[31:0] QUANTVAL = 32'h00000400;

    logic division_overflow, division_complete,start_div;
    logic [DATA_WIDTH-1:0] divisor, dividend, quotient;

    divider #(
        .DATA_WIDTH(DATA_WIDTH)
    ) div_inst (
        .clock(clock),
        .reset(reset),
        .start(start_div),
        .divisor(divisor),
        .dividend(dividend),
        .quotient(quotient),
        .complete(division_complete),
        .overflow(division_overflow)
    );

    logic[DATA_WIDTH-1:0] absY;

    typedef enum logic[1:0] {idle, dividing, multiplying, doneCalc} atanState;

    atanState state_c, state_s;
    logic [DATA_WIDTH - 1:0] quotient_c, quotient_s;

    always_comb begin
        done = 0;
        state_c = state_s;
        quotient_c = quotient_s;
        start_div = 0;
        if ($signed(y) > 0) begin
            absY = y + 1;
        end else begin
            absY = (~y) + 2;
        end
        if ($signed(x) >= 0) begin
            divisor = (x + absY);
            dividend = (x - absY) << 10;
        end else begin
            divisor = (absY - x);
            dividend = (x + absY) << 10;
        end
        case (state_s) 
        idle: begin
            if (start == 1'b1) begin
                quotient_c = 0;
                state_c = dividing;
                start_div = 1;
            end
        end
        dividing: begin
            if (division_complete == 1'b1) begin
                state_c = multiplying;
                quotient_c = quotient;// * FIRSTQUADRANT;
            end
        end
        multiplying: begin
            state_c = doneCalc;
            quotient_c = $signed(quotient_s) / $signed(QUANTVAL);
        end
        doneCalc: begin
            if ($signed(x) >= 0) begin
                if ($signed(y) < 0) begin
                    angle =  -1*(FIRSTQUADRANT - quotient_s);
                end else begin
                    angle = (FIRSTQUADRANT - quotient_s);
                end
            end else begin
                if ($signed(y) < 0) begin
                    angle = -1 * (THIRDQUADRANT - quotient_s);
                end else begin
                    angle = (THIRDQUADRANT - quotient_s);
                end
            end
            done = 1;
            state_c = idle;
        end
        endcase

    end

    always_ff @(posedge clock or posedge reset) begin
        if (reset == 1'b1) begin
            state_s <= idle;
            quotient_s <= 0;
        end else begin
            state_s <= state_c;
            quotient_s <= quotient_c;
        end
    end

endmodule