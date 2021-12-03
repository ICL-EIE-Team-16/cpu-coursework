module statemachine (
input logic reset,
input logic halt,
output logic fetch,
output logic exec1,
output logic exec2
);
logic[2:0] state;

always @(posedge clk) begin
    if (reset) begin
        state = 1;
    end
    else if (~halt) begin
    state[2] <= state[1];
    state[1] <= state[0];
    state[0] <= state[2];
    end
end

always @(*) begin
    fetch = state[0];
    exec1 = state[1];
    exec2 = state[2];
end
endmodule