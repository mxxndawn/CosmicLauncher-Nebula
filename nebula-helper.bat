@echo off
setlocal EnableExtensions EnableDelayedExpansion
chcp 65001 >nul

cd /d "%~dp0"
set "PAGE=Home"
set "WARNING="
set "ENV_FILE=.env"
set "RESET_LIST=.reset_exclusion_list"

goto main

:logo
echo  _   _      _           _
echo ^| \ ^| ^| ___^| ^|__  _   _^| ^| __ _
echo ^|  \^| ^|/ _ \ '_ \^| ^| ^| ^| ^|/ _` ^|
echo ^| ^|\  ^|  __/ ^|_) ^| ^|_^| ^| ^| (_^| ^|
echo ^|_^| \_^|\___^|_.__/ \__,_^|_^|\__,_^|
exit /b

:header
cls
call :logo
echo.
echo nebula helper
echo made by mxxndawn
echo Current Page : %PAGE%
echo ----------------------------------------
exit /b

:refresh
set "ENV_FOUND=0"
set "ROOT_VALUE="
set "BASE_URL_VALUE="
set "JAVA_VALUE="
set "HELIOS_VALUE="
set "ROOT_PATH="
set "ROOT_FOUND=0"
set "SERVERS_FOUND=0"
set "SERVER_COUNT=0"
set "DIST_FOUND=0"

if exist "%ENV_FILE%" (
  set "ENV_FOUND=1"
  for /f "usebackq tokens=1* delims==" %%A in ("%ENV_FILE%") do (
    if /i "%%A"=="ROOT" set "ROOT_VALUE=%%B"
    if /i "%%A"=="BASE_URL" set "BASE_URL_VALUE=%%B"
    if /i "%%A"=="JAVA_EXECUTABLE" set "JAVA_VALUE=%%B"
    if /i "%%A"=="HELIOS_DATA_FOLDER" set "HELIOS_VALUE=%%B"
  )
)

if defined ROOT_VALUE (
  set "ROOT_PATH=%ROOT_VALUE%"
  if not "!ROOT_PATH:~1,1!"==":" if not "!ROOT_PATH:~0,1!"=="\" set "ROOT_PATH=%CD%\!ROOT_PATH!"
  if exist "!ROOT_PATH!\" (
    set "ROOT_FOUND=1"
    if exist "!ROOT_PATH!\servers\" (
      set "SERVERS_FOUND=1"
      for /f %%C in ('dir /b /ad "!ROOT_PATH!\servers" 2^>nul ^| find /c /v ""') do set "SERVER_COUNT=%%C"
    )
    if exist "!ROOT_PATH!\distribution.json" set "DIST_FOUND=1"
  )
)
exit /b

:status
echo Status
if "%ENV_FOUND%"=="1" (
  echo   .env File           : Found
  set "MISSING="
  if not defined JAVA_VALUE set "MISSING=!MISSING!JAVA_EXECUTABLE, "
  if not defined ROOT_VALUE set "MISSING=!MISSING!ROOT, "
  if not defined BASE_URL_VALUE set "MISSING=!MISSING!BASE_URL, "
  if defined MISSING echo   .env Missing        : !MISSING:~0,-2!
) else (
  echo   .env File           : Not found
)
if "%ENV_FOUND%"=="1" if defined ROOT_VALUE (
  if "%ROOT_FOUND%"=="1" (
    echo   ROOT folder         : Found (!ROOT_PATH!)
  ) else (
    echo   ROOT folder         : Not found (!ROOT_PATH!)
  )
)
if "%ROOT_FOUND%"=="1" (
  if "%SERVERS_FOUND%"=="1" (
    if not "%SERVER_COUNT%"=="0" (
      echo   Servers Folder      : %SERVER_COUNT% found
    ) else (
      echo   Servers Folder      : Not found
    )
  ) else (
    echo   Servers Folder      : Not found
  )
)
if "%DIST_FOUND%"=="1" (
  echo   distribution.json   : Found
) else (
  echo   distribution.json   : Not found
)
echo ----------------------------------------
exit /b

