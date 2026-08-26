from pathlib import Path

from PySide6.QtCore import Qt, QTimer, QEvent
from PySide6.QtGui import QColor, QFont
from PySide6.QtWidgets import (
    QFileDialog, QDockWidget, QHBoxLayout, QHeaderView, QLabel, QLineEdit, 
    QMainWindow, QMessageBox, QPushButton, QScrollBar, QSpinBox, QSplitter,
    QTableWidget, QTableWidgetItem, QVBoxLayout, QWidget,
) # QDockWidget : for Add Pop-Up Widget
from core.mem_loader import load_mem_file
from core.mips_decoder import REGISTER_NAMES
from core.mips_simulator import MipsSimulator, format_memory_changes, format_register_change


WORD_BYTES = 4
ADDRESS_SPACE_WORDS = 1 << 30
REGISTER_ROWS = 16
MEMORY_CELL_MIN_WIDTH = 145
MEMORY_ROW_HEIGHT = 45


class MainWindow(QMainWindow):
    def __init__(self) -> None:
        super().__init__()
        self.setWindowTitle("SoC Verifier - MIPS Golden Model")
        self.resize(1450, 850)
        self.trace = []
        self.base_pc = 0 # Real Instruction Line Number
        self.current_memory: dict[int, int] = {}
        self.current_trace_index = -1
        self.memory_top_word = 0
        self.memory_word_columns = 4
        self.memory_visible_rows = 10
        self.highlight_word_address: int | None = None
        self._updating_memory_scroll = False
        self._building_trace = False
        self._build_ui()
        QTimer.singleShot(0, self._refresh_memory_geometry)

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
        """
        main_splitter = QSplitter(Qt.Orientation.Horizontal)
        self.trace_table = QTableWidget(0, 7)
        self.trace_table.setHorizontalHeaderLabels( # Setting Index Title
            #["Step", "PC", "Machine Code", "Assembly", "Register change", "Memory change", "Next PC"]
            ["Line", "PC", "Machine Code", "Assembly", "Register change", "Memory change", "Next PC"]
        )
        trace_header = self.trace_table.horizontalHeader()
        trace_header.setSectionResizeMode(QHeaderView.ResizeMode.ResizeToContents)
        trace_header.setSectionResizeMode(4, QHeaderView.ResizeMode.Stretch)
        trace_header.setSectionResizeMode(5, QHeaderView.ResizeMode.Stretch)
        self.trace_table.setSelectionBehavior(QTableWidget.SelectionBehavior.SelectRows)
        self.trace_table.setEditTriggers(QTableWidget.EditTrigger.NoEditTriggers)
        self.trace_table.itemSelectionChanged.connect(self.show_selected_state)
        main_splitter.addWidget(self.trace_table)

        state_splitter = QSplitter(Qt.Orientation.Vertical)
        state_splitter.addWidget(self._build_register_panel())
        state_splitter.addWidget(self._build_memory_panel())
        state_splitter.setSizes([395, 355])
        state_splitter.setChildrenCollapsible(False)
        state_splitter.splitterMoved.connect(
            lambda _position, _index: QTimer.singleShot(0, self._refresh_memory_geometry)
        )
        main_splitter.addWidget(state_splitter)
        main_splitter.setSizes([1000, 650])
        main_splitter.setChildrenCollapsible(False)
        main_splitter.splitterMoved.connect(
            lambda _position, _index: QTimer.singleShot(0, self._refresh_memory_geometry)
        )
        layout.addWidget(main_splitter, 1)
        self.setCentralWidget(root)
        """
        self.trace_table = QTableWidget(0, 7)
        self.trace_table.setHorizontalHeaderLabels(
            [
                "Line",
                "PC",
                "Machine Code",
                "Assembly",
                "Register change",
                "Memory change",
                "Next PC",
            ]
        )

        trace_header = self.trace_table.horizontalHeader()
        trace_header.setSectionResizeMode(
            QHeaderView.ResizeMode.ResizeToContents
        )
        trace_header.setSectionResizeMode(
            4, QHeaderView.ResizeMode.Stretch
        )
        trace_header.setSectionResizeMode(
            5, QHeaderView.ResizeMode.Stretch
        )

        self.trace_table.setSelectionBehavior(
            QTableWidget.SelectionBehavior.SelectRows
        )
        self.trace_table.setEditTriggers(
            QTableWidget.EditTrigger.NoEditTriggers
        )
        self.trace_table.itemSelectionChanged.connect(
            self.show_selected_state
        )

        layout.addWidget(self.trace_table, 1)
        self.setCentralWidget(root)

        # Register Map Dock
        self.register_dock = self._create_dock(
            "Register Map",
            "registerMapDock",
            self._build_register_panel(),
        )

        # Memory Map Dock
        self.memory_dock = self._create_dock(
            "Memory Map",
            "memoryMapDock",
            self._build_memory_panel(),
        )

        self.addDockWidget(
            Qt.DockWidgetArea.RightDockWidgetArea,
            self.register_dock,
        )
        self.splitDockWidget(
            self.register_dock,
            self.memory_dock,
            Qt.Orientation.Vertical,
        )

        # Initial Y-Size of Register & Memory Map
        self.resizeDocks(
            [self.register_dock, self.memory_dock],
            [390, 350],
            Qt.Orientation.Vertical,
        )

        # Add View Menu to reopen Pop-Up Widget
        view_menu = self.menuBar().addMenu("View")
        view_menu.addAction(self.register_dock.toggleViewAction())
        view_menu.addAction(self.memory_dock.toggleViewAction())

    def _create_dock( # Function to Pop-Up Widget
        self,
        title: str,
        object_name: str,
        content: QWidget,
    ) -> QDockWidget:
        dock = QDockWidget(title, self)
        dock.setObjectName(object_name)
        dock.setWidget(content)

        dock.setFeatures(
            QDockWidget.DockWidgetFeature.DockWidgetMovable
            | QDockWidget.DockWidgetFeature.DockWidgetFloatable
            | QDockWidget.DockWidgetFeature.DockWidgetClosable
        )

        dock.setAllowedAreas(
            Qt.DockWidgetArea.LeftDockWidgetArea
            | Qt.DockWidgetArea.RightDockWidgetArea
            | Qt.DockWidgetArea.TopDockWidgetArea
            | Qt.DockWidgetArea.BottomDockWidgetArea
        )

        return dock

    def _build_register_panel(self) -> QWidget:
        panel = QWidget()
        layout = QVBoxLayout(panel)
        layout.setContentsMargins(0, 0, 0, 0)
        layout.addWidget(QLabel("Register file after selected instruction"))
        self.reg_table = QTableWidget(REGISTER_ROWS, 6)
        self.reg_table.setHorizontalHeaderLabels(["No.", "Register", "Value", "No.", "Register", "Value"])
        header = self.reg_table.horizontalHeader()
        for col in (0, 1, 3, 4):
            header.setSectionResizeMode(col, QHeaderView.ResizeMode.ResizeToContents)
        for col in (2, 5):
            header.setSectionResizeMode(col, QHeaderView.ResizeMode.Stretch)
        self.reg_table.setEditTriggers(QTableWidget.EditTrigger.NoEditTriggers)
        self.reg_table.setSelectionMode(QTableWidget.SelectionMode.NoSelection)
        self.reg_table.setAlternatingRowColors(True)
        self.reg_table.setFont(QFont(self.reg_table.font().family(), 8))
        self.reg_table.verticalHeader().setVisible(False)
        for row in range(REGISTER_ROWS):
            self.reg_table.setRowHeight(row, 21)
        layout.addWidget(self.reg_table, 1)
        self._populate_registers(tuple([0] * 32), -1)
        return panel

    def _build_memory_panel(self) -> QWidget:
        panel = QWidget()
        layout = QVBoxLayout(panel)
        layout.setContentsMargins(0, 0, 0, 0)
        search_row = QHBoxLayout()
        search_row.addWidget(QLabel("32-bit word memory (byte-addressed, big-endian)"), 1)
        search_row.addWidget(QLabel("Address"))
        self.memory_search = QLineEdit("0x00000000")
        self.memory_search.setMaximumWidth(130)
        self.memory_search.returnPressed.connect(self.search_memory)
        search_button = QPushButton("Go")
        search_button.clicked.connect(self.search_memory)
        search_row.addWidget(self.memory_search)
        search_row.addWidget(search_button)
        layout.addLayout(search_row)

        table_row = QHBoxLayout()
        self.mem_table = QTableWidget(0, 0)
        self.mem_table.setEditTriggers(QTableWidget.EditTrigger.NoEditTriggers)
        self.mem_table.setSelectionMode(QTableWidget.SelectionMode.NoSelection)
        self.mem_table.verticalHeader().setVisible(False)
        self.mem_table.setVerticalScrollBarPolicy(Qt.ScrollBarPolicy.ScrollBarAlwaysOff)
        self.mem_table.setHorizontalScrollBarPolicy(Qt.ScrollBarPolicy.ScrollBarAlwaysOff)
        self.mem_table.viewport().installEventFilter(self)
        self.mem_table.setFont(QFont(self.mem_table.font().family(), 8))
        table_row.addWidget(self.mem_table, 1)
        self.memory_scroll = QScrollBar(Qt.Orientation.Vertical)
        self.memory_scroll.valueChanged.connect(self._memory_scroll_changed)
        table_row.addWidget(self.memory_scroll)
        layout.addLayout(table_row, 1)
        return panel

    def open_mem(self) -> None:
        path, _ = QFileDialog.getOpenFileName(
            self, "Open MEM file", "", "MEM files (*.mem *.hex *.txt);;All files (*)"
        )
        if path:
            self.path_edit.setText(path)

    def run_model(self) -> None:
        try:
            path = Path(self.path_edit.text().strip())
            if not path.is_file():
                raise ValueError("Select an existing MEM file.")
            base_pc = int(self.base_pc_edit.text().strip(), 0)
            self.base_pc = base_pc # for Real Instruction Line
            words = load_mem_file(path)
            simulator = MipsSimulator(words, base_pc=base_pc)
            self.trace, reason = simulator.run(self.max_steps.value())
            self.populate_trace()
            self._show_final_state()
            self.summary.setText(
                f"Loaded {len(words)} words · Executed {len(self.trace)} instructions · Stop: {reason}"
            )
        except Exception as exc:
            QMessageBox.critical(self, "Execution error", str(exc))

    def populate_trace(self) -> None:
        self._building_trace = True
        self.trace_table.clearSelection()
        self.trace_table.setRowCount(len(self.trace))
        for row, entry in enumerate(self.trace):
            lineNumber = ((entry.pc - self.base_pc) // 4) + 1 # for Real Instruction Line
            values = [
                #str(entry.step), f"0x{entry.pc:08X}", f"0x{entry.word:08X}", entry.assembly,
                str(lineNumber), f"0x{entry.pc:08X}", f"0x{entry.word:08X}", entry.assembly, # for Real Instruction Line
                format_register_change(entry.register_change), format_memory_changes(entry.memory_changes),
                f"0x{entry.next_pc:08X}",
            ]
            for col, value in enumerate(values):
                self.trace_table.setItem(row, col, QTableWidgetItem(value))
        self.trace_table.setCurrentCell(-1, -1)
        self._building_trace = False

    def _show_final_state(self) -> None:
        self.current_memory.clear()
        for entry in self.trace:
            self._apply_memory_changes(entry.memory_changes, True)
        self.current_trace_index = len(self.trace) - 1
        self.highlight_word_address = None
        self._set_memory_top_address(0)
        registers = self.trace[-1].registers if self.trace else tuple([0] * 32)
        self._populate_registers(registers, -1)
        self._render_memory()

    def show_selected_state(self) -> None:
        if self._building_trace:
            return
        row = self.trace_table.currentRow()
        if not 0 <= row < len(self.trace):
            return
        self._move_memory_snapshot(row)
        entry = self.trace[row]
        changed_register = entry.register_change[0] if entry.register_change else -1
        self._populate_registers(entry.registers, changed_register)
        self.highlight_word_address = None
        if entry.memory_access and entry.memory_access[0] == "store":
            self.highlight_word_address = entry.memory_access[1] & ~0x3
            self._set_memory_top_address(self.highlight_word_address)
        self._render_memory()

    def _move_memory_snapshot(self, target_index: int) -> None:
        if target_index < self.current_trace_index:
            for index in range(self.current_trace_index, target_index, -1):
                self._apply_memory_changes(self.trace[index].memory_changes, False)
        elif target_index > self.current_trace_index:
            for index in range(self.current_trace_index + 1, target_index + 1):
                self._apply_memory_changes(self.trace[index].memory_changes, True)
        self.current_trace_index = target_index

    def _apply_memory_changes(self, changes: list[tuple[int, int, int]], forward: bool) -> None:
        iterable = changes if forward else reversed(changes)
        for address, old, new in iterable:
            value = new if forward else old
            if value:
                self.current_memory[address & 0xFFFFFFFF] = value
            else:
                self.current_memory.pop(address & 0xFFFFFFFF, None)

    def _populate_registers(self, registers: tuple[int, ...], changed_register: int) -> None:
        for row in range(REGISTER_ROWS):
            for block, index in enumerate((row, row + REGISTER_ROWS)):
                values = (str(index), REGISTER_NAMES[index], f"0x{registers[index]:08X}")
                for offset, value in enumerate(values):
                    item = QTableWidgetItem(value)
                    if index == changed_register:
                        item.setBackground(QColor("#FFF59D"))
                        item.setForeground(QColor("#000000"))
                    self.reg_table.setItem(row, block * 3 + offset, item)

    def search_memory(self) -> None:
        try:
            address = int(self.memory_search.text().strip(), 0)
            if not 0 <= address <= 0xFFFFFFFF:
                raise ValueError
        except ValueError:
            QMessageBox.warning(self, "Invalid address", "Enter an address from 0x00000000 to 0xFFFFFFFF.")
            return
        self.highlight_word_address = None
        self._set_memory_top_address(address & ~0x3)
        self._render_memory()

    def _set_memory_top_address(self, address: int) -> None:
        word_index = min((address & 0xFFFFFFFF) // WORD_BYTES, ADDRESS_SPACE_WORDS - 1)
        self.memory_top_word = word_index
        self._updating_memory_scroll = True
        self.memory_scroll.setValue(word_index)
        self._updating_memory_scroll = False
        self.memory_search.setText(f"0x{word_index * WORD_BYTES:08X}")

    def _memory_scroll_changed(self, value: int) -> None:
        if self._updating_memory_scroll:
            return
        columns = max(1, self.memory_word_columns)
        self.memory_top_word = (value // columns) * columns
        self.memory_search.setText(f"0x{self.memory_top_word * WORD_BYTES:08X}")
        self._render_memory()

    def _read_word(self, address: int) -> int:
        value = 0
        for offset in range(WORD_BYTES):
            value = (value << 8) | self.current_memory.get((address + offset) & 0xFFFFFFFF, 0)
        return value

    def _render_memory(self) -> None:
        columns = max(1, self.memory_word_columns)
        rows = max(1, self.memory_visible_rows)
        self.mem_table.setUpdatesEnabled(False)
        self.mem_table.clear()
        self.mem_table.setRowCount(rows)
        self.mem_table.setColumnCount(columns + 1)
        self.mem_table.setHorizontalHeaderLabels(["Row address"] + [f"Word {i}" for i in range(columns)])
        header = self.mem_table.horizontalHeader()
        header.setSectionResizeMode(0, QHeaderView.ResizeMode.ResizeToContents)
        for col in range(1, columns + 1):
            header.setSectionResizeMode(col, QHeaderView.ResizeMode.Stretch)
        for row in range(rows):
            row_word = self.memory_top_word + row * columns
            row_address = row_word * WORD_BYTES
            self.mem_table.setItem(row, 0, QTableWidgetItem(f"0x{row_address:08X}"))
            self.mem_table.setRowHeight(row, MEMORY_ROW_HEIGHT)
            for col in range(columns):
                word_index = row_word + col
                if word_index >= ADDRESS_SPACE_WORDS:
                    continue
                address = word_index * WORD_BYTES
                #item = QTableWidgetItem(f"M[0x{address:08X}]\n0x{self._read_word(address):08X}")
                item = QTableWidgetItem(f"0x{self._read_word(address):08X}")                
                if address == self.highlight_word_address:
                    item.setBackground(QColor("#FFF59D"))
                    item.setForeground(QColor("#000000"))
                self.mem_table.setItem(row, col + 1, item)
        visible_words = rows * columns
        self.memory_scroll.setRange(0, max(0, ADDRESS_SPACE_WORDS - visible_words))
        self.memory_scroll.setSingleStep(columns)
        self.memory_scroll.setPageStep(visible_words)
        self.mem_table.setUpdatesEnabled(True)

    def _refresh_memory_geometry(self) -> None:
        if not hasattr(self, "mem_table"):
            return
        viewport_width = max(1, self.mem_table.viewport().width() - 100)
        viewport_height = max(1, self.mem_table.viewport().height() - 28)
        new_columns = max(1, viewport_width // MEMORY_CELL_MIN_WIDTH)
        new_rows = max(1, viewport_height // MEMORY_ROW_HEIGHT)
        if new_columns != self.memory_word_columns or new_rows != self.memory_visible_rows:
            old_address = self.memory_top_word * WORD_BYTES
            self.memory_word_columns = new_columns
            self.memory_visible_rows = new_rows
            self.memory_top_word = (old_address // WORD_BYTES // new_columns) * new_columns
            self._render_memory()

    def resizeEvent(self, event) -> None:
        super().resizeEvent(event)
        QTimer.singleShot(0, self._refresh_memory_geometry)

    def eventFilter(self, watched, event) -> bool:
        #if watched is self.mem_table.viewport() and event.type() == QEvent.Type.Wheel:
        if watched is self.mem_table.viewport(): # for Add Pop-Up Widget
            if (event.type() == QEvent.Type.Wheel):
                wheelSteps = event.angleDelta().y() // 120
                if (0 != wheelSteps):
                    move_words = wheelSteps * self.memory_word_columns
                    self.memory_scroll.setValue(
                        self.memory_scroll.value() - move_words
                    )
                return True
            if (event.type() == QEvent.Type.Resize):
                QTimer.singleShot(0, self._refresh_memory_geometry)

        return super().eventFilter(watched, event)
