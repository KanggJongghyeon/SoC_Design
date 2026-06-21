`timescale 1ns / 1ps
module top_cpu #(
    parameter ADDR_BIT = 8,
    parameter DATA_BIT = 32
    )(
    input   wire                    clk,            // Global
    input   wire                    rst_n,          // Global
    
    input   wire [DATA_BIT - 1:0]   i_i_mem_data,   // from I-MEM
    output  wire                    o_i_mem_en,     // to   I-MEM
    output  wire [ADDR_BIT - 1:0]   o_i_mem_addr,   // to   I-MEM

    input   wire [DATA_BIT - 1:0]   i_d_mem_data,   // from D-MEM
    output  wire                    o_d_mem_en,     // to   D-MEM
    output  wire                    o_d_mem_wren,   // to   D-MEM
    output  wire [ADDR_BIT - 1:0]   o_d_mem_addr,   // to   D-MEM
    output  wire [DATA_BIT - 1:0]   o_d_mem_data,   // to   D-MEM
    
    output  wire                    o_arbiter_req,  // to   Arbiter
    input   wire                    i_arbiter_gnt   // from Arbiter
    );

    /////////////////////
    // Local Parameter //
    /////////////////////
    //localparam OPCODE_BIT   = (DATA_BIT == 32) ? 6 : 4; // {32-Bit CPU : 6, 16-Bit CPU : 4}
    //localparam REG_BIT      = (DATA_BIT == 32) ? 5 : 2; // {32-Bit CPU : 5, 16-Bit CPU : 2} 
    `ifndef CPU_32BIT
        localparam OPCODE_BIT   = 4;
        localparam REG_BIT      = 2;
    `else
        localparam OPCODE_BIT   = 6;
        localparam REG_BIT      = 5;
    `endif  // CPU_32BIT (Vivado Define Option)

    //////////
    // wire //
    //////////
    wire                                w_if_i_mem_en;                      // I-MEM  Enable
    wire [ADDR_BIT - 1:0]               w_if_pc_addr;                       // PC     ADDR (IF)
    wire [ADDR_BIT - 1:0]               w_id_pc_addr;                       // PC     ADDR (ID)
    wire [ADDR_BIT - 1:0]               w_ex_pc_addr;                       // PC     ADDR (EX)
    wire [ADDR_BIT - 1:0]               w_mem_pc_addr;                      // PC     ADDR (MEM)
    wire [ADDR_BIT - 1:0]               w_wb_pc_addr;                       // PC     ADDR (WB)
    wire [ADDR_BIT - 1:0]               w_if_add4_addr;                     // PC     ADDR + 4 (IF)
    wire [ADDR_BIT - 1:0]               w_ex_jump_mux_addr;                 // Branch ADDR or Jump ADDR ([Warning] Hazard)
    wire [DATA_BIT - OPCODE_BIT - 1:0]  w_id_dec_jaddr;                     // Jump   ADDR (by Decoder)
    wire [DATA_BIT - OPCODE_BIT + 1:0]  w_id_shift_left2_dec_jaddr;         // Jump   ADDR (by Decoder) >> 2
    wire [DATA_BIT - 1:0]               w_id_jump_addr;                     // Jump   ADDR (ID)
    wire [DATA_BIT - 1:0]               w_ex_jump_addr;                     // Jump   ADDR (EX)
    wire [DATA_BIT - 1:0]               w_id_sign_extend_const;             // Sign-Extend Constant (ID)
    wire [DATA_BIT - 1:0]               w_ex_sign_extend_const;             // Sign-Extend Constant (EX)
    wire [DATA_BIT + 1:0]               w_ex_shift_left2_sign_extend_const; // Sign-Extned Constant >> 2 (Bit Extend)
    wire [DATA_BIT - 1:0]               w_ex_sign_extend_branch_addr;       // Standard Bit of Branch ADDR
    wire [DATA_BIT - 1:0]               w_ex_branch_addr;                   // Branch  ADDR
    wire [OPCODE_BIT - 1:0]             w_id_dec_opcode;                    // Decoded OPCODE
    wire [REG_BIT - 1:0]                w_id_dec_rs;                        // Decoded rs Register (ID)
    wire [REG_BIT - 1:0]                w_ex_dec_rs;                        // Decoded rs Register (EX)
    wire [REG_BIT - 1:0]                w_id_dec_rt;                        // Decoded rt Register (ID)
    wire [REG_BIT - 1:0]                w_ex_dec_rt;                        // Decoded rt Register (EX)
    wire [REG_BIT - 1:0]                w_mem_dec_rt;                       // Decoded rt Register (MEM)
    wire [REG_BIT - 1:0]                w_id_dec_rd;                        // Decoded rd Register (ID)
    wire [REG_BIT - 1:0]                w_ex_dec_rd;                        // Decoded rd Register (EX)
    wire [4:0]                          w_id_dec_shamt;                     // Decoded Shamt
    wire [5:0]                          w_id_dec_funct;                     // Decoded FUNCT CODE (ID)
    wire [5:0]                          w_ex_dec_funct;                     // Decoded FUNCT CODE (EX)
    wire [(DATA_BIT / 2) - 1:0]         w_id_dec_const;                     // Decoded Constant
    wire [2:0]                          w_id_aluop;                         // ALUOpA (ID)
    wire [2:0]                          w_ex_aluop;                         // ALUOpA (EX)
    wire                                w_id_regdst;                        // RegDst       Flag (ID)
    wire                                w_ex_ctr_regdst;                    // RegDst       Flag (EX)
    wire                                w_id_ctr_alusrc;                    // ALUSrc       Flag (ID)
    wire                                w_ex_ctr_alusrc;                    // ALUSrc       Flag (EX)
    wire                                w_id_memtoreg;                      // MemtoReg     Flag (ID)
    wire                                w_ex_memtoreg;                      // MemtoReg     Flag (EX)
    wire                                w_mem_memtoreg;                     // MemtoReg     Flag (MEM)
    wire                                w_wb_ctr_memtoreg;                  // MemtoReg     Flag (WB)
    wire                                w_id_regwrite;                      // RegWrite     Flag (ID)
    wire                                w_ex_regwrite;                      // RegWrite     Flag (EX)
    wire                                w_mem_regwrite;                     // RegWrite     Flag (MEM)
    wire                                w_wb_regwrite;                      // RegWrite     Flag (WB)
    wire                                w_id_memread;                       // MemRead      Flag (ID)
    wire                                w_ex_memread;                       // MemRead      Flag (EX)
    wire                                w_mem_memread;                      // MemRead      Flag (MEM)
    wire                                w_id_memwrite;                      // MemWrite     Flag (ID)
    wire                                w_ex_memwrite;                      // MemWrite     Flag (EX)
    wire                                w_mem_memwrite;                     // MemWrite     Flag (MEM)
    wire [1:0]                          w_id_branch;                        // Branch       Flag (ID)
    wire [1:0]                          w_ex_branch;                        // Branch       Flag (EX)
    wire [1:0]                          w_id_jump;                          // Jump         Flag (ID)
    wire [1:0]                          w_ex_ctr_jump;                      // Jump         Flag (EX)
    wire [1:0]                          w_mem_jump;                         // Jump         Flag (MEM)
    wire [1:0]                          w_wb_ctr_jump;                      // Jump         Flag (MEM)
    wire                                w_id_sign_extend;                   // SignExtend   Flag (ID)
    wire [3:0]                          w_ex_alu_ctr;                       // ALUOpB
    wire [REG_BIT - 1:0]                w_ex_regdst_mux_reg;                // rt or rd Register (EX)
    wire [REG_BIT - 1:0]                w_mem_regdst_mux_reg;               // rt or rd Register (MEM)
    wire [REG_BIT - 1:0]                w_wb_regdst_mux_reg;                // rt or rd Register (WB)
    wire [REG_BIT - 1:0]                w_wb_regdst_jal_mux_reg;            // rt or rd or $ra Register (WB)
    wire [DATA_BIT - 1:0]               w_id_reg_rdata1;                    // Registers RDATA1 (ID)
    wire [DATA_BIT - 1:0]               w_ex_reg_rdata1;                    // Registers RDATA1 (EX) 
    wire [DATA_BIT - 1:0]               w_id_reg_rdata2;                    // Registers RDATA2 (ID)
    wire [DATA_BIT - 1:0]               w_ex_reg_rdata2;                    // Registers RDATA2 (EX)
    wire [DATA_BIT - 1:0]               w_mem_reg_rdata2;                   // Registers RDATA2 (MEM)
    wire [DATA_BIT - 1:0]               w_wb_memtoreg_mux_data;             // ALU Output or D-MEM RDATA ([Warning] Hazard)
    wire [DATA_BIT - 1:0]               w_ex_alusrc_mux_data;               // Registers RDATA2 or Sign-Extend Constant
    wire [DATA_BIT - 1:0]               w_ex_alu_out;                       // ALU Output (EX)
    wire [DATA_BIT - 1:0]               w_mem_alu_out;                      // ALU Output (MEM)
    wire [DATA_BIT - 1:0]               w_wb_alu_out;                       // ALU Output (WB)
    wire                                w_ex_alu_carry_out;                 // ALU Carry Out
    wire                                w_ex_alu_zero;                      // ALU Zero  Out
    wire [DATA_BIT - 1:0]               w_ex_hi;                            // HIGH Register in MUL/DIV Unit
    wire [DATA_BIT - 1:0]               w_ex_lo;                            // LOW  Register in MUL/DIV Unit
    wire [ADDR_BIT - 1:0]               w_ex_branch_mux_addr;               // PC ADDR + 4 or Branch ADDR
    wire                                w_ex_ctr_branch;                    // Control Input of Branch MUX
    wire [DATA_BIT - 1:0]               w_i_mem_data;                       // I-MEM DATA
    wire [ADDR_BIT - 1:0]               w_if_pc_mux_addr;                   // I-MEM RADDR (Next)
    wire                                w_fw_ctr_alu_a_1c;                  // ALU ForwardA Output (1 Cycle)
    wire                                w_fw_ctr_alu_b_1c;                  // ALU ForwardB Output (1 Cycle)
    wire                                w_fw_ctr_alu_a_2c;                  // ALU ForwardA Output (2 Cycle)
    wire                                w_fw_ctr_alu_b_2c;                  // ALU ForwardB Output (2 Cycle)
    wire [DATA_BIT - 1:0]               w_ex_alu_fw_mux_data_a;             // ALU ForwardA MUX Data
    wire [DATA_BIT - 1:0]               w_ex_alu_fw_mux_data_b;             // ALU ForwardB MUX Data
    wire                                w_ex_fw_ctr_wdata_2c;               // WDATA Forward Output (2 Cycle) (EX)
    wire                                w_mem_fw_ctr_wdata_2c;              // WDATA Forward Output (2 Cycle) (MEM)
    wire                                w_fw_ctr_wdata_1c;                  // WDATA Forward Output (1 Cycle)
    wire [DATA_BIT - 1:0]               w_mem_wdata_fw_mux_data;            // WDATA Forward MUX Data
    wire [DATA_BIT - 1:0]               w_ex_wdata_fw_mux_data_2c;          // WDATA Forward MUX Data (2 Cycle) (EX) 
    wire [DATA_BIT - 1:0]               w_mem_wdata_fw_mux_data_2c;         // WDATA Forward MUX Data (2 Cycle) (MEM) 
    wire                                w_ex_flush;                         // Instruction Flush Sinal
    wire                                w_load_stall;                       // Load Stall Flag Signal