:home
set "PAGE=Home"
call :refresh
call :header
call :status
echo 1. Step 1 - Nebula Setup
echo 2. Step 2 - Env File Setup
echo 3. Step 3 - Root Directory Setup
echo 4. Step 4 - Server Directory Setup
echo 5. Step 5 - Distro Export
echo 6. List of servers created
echo 7. Nebula Reset
echo 8. Exit
if defined WARNING (
  echo.
  echo Warning : %WARNING%
  set "WARNING="
)
echo.
set /p "MENU=Select menu: "
if "%MENU%"=="1" call :step1
if "%MENU%"=="2" call :step2
if "%MENU%"=="3" call :step3
if "%MENU%"=="4" call :step4
if "%MENU%"=="5" call :step5
if "%MENU%"=="6" call :list_servers
if "%MENU%"=="7" call :reset_menu
if "%MENU%"=="8" goto exit_helper
goto home

:write_env_template
> "%ENV_FILE%" echo JAVA_EXECUTABLE=
>>"%ENV_FILE%" echo ROOT=
>>"%ENV_FILE%" echo BASE_URL=
>>"%ENV_FILE%" echo HELIOS_DATA_FOLDER=
exit /b

:result_menu
set "RESULT_MESSAGE=%~1"
set "NEXT_LABEL=%~2"
set "NEXT_TARGET=%~3"
:result_loop
call :header
echo %RESULT_MESSAGE%
echo.
set "N=1"
if defined NEXT_LABEL (
  echo 1. Next step (%NEXT_LABEL%)
  set "HOME_NUM=2"
  set "EXIT_NUM=3"
) else (
  set "HOME_NUM=1"
  set "EXIT_NUM=2"
)
echo %HOME_NUM%. Back to home
echo %EXIT_NUM%. Exit
set /p "CHOICE=Select menu: "
if defined NEXT_LABEL if "%CHOICE%"=="1" call :%NEXT_TARGET% & exit /b
if "%CHOICE%"=="%HOME_NUM%" exit /b
if "%CHOICE%"=="%EXIT_NUM%" goto exit_helper
goto result_loop

:step1
set "PAGE=Step 1 - Nebula Setup"
call :header
echo npm 종속성 설치를 시작합니다.
echo.
call npm i
pause
call :result_menu "npm 종속성 설치가 완료되었습니다. 다음 단계를 진행할 수 있습니다." "Step 2 - Env File Setup" "step2"
exit /b

:step2
set "PAGE=Step 2 - Env File Setup"
call :refresh
:step2_loop
call :header
if "%ENV_FOUND%"=="1" (
  echo .env 파일이 이미 존재합니다. 재생성하시겠습니까?
  echo.
  echo 1. Delete ^& Create .env template
  echo 2. Delete ^& Start guided setup
  echo 3. Back to home
  echo 4. Exit
  set /p "CHOICE=Select menu: "
  if "!CHOICE!"=="1" del /f /q "%ENV_FILE%" 2>nul & call :write_env_template & call :result_menu ".env 템플릿 파일이 생성되었습니다. 필수 값을 직접 입력한 후 다음 단계를 진행하세요." & exit /b
  if "!CHOICE!"=="2" del /f /q "%ENV_FILE%" 2>nul & call :guided_env & exit /b
  if "!CHOICE!"=="3" exit /b
  if "!CHOICE!"=="4" goto exit_helper
) else (
  echo .env 파일이 존재하지 않습니다.
  echo.
  echo 1. Create .env template
  echo 2. Start guided setup
  echo 3. Back to home
  echo 4. Exit
  set /p "CHOICE=Select menu: "
  if "!CHOICE!"=="1" call :write_env_template & call :result_menu ".env 템플릿 파일이 생성되었습니다. 필수 값을 직접 입력한 후 다음 단계를 진행하세요." & exit /b
  if "!CHOICE!"=="2" call :guided_env & exit /b
  if "!CHOICE!"=="3" exit /b
  if "!CHOICE!"=="4" goto exit_helper
)
goto step2_loop

