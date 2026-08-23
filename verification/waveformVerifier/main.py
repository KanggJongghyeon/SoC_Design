import sys
from PySide6.QtWidgets  import QApplication # Manage Keyboard/Mouse Event / Display Screen / Exit Program
from gui.mainWindow     import MainWindow

##########
## main ##
##########
def main() -> int:  # -> int: return Value(app.exec()) Type is "int"
    ##@ 1. Create QApplication Entity
    app = QApplication(sys.argv)
    ##@ 2. Set Application Name 
    app.setApplicationName("Vivado Waveform verifier")
    ##@ 3. Create Mainwindow(GUI) Entity
    window = MainWindow()
    ##@ 4. Display GUI Window
    window.show()
    ##@ 5. Process Event (like Loop)
    return app.exec()

if __name__ == "__main__":
    raise SystemExit(main())
