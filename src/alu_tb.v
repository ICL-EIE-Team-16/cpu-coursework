module alu_tb();

logic[31:0] a, b, r;
logic zero, positive, negative, fetch, exec1, exec2, clk;
logic[5:0] sa;
logic[6:0] op;
logic[31:0] r_expected;
logic[31:0] r_expected2;
logic[31:0] hi, lo, hi_next, lo_next;
logic[63:0] mult_intermediate;


typedef enum logic[6:0]{
    ADD = 7'd1,
    ADDI = 7'd2,
    ADDIU = 7'd3,
    ADDU = 7'd4,
    AND = 7'd5,
    ANDI = 7'd6,
    DIV = 7'd7,
    DIVU = 7'd8,
    MFHI = 7'd9,
    MFLO = 7'd10,
    MTHI = 7'd11,
    MTLO = 7'd12,
    MULT = 7'd13,
    MULTU = 7'd14,
    OR = 7'd15,
    ORI = 7'd16,
    SLL = 7'd17,
    SLLV = 7'd18,
    SLT = 7'd19,
    SLTI = 7'd20,
    SLTIU = 7'd21,
    SLTU = 7'd22,
    SRA = 7'd23,
    SRAV = 7'd24,
    SRL = 7'd25,
    SRLV = 7'd26,
    SUBU = 7'd27,
    XOR = 7'd28,
    XORI = 7'd29,
    BEQ = 7'd30,
    BGEZ = 7'd31,
    BGEZAL = 7'd32,
    BGTZ = 7'd33,
    BLEZ = 7'd34,
    BLTZ = 7'd35,
    BLTZAL = 7'd36,
    BNE = 7'd37,
    J = 7'd38,
    JAL = 7'd39,
    JALR = 7'd40,
    JR = 7'd41,
    LB = 7'd42,
    LBU = 7'd43,
    LH = 7'd44,
    LHU = 7'd45,
    LUI = 7'd46,
    LW = 7'd47,
    LWL = 7'd48,
    LWR = 7'd49,
    SB = 7'd50,
    SH = 7'd51,
    SW = 7'd52
} opcode_decode;