:guided_env
set "PAGE=Step 2 - Env File Setup"
call :header
echo JAVA_EXECUTABLE
echo 해당 항목은 이후에도 직접 입력할 수 있습니다.
echo 1. Enter path
echo 2. Leave blank
set /p "JAVA_CHOICE=Select menu: "
set "JAVA_INPUT="
if "%JAVA_CHOICE%"=="1" set /p "JAVA_INPUT=JAVA_EXECUTABLE path: "
:guided_root
echo.
set /p "ROOT_INPUT=ROOT 경로를 입력해주세요: "
if not defined ROOT_INPUT goto guided_root
:guided_base
echo.
set /p "BASE_INPUT=CDN URL을 입력해주세요: "
if /i "%BASE_INPUT:~0,7%"=="http://" goto guided_helios
if /i "%BASE_INPUT:~0,8%"=="https://" goto guided_helios
echo Warning : BASE_URL은 http:// 또는 https://로 시작해야 합니다.
goto guided_base
:guided_helios
echo.
echo HELIOS_DATA_FOLDER
echo 해당 항목은 비워둘 수 있습니다.
echo 1. Enter path
echo 2. Leave blank
set /p "HELIOS_CHOICE=Select menu: "
set "HELIOS_INPUT="
if "%HELIOS_CHOICE%"=="1" set /p "HELIOS_INPUT=HELIOS_DATA_FOLDER path: "
> "%ENV_FILE%" echo JAVA_EXECUTABLE=%JAVA_INPUT%
>>"%ENV_FILE%" echo ROOT=%ROOT_INPUT%
>>"%ENV_FILE%" echo BASE_URL=%BASE_INPUT%
>>"%ENV_FILE%" echo HELIOS_DATA_FOLDER=%HELIOS_INPUT%
call :result_menu ".env 파일 작성이 완료되었습니다." "Step 3 - Root Directory Setup" "step3"
exit /b

:ensure_step3
call :refresh
if not "%ENV_FOUND%"=="1" set "WARNING=.env 파일이 존재하지 않습니다. 먼저 Step 2 - Env File Setup을 진행해 주세요." & exit /b 1
if not defined ROOT_VALUE set "WARNING=ROOT 값이 비어 있습니다. 메뉴를 통해 .env 파일을 재생성하거나 수동으로 값을 입력해 주세요." & exit /b 1
exit /b 0

:step3
set "PAGE=Step 3 - Root Directory Setup"
call :ensure_step3 || exit /b
:step3_loop
call :header
if "%ROOT_FOUND%"=="0" (
  echo 설정된 ROOT 경로에 작업 폴더를 생성할 수 있습니다.
  echo ROOT : %ROOT_PATH%
  echo.
  echo 1. Create ROOT folder
  echo 2. Back to home
  echo 3. Exit
  set /p "CHOICE=Select menu: "
  if "!CHOICE!"=="1" call npm run start -- init root & pause & call :result_menu "ROOT folder가 생성되었습니다. Server Directory 생성을 진행하시겠습니까?" "Step 4 - Server Directory Setup" "step4" & exit /b
  if "!CHOICE!"=="2" exit /b
  if "!CHOICE!"=="3" goto exit_helper
) else (
  echo ROOT folder가 이미 존재합니다. 다시 생성하시겠습니까?
  echo ROOT : %ROOT_PATH%
  echo.
  echo 1. Delete ^& Recreate ROOT folder
  echo 2. Back to home
  echo 3. Exit
  set /p "CHOICE=Select menu: "
  if "!CHOICE!"=="1" (
    set /p "CONFIRM=이 작업은 ROOT 내부의 서버/메타/출력 파일을 모두 삭제할 수 있습니다. 계속하시겠습니까? (y/n): "
    if /i "!CONFIRM!"=="y" rmdir /s /q "%ROOT_PATH%" 2>nul & call npm run start -- init root & pause & call :result_menu "ROOT folder가 다시 생성되었습니다." "Step 4 - Server Directory Setup" "step4" & exit /b
  )
  if "!CHOICE!"=="2" exit /b
  if "!CHOICE!"=="3" goto exit_helper
)
goto step3_loop

:ensure_step4
call :refresh
if not "%ENV_FOUND%"=="1" set "WARNING=.env 파일이 존재하지 않습니다. 먼저 Step 2 - Env File Setup을 진행해 주세요." & exit /b 1
if not defined ROOT_VALUE set "WARNING=ROOT 값이 비어 있습니다. 메뉴를 통해 .env 파일을 재생성하거나 수동으로 값을 입력해 주세요." & exit /b 1
if not "%ROOT_FOUND%"=="1" set "WARNING=ROOT folder가 존재하지 않습니다. 먼저 Step 3 - Root Directory Setup을 진행해 주세요." & exit /b 1
if not "%SERVERS_FOUND%"=="1" set "WARNING=ROOT folder 내부 구조를 확인해 주세요. servers folder가 존재하지 않습니다." & exit /b 1
if not defined JAVA_VALUE set "WARNING=JAVA_EXECUTABLE 값이 비어 있습니다. 메뉴를 통해 .env 파일을 재생성하거나 수동으로 값을 입력해 주세요." & exit /b 1
exit /b 0