////////////////////////////////////////
// IF (Instruction Fetch from Memory) //
////////////////////////////////////////
    /* WR Register Decision MUX (RegDst MUX) */
    mux21 #(
        .DATA_BIT       (ADDR_BIT)
    ) u_pc_mux (
        .i_ctr          (w_ex_flush),
        .i_i0           (w_if_add4_addr),
        .i_i1           (w_ex_jump_mux_addr),
        .o_o            (w_if_pc_mux_addr)
    );
    
    /* Program Counter & Peri Logics */
    pc #(           // Program Counter
        .ADDR_BIT       (ADDR_BIT)
    ) u_pc (
        .clk            (clk),
        .rst_n          (rst_n),
        .i_n_mem_addr   (w_if_pc_mux_addr),
        .o_mem_en       (w_if_i_mem_en),
        .o_mem_addr     (w_if_pc_addr)
    );
    adder21 #(      // ADDR Adder (just add ADDR+4)
        .DATA_BIT       (ADDR_BIT)
    ) u_addr_4_adder (
        .i_i0           (w_if_pc_addr),
        .i_i1           (ADDR_BIT'(4)),
        .o_o            (w_if_add4_addr)
    );

    /* IF-ID Bridge */
    if_id #(
        .ADDR_BIT       (ADDR_BIT),
        .DATA_BIT       (DATA_BIT)
    ) u_if_id_bridge(
        .clk            (clk),
        .rst_n          (rst_n),
        .i_flush        (w_ex_flush),
        .i_stall        (w_load_stall),
        .i_i_mem_data   (i_i_mem_data),
        .i_pc_addr      (w_if_pc_addr/*w_if_add4_addr*/),
        .o_i_mem_data   (w_i_mem_data),
        .o_pc_addr      (w_id_pc_addr)
    );

