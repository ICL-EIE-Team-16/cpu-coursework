module alu_tb();

logic[31:0] a, b, hi, lo;
logic[31:0] r_unsigned;
logic signed[31:0] r;
logic zero, positive, negative, fetch, exec1, exec2, clk;
logic[5:0] sa;
logic[6:0] op;
logic[31:0] r_expected;
logic[31:0] r_expected2;
logic[31:0] lo_expected, hi_expected;
logic[63:0] mult_intermediate, mult_intermediate_signed;
logic signed[31:0] a_signed, b_signed, hi_signed, lo_signed;


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
    assign r = r_unsigned;
    assign sa = 6'b000001;
    assign mult_intermediate = a*b;
    assign a_signed = a;
    assign b_signed = b;
    assign mult_intermediate_signed = a_signed * b_signed;


    $display("Test round 1 start");

    assign op = ADDIU;
    #1
    assert(r==a+b) else $fatal(1, "AddI error, values: a=%d, b=%d, r=%d", a, b, r);

    assign op = ADDU;
    #1
    assert(r==a+b) else $fatal(1, "Add error, values: a=%d, b=%d, r=%d", a, b, r);

    assign op = SUBU;
    #1
    assert(r==a-b) else $fatal(1, "Sub error, values: a=%d, b=%d, r=%d", a, b, r);

    assign op = SRA;
    #1
    assert(r==a_signed>>>(sa)) else $fatal(1, "Sra error, values: a=%d, b=%d, r=%d", a, b, r);

    assign op = SRAV;
    #1
    assert(r==a_signed>>>b[4:0]) else $fatal(1, "Srav error, values: a=%d, b=%d, r=%d", a, b, r);

    assign op = SLTU;
    #1
    if(a<b)
        assert(r==32'h0001) else $fatal(1, "Slt error, values: a=%d, b=%d, r=%d", a, b, r);
    else
        assert(r==32'h0000) else $fatal(1, "Slt error, values: a=%d, b=%d, r=%d", a, b, r);

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
    assign clk = 0;
    #1
    assign clk = 1;
    #1
    assert(hi == mult_intermediate[63:32] && lo == mult_intermediate[31:0]) else $display("multu error, hi = %d, lo = %d", hi, lo);

    assign op = DIVU;
    assign clk = 0;
    #1
    assign clk = 1;
    #1
    assert(hi == a%b && lo == a/b) else $display("divu error, hi = %d, lo = %d", hi, lo);

    assign op = MULT;
    assign clk = 0;
    #1
    assign clk = 1;
    #1
    assign lo_signed = lo;
    assign hi_signed = hi;
    #1
    assert(hi_signed == mult_intermediate_signed[63:32] && lo_signed == mult_intermediate_signed[31:0]) else $display("mult error, hi = %d, lo = %d", hi_signed, lo_signed);


    assign op = DIV;
    assign clk = 0;
    #1
    assign clk = 1;
    #1
    assign lo_signed = lo;
    assign hi_signed = hi;
    #1
    assert(hi_signed == a_signed%b_signed && lo_signed == a_signed/b_signed) else $display("div error, hi = %d, lo = %d, hi_expected=%d, lo_expected = %d", hi_signed, lo_signed);

    assign op = MFHI;
    assign clk = 0;
    #1
    assign clk = 1;
    #1
    assert(r==hi) else $display("mfhi error, hi = %d, r = %d", hi, r);

    assign op = MFLO;
    assign clk = 0;
    #1
    assign clk = 1;
    #1
    assert(r==lo) else $display("mflo error, lo = %d, r = %d", lo, r);

    assign op = MTHI;
    assign clk = 0;
    #1
    assign clk =1;
    #1
    assert(hi==a) else $display("mthi error, hi =%d, a= %d", hi, a);

    assign op = MTLO;
    assign clk = 0;
    #1
    assign clk =1;
    #1
    assert(lo==a) else $display("mtlo error, lo =%d, a= %d", lo, a);

    assign op = MFHI;
    assign clk = 0;
    #1
    assign clk = 1;
    #1
    assert(r==a) else $display("mfhi error, hi = %d, r = %d", hi, r);

    assign op = MFLO;
    assign clk = 0;
    #1
    assign clk = 1;
    #1
    assert(r==a) else $display("mflo error, lo = %d, r = %d", lo, r);

    assign op = SLT;
    #1
    if(a_signed<b_signed)
        assert(r==32'h0001) else $fatal(1, "Slt error, values: a=%d, b=%d, r=%d", a, b, r);
    else
        assert(r==32'h0000) else $fatal(1, "Slt error, values: a=%d, b=%d, r=%d", a, b, r);

    assign op = BEQ;
    #1
    if(a_signed == b_signed)
        assert(zero==1 && positive==0 && negative==0) else $display("beq error, a = %d, b = %d, zero = %d, positive = %d, negative = %d", a_signed, b_signed, zero, positive, negative);

    assign op = BNE;
    #1
    if(a_signed != b_signed)
        assert((zero==0 && positive==1 && negative==0) || (zero==0 && positive==0 && negative==1)) else $display("bne error, a = %d, b = %d, zero = %d, positive = %d, negative = %d", a_signed, b_signed, zero, positive, negative);

    assign op = BGEZ;
    #1
    if(a_signed>0)
        assert(zero==0 && positive==1 && negative==0) else $display("flag error, a = %d, zero = %d, positive = %d, negative = %d", a_signed, zero, positive, negative);
    if(a_signed==0)
        assert(zero==1 && positive==0 && negative==0) else $display("flag error, a = %d, zero = %d, positive = %d, negative = %d", a_signed, zero, positive, negative);
    if(a_signed<0)
        assert(zero==0 && positive==0 && negative==1) else $display("flag error, a = %d, zero = %d, positive = %d, negative = %d", a_signed, zero, positive, negative);


    $display("Success!");


    assign a = 32'h0000;
    assign b = 32'h0001;
    assign r = r_unsigned;
    assign sa = 6'b001111;
    assign mult_intermediate = a*b;
    assign a_signed = a;
    assign b_signed = b;
    assign mult_intermediate_signed = a_signed * b_signed;

    $display("Test round 2 start");

    assign op = ADDIU;
    #1
    assert(r==a+b) else $fatal(1, "AddI error, values: a=%d, b=%d, r=%d", a, b, r);

    assign op = ADDU;
    #1
    assert(r==a+b) else $fatal(1, "Add error, values: a=%d, b=%d, r=%d", a, b, r);

    assign op = SUBU;
    #1
    assert(r==a-b) else $fatal(1, "Sub error, values: a=%d, b=%d, r=%d", a, b, r);

    assign op = SRA;
    #1
    assert(r==a_signed>>>(sa)) else $fatal(1, "Sra error, values: a=%d, b=%d, r=%d", a, b, r);

    assign op = SRAV;
    #1
    assert(r==a_signed>>>b[4:0]) else $fatal(1, "Srav error, values: a=%d, b=%d, r=%d", a, b, r);

    assign op = SLTU;
    #1
    if(a<b)
        assert(r==32'h0001) else $fatal(1, "Slt error, values: a=%d, b=%d, r=%d", a, b, r);
    else
        assert(r==32'h0000) else $fatal(1, "Slt error, values: a=%d, b=%d, r=%d", a, b, r);

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
    assign clk = 0;
    #1
    assign clk = 1;
    #1
    assert(hi == mult_intermediate[63:32] && lo == mult_intermediate[31:0]) else $display("multu error, hi = %d, lo = %d", hi, lo);

    assign op = DIVU;
    assign clk = 0;
    #1
    assign clk = 1;
    #1
    assert(hi == a%b && lo == a/b) else $display("divu error, hi = %d, lo = %d", hi, lo);


    assign op = MULT;
    assign clk = 0;
    #1
    assign clk = 1;
    #1
    assign lo_signed = lo;
    assign hi_signed = hi;
    #1
    assert(hi_signed == mult_intermediate_signed[63:32] && lo_signed == mult_intermediate_signed[31:0]) else $display("mult error, hi = %d, lo = %d", hi_signed, lo_signed);


    assign op = DIV;
    assign clk = 0;
    #1
    assign clk = 1;
    #1
    assign lo_signed = lo;
    assign hi_signed = hi;
    #1
    assert(hi_signed == a_signed%b_signed && lo_signed == a_signed/b_signed) else $display("div error, hi = %d, lo = %d, hi_expected=%d, lo_expected = %d", hi_signed, lo_signed);

    assign op = MFHI;
    assign clk = 0;
    #1
    assign clk = 1;
    #1
    assert(r==hi) else $display("mfhi error, hi = %d, r = %d", hi, r);

    assign op = MFLO;
    assign clk = 0;
    #1
    assign clk = 1;
    #1
    assert(r==lo) else $display("mflo error, lo = %d, r = %d", lo, r);

    assign op = MTHI;
    assign clk = 0;
    #1
    assign clk =1;
    #1
    assert(hi==a) else $display("mthi error, hi =%d, a= %d", hi, a);


    assign op = MTLO;
    assign clk = 0;
    #1
    assign clk =1;
    #1
    assert(lo==a) else $display("mtlo error, lo =%d, a= %d", lo, a);

    assign op = MFHI;
    assign clk = 0;
    #1
    assign clk = 1;
    #1
    assert(r==a) else $display("mfhi error, hi = %d, r = %d", hi, r);

    assign op = MFLO;
    assign clk = 0;
    #1
    assign clk = 1;
    #1
    assert(r==a) else $display("mflo error, lo = %d, r = %d", lo, r);

    assign op = SLT;
    #1
    if(a_signed<b_signed)
        assert(r==32'h0001) else $fatal(1, "Slt error, values: a=%d, b=%d, r=%d", a, b, r);
    else
        assert(r==32'h0000) else $fatal(1, "Slt error, values: a=%d, b=%d, r=%d", a, b, r);

    assign op = BEQ;
    #1
    if(a_signed == b_signed)
        assert(zero==1 && positive==0 && negative==0) else $display("beq error, a = %d, b = %d, zero = %d, positive = %d, negative = %d", a_signed, b_signed, zero, positive, negative);

    assign op = BNE;
    #1
    if(a_signed != b_signed)
        assert((zero==0 && positive==1 && negative==0) || (zero==0 && positive==0 && negative==1)) else $display("bne error, a = %d, b = %d, zero = %d, positive = %d, negative = %d", a_signed, b_signed, zero, positive, negative);

    assign op = BLEZ;
    #1
    if(a_signed>0)
        assert(zero==0 && positive==1 && negative==0) else $display("flag error, a = %d, zero = %d, positive = %d, negative = %d", a_signed, zero, positive, negative);
    if(a_signed==0)
        assert(zero==1 && positive==0 && negative==0) else $display("flag error, a = %d, zero = %d, positive = %d, negative = %d", a_signed, zero, positive, negative);
    if(a_signed<0)
        assert(zero==0 && positive==0 && negative==1) else $display("flag error, a = %d, zero = %d, positive = %d, negative = %d", a_signed, zero, positive, negative);


    $display("Success!");


    assign a = 32'hffffffff;
    assign b = 32'h00000001;
    assign r = r_unsigned;
    assign sa = 6'b001111;
    assign mult_intermediate = a*b;
    assign a_signed = a;
    assign b_signed = b;
    assign mult_intermediate_signed = a_signed * b_signed;

    $display("Test round 3 start");

    assign op = ADDIU;
    #1
    assert(r==a+b) else $fatal(1, "AddI error, values: a=%d, b=%d, r=%d", a, b, r);

    assign op = ADDU;
    #1
    assert(r==a+b) else $fatal(1, "Add error, values: a=%d, b=%d, r=%d", a, b, r);

    assign op = SUBU;
    #1
    assert(r==a-b) else $fatal(1, "Sub error, values: a=%d, b=%d, r=%d", a, b, r);

    assign op = SRA;
    #1
    assert(r==a_signed>>>(sa)) else $fatal(1, "Sra error, values: a=%d, b=%d, r=%d", a, b, r);

    assign op = SRAV;
    #1
    assert(r==a_signed>>>b[4:0]) else $fatal(1, "Srav error, values: a=%d, b=%d, r=%d", a, b, r);

    assign op = SLTU;
    #1
    if(a<b)
        assert(r==32'h0001) else $fatal(1, "Slt error, values: a=%d, b=%d, r=%d", a, b, r);
    else
        assert(r==32'h0000) else $fatal(1, "Slt error, values: a=%d, b=%d, r=%d", a, b, r);

    assign op = AND;
    #1
    assert(r==a&b) else $display("And error, values: a=%d, b=%d, r=%d, expected = %d", a, b, r, a&b);
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
    assign clk = 0;
    #1
    assign clk = 1;
    #1
    assert(hi == mult_intermediate[63:32] && lo == mult_intermediate[31:0]) else $display("multu error, hi = %d, lo = %d", hi, lo);

    assign op = DIVU;
    assign clk = 0;
    #1
    assign clk = 1;
    #1
    assert(hi == a%b && lo == a/b) else $display("divu error, hi = %d, lo = %d", hi, lo);

    assign op = MULT;
    assign clk = 0;
    #1
    assign clk = 1;
    #1
    assign lo_signed = lo;
    assign hi_signed = hi;
    #1
    assert(hi_signed == mult_intermediate_signed[63:32] && lo_signed == mult_intermediate_signed[31:0]) else $display("mult error, hi = %d, lo = %d", hi_signed, lo_signed);


    assign op = DIV;
    assign clk = 0;
    #1
    assign clk = 1;
    #1
    assign lo_signed = lo;
    assign hi_signed = hi;
    #1
    assert(hi_signed == a_signed%b_signed && lo_signed == a_signed/b_signed) else $display("div error, hi = %d, lo = %d, hi_expected=%d, lo_expected = %d", hi_signed, lo_signed);

    assign op = MFHI;
    assign clk = 0;
    #1
    assign clk = 1;
    #1
    assert(r==hi) else $display("mfhi error, hi = %d, r = %d", hi, r);

    assign op = MFLO;
    assign clk = 0;
    #1
    assign clk = 1;
    #1
    assert(r==lo) else $display("mflo error, lo = %d, r = %d", lo, r);

    assign op = MTHI;
    assign clk = 0;
    #1
    assign clk =1;
    #1
    assert(hi==a) else $display("mthi error, hi =%d, a= %d", hi, a);

    assign op = MTLO;
    assign clk = 0;
    #1
    assign clk =1;
    #1
    assert(lo==a) else $display("mtlo error, lo =%d, a= %d", lo, a);

    assign op = MFHI;
    assign clk = 0;
    #1
    assign clk = 1;
    #1
    assert(r==a) else $display("mfhi error, hi = %d, r = %d", hi, r);

    assign op = MFLO;
    assign clk = 0;
    #1
    assign clk = 1;
    #1
    assert(r==a) else $display("mflo error, lo = %d, r = %d", lo, r);

    assign op = SLT;
    #1
    if(a_signed<b_signed)
        assert(r==32'h0001) else $fatal(1, "Slt error, values: a=%d, b=%d, r=%d", a, b, r);
    else
        assert(r==32'h0000) else $fatal(1, "Slt error, values: a=%d, b=%d, r=%d", a, b, r);

    assign op = BEQ;
    #1
    if(a_signed == b_signed)
        assert(zero==1 && positive==0 && negative==0) else $display("beq error, a = %d, b = %d, zero = %d, positive = %d, negative = %d", a_signed, b_signed, zero, positive, negative);

    assign op = BNE;
    #1
    if(a_signed != b_signed)
        assert((zero==0 && positive==1 && negative==0) || (zero==0 && positive==0 && negative==1)) else $display("bne error, a = %d, b = %d, zero = %d, positive = %d, negative = %d", a_signed, b_signed, zero, positive, negative);

    assign op = BLTZAL;
    #1
    if(a_signed>0)
        assert(zero==0 && positive==1 && negative==0) else $display("flag error, a = %d, zero = %d, positive = %d, negative = %d", a_signed, zero, positive, negative);
    if(a_signed==0)
        assert(zero==1 && positive==0 && negative==0) else $display("flag error, a = %d, zero = %d, positive = %d, negative = %d", a_signed, zero, positive, negative);
    if(a_signed<0)
        assert(zero==0 && positive==0 && negative==1) else $display("flag error, a = %d, zero = %d, positive = %d, negative = %d", a_signed, zero, positive, negative);


    $display("Success!");


    assign a = 32'h03f5;
    assign b = 32'h0001;
    assign r = r_unsigned;
    assign sa = 6'b001111;
    assign mult_intermediate = a*b;
    assign a_signed = a;
    assign b_signed = b;
    assign mult_intermediate_signed = a_signed * b_signed;

    $display("Test round 4 start");

    assign op = ADDIU;
    #1
    assert(r==a+b) else $fatal(1, "AddI error, values: a=%d, b=%d, r=%d", a, b, r);

    assign op = ADDU;
    #1
    assert(r==a+b) else $fatal(1, "Add error, values: a=%d, b=%d, r=%d", a, b, r);

    assign op = SUBU;
    #1
    assert(r==a-b) else $fatal(1, "Sub error, values: a=%d, b=%d, r=%d", a, b, r);

    assign op = SRA;
    #1
    assert(r==a_signed>>>(sa)) else $fatal(1, "Sra error, values: a=%d, b=%d, r=%d", a, b, r);

    assign op = SRAV;
    #1
    assert(r==a_signed>>>b[4:0]) else $fatal(1, "Srav error, values: a=%d, b=%d, r=%d", a, b, r);

    assign op = SLTU;
    #1
    if(a<b)
        assert(r==32'h0001) else $fatal(1, "Slt error, values: a=%d, b=%d, r=%d", a, b, r);
    else
        assert(r==32'h0000) else $fatal(1, "Slt error, values: a=%d, b=%d, r=%d", a, b, r);


    assign op = AND;
    #1
    assert(r==a&b) else $display("And error, values: a=%d, b=%d, r=%d, expected=%d", a, b, r, a&b);
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
    assign clk = 0;
    #1
    assign clk = 1;
    #1
    assert(hi == mult_intermediate[63:32] && lo == mult_intermediate[31:0]) else $display("multu error, hi = %d, lo = %d", hi, lo);

    assign op = DIVU;
    assign clk = 0;
    #1
    assign clk = 1;
    #1
    assert(hi == a%b && lo == a/b) else $display("divu error, hi = %d, lo = %d", hi, lo);

    assign op = MULT;
    assign clk = 0;
    #1
    assign clk = 1;
    #1
    assign lo_signed = lo;
    assign hi_signed = hi;
    #1
    assert(hi_signed == mult_intermediate_signed[63:32] && lo_signed == mult_intermediate_signed[31:0]) else $display("mult error, hi = %d, lo = %d", hi_signed, lo_signed);


    assign op = DIV;
    assign clk = 0;
    #1
    assign clk = 1;
    #1
    assign lo_signed = lo;
    assign hi_signed = hi;
    #1
    assert(hi_signed == a_signed%b_signed && lo_signed == a_signed/b_signed) else $display("div error, hi = %d, lo = %d, hi_expected=%d, lo_expected = %d", hi_signed, lo_signed);

    assign op = MFHI;
    assign clk = 0;
    #1
    assign clk = 1;
    #1
    assert(r==hi) else $display("mfhi error, hi = %d, r = %d", hi, r);

    assign op = MFLO;
    assign clk = 0;
    #1
    assign clk = 1;
    #1
    assert(r==lo) else $display("mflo error, lo = %d, r = %d", lo, r);

    assign op = MTHI;
    assign clk = 0;
    #1
    assign clk =1;
    #1
    assert(hi==a) else $display("mthi error, hi =%d, a= %d", hi, a);

    assign op = MTLO;
    assign clk = 0;
    #1
    assign clk =1;
    #1
    assert(lo==a) else $display("mtlo error, lo =%d, a= %d", lo, a);

    assign op = MFHI;
    assign clk = 0;
    #1
    assign clk = 1;
    #1
    assert(r==a) else $display("mfhi error, hi = %d, r = %d", hi, r);

    assign op = MFLO;
    assign clk = 0;
    #1
    assign clk = 1;
    #1
    assert(r==a) else $display("mflo error, lo = %d, r = %d", lo, r);

    assign op = SLT;
    #1
    if(a_signed<b_signed)
        assert(r==32'h0001) else $fatal(1, "Slt error, values: a=%d, b=%d, r=%d", a, b, r);
    else
        assert(r==32'h0000) else $fatal(1, "Slt error, values: a=%d, b=%d, r=%d", a, b, r);

   assign op = BEQ;
    #1
    if(a_signed == b_signed)
        assert(zero==1 && positive==0 && negative==0) else $display("beq error, a = %d, b = %d, zero = %d, positive = %d, negative = %d", a_signed, b_signed, zero, positive, negative);

    assign op = BNE;
    #1
    if(a_signed != b_signed)
        assert((zero==0 && positive==1 && negative==0) || (zero==0 && positive==0 && negative==1)) else $display("bne error, a = %d, b = %d, zero = %d, positive = %d, negative = %d", a_signed, b_signed, zero, positive, negative);

    assign op = BGTZ;
    #1
    if(a_signed>0)
        assert(zero==0 && positive==1 && negative==0) else $display("flag error, a = %d, zero = %d, positive = %d, negative = %d", a_signed, zero, positive, negative);
    if(a_signed==0)
        assert(zero==1 && positive==0 && negative==0) else $display("flag error, a = %d, zero = %d, positive = %d, negative = %d", a_signed, zero, positive, negative);
    if(a_signed<0)
        assert(zero==0 && positive==0 && negative==1) else $display("flag error, a = %d, zero = %d, positive = %d, negative = %d", a_signed, zero, positive, negative);

    $display("Success!");


    assign a = 32'd6000003;
    assign b = 32'd2000000;
    assign r = r_unsigned;
    assign mult_intermediate = a*b;
    assign a_signed = a;
    assign b_signed = b;
    assign mult_intermediate_signed = a_signed * b_signed;

    $display("Test round 5 start");

        assign op = ADDIU;
    #1
    assert(r==a+b) else $fatal(1, "AddI error, values: a=%d, b=%d, r=%d", a, b, r);

    assign op = ADDU;
    #1
    assert(r==a+b) else $fatal(1, "Add error, values: a=%d, b=%d, r=%d", a, b, r);

    assign op = SUBU;
    #1
    assert(r==a-b) else $fatal(1, "Sub error, values: a=%d, b=%d, r=%d", a, b, r);

    assign op = SRA;
    #1
    assert(r==a_signed>>>(sa)) else $fatal(1, "Sra error, values: a=%d, b=%d, r=%d", a, b, r);

    assign op = SRAV;
    #1
    assert(r==a_signed>>>b[4:0]) else $fatal(1, "Srav error, values: a=%d, b=%d, r=%d", a, b, r);

    assign op = SLTU;
    #1
    if(a<b)
        assert(r==32'h0001) else $fatal(1, "Slt error, values: a=%d, b=%d, r=%d", a, b, r);
    else
        assert(r==32'h0000) else $fatal(1, "Slt error, values: a=%d, b=%d, r=%d", a, b, r);

    assign op = AND;
    #1
    assert(r==a&b) else $display("And error, values: a=%d, b=%d, r=%d, r_expected=%d", a, b, r, a&b);
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
    assign clk = 0;
    #1
    assign clk = 1;
    #1
    assert(hi == mult_intermediate[63:32] && lo == mult_intermediate[31:0]) else $display("multu error, hi = %d, lo = %d", hi, lo);

    assign op = DIVU;
    assign clk = 0;
    #1
    assign clk = 1;
    #1
    assert(hi == a%b && lo == a/b) else $display("divu error, hi = %d, lo = %d", hi, lo);

    assign op = MULT;
    assign clk = 0;
    #1
    assign clk = 1;
    #1
    assign lo_signed = lo;
    assign hi_signed = hi;
    #1
    assert(hi_signed == mult_intermediate_signed[63:32] && lo_signed == mult_intermediate_signed[31:0]) else $display("mult error, hi = %d, lo = %d", hi_signed, lo_signed);


    assign op = DIV;
    assign clk = 0;
    #1
    assign clk = 1;
    #1
    assign lo_signed = lo;
    assign hi_signed = hi;
    #1
    assert(hi_signed == a_signed%b_signed && lo_signed == a_signed/b_signed) else $display("div error, hi = %d, lo = %d, hi_expected=%d, lo_expected = %d", hi_signed, lo_signed);

    assign op = MFHI;
    assign clk = 0;
    #1
    assign clk = 1;
    #1
    assert(r==hi) else $display("mfhi error, hi = %d, r = %d", hi, r);

    assign op = MFLO;
    assign clk = 0;
    #1
    assign clk = 1;
    #1
    assert(r==lo) else $display("mflo error, lo = %d, r = %d", lo, r);

    assign op = MTHI;
    assign clk = 0;
    #1
    assign clk =1;
    #1
    assert(hi==a) else $display("mthi error, hi =%d, a= %d", hi, a);

    assign op = MTLO;
    assign clk = 0;
    #1
    assign clk =1;
    #1
    assert(lo==a) else $display("mtlo error, lo =%d, a= %d", lo, a);

    assign op = MFHI;
    assign clk = 0;
    #1
    assign clk = 1;
    #1
    assert(r==a) else $display("mfhi error, hi = %d, r = %d", hi, r);

    assign op = MFLO;
    assign clk = 0;
    #1
    assign clk = 1;
    #1
    assert(r==a) else $display("mflo error, lo = %d, r = %d", lo, r);

    assign op = SLT;
    #1
    if(a_signed<b_signed)
        assert(r==32'h0001) else $fatal(1, "Slt error, values: a=%d, b=%d, r=%d", a, b, r);
    else
        assert(r==32'h0000) else $fatal(1, "Slt error, values: a=%d, b=%d, r=%d", a, b, r);

   assign op = BEQ;
    #1
    if(a_signed == b_signed)
        assert(zero==1 && positive==0 && negative==0) else $display("beq error, a = %d, b = %d, zero = %d, positive = %d, negative = %d", a_signed, b_signed, zero, positive, negative);

    assign op = BNE;
    #1
    if(a_signed != b_signed)
        assert((zero==0 && positive==1 && negative==0) || (zero==0 && positive==0 && negative==1)) else $display("bne error, a = %d, b = %d, zero = %d, positive = %d, negative = %d", a_signed, b_signed, zero, positive, negative);

    assign op = BGTZ;
    #1
    if(a_signed>0)
        assert(zero==0 && positive==1 && negative==0) else $display("flag error, a = %d, zero = %d, positive = %d, negative = %d", a_signed, zero, positive, negative);
    if(a_signed==0)
        assert(zero==1 && positive==0 && negative==0) else $display("flag error, a = %d, zero = %d, positive = %d, negative = %d", a_signed, zero, positive, negative);
    if(a_signed<0)
        assert(zero==0 && positive==0 && negative==1) else $display("flag error, a = %d, zero = %d, positive = %d, negative = %d", a_signed, zero, positive, negative);

    $display("Success!");


    assign a = -32'd45;
    assign b = 32'd5;
    assign r = r_unsigned;
    assign a_signed = a;
    assign b_signed = b;
    assign mult_intermediate = a*b;
    assign mult_intermediate_signed = a_signed * b_signed;

    $display("Test round 6 start");

        assign op = ADDIU;
    #1
    assert(r==a+b) else $fatal(1, "AddI error, values: a=%d, b=%d, r=%d", a, b, r);

    assign op = ADDU;
    #1
    assert(r==a+b) else $fatal(1, "Add error, values: a=%d, b=%d, r=%d", a, b, r);

    assign op = SUBU;
    #1
    assert(r==a-b) else $fatal(1, "Sub error, values: a=%d, b=%d, r=%d", a, b, r);

    assign op = SRA;
    #1
    assert(r==a_signed>>>(sa)) else $fatal(1, "Sra error, values: a=%d, b=%d, r=%d", a, b, r);

    assign op = SRAV;
    #1
    assert(r==a_signed>>>b[4:0]) else $fatal(1, "Srav error, values: a=%d, b=%d, r=%d", a, b, r);

    assign op = SLTU;
    #1
    if(a<b)
        assert(r==32'h0001) else $fatal(1, "Slt error, values: a=%d, b=%d, r=%d", a, b, r);
    else
        assert(r==32'h0000) else $fatal(1, "Slt error, values: a=%d, b=%d, r=%d", a, b, r);


    assign op = AND;
    #1
    assert(r==a&b) else $display("And error, values: a=%d, b=%d, r=%d, r_expected=%d", a, b, r, a&b);
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
    assign clk = 0;
    #1
    assign clk = 1;
    #1
    assert(hi == mult_intermediate[63:32] && lo == mult_intermediate[31:0]) else $display("multu error, hi = %d, lo = %d", hi, lo);

    assign op = DIVU;
    assign clk = 0;
    #1
    assign clk = 1;
    #1
    assert(hi == a%b && lo == a/b) else $display("divu error, hi = %d, lo = %d", hi, lo);

    assign op = MULT;
    assign clk = 0;
    #1
    assign clk = 1;
    #1
    assign lo_signed = lo;
    assign hi_signed = hi;
    #1
    assert(hi_signed == mult_intermediate_signed[63:32] && lo_signed == mult_intermediate_signed[31:0]) else $display("mult error, hi = %d, lo = %d", hi_signed, lo_signed);


    assign op = DIV;
    assign clk = 0;
    #1
    assign clk = 1;
    #1
    assign lo_signed = lo;
    assign hi_signed = hi;
    #1
    assert(hi_signed == a_signed%b_signed && lo_signed == a_signed/b_signed) else $display("div error, hi = %d, lo = %d, hi_expected=%d, lo_expected = %d", hi_signed, lo_signed);

    assign op = MFHI;
    assign clk = 0;
    #1
    assign clk = 1;
    #1
    assert(r==hi) else $display("mfhi error, hi = %d, r = %d", hi, r);

    assign op = MFLO;
    assign clk = 0;
    #1
    assign clk = 1;
    #1
    assert(r==lo) else $display("mflo error, lo = %d, r = %d", lo, r);

    assign op = MTHI;
    assign clk = 0;
    #1
    assign clk =1;
    #1
    assert(hi==a) else $display("mthi error, hi =%d, a= %d", hi, a);

    assign op = MTLO;
    assign clk = 0;
    #1
    assign clk =1;
    #1
    assert(lo==a) else $display("mtlo error, lo =%d, a= %d", lo, a);

    assign op = MFHI;
    assign clk = 0;
    #1
    assign clk = 1;
    #1
    assert(r==a) else $display("mfhi error, hi = %d, r = %d", hi, r);

    assign op = MFLO;
    assign clk = 0;
    #1
    assign clk = 1;
    #1
    assert(r==a) else $display("mflo error, lo = %d, r = %d", lo, r);

    assign op = SLT;
    #1
    if(a_signed<b_signed)
        assert(r==32'h0001) else $fatal(1, "Slt error, values: a=%d, b=%d, r=%d", a, b, r);
    else
        assert(r==32'h0000) else $fatal(1, "Slt error, values: a=%d, b=%d, r=%d", a, b, r);

   assign op = BEQ;
    #1
    if(a_signed == b_signed)
        assert(zero==1 && positive==0 && negative==0) else $display("beq error, a = %d, b = %d, zero = %d, positive = %d, negative = %d", a_signed, b_signed, zero, positive, negative);

    assign op = BNE;
    #1
    if(a_signed != b_signed)
        assert((zero==0 && positive==1 && negative==0) || (zero==0 && positive==0 && negative==1)) else $display("bne error, a = %d, b = %d, zero = %d, positive = %d, negative = %d", a_signed, b_signed, zero, positive, negative);

    assign op = BGTZ;
    #1
    if(a_signed>0)
        assert(zero==0 && positive==1 && negative==0) else $display("flag error, a = %d, zero = %d, positive = %d, negative = %d", a_signed, zero, positive, negative);
    if(a_signed==0)
        assert(zero==1 && positive==0 && negative==0) else $display("flag error, a = %d, zero = %d, positive = %d, negative = %d", a_signed, zero, positive, negative);
    if(a_signed<0)
        assert(zero==0 && positive==0 && negative==1) else $display("flag error, a = %d, zero = %d, positive = %d, negative = %d", a_signed, zero, positive, negative);

    $display("Success!");


    $finish;


end



ALU dut(
    .a(a),
    .b(b),
    .r(r_unsigned),
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
    .lo(lo)
);

endmodule