:step4
set "PAGE=Step 4 - Server Directory Setup"
call :ensure_step4 || exit /b
:step4_loop
call :refresh
call :header
echo Server Directory 생성을 진행합니다.
echo 생성 기준 경로 : %ROOT_PATH%\servers
echo.
if not "%SERVER_COUNT%"=="0" (
  echo 기존에 생성된 서버가 있습니다. 새 서버를 추가로 생성할 수 있습니다.
  echo.
  echo 1. Create new server directory
  echo 2. View server list
  echo 3. Back to home
  echo 4. Exit
  set /p "CHOICE=Select menu: "
  if "!CHOICE!"=="1" call :create_server & exit /b
  if "!CHOICE!"=="2" call :list_servers & exit /b
  if "!CHOICE!"=="3" exit /b
  if "!CHOICE!"=="4" goto exit_helper
) else (
  echo 생성된 서버가 없습니다. 새 서버를 생성할 수 있습니다.
  echo.
  echo 1. Create new server directory
  echo 2. Back to home
  echo 3. Exit
  set /p "CHOICE=Select menu: "
  if "!CHOICE!"=="1" call :create_server & exit /b
  if "!CHOICE!"=="2" exit /b
  if "!CHOICE!"=="3" goto exit_helper
)
goto step4_loop

:create_server
set "PAGE=Create new server directory"
call :header
set /p "SERVER_ID=Server Name을 입력해주세요: "
if not defined SERVER_ID goto create_server
set /p "MC_VERSION=Minecraft Version을 입력해주세요. 예: 1.20.1: "
if not defined MC_VERSION goto create_server
:select_type
call :header
echo 서버 타입을 선택해주세요.
echo.
echo 1. Vanilla
echo 2. Modded
echo 3. Back to home
echo 4. Exit
set /p "TYPE_CHOICE=Select menu: "
if "%TYPE_CHOICE%"=="1" set "SERVER_TYPE=Vanilla" & set "LOADER_FLAG=" & set "LOADER_VERSION=" & goto preview_server
if "%TYPE_CHOICE%"=="2" goto select_loader
if "%TYPE_CHOICE%"=="3" exit /b
if "%TYPE_CHOICE%"=="4" goto exit_helper
goto select_type

:select_loader
call :header
echo 모드 로더를 선택해주세요.
echo.
echo 1. Forge
echo 2. Fabric
echo 3. Back to Select Type
echo 4. Back to home
echo 5. Exit
set /p "LOADER_CHOICE=Select menu: "
if "%LOADER_CHOICE%"=="1" set "SERVER_TYPE=Forge" & set "LOADER_FLAG=--forge" & goto select_loader_version
if "%LOADER_CHOICE%"=="2" set "SERVER_TYPE=Fabric" & set "LOADER_FLAG=--fabric" & goto select_loader_version
if "%LOADER_CHOICE%"=="3" goto select_type
if "%LOADER_CHOICE%"=="4" exit /b
if "%LOADER_CHOICE%"=="5" goto exit_helper
goto select_loader

:select_loader_version
call :header
echo 모드 로더 버전을 선택하거나 직접 입력해주세요.
echo.
echo 1. latest
echo 2. recommended
echo 3. Enter manually
echo 4. Back to Select Type
echo 5. Back to home
echo 6. Exit
set /p "VER_CHOICE=Select menu: "
if "%VER_CHOICE%"=="1" set "LOADER_VERSION=latest" & goto preview_server
if "%VER_CHOICE%"=="2" set "LOADER_VERSION=recommended" & goto preview_server
if "%VER_CHOICE%"=="3" set /p "LOADER_VERSION=Loader Version: " & if defined LOADER_VERSION goto preview_server
if "%VER_CHOICE%"=="4" goto select_type
if "%VER_CHOICE%"=="5" exit /b
if "%VER_CHOICE%"=="6" goto exit_helper
goto select_loader_version

