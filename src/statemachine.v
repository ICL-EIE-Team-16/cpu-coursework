module statemachine (
input logic reset,
output logic fetch,
output logic exec1,
output logic exec2
);
logic[2:0] state;

always @(posedge clk) begin
    if (reset) begin
        state = 1;
    end
    else
    state[2] = state[1];
    state[1] = state[0];
    state[0] = state[2];
end

always @(*) begin
    fetch = state[0];
    exec1 = state[1];
    exec2 = state[2];
end
endmodule