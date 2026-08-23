# Vivado Waveform Verifiler

32-bit MIPS MEM 파일을 명령어 단위로 실행하여 예상 Register File과 Data Memory 상태를 보여주는 Golden Model GUI입니다.

## 설치 위치

ZIP을 `V:\soc_design\verification`에서 압축 해제하면 다음 경로를 권장합니다.

```text
V:\soc_design\verification\waveformVerifier
```

## 실행

필요 패키지가 이미 설치되었다면 `run.bat`을 더블클릭하거나 PowerShell에서 실행합니다.

```powershell
cd V:\soc_design\verification\waveformVerifier
python main.py
```

## 사용법

1. `Open MEM`을 눌러 한 줄에 하나의 32-bit MIPS 명령어가 있는 `.mem` 파일을 선택합니다.
2. MEM 파일의 첫 명령어 주소를 `Base PC`에 입력합니다. 예: `0x00400000`.
3. Branch/Jump 반복을 제한할 `Max steps`를 입력합니다.
4. `Run Golden Model`을 누릅니다.
5. 왼쪽 실행 Trace의 행을 선택하면 해당 명령어 실행 직후 Register File과 Data Memory 상태가 오른쪽에 표시됩니다.

## EXE 생성

`buildExecuatble.bat`을 더블클릭하거나 다음 명령을 실행합니다.

```powershell
python -m PyInstaller --noconfirm --clean --onefile --windowed --name waveformVerifier main.py
```

완성된 파일은 `dist\waveformVerifier.exe`입니다.

## 현재 범위

- 32-bit MIPS 명령어 Golden Model
- R/I/J Type, REGIMM, Load/Store, HI/LO 연산
- 명령어 실행 Trace
- 단계별 Register File 및 byte-addressed Data Memory Map
- Big-endian Data Memory
- `.mem`의 빈 줄, `#`, `//`, `0x`, underscore 허용

## 다음 단계

- 초기 Register/Data Memory를 GUI에서 불러오는 기능
- 네 RTL과 Branch/Jump 동작 규칙의 세부 일치 검증
- Vivado Simulation을 VCD/CSV로 Export한 뒤 Golden Trace와 비교
- Instruction별 PASS/FAIL 및 실패 원인 표시

## 주의

이 버전은 첫 번째 기능 검증용입니다. Branch delay slot, exception, alignment exception 등은 네 RTL의 정확한 동작 규칙과 비교해 추가 조정해야 합니다.