:preview_server
call :header
echo Result Preview
echo   Server Name    : %SERVER_ID%
echo   MC Version     : %MC_VERSION%
if "%SERVER_TYPE%"=="Vanilla" (
  echo   Server Type    : Vanilla
  echo   Mod Loader     : none
  echo   Loader Version : none
  echo   Command        : npm start -- generate server %SERVER_ID% %MC_VERSION%
) else (
  echo   Server Type    : Modded
  echo   Mod Loader     : %SERVER_TYPE%
  echo   Loader Version : %LOADER_VERSION%
  echo   Command        : npm start -- generate server %SERVER_ID% %MC_VERSION% %LOADER_FLAG% %LOADER_VERSION%
)
echo.
echo 1. Run command
echo 2. Back to previous
echo 3. Re-enter values
echo 4. Back to home
echo 5. Exit
set /p "CHOICE=Select menu: "
if "%CHOICE%"=="1" (
  if "%SERVER_TYPE%"=="Vanilla" (
    call npm start -- generate server "%SERVER_ID%" "%MC_VERSION%"
  ) else (
    call npm start -- generate server "%SERVER_ID%" "%MC_VERSION%" "%LOADER_FLAG%" "%LOADER_VERSION%"
  )
  pause
  call :after_server_created
  exit /b
)
if "%CHOICE%"=="2" exit /b
if "%CHOICE%"=="3" goto create_server
if "%CHOICE%"=="4" exit /b
if "%CHOICE%"=="5" goto exit_helper
goto preview_server

:after_server_created
call :header
echo Server Directory 생성이 완료되었습니다.
echo.
echo 1. Create another server directory
echo 2. Next step (Step 5)
echo 3. Back to home
echo 4. Exit
set /p "CHOICE=Select menu: "
if "%CHOICE%"=="1" call :create_server & exit /b
if "%CHOICE%"=="2" call :step5 & exit /b
if "%CHOICE%"=="3" exit /b
if "%CHOICE%"=="4" goto exit_helper
goto after_server_created

:ensure_step5
call :refresh
if not "%ENV_FOUND%"=="1" set "WARNING=.env 파일이 존재하지 않습니다. 먼저 .env 파일을 수동으로 작성하거나 Step 2 - Env File Setup을 진행해 주세요." & exit /b 1
if not defined ROOT_VALUE set "WARNING=ROOT 값이 비어 있습니다. 메뉴를 통해 .env 파일을 재생성하거나 수동으로 값을 입력해 주세요." & exit /b 1
if not "%ROOT_FOUND%"=="1" set "WARNING=ROOT folder가 존재하지 않습니다. 먼저 Step 3 - Root Directory Setup을 진행해 주세요." & exit /b 1
if not defined BASE_URL_VALUE set "WARNING=BASE_URL 값이 비어 있습니다. 메뉴를 통해 .env 파일을 재생성하거나 수동으로 값을 입력해 주세요." & exit /b 1
if /i not "%BASE_URL_VALUE:~0,7%"=="http://" if /i not "%BASE_URL_VALUE:~0,8%"=="https://" set "WARNING=BASE_URL 값이 올바르지 않습니다. http:// 또는 https://를 포함해 주세요." & exit /b 1
if not defined JAVA_VALUE set "WARNING=JAVA_EXECUTABLE 값이 비어 있습니다. 메뉴를 통해 .env 파일을 재생성하거나 수동으로 값을 입력해 주세요." & exit /b 1
if "%SERVER_COUNT%"=="0" set "WARNING=생성된 서버가 없습니다. 먼저 Step 4 - Server Directory Setup을 진행해 주세요." & exit /b 1
exit /b 0

:step5
set "PAGE=Step 5 - Distro Export"
call :ensure_step5 || exit /b
call :header
echo distribution 파일을 생성할 수 있습니다.
echo.
echo Pre-check
echo   .env file        : Found
echo   ROOT folder      : Found
echo   BASE_URL         : Valid
echo   JAVA_EXECUTABLE  : Found
echo   servers          : %SERVER_COUNT% found
echo.
echo 1. Run distro export
echo 2. Back to home
echo 3. Exit
set /p "CHOICE=Select menu: "
if "%CHOICE%"=="1" call npm start -- generate distro & pause & call :result_menu "distribution 파일 생성이 완료되었습니다. Output : %ROOT_PATH%\distribution.json" & exit /b
if "%CHOICE%"=="2" exit /b
if "%CHOICE%"=="3" goto exit_helper
goto step5

