module divider#(
    parameter DATA_WIDTH = 32
) (
    input logic                         clock,
    input logic                         reset,
    input logic                         start,
    input logic [DATA_WIDTH-1:0]        divisor,
    input logic [DATA_WIDTH-1:0]        dividend,
    output logic [DATA_WIDTH-1:0]       quotient,
    output logic                        complete,
    output logic                        overflow
);

    typedef enum logic[1:0] {idle, calculating, done} state_var;

    logic [DATA_WIDTH:0] CompLHS_c, CompLHS_s;
    logic [DATA_WIDTH-1:0] CompRes, absDiv;
    logic CompGEQ;
    logic [DATA_WIDTH-1:0] divComp;
    state_var state_s, state_c;

    comparator #(
        .DATA_WIDTH(DATA_WIDTH)
        ) comp (
        .Din_L(CompLHS_s),
        .Din_R(divComp),
        .Dout(CompRes),
        .isGreaterEqual(CompGEQ)
    );

  // Internal signals
  
    logic [DATA_WIDTH-1:0] runningQuotient_s, runningQuotient_c;
    logic [5:0]current_c, current_s;
    logic [DATA_WIDTH:0] ZERO = 0;
    logic negative;
    always_comb begin
        negative = dividend[DATA_WIDTH-1] ^ divisor[DATA_WIDTH-1];
        current_c = current_s;
        CompLHS_c = CompLHS_s;
        runningQuotient_c = runningQuotient_s;
        state_c = state_s;
        overflow = 0;
        quotient = ((negative == 1'b0) ? runningQuotient_c : (runningQuotient_c * -1));
        complete = 0;
        absDiv = ($signed(dividend) > 0) ? dividend : (-1 * dividend);
        divComp = (($signed(divisor) > 0) ? divisor : (-1 * divisor));
        case (state_s)
            idle: begin
                current_c = DATA_WIDTH;
                CompLHS_c = {ZERO[DATA_WIDTH-1:0],absDiv[DATA_WIDTH-1]};
                complete = 1;
                if (start == 1'b1) begin
                    runningQuotient_c = 0;
                    state_c = calculating;
                    complete = 0;
                end
               // runningQuotient_c = runningQuotient_s + 1;
            end
            calculating: begin
                current_c = current_s - 1;
                if (current_s != 0) begin
                    CompLHS_c = {CompRes, absDiv[current_s - 1]};
                end
                
                if (current_s < DATA_WIDTH && current_s >= 0) begin
                    runningQuotient_c[current_s] = CompGEQ;
                end
                if (current_s == 0) begin
                    state_c = idle;
                end
            end
        endcase
    end

    always_ff @(posedge clock or posedge reset) begin
            if (reset == 1'b1) begin
                state_s <= idle;
                CompLHS_s <= 0;
                runningQuotient_s <= 0;
                current_s <= 0; 
            end else begin
                state_s <= state_c;
                CompLHS_s <= CompLHS_c;
                runningQuotient_s <= runningQuotient_c;
                current_s <= current_c;
            end
        end
    
endmodule