///////////////////////////////////////////////
// ID (Instruction Decode and Read Register) //
///////////////////////////////////////////////
    /* PC Peri Logic */    
    shift_left #(   // Shift Left 2 for make Jump ADDR
        .LEFT_CNT       (2),
        .ADDR_BIT       (DATA_BIT - OPCODE_BIT)
    ) u_shift_left_jump (
        .i_i            ({2'b00, w_id_dec_jaddr}),
        .o_o            (w_id_shift_left2_dec_jaddr)
    );

    /* Instruction Decoder */
    inst_decoder #(
        .DATA_BIT       (DATA_BIT),
        .OPCODE_BIT     (OPCODE_BIT),
        .REG_BIT        (REG_BIT)
    ) u_inst_decoder (
        .i_data         (w_i_mem_data/*i_i_mem_data*/),
        .o_opcode       (w_id_dec_opcode),
        .o_rs           (w_id_dec_rs),
        .o_rt           (w_id_dec_rt),
        .o_rd           (w_id_dec_rd),
        .o_shamt        (w_id_dec_shamt),
        .o_funct        (w_id_dec_funct),
        .o_const        (w_id_dec_const),
        .o_jaddr        (w_id_dec_jaddr)
    );

    /* Control Unit */
    ctr_unit #(
        .DATA_BIT       (DATA_BIT),
        .OPCODE_BIT     (OPCODE_BIT)
    ) u_control_unit (
        .i_opcode       (w_id_dec_opcode),
        .i_funct        (w_id_dec_funct),
        .o_regdst       (w_id_regdst),
        .o_alusrc       (w_id_ctr_alusrc),
        .o_memtoreg     (w_id_memtoreg),
        .o_regwrite     (w_id_regwrite),
        .o_memread      (w_id_memread),
        .o_memwrite     (w_id_memwrite),
        .o_branch       (w_id_branch),
        .o_aluop        (w_id_aluop),
        .o_jump         (w_id_jump),
        .o_sign_extend  (w_id_sign_extend),
        .o_arbiter_req  (o_arbiter_req),
        .i_arbiter_gnt  (i_arbiter_gnt)
    );

    /* Registers */
    registers #(
        .DATA_BIT       (DATA_BIT),
        .REG_BIT        (REG_BIT)
    ) u_registers (
        .clk            (clk),
        .rst_n          (rst_n),
        .i_regwrite     (w_wb_regwrite),
        .i_rd_reg1      (w_id_dec_rs),
        .i_rd_reg2      (w_id_dec_rt),
        .i_wr_reg       (w_wb_regdst_mux_reg),
        .i_wr_data      (w_wb_memtoreg_mux_data),
        .o_rd_data1     (w_id_reg_rdata1),
        .o_rd_data2     (w_id_reg_rdata2)
    );
    
    /* Sign-Extend */
    sign_extend #(
        .DATA_BIT       (DATA_BIT)
    ) u_sign_extend (
        .i_sign_extend  (w_id_sign_extend),
        .i_const        (w_id_dec_const),
        .o_const        (w_id_sign_extend_const)
    );

    /* ID-EX Bridge */
    id_ex #(
        .REG_BIT        (REG_BIT),
        .ADDR_BIT       (ADDR_BIT),
        .DATA_BIT       (DATA_BIT)
    ) u_id_ex_bridge (
        .clk            (clk),
        .rst_n          (rst_n),
        .i_flush        (w_ex_flush | w_load_stall),
        .i_pc_addr      (w_id_pc_addr),
        .i_rs           (w_id_dec_rs),
        .i_rt           (w_id_dec_rt),
        .i_rd           (w_id_dec_rd),
        .i_funct        (w_id_dec_funct),
        .i_jump_addr    (w_id_jump_addr),
        .i_regdst       (w_id_regdst),
        .i_alusrc       (w_id_ctr_alusrc),
        .i_memtoreg     (w_id_memtoreg),
        .i_regwrite     (w_id_regwrite),
        .i_memread      (w_id_memread),
        .i_memwrite     (w_id_memwrite),
        .i_branch       (w_id_branch),
        .i_aluop        (w_id_aluop),
        .i_jump         (w_id_jump),
        .i_reg_rdata1   (w_id_reg_rdata1),
        .i_reg_rdata2   (w_id_reg_rdata2),
        .i_sign_extend  (w_id_sign_extend_const),
        .o_branch       (w_ex_branch),
        .o_jump         (w_ex_ctr_jump),
        .o_jump_addr    (w_ex_jump_addr),
        .o_aluop        (w_ex_aluop),
        .o_funct        (w_ex_dec_funct),
        .o_alusrc       (w_ex_ctr_alusrc),
        .o_reg_rdata1   (w_ex_reg_rdata1),
        .o_reg_rdata2   (w_ex_reg_rdata2),
        .o_sign_extend  (w_ex_sign_extend_const),
        .o_pc_addr      (w_ex_pc_addr),
        .o_rs           (w_ex_dec_rs),
        .o_rt           (w_ex_dec_rt),
        .o_rd           (w_ex_dec_rd),
        .o_regdst       (w_ex_ctr_regdst),
        .o_memtoreg     (w_ex_memtoreg),
        .o_regwrite     (w_ex_ctr_regwrite),
        .o_memread      (w_ex_memread),
        .o_memwrite     (w_ex_memwrite)
    );

