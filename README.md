# SoC Design Project

해당 프로젝트는 RTL 설계를 이용해 SoC를구현하고, MIPS Cross Compiler를 활용해 SoC를 검증하는 프로젝트입니다.
RTL 설계에 사용되는 HDL은 SystemVerilogHDL이고, SoC의 FW 검증은 C 언어를 사용했습니다.
RTL 동작 및 검증 도구는 Xilinx Vivado를 활용했습니다.

RTL 설계는 Windows 환경에서 진행했고, 검증용 C코드 작성은 Ubuntu 환경에서 이루어졌습니다.

SoC Design Project 순서는 다음과 같습니다.
1. RTL 설계
2. 검증용 C 코드 작성
3. MIPS Compiler로 컴파일 및 16진수 Memory File 변환
4. Memory File을 TestBench의 입력으로 불러온 후, Xilinx Vivado의 Simulation 진행
5. Verifier 도구를 이용해 Simulation 결과와 Golden Model의 결과 비교

SoC Design Project는 하위 폴더는 크게 5가지로 구분됩니다.
1. `.\design` : SystemVerilogHDL(.sv)로 이루어진 SoC 내부 디지털 IP들로 구성됩니다.
2. `.\document` : SoC Design RTL 설계의 명세를 정리한 문서들로 구성됩니다.
3. `.\for_ubuntu` : Ubuntu 환경에서 설계한 검증 코드들로 구성됩니다.
4. `.\tb : .\design` 경로의 IP들을 검증하는 TestBench 파일과 디버깅용 Assembly/Disassembly 자동화 C 코드들로 구성됩니다.
5. `.\verification` : Xilinx Vivado의 Waveform과 Golden Model을 비교해주는 파일 및 프로그램들로 구성됩니다.

## .\design

구현된 RTL 모듈은 Core와 NoC 및 SoC를 구성하는 디지털 IP로 구성됩니다.
여기서 중추가 되는 Core는 6-Stage Pipeline을 수행하는 MIPS CPU입니다.

## .\document

해당 경로에서 명세화된 문서는 `IDD`(Interface Design Description, 인터페이스 설계 기술서)과 `RDD`(Register-transfer-level Design Document, 레지스터 전송 레벨  설계 기술서)가 있습니다.

## .\for_ubuntu

Ubuntu 환경에서 개발된 C 소스 파일을 저장한 폴더입니다.
폴더 내 `copyUbuntu.bat` 파일을 실행하면 Ubuntu 환경에 있는 파일들이 해당 경로로 복사됩니다.

현재 SoC 검증용 C 코드는 `application`과 `boot_loader` 두 가지 방향으로 개발 및 테스트 중입니다.

## .\tb

`.\design` 경로의 디지털 IP를 검증하기 위한 폴더로, TestBench 파일들로 구성됩니다.
또한, 하위 경로의 `.\for_debug`는 Assembly/Disassembly를 자동화 해주는 C 코드로 이루어져 있습니다.
각 하위 폴더 내부의 .bat 파일을 실행하면 Assembly 및 Disassmelby를 자동화해주는 실행 프로그램을 만들 수 있습니다.

## .\verification
해당 폴더는 AI(Chat GPT)가 자동으로 생성한 검증용 도구로 버전 업그레이드가 진행 중에 있습니다.
하위 폴더의 실행 프로그램을 생성하면 GUI를 이용해 Vivado Waveform의 결과와 실제 명령어 기반의 레지스터맵 및 메모리맵 결과와 비교할 수 있습니다.
