# Nebula Helper

## 원본 레포지토리
- https://github.com/dscalzi/Nebula.git

## 작성되는 파일
- windows : nebula-helper.bat
- mac/linux : nebula-helper.sh
- 공통 : .reset_exclusion_list

## 명령어 및 변수 정리

### 1. 종속성 설치
- 명령어 : npm i
- 변수 : 없음

### 2. 작업 폴더 생성
- 명령어 : npm run start -- init root
- 변수 : 없음

### 3. 서버 폴더 생성
- 명령어 : npm start -- generate server <id> <version> <options> <options-string>
- 변수
  - id : string | Server Name
  - version : string | Server MC Version
  - options : --forge, --fabric | Mod Loader
  - options-string : string | Mod Loader Version

### 4. 최종 파일 생성
- 명령어 : npm start -- generate distro
- 변수 : Helper에서 지원하지 않음

## Helper 실행시 검출 내용

### .env File
- 검출 진행 조건 : 무조건
- '.env' 파일 검출
  - Found / Not found
- 파일 검출 후 JAVA, ROOT, URL항목의 값 검출. 만약 모든값이 있다면 해당 검출 결과는 표기하지 않음.(JAVA는 distro 메뉴 외에는 경고만 한다)
  - JAVA, ROOT, URL miss
  - JAVA, ROOT miss
  - JAVA, URL miss
  - ROOT, URL miss
  - JAVA miss
  - ROOT miss
  - URL miss

### ROOT folder
- 검출 진행 조건 : '.env' 파일 검출 결과 Found / ROOT항목 값 검출됨
- ROOT path와 실제 ${ROOT} 폴더의 경로를 비교 검출
  - Found / Not found

### Servers Folder
- 검출 진행 조건 : ROOT folder 검출 결과 Found
- `${ROOT}/servers` 하위 디렉토리(1 depth)의 수량 검출
  - x found / Not found
- `x` : 검출된 하위 디렉토리 수량

### distribution.json
- 검출 진행 조건 : 무조건
- `${ROOT}/distribution.json` 검출
  - Found / Not found

## Helper 디자인

### 항상 유지
- Nebula 아스키 코드 로고
- nebula helper
- made by mxxndawn
- Current Page : 현재 메뉴 위치

### Home 에서만 유지
- Status : 검출된 결과 나열

### Home 메뉴
1. Step 1 - Nebula Setup
2. Step 2 - Env File Setup
3. Step 3 - Root Directory Setup
4. Step 4 - Server Directory Setup
5. Step 5 - Distro Export
6. List of servers created
7. Nebula Reset
8. Exit

## Home 기능

### 현재 Nebula의 작성 상태확인

### 현재 상태에 맞는 메뉴 선택
- 메뉴는 각 스탭으로 구분되어있으나, 검출된 값을 바탕으로 아직 진행 불가능한 메뉴는 선택이 불가능하도록 함.
- 공통 - 접근 불가 조건시 : Home 화면은 유지하고, 접근 불가 사유에 대한 `Warning` 메시지를 화면 최하단에 출력함.

## Menu별 진행

### Step 1 - Nebula Setup
- 접근 조건 : 언제나
- Action : `npm i`

- Result
  - Prompt : npm 종속성 설치가 완료되었습니다. 다음 단계를 진행할 수 있습니다.
  - Options
    - Next step (Step 2)
    - Back to home
    - Exit

### Step 2 - Env File Setup
- 접근 조건 : 언제나

- `.env` 검출값 : Found
  - Prompt : `.env` 파일이 이미 존재합니다. 재생성하시겠습니까?
  - Options
    - Delete & Create .env template
    - Delete & Start guided setup
    - Back to home
    - Exit

