from dataclasses    import dataclass, field
from .mips_decoder  import DecodedInstruction, REGISTER_NAMES, decode, sign_extend_16

MASK32 = 0xFFFFFFFF

def u32(value: int) -> int:
    return value & MASK32

def s32(value: int) -> int:
    value &= MASK32
    return value - 0x100000000 if value & 0x80000000 else value

@dataclass
class TraceEntry:
    step: int
    pc: int
    word: int
    assembly: str
    next_pc: int
    register_change: tuple[int, int, int] | None
    memory_changes: list[tuple[int, int, int]]
    registers: tuple[int, ...]
    memory: dict[int, int]
    note: str = ""

@dataclass
class MipsSimulator:
    instructions: list[int]
    base_pc: int = 0
    registers: list[int] = field(default_factory=lambda: [0] * 32)
    memory: dict[int, int] = field(default_factory=dict)  # byte-addressed
    hi: int = 0
    lo: int = 0
    pc: int = 0

    def __post_init__(self) -> None:
        self.pc = self.base_pc & MASK32
        self.registers[0] = 0

    def fetch(self) -> int:
        if self.pc < self.base_pc or (self.pc - self.base_pc) % 4:
            raise RuntimeError(f"PC 0x{self.pc:08X} is outside/aligned incorrectly")
        index = (self.pc - self.base_pc) // 4
        if not 0 <= index < len(self.instructions):
            raise StopIteration
        return self.instructions[index]

    def read_mem(self, address: int, size: int, signed: bool = False) -> int:
        # MIPS big-endian byte order, matching elf32-tradbigmips.
        value = 0
        for offset in range(size):
            value = (value << 8) | self.memory.get(u32(address + offset), 0)
        if signed and value & (1 << (size * 8 - 1)):
            value -= 1 << (size * 8)
        return u32(value)

    def write_mem(self, address: int, size: int, value: int) -> list[tuple[int, int, int]]:
        changes = []
        for offset in range(size):
            shift = (size - 1 - offset) * 8
            byte = (value >> shift) & 0xFF
            addr = u32(address + offset)
            old = self.memory.get(addr, 0)
            self.memory[addr] = byte
            if old != byte:
                changes.append((addr, old, byte))
        return changes

    def set_reg(self, index: int, value: int) -> tuple[int, int, int] | None:
        if index == 0:
            return None
        old = self.registers[index]
        new = u32(value)
        self.registers[index] = new
        return (index, old, new) if old != new else None

    def execute_one(self, step: int) -> TraceEntry:
        pc = self.pc
        word = self.fetch()
        ins = decode(word)
        r = self.registers
        next_pc = u32(pc + 4)
        reg_change = None
        mem_changes: list[tuple[int, int, int]] = []
        note = ""
        n = ins.name
        imm_s = sign_extend_16(ins.immediate)

        if n == "nop":
            pass
        elif n in {"add", "addu"}:
            reg_change = self.set_reg(ins.rd, r[ins.rs] + r[ins.rt])
        elif n in {"sub", "subu"}:
            reg_change = self.set_reg(ins.rd, r[ins.rs] - r[ins.rt])
        elif n == "and": reg_change = self.set_reg(ins.rd, r[ins.rs] & r[ins.rt])
        elif n == "or": reg_change = self.set_reg(ins.rd, r[ins.rs] | r[ins.rt])
        elif n == "xor": reg_change = self.set_reg(ins.rd, r[ins.rs] ^ r[ins.rt])
        elif n == "nor": reg_change = self.set_reg(ins.rd, ~(r[ins.rs] | r[ins.rt]))
        elif n == "slt": reg_change = self.set_reg(ins.rd, int(s32(r[ins.rs]) < s32(r[ins.rt])))
        elif n == "sltu": reg_change = self.set_reg(ins.rd, int(r[ins.rs] < r[ins.rt]))
        elif n == "sll": reg_change = self.set_reg(ins.rd, r[ins.rt] << ins.shamt)
        elif n == "srl": reg_change = self.set_reg(ins.rd, r[ins.rt] >> ins.shamt)
        elif n == "sra": reg_change = self.set_reg(ins.rd, s32(r[ins.rt]) >> ins.shamt)
        elif n == "sllv": reg_change = self.set_reg(ins.rd, r[ins.rt] << (r[ins.rs] & 0x1F))
        elif n == "srlv": reg_change = self.set_reg(ins.rd, r[ins.rt] >> (r[ins.rs] & 0x1F))
        elif n == "srav": reg_change = self.set_reg(ins.rd, s32(r[ins.rt]) >> (r[ins.rs] & 0x1F))
        elif n in {"addi", "addiu"}: reg_change = self.set_reg(ins.rt, r[ins.rs] + imm_s)
        elif n == "slti": reg_change = self.set_reg(ins.rt, int(s32(r[ins.rs]) < imm_s))
        elif n == "sltiu": reg_change = self.set_reg(ins.rt, int(r[ins.rs] < u32(imm_s)))
        elif n == "andi": reg_change = self.set_reg(ins.rt, r[ins.rs] & ins.immediate)
        elif n == "ori": reg_change = self.set_reg(ins.rt, r[ins.rs] | ins.immediate)
        elif n == "xori": reg_change = self.set_reg(ins.rt, r[ins.rs] ^ ins.immediate)
        elif n == "lui": reg_change = self.set_reg(ins.rt, ins.immediate << 16)
        elif n in {"mult", "multu"}:
            product = (s32(r[ins.rs]) * s32(r[ins.rt])) if n == "mult" else (r[ins.rs] * r[ins.rt])
            product &= 0xFFFFFFFFFFFFFFFF
            self.hi, self.lo = (product >> 32) & MASK32, product & MASK32
        elif n in {"div", "divu"}:
            divisor = s32(r[ins.rt]) if n == "div" else r[ins.rt]
            dividend = s32(r[ins.rs]) if n == "div" else r[ins.rs]
            if divisor:
                self.lo = u32(int(dividend / divisor))
                self.hi = u32(dividend - int(dividend / divisor) * divisor)
            else:
                note = "divide by zero; HI/LO unchanged"
        elif n == "mfhi": reg_change = self.set_reg(ins.rd, self.hi)
        elif n == "mflo": reg_change = self.set_reg(ins.rd, self.lo)
        elif n == "mthi": self.hi = r[ins.rs]
        elif n == "mtlo": self.lo = r[ins.rs]
        elif n == "jr": next_pc = r[ins.rs]
        elif n == "jalr":
            reg_change = self.set_reg(ins.rd or 31, pc + 8)
            next_pc = r[ins.rs]
        elif n in {"j", "jal"}:
            if n == "jal": reg_change = self.set_reg(31, pc + 8)
            next_pc = ((pc + 4) & 0xF0000000) | (ins.target << 2)
        elif n in {"beq", "bne", "beql", "bnel"}:
            taken = (r[ins.rs] == r[ins.rt]) if n.startswith("beq") else (r[ins.rs] != r[ins.rt])
            if taken: next_pc = u32(pc + 4 + (imm_s << 2))
        elif n in {"blez", "blezl"}:
            if s32(r[ins.rs]) <= 0: next_pc = u32(pc + 4 + (imm_s << 2))
        elif n in {"bgtz", "bgtzl"}:
            if s32(r[ins.rs]) > 0: next_pc = u32(pc + 4 + (imm_s << 2))
        elif n.startswith("bltz") or n.startswith("bgez"):
            taken = s32(r[ins.rs]) < 0 if n.startswith("bltz") else s32(r[ins.rs]) >= 0
            if "al" in n: reg_change = self.set_reg(31, pc + 8)
            if taken: next_pc = u32(pc + 4 + (imm_s << 2))
        elif n in {"lb", "lh", "lw", "lbu", "lhu"}:
            size = {"lb": 1, "lbu": 1, "lh": 2, "lhu": 2, "lw": 4}[n]
            reg_change = self.set_reg(ins.rt, self.read_mem(r[ins.rs] + imm_s, size, n in {"lb", "lh"}))
        elif n in {"sb", "sh", "sw"}:
            size = {"sb": 1, "sh": 2, "sw": 4}[n]
            mem_changes = self.write_mem(r[ins.rs] + imm_s, size, r[ins.rt])
        else:
            raise RuntimeError(f"Unsupported instruction 0x{word:08X} ({n}) at PC 0x{pc:08X}")

        self.registers[0] = 0
        self.pc = u32(next_pc)
        return TraceEntry(step, pc, word, ins.assembly, self.pc, reg_change, mem_changes,
                          tuple(self.registers), dict(self.memory), note)

    def run(self, max_steps: int = 1000) -> tuple[list[TraceEntry], str]:
        trace: list[TraceEntry] = []
        reason = "Maximum step count reached"
        for step in range(1, max_steps + 1):
            try:
                trace.append(self.execute_one(step))
            except StopIteration:
                reason = "PC reached outside the loaded instruction range"
                break
        return trace, reason

def format_register_change(change: tuple[int, int, int] | None) -> str:
    if not change:
        return "-"
    index, old, new = change
    return f"{REGISTER_NAMES[index]}: 0x{old:08X} → 0x{new:08X}"

def format_memory_changes(changes: list[tuple[int, int, int]]) -> str:
    if not changes:
        return "-"
    return ", ".join(f"[0x{a:08X}] {old:02X}→{new:02X}" for a, old, new in changes)