//////////////////////////////////////////////
// EX (Execute Operation or Calculate ADDR) //
//////////////////////////////////////////////
    /* PC Peri Logics */
    shift_left #(   // Shift Left 2 for make input source that making Branch ADDR
        .LEFT_CNT       (2),
        .ADDR_BIT       (DATA_BIT)
    ) u_shift_left_branch (
        .i_i            ({2'b00, w_ex_sign_extend_const}),
        .o_o            (w_ex_shift_left2_sign_extend_const)
    );
    adder21 #(  // Branch ADDR Adder
        .DATA_BIT       (DATA_BIT)
    ) u_branch_addr_adder ( 
        .i_i0           ({{(DATA_BIT - ADDR_BIT){1'b0}}, w_ex_pc_addr}),
        .i_i1           (w_ex_sign_extend_branch_addr),
        .o_o            (w_ex_branch_addr)
    );
    
    /* Branch ADDR Decision MUX (Bracnh MUX) */
    mux21 #(
        .DATA_BIT       (ADDR_BIT)
    ) u_branch_mux (
        .i_ctr          (w_ex_ctr_branch),
        .i_i0           (w_ex_pc_addr),
        .i_i1           (w_ex_branch_addr[ADDR_BIT - 1:0]),
        .o_o            (w_ex_branch_mux_addr)
    );
    
    /* I-MEM RADDR Decision MUX (Jump MUX) */
    mux41 #(
        .DATA_BIT       (ADDR_BIT)
    ) u_jump_mux (
        .i_ctr          (w_ex_ctr_jump),
        .i_i00          (w_ex_branch_mux_addr),             // branch
        .i_i01          (w_ex_jump_addr[ADDR_BIT - 1:0]),   // j
        .i_i11          (w_ex_jump_addr[ADDR_BIT - 1:0]),   // jal
        .i_i10          (w_ex_reg_rdata1),                  // jr
        .o_o            (w_ex_jump_mux_addr)
    );

    /* ALU Control */
    alu_ctr #(
        .DATA_BIT       (DATA_BIT)
    ) u_alu_control (
        .i_funct        (w_ex_dec_funct),
        .i_aluop        (w_ex_aluop),
        .o_aluop        (w_ex_alu_ctr)
    );
  
    /* ALU ForwardA MUX */
    mux41 #(
        .DATA_BIT       (DATA_BIT)
    ) u_alu_forward_a_mux (
        .i_ctr          ({w_fw_ctr_alu_a_2c, w_fw_ctr_alu_a_1c}),
        .i_i00          (w_ex_reg_rdata1),
        .i_i01          (w_mem_alu_out),
        .i_i11          (w_mem_alu_out),
        .i_i10          (w_wb_memtoreg_mux_data),
        .o_o            (w_ex_alu_fw_mux_data_a)
    );

    /* ALU ForwardB MUX */
    mux41 #(
        .DATA_BIT       (DATA_BIT)
    ) u_alu_forward_b_mux (
        .i_ctr          ({w_fw_ctr_alu_b_2c, w_fw_ctr_alu_b_1c}),
        .i_i00          (w_ex_reg_rdata2),
        .i_i01          (w_mem_alu_out),
        .i_i11          (w_mem_alu_out),
        .i_i10          (w_wb_memtoreg_mux_data),
        .o_o            (w_ex_alu_fw_mux_data_b)
    );

    /* ALU Input Decision MUX (ALUSrc MUX) */
    mux21 #(
        .DATA_BIT       (DATA_BIT)
    ) u_alusrc_mux (
        .i_ctr          (w_ex_ctr_alusrc),
        .i_i0           (w_ex_alu_fw_mux_data_b),
        .i_i1           (w_ex_sign_extend_const),
        .o_o            (w_ex_alusrc_mux_data)
    );

    /* Arithmetic Logic Unit (ALU) */
    alu #(
        .DATA_BIT       (DATA_BIT)
    ) u_alu (
        .i_in0          (w_ex_alu_fw_mux_data_a),
        .i_in1          (w_ex_alusrc_mux_data),
        .i_carry        (1'b0),
        .i_aluop        (w_ex_alu_ctr),
        .o_out          (w_ex_alu_out),
        .o_carry        (w_ex_alu_carry_out),
        .o_zero         (w_ex_alu_zero)
    );

    /* WDATA Decision MUX (2 Cycle) */
    mux21 #(
        .DATA_BIT       (DATA_BIT) 
    ) u_wdata_forward_2cycle_mux (
        .i_ctr          (w_ex_fw_ctr_wdata_2c),
        .i_i0           (w_ex_reg_rdata2),
        .i_i1           (w_wb_alu_out),
        .o_o            (w_ex_wdata_fw_mux_data_2c)
    );

    /* Multiple/Divide Unit */
    mul_div_unit #(
        .DATA_BIT       (DATA_BIT)
    ) u_mul_div_unit (
        .i_in0          (w_ex_alu_fw_mux_data_a),
        .i_in1          (w_ex_alusrc_mux_data),
        .i_aluop        (w_ex_alu_ctr),
        .o_hi           (w_ex_hi),
        .o_lo           (w_ex_lo)
    );

    /* WR Register Decision MUX (RegDst MUX) */
    mux21 #(
        .DATA_BIT       (REG_BIT)
    ) u_regdst_mux (
        .i_ctr          (w_ex_ctr_regdst),
        .i_i0           (w_ex_dec_rt),
        .i_i1           (w_ex_dec_rd),
        .o_o            (w_ex_regdst_mux_reg)
    );   

    /* EX-MEM Bridge */
    ex_mem #(
        .REG_BIT            (REG_BIT),
        .ADDR_BIT           (ADDR_BIT),
        .DATA_BIT           (DATA_BIT)
    ) u_ex_mem_bridge (
        .clk                (clk),
        .rst_n              (rst_n),
        .i_pc_addr          (w_ex_pc_addr),
        .i_rt               (w_ex_dec_rt),
        .i_wr_reg           (w_ex_regdst_mux_reg),
        .i_memtoreg         (w_ex_memtoreg),
        .i_regwrite         (w_ex_ctr_regwrite),
        .i_memread          (w_ex_memread),
        .i_memwrite         (w_ex_memwrite),
        .i_jump             (w_ex_ctr_jump),
        .i_reg_rdata2       (w_ex_reg_rdata2),
        .i_alu_out          (w_ex_alu_out),
        .i_fw_ctr_wdata_2c  (w_ex_fw_ctr_wdata_2c),
        .i_wdata_fw_mux_data(w_ex_wdata_fw_mux_data_2c),
        .o_pc_addr          (w_mem_pc_addr),
        .o_rt               (w_mem_dec_rt),
        .o_wr_reg           (w_mem_regdst_mux_reg),
        .o_memtoreg         (w_mem_memtoreg),
        .o_regwrite         (w_mem_regwrite),
        .o_memread          (w_mem_memread),
        .o_memwrite         (w_mem_memwrite),
        .o_jump             (w_mem_jump),
        .o_alu_out          (w_mem_alu_out),
        .o_reg_rdata2       (w_mem_reg_rdata2),
        .o_fw_ctr_wdata_2c  (w_mem_fw_ctr_wdata_2c),
        .o_wdata_fw_mux_data(w_mem_wdata_fw_mux_data_2c)
    );