- `.env` 검출값 : Not found
  - Prompt : `.env` 파일이 존재하지 않습니다.
  - Options
    - Create .env template
      - Result
        - Prompt : `.env` 템플릿 파일이 생성되었습니다. 필수 값을 직접 입력한 후 다음 단계를 진행하세요.
        - Options
          - Back to home
          - Exit

    - Start guided setup
      - Input
        - `JAVA_EXECUTABLE`
          - Prompt : 해당 항목은 이후에도 직접 입력할 수 있습니다.
          - Options
            - Enter path
            - Leave blank

        - `ROOT`
          - Prompt : Nebula 작업을 위한 `ROOT` 경로를 입력해주세요. 모든 작업은 이 폴더를 기준으로 진행됩니다.

        - `BASE_URL`
          - Prompt : `ROOT` 폴더가 업로드될 CDN URL을 입력해주세요. 반드시 `http://` 또는 `https://`가 포함되어야 합니다.

        - `HELIOS_DATA_FOLDER`
          - Prompt : 해당 항목은 비워둘 수 있으며, 입력하더라도 관련 기능은 Helper에서 지원하지 않습니다.
          - Options
            - Enter path
            - Leave blank

      - Result
        - Prompt : `.env` 파일 작성이 완료되었습니다.
        - Options
          - Next step (Step 3)
          - Back to home
          - Exit

    - Back to home
    - Exit

### Step 3 - Root Directory Setup
- 접근 불가
  - `.env` : Not Found
    - Warning : `.env` 파일이 존재하지 않습니다. 먼저 Step 2 - Env File Setup을 진행해 주세요.

  - `.env` : Found, `ROOT` value : Not found
    - Warning : `ROOT` 값이 비어 있습니다. 메뉴를 통해 `.env` 파일을 재생성하거나 수동으로 값을 입력해 주세요.

- 접근 가능
  - `.env` : Found, `ROOT` value : Found, `ROOT` folder : Not found
    - Prompt : 설정된 ROOT 경로에 작업 폴더를 생성할 수 있습니다.
    - Options
      - Create ROOT folder
        - Action : `npm run start -- init root`
        - Result
          - Prompt : ROOT folder가 생성되었습니다. Server Directory 생성을 진행하시겠습니까?
          - Options
            - Go to Step 4 - Server Directory Setup
            - Back to home
            - Exit
      - Back to home
      - Exit

  - `.env` : Found, `ROOT` value : Found, `ROOT` folder : Found
    - Prompt : ROOT folder가 이미 존재합니다. 다시 생성하시겠습니까?
    - Options
      - Delete & Recreate ROOT folder
        - Prompt : 이 작업은 ROOT 내부의 서버/메타/출력 파일을 모두 삭제할 수 있습니다. 계속하시겠습니까?
        - Options
          - Yes (y)
            - Action : 기존 ROOT folder 삭제 후 `npm run start -- init root`
            - Result
              - Prompt : ROOT folder가 다시 생성되었습니다.
              - Options
                - Go to Step 4 - Server Directory Setup
                - Back to home
                - Exit
          - No (n) -> Back to previous
      - Back to home
      - Exit

### Step 4 - Server Directory Setup
- 접근 불가
  - `.env` : Not Found
    - Warning : `.env` 파일이 존재하지 않습니다. 먼저 Step 2 - Env File Setup을 진행해 주세요.

  - `.env` : Found, `ROOT` value : Not found
    - Warning : `ROOT` 값이 비어 있습니다. 메뉴를 통해 `.env` 파일을 재생성하거나 수동으로 값을 입력해 주세요.

  - `.env` : Found, `ROOT` value : Found, `ROOT` folder : Not found
    - Warning : ROOT folder가 존재하지 않습니다. 먼저 Step 3 - Root Directory Setup을 진행해 주세요.

  - `.env` : Found, `ROOT` value : Found, `ROOT` folder : Found, `${ROOT}/servers` folder : Not found
    - Warning : ROOT folder 내부 구조를 확인해 주세요. `servers` folder가 존재하지 않습니다.

  - `.env` : Found, `JAVA_EXECUTABLE` value : Not found
    - Warning : `JAVA_EXECUTABLE` 값이 비어 있습니다. 메뉴를 통해 `.env` 파일을 재생성하거나 수동으로 값을 입력해 주세요.

- 접근 가능
  - `.env` : Found, `ROOT` value : Found, `ROOT` folder : Found, `${ROOT}/servers` folder : Found, `JAVA_EXECUTABLE` value : Found
    - Prompt : Server Directory 생성을 진행합니다.
    - Info
      - 생성 기준 경로 : `${ROOT}/servers`
      - 기존 서버가 있는 경우, 새로운 서버를 추가 생성할 수 있습니다.

    - `${ROOT}/servers/*` (1 depth) : Not found
      - Prompt : 생성된 서버가 없습니다. 새 서버를 생성할 수 있습니다.
      - Options
        - Create new server directory
        - Back to home
        - Exit

    - `${ROOT}/servers/*` (1 depth) : x found
      - Prompt : 기존에 생성된 서버가 있습니다. 새 서버를 추가로 생성할 수 있습니다.
      - Options
        - Create new server directory
        - View server list
        - Back to home
        - Exit

