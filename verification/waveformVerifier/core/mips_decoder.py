from dataclasses import dataclass

REGISTER_NAMES = [
    "$zero", "$at", "$v0", "$v1", "$a0", "$a1", "$a2", "$a3",
    "$t0", "$t1", "$t2", "$t3", "$t4", "$t5", "$t6", "$t7",
    "$s0", "$s1", "$s2", "$s3", "$s4", "$s5", "$s6", "$s7",
    "$t8", "$t9", "$k0", "$k1", "$gp", "$sp", "$fp", "$ra",
]

R_FUNCTS = {
    0x00: "sll", 0x02: "srl", 0x03: "sra", 0x04: "sllv", 0x06: "srlv", 0x07: "srav",
    0x08: "jr", 0x09: "jalr", 0x10: "mfhi", 0x11: "mthi", 0x12: "mflo", 0x13: "mtlo",
    0x18: "mult", 0x19: "multu", 0x1A: "div", 0x1B: "divu",
    0x20: "add", 0x21: "addu", 0x22: "sub", 0x23: "subu",
    0x24: "and", 0x25: "or", 0x26: "xor", 0x27: "nor", 0x2A: "slt", 0x2B: "sltu",
}

I_OPS = {
    0x04: "beq", 0x05: "bne", 0x06: "blez", 0x07: "bgtz",
    0x08: "addi", 0x09: "addiu", 0x0A: "slti", 0x0B: "sltiu",
    0x0C: "andi", 0x0D: "ori", 0x0E: "xori", 0x0F: "lui",
    0x14: "beql", 0x15: "bnel", 0x16: "blezl", 0x17: "bgtzl",
    0x20: "lb", 0x21: "lh", 0x23: "lw", 0x24: "lbu", 0x25: "lhu",
    0x28: "sb", 0x29: "sh", 0x2B: "sw",
}

REGIMM = {
    0x00: "bltz", 0x01: "bgez", 0x02: "bltzl", 0x03: "bgezl",
    0x10: "bltzal", 0x11: "bgezal", 0x12: "bltzall", 0x13: "bgezall",
}

def sign_extend_16(value: int) -> int:
    value &= 0xFFFF
    return value - 0x10000 if value & 0x8000 else value

@dataclass(frozen=True)
class DecodedInstruction:
    word: int
    name: str
    rs: int
    rt: int
    rd: int
    shamt: int
    immediate: int
    target: int

    @property
    def assembly(self) -> str:
        r = REGISTER_NAMES
        n = self.name
        if n == "nop":
            return "nop"
        if n in {"sll", "srl", "sra"}:
            return f"{n} {r[self.rd]}, {r[self.rt]}, {self.shamt}"
        if n in {"sllv", "srlv", "srav"}:
            return f"{n} {r[self.rd]}, {r[self.rt]}, {r[self.rs]}"
        if n == "jr":
            return f"jr {r[self.rs]}"
        if n == "jalr":
            return f"jalr {r[self.rd]}, {r[self.rs]}"
        if n in {"mfhi", "mflo"}:
            return f"{n} {r[self.rd]}"
        if n in {"mthi", "mtlo"}:
            return f"{n} {r[self.rs]}"
        if n in {"mult", "multu", "div", "divu"}:
            return f"{n} {r[self.rs]}, {r[self.rt]}"
        if n in {"add", "addu", "sub", "subu", "and", "or", "xor", "nor", "slt", "sltu"}:
            return f"{n} {r[self.rd]}, {r[self.rs]}, {r[self.rt]}"
        if n in {"j", "jal"}:
            return f"{n} 0x{self.target << 2:08X}"
        if n in {"beq", "bne", "beql", "bnel"}:
            return f"{n} {r[self.rs]}, {r[self.rt]}, {sign_extend_16(self.immediate)}"
        if n.startswith("b") and n not in {"break"}:
            return f"{n} {r[self.rs]}, {sign_extend_16(self.immediate)}"
        if n in {"lb", "lh", "lw", "lbu", "lhu", "sb", "sh", "sw"}:
            return f"{n} {r[self.rt]}, {sign_extend_16(self.immediate)}({r[self.rs]})"
        if n == "lui":
            return f"lui {r[self.rt]}, 0x{self.immediate:04X}"
        if n in {"andi", "ori", "xori"}:
            return f"{n} {r[self.rt]}, {r[self.rs]}, 0x{self.immediate:04X}"
        return f"{n} {r[self.rt]}, {r[self.rs]}, {sign_extend_16(self.immediate)}"


def decode(word: int) -> DecodedInstruction:
    word &= 0xFFFFFFFF
    opcode = (word >> 26) & 0x3F
    rs = (word >> 21) & 0x1F
    rt = (word >> 16) & 0x1F
    rd = (word >> 11) & 0x1F
    shamt = (word >> 6) & 0x1F
    funct = word & 0x3F
    immediate = word & 0xFFFF
    target = word & 0x03FFFFFF

    if word == 0:
        name = "nop"
    elif opcode == 0:
        name = R_FUNCTS.get(funct, f"unsupported_r_0x{funct:02X}")
    elif opcode == 1:
        name = REGIMM.get(rt, f"unsupported_regimm_0x{rt:02X}")
    elif opcode == 2:
        name = "j"
    elif opcode == 3:
        name = "jal"
    else:
        name = I_OPS.get(opcode, f"unsupported_op_0x{opcode:02X}")
    return DecodedInstruction(word, name, rs, rt, rd, shamt, immediate, target)