/////////////////////////////////
// MEM (Access Memory Operand) //
/////////////////////////////////
    /* WDATA Decision MUX */
    mux41 #(
        .DATA_BIT       (DATA_BIT)
    ) u_wdata_forward_mux (
        .i_ctr          ({w_fw_ctr_wdata_1c, w_mem_fw_ctr_wdata_2c}),
        .i_i00          (w_mem_reg_rdata2),
        .i_i01          (w_mem_wdata_fw_mux_data_2c),
        .i_i11          (w_mem_wdata_fw_mux_data_2c/* don't care */),
        .i_i10          (w_wb_alu_out),
        .o_o            (w_mem_wdata_fw_mux_data)
    );

    /* MEM-WB Bridge */
    mem_wb #(
        .REG_BIT        (REG_BIT),
        .ADDR_BIT       (ADDR_BIT),
        .DATA_BIT       (DATA_BIT)
    ) u_mem_wb_bridge (
        .clk            (clk),
        .rst_n          (rst_n),
        .i_pc_addr      (w_mem_pc_addr),
        .i_wr_reg       (w_mem_regdst_mux_reg),
        .i_memtoreg     (w_mem_memtoreg),
        .i_regwrite     (w_mem_regwrite),
        .i_jump         (w_mem_jump),
        .i_alu_out      (w_mem_alu_out),
        .o_pc_addr      (w_wb_pc_addr),
        .o_wr_reg       (w_wb_regdst_mux_reg),
        .o_memtoreg     (w_wb_ctr_memtoreg),
        .o_regwrite     (w_wb_regwrite),
        .o_jump         (w_wb_ctr_jump),
        .o_alu_out      (w_wb_alu_out)
    );