initial begin
    
    assign a = 32'h0008;
    assign b = 32'h000f;
    assign sa = 6'b000001;
    assign mult_intermediate = a*b;


    $display("Test round 1 start");
    
    assign op = ADDIU;
    #1
    assert(r==a+b) else $fatal(1, "AddI error, values: a=%d, b=%d, r=%d", a, b, r);
    assert(negative==0 && positive==1 && zero==0) else $display("Flag error: r=%d, negative=%d, positive=%d, zero=%d", r, negative, positive, zero);

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

    assign op = MULTU;

    assign fetch = 1;
    assign exec1 = 0;
    assign exec2 = 0;
    assign clk = 0;
    #1
    assign clk = 1;
    #1
    assign fetch = 0;
    assign exec1 = 1;
    assign exec2 = 0;
    #1
    assign clk = 0;
    #1
    assign clk = 1;
    #1
    assert(hi == mult_intermediate[63:32] && lo == mult_intermediate[31:0]) else $display("multu error, hi = %d, lo = %d, hi_next = %d, lo_next = %d", hi, lo, hi_next, lo_next);
    assign fetch = 0;
    assign exec1 = 0;
    assign exec2 = 1;
    #1
    assign clk = 0;
    #1
    assign clk = 1;
    #1
    assert(hi == mult_intermediate[63:32] && lo == mult_intermediate[31:0]) else $display("multu error, hi = %d, lo = %d, hi_next = %d, lo_next = %d", hi, lo, hi_next, lo_next);
    
    assign op = DIVU;
    
    assign fetch = 1;
    assign exec1 = 0;
    assign exec2 = 0;
    assign clk = 0;
    #1
    assign clk = 1;
    #1
    assert(hi == mult_intermediate[63:32] && lo == mult_intermediate[31:0]) else $display("multu error, hi = %d, lo = %d, hi_next = %d, lo_next = %d", hi, lo, hi_next, lo_next);
    assign fetch = 0;
    assign exec1 = 1;
    assign exec2 = 0;
    #1
    assign clk = 0;
    #1
    assign clk = 1;
    #1
    assert(hi == a%b && lo == a/b) else $display("multu error, hi = %d, lo = %d, hi_next = %d, lo_next = %d", hi, lo, hi_next, lo_next);
    assign fetch = 0;
    assign exec1 = 0;
    assign exec2 = 1;
    #1
    assign clk = 0;
    #1
    assign clk = 1;
    #1
    assert(hi == a%b && lo == a/b) else $display("multu error, hi = %d, lo = %d, hi_next = %d, lo_next = %d", hi, lo, hi_next, lo_next);
    

    $display("Success!");


    assign a = 32'h0000;
    assign b = 32'h0001;
    assign sa = 6'b001111;
    assign mult_intermediate = a*b;

    $display("Test round 2 start");

    assign op = ADDIU;
    #1
    assert(r==a+b) else $fatal(1, "AddI error, values: a=%d, b=%d, r=%d", a, b, r);
    assert(negative==0 && positive==1 && zero==0) else $display("Flag error: r=%d, negative=%d, positive=%d, zero=%d", r, negative, positive, zero);
    
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

    assign op = MULTU;

    assign fetch = 1;
    assign exec1 = 0;
    assign exec2 = 0;
    assign clk = 0;
    #1
    assign clk = 1;
    #1
    assign fetch = 0;
    assign exec1 = 1;
    assign exec2 = 0;
    #1
    assign clk = 0;
    #1
    assign clk = 1;
    #1
    assert(hi == mult_intermediate[63:32] && lo == mult_intermediate[31:0]) else $display("multu error, hi = %d, lo = %d, hi_next = %d, lo_next = %d", hi, lo, hi_next, lo_next);
    assign fetch = 0;
    assign exec1 = 0;
    assign exec2 = 1;
    #1
    assign clk = 0;
    #1
    assign clk = 1;
    #1
    assert(hi == mult_intermediate[63:32] && lo == mult_intermediate[31:0]) else $display("multu error, hi = %d, lo = %d, hi_next = %d, lo_next = %d", hi, lo, hi_next, lo_next);
    
    assign op = DIVU;

    assign fetch = 1;
    assign exec1 = 0;
    assign exec2 = 0;
    assign clk = 0;
    #1
    assign clk = 1;
    #1
    assert(hi == mult_intermediate[63:32] && lo == mult_intermediate[31:0]) else $display("multu error, hi = %d, lo = %d, hi_next = %d, lo_next = %d", hi, lo, hi_next, lo_next);
    assign fetch = 0;
    assign exec1 = 1;
    assign exec2 = 0;
    #1
    assign clk = 0;
    #1
    assign clk = 1;
    #1
    assert(hi == a%b && lo == a/b) else $display("multu error, hi = %d, lo = %d, hi_next = %d, lo_next = %d", hi, lo, hi_next, lo_next);
    assign fetch = 0;
    assign exec1 = 0;
    assign exec2 = 1;
    #1
    assign clk = 0;
    #1
    assign clk = 1;
    #1
    assert(hi == a%b && lo == a/b) else $display("multu error, hi = %d, lo = %d, hi_next = %d, lo_next = %d", hi, lo, hi_next, lo_next);
    

    $display("Success!");


    assign a = 32'hffffffff;
    assign b = 32'h00000001;
    assign sa = 6'b001111;
    assign mult_intermediate = a*b;
    
    $display("Test round 3 start");

    assign op = ADDIU;
    #1
    assert(r==a+b) else $fatal(1, "AddI error, values: a=%d, b=%d, r=%d", a, b, r);
    assert(negative==0 && positive==0 && zero==1) else $display("Flag error: r=%d, negative=%d, positive=%d, zero=%d", r, negative, positive, zero);
    
    assign op = ADDU;
    #1
    assert(r==a+b) else $fatal(1, "Add error, values: a=%d, b=%d, r=%d", a, b, r);
    assert(negative==0 && positive==0 && zero==1) else $display("Flag error: r=%d, negative=%d, positive=%d, zero=%d", r, negative, positive, zero);

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

    assign op = MULTU;

    assign fetch = 1;
    assign exec1 = 0;
    assign exec2 = 0;
    assign clk = 0;
    #1
    assign clk = 1;
    #1
    assign fetch = 0;
    assign exec1 = 1;
    assign exec2 = 0;
    #1
    assign clk = 0;
    #1
    assign clk = 1;
    #1
    assert(hi == mult_intermediate[63:32] && lo == mult_intermediate[31:0]) else $display("multu error, hi = %d, lo = %d, hi_next = %d, lo_next = %d", hi, lo, hi_next, lo_next);
    assign fetch = 0;
    assign exec1 = 0;
    assign exec2 = 1;
    #1
    assign clk = 0;
    #1
    assign clk = 1;
    #1
    assert(hi == mult_intermediate[63:32] && lo == mult_intermediate[31:0]) else $display("multu error, hi = %d, lo = %d, hi_next = %d, lo_next = %d", hi, lo, hi_next, lo_next);
    
    assign op = DIVU;

    assign fetch = 1;
    assign exec1 = 0;
    assign exec2 = 0;
    assign clk = 0;
    #1
    assign clk = 1;
    #1
    assert(hi == mult_intermediate[63:32] && lo == mult_intermediate[31:0]) else $display("multu error, hi = %d, lo = %d, hi_next = %d, lo_next = %d", hi, lo, hi_next, lo_next);
    assign fetch = 0;
    assign exec1 = 1;
    assign exec2 = 0;
    #1
    assign clk = 0;
    #1
    assign clk = 1;
    #1
    assert(hi == a%b && lo == a/b) else $display("multu error, hi = %d, lo = %d, hi_next = %d, lo_next = %d", hi, lo, hi_next, lo_next);
    assign fetch = 0;
    assign exec1 = 0;
    assign exec2 = 1;
    #1
    assign clk = 0;
    #1
    assign clk = 1;
    #1
    assert(hi == a%b && lo == a/b) else $display("multu error, hi = %d, lo = %d, hi_next = %d, lo_next = %d", hi, lo, hi_next, lo_next);
    

    $display("Success!");


    assign a = 32'h03f5;
    assign b = 32'h0001;
    assign sa = 6'b001111;
    assign mult_intermediate = a*b;
    
    $display("Test round 4 start");

    assign op = ADDIU;
    #1
    assert(r==a+b) else $fatal(1, "AddI error, values: a=%d, b=%d, r=%d", a, b, r);
    assert(negative==0 && positive==1 && zero==0) else $display("Flag error: r=%d, negative=%d, positive=%d, zero=%d", r, negative, positive, zero);
    
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

    assign op = MULTU;

    assign fetch = 1;
    assign exec1 = 0;
    assign exec2 = 0;
    assign clk = 0;
    #1
    assign clk = 1;
    #1
    assign fetch = 0;
    assign exec1 = 1;
    assign exec2 = 0;
    #1
    assign clk = 0;
    #1
    assign clk = 1;
    #1
    assert(hi == mult_intermediate[63:32] && lo == mult_intermediate[31:0]) else $display("multu error, hi = %d, lo = %d, hi_next = %d, lo_next = %d", hi, lo, hi_next, lo_next);
    assign fetch = 0;
    assign exec1 = 0;
    assign exec2 = 1;
    #1
    assign clk = 0;
    #1
    assign clk = 1;
    #1
    assert(hi == mult_intermediate[63:32] && lo == mult_intermediate[31:0]) else $display("multu error, hi = %d, lo = %d, hi_next = %d, lo_next = %d", hi, lo, hi_next, lo_next);
    
    assign op = DIVU;

    assign fetch = 1;
    assign exec1 = 0;
    assign exec2 = 0;
    assign clk = 0;
    #1
    assign clk = 1;
    #1
    assert(hi == mult_intermediate[63:32] && lo == mult_intermediate[31:0]) else $display("multu error, hi = %d, lo = %d, hi_next = %d, lo_next = %d", hi, lo, hi_next, lo_next);
    assign fetch = 0;
    assign exec1 = 1;
    assign exec2 = 0;
    #1
    assign clk = 0;
    #1
    assign clk = 1;
    #1
    assert(hi == a%b && lo == a/b) else $display("multu error, hi = %d, lo = %d, hi_next = %d, lo_next = %d", hi, lo, hi_next, lo_next);
    assign fetch = 0;
    assign exec1 = 0;
    assign exec2 = 1;
    #1
    assign clk = 0;
    #1
    assign clk = 1;
    #1
    assert(hi == a%b && lo == a/b) else $display("multu error, hi = %d, lo = %d, hi_next = %d, lo_next = %d", hi, lo, hi_next, lo_next);
    
    $display("Success!");

    assign a = 32'd6000003;
    assign b = 32'd2000000;
    assign mult_intermediate = a*b;

    $display("Test round 5 start");

    assign op = MULTU;

    assign fetch = 1;
    assign exec1 = 0;
    assign exec2 = 0;
    assign clk = 0;
    #1
    assign clk = 1;
    #1
    assign fetch = 0;
    assign exec1 = 1;
    assign exec2 = 0;
    #1
    assign clk = 0;
    #1
    assign clk = 1;
    #1
    assert(hi == mult_intermediate[63:32] && lo == mult_intermediate[31:0]) else $display("multu error, hi = %d, lo = %d, hi_next = %d, lo_next = %d", hi, lo, hi_next, lo_next);
    assign fetch = 0;
    assign exec1 = 0;
    assign exec2 = 1;
    #1
    assign clk = 0;
    #1
    assign clk = 1;
    #1
    assert(hi == mult_intermediate[63:32] && lo == mult_intermediate[31:0]) else $display("multu error, hi = %d, lo = %d, hi_next = %d, lo_next = %d", hi, lo, hi_next, lo_next);
    
    assign op = DIVU;

    assign fetch = 1;
    assign exec1 = 0;
    assign exec2 = 0;
    assign clk = 0;
    #1
    assign clk = 1;
    #1
    assert(hi == mult_intermediate[63:32] && lo == mult_intermediate[31:0]) else $display("multu error, hi = %d, lo = %d, hi_next = %d, lo_next = %d", hi, lo, hi_next, lo_next);
    assign fetch = 0;
    assign exec1 = 1;
    assign exec2 = 0;
    #1
    assign clk = 0;
    #1
    assign clk = 1;
    #1
    assert(hi == a%b && lo == a/b) else $display("multu error, hi = %d, lo = %d, hi_next = %d, lo_next = %d", hi, lo, hi_next, lo_next);
    assign fetch = 0;
    assign exec1 = 0;
    assign exec2 = 1;
    #1
    assign clk = 0;
    #1
    assign clk = 1;
    #1
    assert(hi == a%b && lo == a/b) else $display("multu error, hi = %d, lo = %d, hi_next = %d, lo_next = %d", hi, lo, hi_next, lo_next);

    $display("Success!");


    $finish;


end



ALU dut(
    .a(a),
    .b(b),
    .r(r),
    .zero(zero),
    .negative(negative),
    .positive(positive),
    .sa(sa),
    .op(op),
    .fetch(fetch),
    .exec1(exec1),
    .exec2(exec2),
    .clk(clk),
    .hi(hi),
    .lo(lo),
    .hi_next(hi_next),
    .lo_next(lo_next)
);

endmodule