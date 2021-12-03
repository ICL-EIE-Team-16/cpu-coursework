module alu_tb();

logic[31:0] a, b, r;
/*logic zero, positive, negative;
logic[5:0] sa;*/
logic[6:0] op;
/*logic[5:0] op_immediate;
logic[31:0] r_expected;
logic[31:0] r_expected2;*/

/*typedef enum logic[5:0]{
    ADDU = 6'b100001,
    SUBU = 6'b100011,
    SRA = 6'b000011,
    SRAV = 6'b000111,
    SLTU = 6'b101011,
    AND = 6'b100100,
    OR = 6'b100101,
    SLL = 6'b000000,
    SLLV = 6'b000100,
    SRL = 6'b000010,
    SRLV = 6'b000110,
    XOR = 6'b100110
} opcode_decode;*/

typedef enum logic[6:0]{
    ADDIU = 7'd3,
    ADDU = 7'd4
} opcode_internal;

initial begin
    
    assign a = 32'h0008;
    assign b = 32'h000f;

    $display("test start");

    assign op = ADDIU;
    #1
    assert(r ==  a+b) else $display("addiu error");

    assign op = ADDU;
    #1
    assert(r == a+b) else $display("add error");

    $finish;

end 

    /*assign sa = 6'b000001;
    assign op_immediate = 6'b000000;

    $display("Test round 1 start");
    
    assign op = ADDU;
    #1
    assert(r==a+b) else $fatal(1, "Add error, values: a=%d, b=%d, r=%d", a, b, r);
    assert(negative==0 && positive==1 && zero==0) else $display("Flag error: r=%d, negative=%d, positive=%d, zero=%d", r, negative, positive, zero);

    assign op = SUBU;
    #1
    assert(r==a-b) else $fatal(1, "Sub error, values: a=%d, b=%d, r=%d", a, b, r);
    assert(negative==1 && positive==0 && zero==0) else $display("Flag error: r=%d, negative=%d, positive=%d, zero=%d", r, negative, positive, zero);

    assign op = SRA;
    #1
    assert(r==a>>>(sa)) else $fatal(1, "Sra error, values: a=%d, b=%d, r=%d", a, b, r);

    assign op = SRAV;
    #1
    assert(r==a>>>(b[4:0])) else $fatal(1, "Srav error, values: a=%d, b=%d, r=%d", a, b, r);

    assign op = SLTU;
    #1
    assert(r==32'h0001) else $fatal(1, "Slt error, values: a=%d, b=%d, r=%d", a, b, r);

    assign op = AND;
    #1
    assert(r==a&b) else $fatal(1, "And error, values: a=%d, b=%d, r=%d", a, b, r);

    assign op = OR;
    #1
    assert(r==a|b) else $fatal(1, "Or error, values: a=%d, b=%d, r=%d", a, b, r);

    assign op = SLL;
    #1
    assert(r==a<<(sa)) else $fatal(1, "Sll error, values: a=%d, b=%d, r=%d", a, b, r);

    assign op = SLLV;
    #1
    assert(r==a<<(b[4:0])) else $fatal(1, "Sllv error, values: a=%d, b=%d, r=%d", a, b, r);

    assign op = SRL;
    #1
    assert(r==a>>(sa)) else $fatal(1, "Srl error, values: a=%d, b=%d, r=%d", a, b, r);

    assign op = SRLV;
    #1
    assert(r==a>>(b[4:0])) else $fatal(1, "Srlv error, values: a=%d, b=%d, r=%d", a, b, r);

    assign op = XOR;
    #1
    assert(r==a^b) else $fatal(1, "Xor error, values: a=%d, b=%d, r=%d", a, b, r);
    

    $display("Success!");


    assign a = 32'h0000;
    assign b = 32'h0001;
    assign sa = 6'b001111;
    assign op_immediate = 6'b000000;

    $display("Test round 2 start");
    
    assign op = ADDU;
    #1
    assert(r==a+b) else $fatal(1, "Add error, values: a=%d, b=%d, r=%d", a, b, r);
    assert(negative==0 && positive==1 && zero==0) else $display("Flag error: r=%d, negative=%d, positive=%d, zero=%d", r, negative, positive, zero);

    assign op = SUBU;
    #1
    assert(r==a-b) else $fatal(1, "Sub error, values: a=%d, b=%d, r=%d", a, b, r);
    assert(negative==1 && positive==0 && zero==0) else $display("Flag error: r= %d, negative=%d, positive=%d, zero=%d", r, negative, positive, zero);

    assign op = SRA;
    #1
    assert(r==a>>>(sa)) else $fatal(1, "Sra error, values: a=%d, b=%d, r=%d", a, b, r);

    assign op = SRAV;
    #1
    assert(r==a>>>(b[4:0])) else $fatal(1, "Srav error, values: a=%d, b=%d, r=%d", a, b, r);

    assign op = SLTU;
    #1
    assert(r==32'h0001) else $fatal(1, "Slt error, values: a=%d, b=%d, r=%d", a, b, r);

    assign op = AND;
    #1
    assert(r==a&b) else $fatal(1, "And error, values: a=%d, b=%d, r=%d", a, b, r);

    assign op = OR;
    #1
    assert(r==a|b) else $fatal(1, "Or error, values: a=%d, b=%d, r=%d", a, b, r);

    assign op = SLL;
    #1
    assert(r==a<<(sa)) else $fatal(1, "Sll error, values: a=%d, b=%d, r=%d", a, b, r);

    assign op = SLLV;
    #1
    assert(r==a<<(b[4:0])) else $fatal(1, "Sllv error, values: a=%d, b=%d, r=%d", a, b, r);

    assign op = SRL;
    #1
    assert(r==a>>(sa)) else $fatal(1, "Srl error, values: a=%d, b=%d, r=%d", a, b, r);

    assign op = SRLV;
    #1
    assert(r==a>>(b[4:0])) else $fatal(1, "Srlv error, values: a=%d, b=%d, r=%d", a, b, r);

    assign op = XOR;
    #1
    assert(r==a^b) else $fatal(1, "Xor error, values: a=%d, b=%d, r=%d", a, b, r);
    

    $display("Success!");


    assign a = 32'hffff;
    assign b = 32'h0001;
    assign sa = 6'b001111;
    assign op_immediate = 6'b000000;
    
    $display("Test round 3 start");
    
    assign op = ADDU;
    #1
    assert(r==a+b) else $fatal(1, "Add error, values: a=%d, b=%d, r=%d", a, b, r);
    assert(negative==0 && positive==0 && zero==1) else $display("Flag error: r=%d, negative=%d, positive=%d, zero=%d", r, negative, positive, zero);
    //how can r equal 65536 (33'h1ffff) here when r only has 32 bits??

    assign op = SUBU;
    #1
    assert(r==a-b) else $fatal(1, "Sub error, values: a=%d, b=%d, r=%d", a, b, r);
    assert(negative==0 && positive==1 && zero==0) else $display("Flag error: r=%d, negative=%d, positive=%d, zero=%d", r, negative, positive, zero);

    assign op = SRA;
    #1
    assert(r==a>>>(sa)) else $fatal(1, "Sra error, values: a=%d, b=%d, r=%d", a, b, r);

    assign op = SRAV;
    #1
    assert(r==a>>>(b[4:0])) else $fatal(1, "Srav error, values: a=%d, b=%d, r=%d", a, b, r);

    assign op = SLTU;
    #1
    assert(r==32'h0000) else $fatal(1, "Slt error, values: a=%d, b=%d, r=%d", a, b, r);

    assign op = AND;
    assign r_expected = a&b;
    #1
    assert(r==a&b) else $display("And error, values: a=%d, b=%d, r=%d, r_expected=%d", a, b, r, r_expected);
    //this throws an error for some reason even though r does equal a&b, as evidenced by r being equal to r_expected

    assign op = OR;
    #1
    assert(r==a|b) else $fatal(1, "Or error, values: a=%d, b=%d, r=%d", a, b, r);

    assign op = SLL;
    #1
    assert(r==a<<(sa)) else $fatal(1, "Sll error, values: a=%d, b=%d, r=%d", a, b, r);

    assign op = SLLV;
    #1
    assert(r==a<<(b[4:0])) else $fatal(1, "Sllv error, values: a=%d, b=%d, r=%d", a, b, r);

    assign op = SRL;
    #1
    assert(r==a>>(sa)) else $fatal(1, "Srl error, values: a=%d, b=%d, r=%d", a, b, r);

    assign op = SRLV;
    #1
    assert(r==a>>(b[4:0])) else $fatal(1, "Srlv error, values: a=%d, b=%d, r=%d", a, b, r);

    assign op = XOR;
    #1
    assert(r==a^b) else $fatal(1, "Xor error, values: a=%d, b=%d, r=%d", a, b, r);
    

    $display("Success!");


    assign a = 32'h03f5;
    assign b = 32'h0000;
    assign sa = 6'b001111;
    assign op_immediate = 6'b000000;
    
    $display("Test round 4 start");
    
    assign op = ADDU;
    #1
    assert(r==a+b) else $fatal(1, "Add error, values: a=%d, b=%d, r=%d", a, b, r);
    assert(negative==0 && positive==1 && zero==0) else $display("Flag error: r=%d, negative=%d, positive=%d, zero=%d", r, negative, positive, zero);

    assign op = SUBU;
    #1
    assert(r==a-b) else $fatal(1, "Sub error, values: a=%d, b=%d, r=%d", a, b, r);
    assert(negative==0 && positive==1 && zero==0) else $display("Flag error: r0%d, negative=%d, positive=%d, zero=%d", r, negative, positive, zero);

    assign op = SRA;
    #1
    assert(r==a>>>(sa)) else $fatal(1, "Sra error, values: a=%d, b=%d, r=%d", a, b, r);

    assign op = SRAV;
    #1
    assert(r==a>>>(b[4:0])) else $fatal(1, "Srav error, values: a=%d, b=%d, r=%d", a, b, r);

    assign op = SLTU;
    #1
    assert(r==32'h0000) else $fatal(1, "Slt error, values: a=%d, b=%d, r=%d", a, b, r);

    assign op = AND;
    assign r_expected2 = a&&b;
    #1
    assert(r==a&&b) else $display("And error, values: a=%d, b=%d, r=%d, r_expected=%d", a, b, r, r_expected2);
    //this throws an error for some reason even though r does equal a&b, as evidenced by r being equal to r_expected

    assign op = OR;
    #1
    assert(r==a|b) else $fatal(1, "Or error, values: a=%d, b=%d, r=%d", a, b, r);

    assign op = SLL;
    #1
    assert(r==a<<(sa)) else $fatal(1, "Sll error, values: a=%d, b=%d, r=%d", a, b, r);

    assign op = SLLV;
    #1
    assert(r==a<<(b[4:0])) else $fatal(1, "Sllv error, values: a=%d, b=%d, r=%d", a, b, r);

    assign op = SRL;
    #1
    assert(r==a>>(sa)) else $fatal(1, "Srl error, values: a=%d, b=%d, r=%d", a, b, r);

    assign op = SRLV;
    #1
    assert(r==a>>(b[4:0])) else $fatal(1, "Srlv error, values: a=%d, b=%d, r=%d", a, b, r);

    assign op = XOR;
    #1
    assert(r==a^b) else $fatal(1, "Xor error, values: a=%d, b=%d, r=%d", a, b, r);
    

    $display("Success!");



    assign a = 32'h03f5;
    assign b = 32'h0000;
    assign sa = 6'b001111;
    assign op_immediate = 6'b001001;
    
    $display("Test round 5 start");
    
    assign op = ADDU;
    #1
    assert(r==a+b) else $fatal(1, "AddI error, values: a=%d, b=%d, r=%d", a, b, r);
    assert(negative==0 && positive==1 && zero==0) else $display("Flag error: r=%d, negative=%d, positive=%d, zero=%d", r, negative, positive, zero);

    assign op = SUBU;
    #1
    assert(r==a+b) else $fatal(1, "AddI error, values: a=%d, b=%d, r=%d", a, b, r);
    assert(negative==0 && positive==1 && zero==0) else $display("Flag error: r=%d, negative=%d, positive=%d, zero=%d", r, negative, positive, zero);

    assign op = SRA;
    #1
    assert(r==a+b) else $fatal(1, "AddI error, values: a=%d, b=%d, r=%d", a, b, r);

    assign op = SRAV;
    #1
    assert(r==a+b) else $fatal(1, "AddI error, values: a=%d, b=%d, r=%d", a, b, r);

    assign op = SLTU;
    #1
    assert(r==a+b) else $fatal(1, "AddI error, values: a=%d, b=%d, r=%d", a, b, r);

    assign op = AND;
    assign r_expected2 = a&b;
    #1
    assert(r==a+b) else $fatal(1, "AddI error, values: a=%d, b=%d, r=%d", a, b, r);
    //this throws an error for some reason even though r does equal a&b, as evidenced by r being equal to r_expected

    assign op = OR;
    #1
    assert(r==a+b) else $fatal(1, "AddI error, values: a=%d, b=%d, r=%d", a, b, r);

    assign op = SLL;
    #1
    assert(r==a+b) else $fatal(1, "AddI error, values: a=%d, b=%d, r=%d", a, b, r);

    assign op = SLLV;
    #1
    assert(r==a+b) else $fatal(1, "AddI error, values: a=%d, b=%d, r=%d", a, b, r);

    assign op = SRL;
    #1
    assert(r==a+b) else $fatal(1, "AddI error, values: a=%d, b=%d, r=%d", a, b, r);

    assign op = SRLV;
    #1
    assert(r==a+b) else $fatal(1, "AddI error, values: a=%d, b=%d, r=%d", a, b, r);

    assign op = XOR;
    #1
    assert(r==a+b) else $fatal(1, "AddI error, values: a=%d, b=%d, r=%d", a, b, r);
    

    $display("Success!");

    $finish;


end


*/
ALU dut(
    .a(a),
    .b(b),
    .r(r),
    /*.zero(zero),
    .negative(negative),
    .positive(positive),
    .sa(sa),*/
    .op(op)
    /*.op_immediate(op_immediate)*/
);

endmodule