////////////////////////////////////////
// WB (Write Result Back to Register) //
////////////////////////////////////////
    /* WR Register Decision MUX (for jal) */
    mux21 #(
        .DATA_BIT       (REG_BIT)
    ) u_regdst_jal_mux (
        .i_ctr          ((w_wb_ctr_jump == 2'b11)),
        .i_i0           (w_wb_regdst_mux_reg),
        .i_i1           ({REG_BIT{1'b1}}),          // $ra
        .o_o            (w_wb_regdst_jal_mux_reg)
    );  

    /* Registers WDATA Decision MUX (MEMtoREG MUX) */
    mux41 #(
        .DATA_BIT       (DATA_BIT)
    ) u_memtoreg_mux (
        .i_ctr          ({w_wb_ctr_memtoreg, (w_wb_ctr_jump == 2'b11)}),
        .i_i00          (w_wb_alu_out),
        .i_i01          (w_wb_pc_addr),
        .i_i11          (w_wb_ctr_jump),    // never happend
        .i_i10          (i_d_mem_data),
        .o_o            (w_wb_memtoreg_mux_data)
    );

/////////////////////
// Forwarding Unit //
/////////////////////
    /* ALU Input Forwarding Unit */
    alu_forwarding_unit #(
        .REG_BIT        (REG_BIT)
    ) u_alu_forwarding_unit (
        .i_mem_regwrite (w_mem_regwrite),
        .i_wb_regwrite  (w_wb_regwrite),
        .i_mem_wr_reg   (w_mem_regdst_mux_reg),
        .i_wb_wr_reg    (w_wb_regdst_mux_reg),
        .i_ex_rs        (w_ex_dec_rs),
        .i_ex_rt        (w_ex_dec_rt),
        .o_1c_forward_a (w_fw_ctr_alu_a_1c),
        .o_1c_forward_b (w_fw_ctr_alu_b_1c),
        .o_2c_forward_a (w_fw_ctr_alu_a_2c),
        .o_2c_forward_b (w_fw_ctr_alu_b_2c)
    );

    /* D-MEM WDATA Forwarding Unit */
    wdata_forwarding_unit #(
        .REG_BIT        (REG_BIT)
    ) u_wdata_forwarding_unit (
        .i_wb_regwrite  (w_wb_regwrite),
        .i_wb_wr_reg    (w_wb_regdst_mux_reg),
        .i_ex_rt        (w_ex_dec_rt),
        .i_mem_rt       (w_mem_dec_rt),
        .o_2c_forward   (w_ex_fw_ctr_wdata_2c),
        .o_1c_forward   (w_fw_ctr_wdata_1c)
    );

    /* Load Stall Unit */
    load_stall_unit #(
        .REG_BIT        (REG_BIT)
    ) u_load_stall_unit (
        .i_ex_memread   (w_ex_memread),
        .i_ex_wr_reg    (w_ex_regdst_mux_reg),
        .i_id_rs        (w_id_dec_rs),
        .i_id_rt        (w_id_dec_rt),
        .o_load_stall   (w_load_stall)
    );

    /* Assign wire */
    assign w_id_jump_addr               = {w_id_pc_addr[ADDR_BIT - 1:ADDR_BIT - 4], w_id_shift_left2_dec_jaddr};
    assign w_ex_sign_extend_branch_addr = w_ex_shift_left2_sign_extend_const[DATA_BIT - 1:0];
    assign w_ex_ctr_branch              = ((w_ex_branch == 2'b01) && (w_ex_alu_zero == 1'b1)) || ((w_ex_branch == 2'b10) && (w_ex_alu_zero == 1'b0));
    assign w_ex_flush                   = (w_ex_ctr_branch == 1'b1) || (w_ex_ctr_jump != 2'b00);

    assign o_i_mem_en                   = w_if_i_mem_en;
    assign o_i_mem_addr                 = w_if_pc_addr;
    assign o_d_mem_en                   = w_mem_memwrite | w_mem_memread;
    assign o_d_mem_wren                 = w_mem_memwrite;
    assign o_d_mem_addr                 = w_mem_alu_out[ADDR_BIT - 1:0];
    assign o_d_mem_data                 = w_mem_wdata_fw_mux_data;

endmodule
