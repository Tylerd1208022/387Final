module add #(
    parameter DATA_WIDTH = 32
) (
    input logic                          clock,
    input logic                          reset,
    input logic                          start,
    input logic [DATA_WIDTH-1:0]         addend1,
    input logic [DATA_WIDTH-1:0]         addend2,
    output logic [DATA_WIDTH-1:0]        sum,
    output logic                         complete
);

    typedef enum logic [1:0] {
        IDLE,
        ADD,
        OUTPUT
    } state_t;

    state_t state, next_state;

    logic [DATA_WIDTH:0] tempSum;

    always_ff @(posedge clock or posedge reset) begin
        if (reset) begin
            state <= IDLE;
            sum <= 0;
            complete <= 0;
        end else begin
            state <= next_state;
        end
    end

    always_comb begin
        next_state = state;
        case (state)
            IDLE: begin
                if (start) begin
                    next_state = ADD;
                end
            end
            ADD: begin
                tempSum = {1'b0, addend1} + {1'b0, addend2};
                next_state = OUTPUT;
            end
            OUTPUT: begin
                sum = tempSum[DATA_WIDTH-1:0];
                complete = 1;
                next_state = IDLE;
            end
            default: next_state = IDLE;
        endcase
    end

endmodule