- Create new server directory
  - Input
    - `id`
      - Prompt : Server Name을 입력해주세요. 서버 식별자 및 폴더명으로 사용됩니다.

    - `version`
      - Prompt : Minecraft Version을 입력해주세요. 예: `1.20.1`

    - Server Type
      - Prompt : 바닐라 서버인지 모드 서버인지 선택해주세요.
      - Options
        - Vanilla
        - Modded
        - Back to home
        - Exit

    - Server Type : Vanilla
      - Result Preview
        - Server Name : `<id>`
        - MC Version : `<version>`
        - Server Type : **Vanilla** / Modded
        - Mod Loader : none
        - Loader Version : none
        - Command : `npm start -- generate server <id> <version>`
      - Options
        - Run command
        - Back to previous
        - Re-enter values
        - Back to home
        - Exit

    - Server Type : Modded
      - Loader Selection
        - Prompt : 모드 로더를 선택해주세요.
        - Options
          - Forge
          - Fabric
          - Back to Select Type
          - Back to home
          - Exit

      - Loader Version
        - Prompt : 모드 로더 버전을 선택하거나 직접 입력해주세요.
        - Options
          - latest
          - recommended
          - Enter manually
          - Back to Select Type
          - Back to previous
          - Back to home
          - Exit

      - Loader Selection : Forge
        - Result Preview
          - Server Name : `<id>`
          - MC Version : `<version>`
          - Server Type : Vanilla / **Modded**
          - Mod Loader : Forge
          - Loader Version : `<options-string>`
          - Command : `npm start -- generate server <id> <version> --forge <options-string>`
        - Options
          - Run command
          - Back to Select Type
          - Re-enter values
          - Back to home
          - Exit

      - Loader Selection : Fabric
        - Result Preview
          - Server Name : `<id>`
          - MC Version : `<version>`
          - Server Type : Vanilla / **Modded**
          - Mod Loader : Fabric
          - Loader Version : `<options-string>`
          - Command : `npm start -- generate server <id> <version> --fabric <options-string>`
        - Options
          - Run command
          - Back to Select Type
          - Re-enter values
          - Back to home
          - Exit

- Result
  - Prompt : Server Directory 생성이 완료되었습니다.
  - Options
    - Create another server directory
    - Next step (Step 5)
    - Back to home
    - Exit

### Step 5 - Distro Export
- 접근 불가
  - `.env` : Not Found
    - Warning : `.env` 파일이 존재하지 않습니다. 먼저 `.env` 파일을 수동으로 작성하거나 Step 2 - Env File Setup을 진행해 주세요.

  - `.env` : Found, `ROOT` value : Not found
    - Warning : `ROOT` 값이 비어 있습니다. 메뉴를 통해 `.env` 파일을 재생성하거나 수동으로 값을 입력해 주세요.

  - `.env` : Found, `ROOT` value : Found, `ROOT` folder : Not found
    - Warning : ROOT folder가 존재하지 않습니다. 먼저 Step 3 - Root Directory Setup을 진행해 주세요.

  - `.env` : Found, `BASE_URL` value : Not found
    - Warning : `BASE_URL` 값이 비어 있습니다. 메뉴를 통해 `.env` 파일을 재생성하거나 수동으로 값을 입력해 주세요.

  - `.env` : Found, `JAVA_EXECUTABLE` value : Not found
    - Warning : `JAVA_EXECUTABLE` 값이 비어 있습니다. 메뉴를 통해 `.env` 파일을 재생성하거나 수동으로 값을 입력해 주세요.

  - `${ROOT}/servers/*` (1 depth) : Not found
    - Warning : 생성된 서버가 없습니다. 먼저 Step 4 - Server Directory Setup을 진행해 주세요.

