module statemachine_tb();
 logic clk;
logic reset;
logic halt;
logic fetch;
logic exec1;
logic exec2;

statemachine sm(.clk(clk), .reset(reset), .halt(halt), .fetch());
endmodule