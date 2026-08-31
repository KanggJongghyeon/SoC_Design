import unittest
from core.mips_simulator import MipsSimulator

class TestCore(unittest.TestCase):
    def testArithmeticAndStoreAndLoad(self):
        # addiu $t0,$zero,5; addiu $t1,$zero,7; addu $t2,$t0,$t1;
        # sw $t2,0x100($zero); lw $t3,0x100($zero)
        words = [0x24080005, 0x24090007, 0x01095021, 0xAC0A0100, 0x8C0B0100]
        sim = MipsSimulator(words)
        trace, reason = sim.run(10)
        self.assertEqual(reason, "PC reached outside the loaded instruction range")
        self.assertEqual(len(trace), 5)
        self.assertEqual(sim.registers[10], 12)
        self.assertEqual(sim.registers[11], 12)
        self.assertEqual(sim.read_mem(0x100, 4), 12)

    def testTakenBranch(self):
        # addiu $t0,0,1; beq $t0,$t0,+1; addiu $t1,0,99; addiu $t1,0,7
        words = [0x24080001, 0x11080001, 0x24090063, 0x24090007]
        sim = MipsSimulator(words)
        trace, _ = sim.run(10)
        self.assertEqual([entry.pc for entry in trace], [0, 4, 12])
        self.assertEqual(sim.registers[9], 7)

if __name__ == "__main__":
    unittest.main()