- 접근 가능
  - `.env` : Found, `ROOT` value : Found, `ROOT` folder : Found, `BASE_URL` value : Found, `JAVA_EXECUTABLE` value : Found
  - `${ROOT}/servers/*` (1 depth) : x found
    - Prompt : distribution 파일을 생성할 수 있습니다.
    - Pre-check
      - `.env` file : Found
      - `ROOT` folder : Found
      - `BASE_URL` : Valid
      - `JAVA_EXECUTABLE` : Found
      - `servers` : x found
    - Options
      - Run distro export
        - Action : `npm start -- generate distro`
        - Result
          - Prompt : distribution 파일 생성이 완료되었습니다.
          - Info
            - Output : `${ROOT}/distribution.json`
          - Options
            - Back to home
            - Exit
      - Back to home
      - Exit

### List of servers created
- 접근 불가
  - `.env` : Not Found
    - Warning : `.env` 파일이 존재하지 않습니다.

  - `.env` : Found, `ROOT` value : Not found
    - Warning : `ROOT` 값이 비어 있습니다. 메뉴를 통해 `.env` 파일을 재생성하거나 수동으로 값을 입력해 주세요.

  - `.env` : Found, `ROOT` value : Found, `ROOT` folder : Not found
    - Warning : ROOT 폴더가 존재하지 않습니다.

  - `.env` : Found, `ROOT` value : Found, `ROOT` folder : Found, `${ROOT}/servers` folder : Not found
    - Warning : ROOT folder는 존재하지만 내부에 `servers` folder가 존재하지 않습니다. 구성을 확인해 주세요.

  - `${ROOT}/servers/*` (1 depth) : Not found
    - Warning : 생성된 서버가 존재하지 않습니다. 서버 생성 후 확인할 수 있습니다.

- 접근 가능
  - `.env` : Found, `ROOT` value : Found, `ROOT` folder : Found, `${ROOT}/servers` folder : Found
  - `${ROOT}/servers/*` (1 depth) : x found
    - Result
      - Prompt : 생성된 서버 목록입니다.
      - Output
        - Server directory names
        - Server count
      - Options
        - Back to home
        - Exit

### Nebula Reset
- 접근 조건 : 언제나

- Prompt : Nebula Helper에서 생성하거나 초기화한 파일 및 폴더를 정리할 수 있습니다.
- Options
  - Delete `.env` only
  - Delete ROOT folder only
  - Delete `.env` and ROOT folder
  - Delete all data except original data
  - Back to home
  - Exit

- Delete `.env` only
  - Confirmation
    - Prompt : `.env` 파일을 삭제하시겠습니까?
    - Options
      - Yes (y)
        - Result
          - Prompt : `.env` 파일이 삭제되었습니다.
          - Options
            - Back to home
            - Exit
      - No (n) -> Back to previous

- Delete ROOT folder only
  - Confirmation
    - Prompt : ROOT folder 및 내부 파일을 모두 삭제하시겠습니까?
    - Options
      - Yes (y)
        - Result
          - Prompt : ROOT folder가 삭제되었습니다.
          - Options
            - Back to home
            - Exit
      - No (n) -> Back to previous

- Delete `.env` and ROOT folder
  - Confirmation
    - Prompt : `.env` 파일과 ROOT folder 및 내부 파일을 모두 삭제하시겠습니까?
    - Options
      - Yes (y)
        - Result
          - Prompt : `.env` 파일과 ROOT folder가 삭제되었습니다.
          - Options
            - Back to home
            - Exit
      - No (n) -> Back to previous

- Delete all data except original data
  - Prompt : 현재 clone된 Git 레포의 원본 구조를 제외한 모든 추가 데이터를 삭제합니다.
  - Info
    - clone 직후 Git 레포에 포함되어 있던 파일 및 폴더 구조는 유지됩니다.
    - Nebula 작업으로 생성된 `.env`, `ROOT`, 서버 데이터, distribution 결과물 등은 삭제 대상입니다.
  - Action
    - .reset_exclusion_list의 목록 불러오기
    - .reset_exclusion_list의 목록에 포함되지 않은 파일 및 폴더 삭제
  - Confirmation
    - Prompt : Git 원본 구조에 포함되지 않은 모든 데이터가 삭제됩니다. 계속하시겠습니까?
    - Options
      - Yes (y)
        - Result
          - Prompt : Git 원본 구조 외의 데이터가 삭제되었습니다.
          - Options
            - Back to home
            - Exit
      - No (n) -> Back to previous

### Exit
- 접근 조건 : 언제나
- Prompt : Nebula Helper를 종료합니다.