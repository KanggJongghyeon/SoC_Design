from pathlib            import Path
from PySide6.QtCore     import Qt
from PySide6.QtGui      import QColor
from PySide6.QtWidgets  import (
    QFileDialog, QFormLayout, QHBoxLayout, QHeaderView, QLabel, QLineEdit,
    QMainWindow, QMessageBox, QPushButton, QSpinBox, QSplitter, QTableWidget,
    QTableWidgetItem, QVBoxLayout, QWidget,
)

from core.mem_loader        import load_mem_file
from core.mips_decoder      import REGISTER_NAMES
from core.mips_simulator    import MipsSimulator, format_memory_changes, format_register_change


class MainWindow(QMainWindow):
    def __init__(self) -> None:
        super().__init__()
        self.setWindowTitle("SoC Verifier - MIPS Golden Model")
        self.resize(1450, 850)
        self.trace = []
        self._build_ui()

    def _build_ui(self) -> None:
        root = QWidget()
        layout = QVBoxLayout(root)

        controls = QHBoxLayout()
        self.path_edit = QLineEdit()
        self.path_edit.setPlaceholderText("Select a 32-bit MIPS .mem file")
        browse = QPushButton("Open MEM")
        browse.clicked.connect(self.open_mem)
        run = QPushButton("Run Golden Model")
        run.clicked.connect(self.run_model)
        controls.addWidget(self.path_edit, 1)
        controls.addWidget(browse)
        controls.addWidget(QLabel("Base PC"))
        self.base_pc_edit = QLineEdit("0x00000000")
        self.base_pc_edit.setMaximumWidth(130)
        controls.addWidget(self.base_pc_edit)
        controls.addWidget(QLabel("Max steps"))
        self.max_steps = QSpinBox()
        self.max_steps.setRange(1, 1_000_000)
        self.max_steps.setValue(1000)
        controls.addWidget(self.max_steps)
        controls.addWidget(run)
        layout.addLayout(controls)

        self.summary = QLabel("Open a MEM file to begin.")
        layout.addWidget(self.summary)

        splitter = QSplitter(Qt.Orientation.Horizontal)
        self.trace_table = QTableWidget(0, 7)
        self.trace_table.setHorizontalHeaderLabels(
            ["Step", "PC", "Machine Code", "Assembly", "Register change", "Memory change", "Next PC"]
        )
        self.trace_table.horizontalHeader().setSectionResizeMode(QHeaderView.ResizeMode.ResizeToContents)
        self.trace_table.horizontalHeader().setSectionResizeMode(3, QHeaderView.ResizeMode.Stretch)
        self.trace_table.setSelectionBehavior(QTableWidget.SelectionBehavior.SelectRows)
        self.trace_table.setEditTriggers(QTableWidget.EditTrigger.NoEditTriggers)
        self.trace_table.itemSelectionChanged.connect(self.show_selected_state)
        splitter.addWidget(self.trace_table)

        state = QWidget()
        state_layout = QVBoxLayout(state)
        state_layout.addWidget(QLabel("Register file after selected instruction"))
        self.reg_table = QTableWidget(32, 3)
        self.reg_table.setHorizontalHeaderLabels(["No.", "Register", "Value"])
        self.reg_table.horizontalHeader().setSectionResizeMode(QHeaderView.ResizeMode.Stretch)
        self.reg_table.setEditTriggers(QTableWidget.EditTrigger.NoEditTriggers)
        state_layout.addWidget(self.reg_table, 1)
        state_layout.addWidget(QLabel("Changed/allocated data memory (byte-addressed, big-endian)"))
        self.mem_table = QTableWidget(0, 2)
        self.mem_table.setHorizontalHeaderLabels(["Address", "Byte"])
        self.mem_table.horizontalHeader().setSectionResizeMode(QHeaderView.ResizeMode.Stretch)
        self.mem_table.setEditTriggers(QTableWidget.EditTrigger.NoEditTriggers)
        state_layout.addWidget(self.mem_table, 1)
        splitter.addWidget(state)
        splitter.setSizes([1000, 400])
        layout.addWidget(splitter, 1)
        self.setCentralWidget(root)

    def open_mem(self) -> None:
        path, _ = QFileDialog.getOpenFileName(self, "Open MEM file", "", "MEM files (*.mem *.hex *.txt);;All files (*)")
        if path:
            self.path_edit.setText(path)

    def run_model(self) -> None:
        try:
            path = Path(self.path_edit.text().strip())
            if not path.is_file():
                raise ValueError("Select an existing MEM file.")
            base_pc = int(self.base_pc_edit.text().strip(), 0)
            words = load_mem_file(path)
            simulator = MipsSimulator(words, base_pc=base_pc)
            self.trace, reason = simulator.run(self.max_steps.value())
            self.populateTrace()
            self.summary.setText(f"Loaded {len(words)} words · Executed {len(self.trace)} instructions · Stop: {reason}")
        except Exception as exc:
            QMessageBox.critical(self, "Execution error", str(exc))

    def populateTrace(self) -> None:
        self.trace_table.setRowCount(len(self.trace))
        for row, entry in enumerate(self.trace):
            values = [
                str(entry.step), f"0x{entry.pc:08X}", f"0x{entry.word:08X}", entry.assembly,
                format_register_change(entry.register_change), format_memory_changes(entry.memory_changes),
                f"0x{entry.next_pc:08X}",
            ]
            for col, value in enumerate(values):
                self.trace_table.setItem(row, col, QTableWidgetItem(value))
            if entry.register_change or entry.memory_changes:
                for col in range(self.trace_table.columnCount()):
                    #self.trace_table.item(row, col).setBackground(QColor("#E8F5E9"))
                    item = self.trace_table.item(row, col)
                    item.setBackground(QColor("#D9EAD3"))
                    item.setForeground(QColor("#000000"))
        if self.trace:
            self.trace_table.selectRow(0)

    def show_selected_state(self) -> None:
        row = self.trace_table.currentRow()
        if not 0 <= row < len(self.trace):
            return
        entry = self.trace[row]
        changedRegister = entry.register_change[0] if entry.register_change else -1
        for index, value in enumerate(entry.registers):
            items = [QTableWidgetItem(str(index)), QTableWidgetItem(REGISTER_NAMES[index]), QTableWidgetItem(f"0x{value:08X}")]
            for col, item in enumerate(items):
                if index == changedRegister:
                    item.setBackground(QColor("#FFF59D"))
                    item.setForeground(QColor("#000000"))
                self.reg_table.setItem(index, col, item)

        memory = sorted(entry.memory.items())
        self.mem_table.setRowCount(len(memory))
        changedAddresses = {address for address, _, _ in entry.memory_changes}
        for mem_row, (address, value) in enumerate(memory):
            for col, text in enumerate((f"0x{address:08X}", f"0x{value:02X}")):
                item = QTableWidgetItem(text)
                if address in changedAddresses:
                    item.setBackground(QColor("#FFF59D"))
                    item.setForeground(QColor("#000000"))
                self.mem_table.setItem(mem_row, col, item)