:ensure_list_servers
call :refresh
if not "%ENV_FOUND%"=="1" set "WARNING=.env 파일이 존재하지 않습니다." & exit /b 1
if not defined ROOT_VALUE set "WARNING=ROOT 값이 비어 있습니다. 메뉴를 통해 .env 파일을 재생성하거나 수동으로 값을 입력해 주세요." & exit /b 1
if not "%ROOT_FOUND%"=="1" set "WARNING=ROOT 폴더가 존재하지 않습니다." & exit /b 1
if not "%SERVERS_FOUND%"=="1" set "WARNING=ROOT folder는 존재하지만 내부에 servers folder가 존재하지 않습니다. 구성을 확인해 주세요." & exit /b 1
if "%SERVER_COUNT%"=="0" set "WARNING=생성된 서버가 존재하지 않습니다. 서버 생성 후 확인할 수 있습니다." & exit /b 1
exit /b 0

:list_servers
set "PAGE=List of servers created"
call :ensure_list_servers || exit /b
call :header
echo 생성된 서버 목록입니다.
echo.
dir /b /ad "%ROOT_PATH%\servers"
echo.
echo Server count : %SERVER_COUNT%
echo.
echo 1. Back to home
echo 2. Exit
set /p "CHOICE=Select menu: "
if "%CHOICE%"=="2" goto exit_helper
exit /b

:reset_menu
set "PAGE=Nebula Reset"
call :header
echo Nebula Helper에서 생성하거나 초기화한 파일 및 폴더를 정리할 수 있습니다.
echo.
echo 1. Delete .env only
echo 2. Delete ROOT folder only
echo 3. Delete .env and ROOT folder
echo 4. Delete all data except original data
echo 5. Back to home
echo 6. Exit
set /p "CHOICE=Select menu: "
if "%CHOICE%"=="1" call :delete_env_only & exit /b
if "%CHOICE%"=="2" call :delete_root_only & exit /b
if "%CHOICE%"=="3" call :delete_env_and_root & exit /b
if "%CHOICE%"=="4" call :reset_all & exit /b
if "%CHOICE%"=="5" exit /b
if "%CHOICE%"=="6" goto exit_helper
goto reset_menu

:delete_env_only
set /p "CONFIRM=.env 파일을 삭제하시겠습니까? (y/n): "
if /i "%CONFIRM%"=="y" del /f /q "%ENV_FILE%" 2>nul & call :result_menu ".env 파일이 삭제되었습니다."
exit /b

:delete_root_only
call :refresh
if not defined ROOT_PATH call :result_menu "ROOT 값이 비어 있어 삭제할 ROOT folder가 없습니다." & exit /b
set /p "CONFIRM=ROOT folder 및 내부 파일을 모두 삭제하시겠습니까? (%ROOT_PATH%) (y/n): "
if /i "%CONFIRM%"=="y" rmdir /s /q "%ROOT_PATH%" 2>nul & call :result_menu "ROOT folder가 삭제되었습니다."
exit /b

:delete_env_and_root
call :refresh
set /p "CONFIRM=.env 파일과 ROOT folder 및 내부 파일을 모두 삭제하시겠습니까? (y/n): "
if /i "%CONFIRM%"=="y" (
  if defined ROOT_PATH rmdir /s /q "%ROOT_PATH%" 2>nul
  del /f /q "%ENV_FILE%" 2>nul
  call :result_menu ".env 파일과 ROOT folder가 삭제되었습니다."
)
exit /b

:reset_all
call :header
if not exist "%RESET_LIST%" call :result_menu ".reset_exclusion_list 파일이 존재하지 않습니다." & exit /b
echo 현재 clone된 Git 레포의 원본 구조를 제외한 모든 추가 데이터를 삭제합니다.
echo .reset_exclusion_list에 포함되지 않은 최상위 파일 및 폴더가 삭제됩니다.
echo.
set /p "CONFIRM=계속하시겠습니까? (y/n): "
if /i not "%CONFIRM%"=="y" exit /b
for /f "delims=" %%I in ('dir /b /a') do (
  set "KEEP=0"
  for /f "usebackq delims=" %%K in ("%RESET_LIST%") do (
    if /i "%%I"=="%%K" set "KEEP=1"
  )
  if "!KEEP!"=="0" (
    if exist "%%I\" (
      rmdir /s /q "%%I"
    ) else (
      del /f /q "%%I" 2>nul
    )
  )
)
call :result_menu "Git 원본 구조 외의 데이터가 삭제되었습니다."
exit /b

:exit_helper
set "PAGE=Exit"
call :header
echo Nebula Helper를 종료합니다.
exit /b 0

:main
goto home
