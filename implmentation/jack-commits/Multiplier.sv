module multiply #(
    parameter DATA_WIDTH = 32
) (
    input logic                          clock,
    input logic                          reset,
    input logic                          start,
    input logic [DATA_WIDTH-1:0]         multiplicand,
    input logic [DATA_WIDTH-1:0]         multiplier,
    output logic [2*DATA_WIDTH-1:0]      product,
    output logic                         complete
);

    typedef enum logic [1:0] {
        IDLE,
        MULTIPLY,
        OUTPUT
    } state_t;

    state_t state, next_state;

    logic [2*DATA_WIDTH-1:0] tempProduct;

    always_ff @(posedge clock or posedge reset) begin
        if (reset) begin
            state <= IDLE;
            product <= 0;
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
                    next_state = MULTIPLY;
                end
            end
            MULTIPLY: begin
                tempProduct = multiplicand * multiplier;
                next_state = OUTPUT;
            end
            OUTPUT: begin
                product = tempProduct;
                complete = 1;
                next_state = IDLE;
            end
            default: next_state = IDLE;
        endcase
    end

endmodule



