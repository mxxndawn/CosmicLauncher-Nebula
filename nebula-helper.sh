#!/usr/bin/env sh

set -u

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
cd "$SCRIPT_DIR" || exit 1

PAGE="Home"
WARNING=""

ENV_FILE=".env"
RESET_LIST=".reset_exclusion_list"

ENV_FOUND=0
ROOT_VALUE=""
BASE_URL_VALUE=""
JAVA_VALUE=""
HELIOS_VALUE=""
ROOT_PATH=""
ROOT_FOUND=0
SERVERS_FOUND=0
SERVER_COUNT=0
DIST_FOUND=0

logo() {
  cat <<'EOF'
 _   _      _           _
| \ | | ___| |__  _   _| | __ _
|  \| |/ _ \ '_ \| | | | |/ _` |
| |\  |  __/ |_) | |_| | | (_| |
|_| \_|\___|_.__/ \__,_|_|\__,_|
EOF
}

pause() {
  printf "\nPress Enter to continue..."
  IFS= read -r _
}

clear_screen() {
  if command -v clear >/dev/null 2>&1; then
    clear
  else
    printf '\033c'
  fi
}

trim() {
  printf '%s' "$1" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//'
}

get_env_value() {
  key="$1"
  if [ ! -f "$ENV_FILE" ]; then
    return
  fi
  sed -n "s/^[[:space:]]*$key[[:space:]]*=[[:space:]]*//p" "$ENV_FILE" | tail -n 1 | sed 's/[[:space:]]*$//'
}

resolve_path() {
  value="$1"
  case "$value" in
    "" ) printf '' ;;
    "~" ) printf '%s' "$HOME" ;;
    "~/"* ) printf '%s/%s' "$HOME" "${value#~/}" ;;
    /* ) printf '%s' "$value" ;;
    * ) printf '%s/%s' "$SCRIPT_DIR" "$value" ;;
  esac
}

refresh_status() {
  ENV_FOUND=0
  ROOT_VALUE=""
  BASE_URL_VALUE=""
  JAVA_VALUE=""
  HELIOS_VALUE=""
  ROOT_PATH=""
  ROOT_FOUND=0
  SERVERS_FOUND=0
  SERVER_COUNT=0
  DIST_FOUND=0

  if [ -f "$ENV_FILE" ]; then
    ENV_FOUND=1
    ROOT_VALUE=$(trim "$(get_env_value ROOT)")
    BASE_URL_VALUE=$(trim "$(get_env_value BASE_URL)")
    JAVA_VALUE=$(trim "$(get_env_value JAVA_EXECUTABLE)")
    HELIOS_VALUE=$(trim "$(get_env_value HELIOS_DATA_FOLDER)")
  fi

  if [ -n "$ROOT_VALUE" ]; then
    ROOT_PATH=$(resolve_path "$ROOT_VALUE")
    if [ -d "$ROOT_PATH" ]; then
      ROOT_FOUND=1
      if [ -d "$ROOT_PATH/servers" ]; then
        SERVERS_FOUND=1
        SERVER_COUNT=$(find "$ROOT_PATH/servers" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | wc -l | tr -d ' ')
      fi
      if [ -f "$ROOT_PATH/distribution.json" ]; then
        DIST_FOUND=1
      fi
    fi
  fi
}

print_header() {
  clear_screen
  logo
  printf "\nnebula helper\nmade by mxxndawn\nCurrent Page : %s\n" "$PAGE"
  printf '%s\n' "----------------------------------------"
}

print_status() {
  printf "Status\n"
  if [ "$ENV_FOUND" -eq 1 ]; then
    printf "  .env File           : Found\n"
    missing=""
    [ -z "$JAVA_VALUE" ] && missing="${missing}JAVA_EXECUTABLE, "
    [ -z "$ROOT_VALUE" ] && missing="${missing}ROOT, "
    [ -z "$BASE_URL_VALUE" ] && missing="${missing}BASE_URL, "
    if [ -n "$missing" ]; then
      missing=$(printf '%s' "$missing" | sed 's/, $//')
      printf "  .env Missing        : %s\n" "$missing"
    fi
  else
    printf "  .env File           : Not found\n"
  fi

  if [ "$ENV_FOUND" -eq 1 ] && [ -n "$ROOT_VALUE" ]; then
    if [ "$ROOT_FOUND" -eq 1 ]; then
      printf "  ROOT folder         : Found (%s)\n" "$ROOT_PATH"
    else
      printf "  ROOT folder         : Not found (%s)\n" "$ROOT_PATH"
    fi
  fi

  if [ "$ROOT_FOUND" -eq 1 ]; then
    if [ "$SERVERS_FOUND" -eq 1 ]; then
      if [ "$SERVER_COUNT" -gt 0 ]; then
        printf "  Servers Folder      : %s found\n" "$SERVER_COUNT"
      else
        printf "  Servers Folder      : Not found\n"
      fi
    else
      printf "  Servers Folder      : Not found\n"
    fi
  fi

  if [ "$DIST_FOUND" -eq 1 ]; then
    printf "  distribution.json   : Found\n"
  else
    printf "  distribution.json   : Not found\n"
  fi
  printf '%s\n' "----------------------------------------"
}

show_home() {
  PAGE="Home"
  refresh_status
  print_header
  print_status
  cat <<'EOF'
1. Step 1 - Nebula Setup
2. Step 2 - Env File Setup
3. Step 3 - Root Directory Setup
4. Step 4 - Server Directory Setup
5. Step 5 - Distro Export
6. List of servers created
7. Nebula Reset
8. Exit
EOF
  if [ -n "$WARNING" ]; then
    printf "\nWarning : %s\n" "$WARNING"
    WARNING=""
  fi
  printf "\nSelect menu: "
}

ask_choice() {
  prompt="$1"
  printf "%s" "$prompt" >&2
  IFS= read -r choice
  printf '%s' "$choice"
}

write_env_template() {
  cat > "$ENV_FILE" <<'EOF'
JAVA_EXECUTABLE=
ROOT=
BASE_URL=
HELIOS_DATA_FOLDER=
EOF
}

guided_env_setup() {
  PAGE="Step 2 - Env File Setup"
  print_header
  printf "JAVA_EXECUTABLE\n해당 항목은 이후에도 직접 입력할 수 있습니다.\n"
  printf "1. Enter path\n2. Leave blank\nSelect menu: "
  IFS= read -r java_choice
  java=""
  if [ "$java_choice" = "1" ]; then
    printf "JAVA_EXECUTABLE path: "
    IFS= read -r java
  fi

  root=""
  while [ -z "$root" ]; do
    printf "\nROOT\nNebula 작업을 위한 ROOT 경로를 입력해주세요: "
    IFS= read -r root
    root=$(trim "$root")
  done

  base=""
  while :; do
    printf "\nBASE_URL\nROOT 폴더가 업로드될 CDN URL을 입력해주세요: "
    IFS= read -r base
    base=$(trim "$base")
    case "$base" in
      http://*|https://*) break ;;
      *) printf "Warning : BASE_URL은 http:// 또는 https://로 시작해야 합니다.\n" ;;
    esac
  done

  printf "\nHELIOS_DATA_FOLDER\n해당 항목은 비워둘 수 있습니다.\n"
  printf "1. Enter path\n2. Leave blank\nSelect menu: "
  IFS= read -r helios_choice
  helios=""
  if [ "$helios_choice" = "1" ]; then
    printf "HELIOS_DATA_FOLDER path: "
    IFS= read -r helios
  fi

  {
    printf 'JAVA_EXECUTABLE=%s\n' "$java"
    printf 'ROOT=%s\n' "$root"
    printf 'BASE_URL=%s\n' "$base"
    printf 'HELIOS_DATA_FOLDER=%s\n' "$helios"
  } > "$ENV_FILE"

  result_menu ".env 파일 작성이 완료되었습니다." "Step 3 - Root Directory Setup" step3
}

result_menu() {
  message="$1"
  next_label="${2:-}"
  next_func="${3:-}"
  while :; do
    print_header
    printf "%s\n\n" "$message"
    n=1
    if [ -n "$next_label" ]; then
      printf "%s. Next step (%s)\n" "$n" "$next_label"
      n=$((n + 1))
    fi
    printf "%s. Back to home\n" "$n"
    home_num=$n
    n=$((n + 1))
    printf "%s. Exit\n" "$n"
    exit_num=$n
    choice=$(ask_choice "Select menu: ")
    if [ -n "$next_label" ] && [ "$choice" = "1" ]; then
      "$next_func"
      return
    elif [ "$choice" = "$home_num" ]; then
      return
    elif [ "$choice" = "$exit_num" ]; then
      exit_helper
    fi
  done
}

step1() {
  PAGE="Step 1 - Nebula Setup"
  print_header
  printf "npm 종속성 설치를 시작합니다.\n\n"
  npm i
  pause
  result_menu "npm 종속성 설치가 완료되었습니다. 다음 단계를 진행할 수 있습니다." "Step 2 - Env File Setup" step2
}

step2() {
  PAGE="Step 2 - Env File Setup"
  refresh_status
  while :; do
    print_header
    if [ "$ENV_FOUND" -eq 1 ]; then
      cat <<'EOF'
.env 파일이 이미 존재합니다. 재생성하시겠습니까?

1. Delete & Create .env template
2. Delete & Start guided setup
3. Back to home
4. Exit
EOF
      choice=$(ask_choice "Select menu: ")
      case "$choice" in
        1) rm -f "$ENV_FILE"; write_env_template; result_menu ".env 템플릿 파일이 생성되었습니다. 필수 값을 직접 입력한 후 다음 단계를 진행하세요."; return ;;
        2) rm -f "$ENV_FILE"; guided_env_setup; return ;;
        3) return ;;
        4) exit_helper ;;
      esac
    else
      cat <<'EOF'
.env 파일이 존재하지 않습니다.

1. Create .env template
2. Start guided setup
3. Back to home
4. Exit
EOF
      choice=$(ask_choice "Select menu: ")
      case "$choice" in
        1) write_env_template; result_menu ".env 템플릿 파일이 생성되었습니다. 필수 값을 직접 입력한 후 다음 단계를 진행하세요."; return ;;
        2) guided_env_setup; return ;;
        3) return ;;
        4) exit_helper ;;
      esac
    fi
  done
}

ensure_step3() {
  refresh_status
  if [ "$ENV_FOUND" -ne 1 ]; then
    WARNING=".env 파일이 존재하지 않습니다. 먼저 Step 2 - Env File Setup을 진행해 주세요."
    return 1
  fi
  if [ -z "$ROOT_VALUE" ]; then
    WARNING="ROOT 값이 비어 있습니다. 메뉴를 통해 .env 파일을 재생성하거나 수동으로 값을 입력해 주세요."
    return 1
  fi
  return 0
}

step3() {
  PAGE="Step 3 - Root Directory Setup"
  if ! ensure_step3; then return; fi
  while :; do
    print_header
    if [ "$ROOT_FOUND" -eq 0 ]; then
      printf "설정된 ROOT 경로에 작업 폴더를 생성할 수 있습니다.\nROOT : %s\n\n" "$ROOT_PATH"
      printf "1. Create ROOT folder\n2. Back to home\n3. Exit\n"
      choice=$(ask_choice "Select menu: ")
      case "$choice" in
        1) npm run start -- init root; pause; result_menu "ROOT folder가 생성되었습니다. Server Directory 생성을 진행하시겠습니까?" "Step 4 - Server Directory Setup" step4; return ;;
        2) return ;;
        3) exit_helper ;;
      esac
    else
      printf "ROOT folder가 이미 존재합니다. 다시 생성하시겠습니까?\nROOT : %s\n\n" "$ROOT_PATH"
      printf "1. Delete & Recreate ROOT folder\n2. Back to home\n3. Exit\n"
      choice=$(ask_choice "Select menu: ")
      case "$choice" in
        1)
          printf "\n이 작업은 ROOT 내부의 서버/메타/출력 파일을 모두 삭제할 수 있습니다. 계속하시겠습니까? (y/n): "
          IFS= read -r confirm
          if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
            rm -rf -- "$ROOT_PATH"
            npm run start -- init root
            pause
            result_menu "ROOT folder가 다시 생성되었습니다." "Step 4 - Server Directory Setup" step4
            return
          fi
          ;;
        2) return ;;
        3) exit_helper ;;
      esac
    fi
  done
}

ensure_step4() {
  refresh_status
  if [ "$ENV_FOUND" -ne 1 ]; then WARNING=".env 파일이 존재하지 않습니다. 먼저 Step 2 - Env File Setup을 진행해 주세요."; return 1; fi
  if [ -z "$ROOT_VALUE" ]; then WARNING="ROOT 값이 비어 있습니다. 메뉴를 통해 .env 파일을 재생성하거나 수동으로 값을 입력해 주세요."; return 1; fi
  if [ "$ROOT_FOUND" -ne 1 ]; then WARNING="ROOT folder가 존재하지 않습니다. 먼저 Step 3 - Root Directory Setup을 진행해 주세요."; return 1; fi
  if [ "$SERVERS_FOUND" -ne 1 ]; then WARNING="ROOT folder 내부 구조를 확인해 주세요. servers folder가 존재하지 않습니다."; return 1; fi
  if [ -z "$JAVA_VALUE" ]; then WARNING="JAVA_EXECUTABLE 값이 비어 있습니다. 메뉴를 통해 .env 파일을 재생성하거나 수동으로 값을 입력해 주세요."; return 1; fi
  return 0
}

create_server() {
  while :; do
    PAGE="Create new server directory"
    print_header
    printf "Server Name을 입력해주세요: "
    IFS= read -r server_id
    server_id=$(trim "$server_id")
    [ -z "$server_id" ] && continue
    printf "Minecraft Version을 입력해주세요. 예: 1.20.1: "
    IFS= read -r mc_version
    mc_version=$(trim "$mc_version")
    [ -z "$mc_version" ] && continue

    while :; do
      print_header
      printf "서버 타입을 선택해주세요.\n\n1. Vanilla\n2. Modded\n3. Back to home\n4. Exit\n"
      type_choice=$(ask_choice "Select menu: ")
      case "$type_choice" in
        1)
          preview_and_run "$server_id" "$mc_version" "Vanilla" "" ""
          return
          ;;
        2)
          select_loader "$server_id" "$mc_version"
          return
          ;;
        3) return ;;
        4) exit_helper ;;
      esac
    done
  done
}

select_loader() {
  server_id="$1"
  mc_version="$2"
  while :; do
    print_header
    printf "모드 로더를 선택해주세요.\n\n1. Forge\n2. Fabric\n3. Back to Select Type\n4. Back to home\n5. Exit\n"
    loader_choice=$(ask_choice "Select menu: ")
    case "$loader_choice" in
      1) loader="Forge"; flag="--forge" ;;
      2) loader="Fabric"; flag="--fabric" ;;
      3) return ;;
      4) return ;;
      5) exit_helper ;;
      *) continue ;;
    esac

    while :; do
      print_header
      printf "모드 로더 버전을 선택하거나 직접 입력해주세요.\n\n1. latest\n2. recommended\n3. Enter manually\n4. Back to Select Type\n5. Back to home\n6. Exit\n"
      ver_choice=$(ask_choice "Select menu: ")
      case "$ver_choice" in
        1) loader_version="latest"; break ;;
        2) loader_version="recommended"; break ;;
        3) printf "Loader Version: "; IFS= read -r loader_version; loader_version=$(trim "$loader_version"); [ -n "$loader_version" ] && break ;;
        4) break ;;
        5) return ;;
        6) exit_helper ;;
      esac
    done
    [ "$ver_choice" = "4" ] && continue
    preview_and_run "$server_id" "$mc_version" "$loader" "$flag" "$loader_version"
    return
  done
}

preview_and_run() {
  server_id="$1"
  mc_version="$2"
  server_type="$3"
  loader_flag="$4"
  loader_version="$5"
  while :; do
    print_header
    printf "Result Preview\n"
    printf "  Server Name    : %s\n" "$server_id"
    printf "  MC Version     : %s\n" "$mc_version"
    if [ "$server_type" = "Vanilla" ]; then
      printf "  Server Type    : Vanilla\n  Mod Loader     : none\n  Loader Version : none\n"
      printf "  Command        : npm start -- generate server %s %s\n\n" "$server_id" "$mc_version"
      printf "1. Run command\n2. Back to previous\n3. Re-enter values\n4. Back to home\n5. Exit\n"
    else
      printf "  Server Type    : Modded\n  Mod Loader     : %s\n  Loader Version : %s\n" "$server_type" "$loader_version"
      printf "  Command        : npm start -- generate server %s %s %s %s\n\n" "$server_id" "$mc_version" "$loader_flag" "$loader_version"
      printf "1. Run command\n2. Back to Select Type\n3. Re-enter values\n4. Back to home\n5. Exit\n"
    fi
    choice=$(ask_choice "Select menu: ")
    case "$choice" in
      1)
        if [ "$server_type" = "Vanilla" ]; then
          npm start -- generate server "$server_id" "$mc_version"
        else
          npm start -- generate server "$server_id" "$mc_version" "$loader_flag" "$loader_version"
        fi
        pause
        after_server_created
        return
        ;;
      2) return ;;
      3) create_server; return ;;
      4) return ;;
      5) exit_helper ;;
    esac
  done
}

after_server_created() {
  while :; do
    print_header
    printf "Server Directory 생성이 완료되었습니다.\n\n"
    printf "1. Create another server directory\n2. Next step (Step 5)\n3. Back to home\n4. Exit\n"
    choice=$(ask_choice "Select menu: ")
    case "$choice" in
      1) create_server; return ;;
      2) step5; return ;;
      3) return ;;
      4) exit_helper ;;
    esac
  done
}

step4() {
  PAGE="Step 4 - Server Directory Setup"
  if ! ensure_step4; then return; fi
  while :; do
    refresh_status
    print_header
    printf "Server Directory 생성을 진행합니다.\n생성 기준 경로 : %s/servers\n\n" "$ROOT_PATH"
    if [ "$SERVER_COUNT" -gt 0 ]; then
      printf "기존에 생성된 서버가 있습니다. 새 서버를 추가로 생성할 수 있습니다.\n\n"
      printf "1. Create new server directory\n2. View server list\n3. Back to home\n4. Exit\n"
      choice=$(ask_choice "Select menu: ")
      case "$choice" in
        1) create_server; return ;;
        2) list_servers_screen; return ;;
        3) return ;;
        4) exit_helper ;;
      esac
    else
      printf "생성된 서버가 없습니다. 새 서버를 생성할 수 있습니다.\n\n"
      printf "1. Create new server directory\n2. Back to home\n3. Exit\n"
      choice=$(ask_choice "Select menu: ")
      case "$choice" in
        1) create_server; return ;;
        2) return ;;
        3) exit_helper ;;
      esac
    fi
  done
}

ensure_step5() {
  refresh_status
  if [ "$ENV_FOUND" -ne 1 ]; then WARNING=".env 파일이 존재하지 않습니다. 먼저 .env 파일을 수동으로 작성하거나 Step 2 - Env File Setup을 진행해 주세요."; return 1; fi
  if [ -z "$ROOT_VALUE" ]; then WARNING="ROOT 값이 비어 있습니다. 메뉴를 통해 .env 파일을 재생성하거나 수동으로 값을 입력해 주세요."; return 1; fi
  if [ "$ROOT_FOUND" -ne 1 ]; then WARNING="ROOT folder가 존재하지 않습니다. 먼저 Step 3 - Root Directory Setup을 진행해 주세요."; return 1; fi
  case "$BASE_URL_VALUE" in http://*|https://*) ;; *) WARNING="BASE_URL 값이 비어 있거나 올바르지 않습니다. 메뉴를 통해 .env 파일을 재생성하거나 수동으로 값을 입력해 주세요."; return 1 ;; esac
  if [ -z "$JAVA_VALUE" ]; then WARNING="JAVA_EXECUTABLE 값이 비어 있습니다. 메뉴를 통해 .env 파일을 재생성하거나 수동으로 값을 입력해 주세요."; return 1; fi
  if [ "$SERVER_COUNT" -eq 0 ]; then WARNING="생성된 서버가 없습니다. 먼저 Step 4 - Server Directory Setup을 진행해 주세요."; return 1; fi
  return 0
}

step5() {
  PAGE="Step 5 - Distro Export"
  if ! ensure_step5; then return; fi
  while :; do
    print_header
    printf "distribution 파일을 생성할 수 있습니다.\n\n"
    printf "Pre-check\n"
    printf "  .env file        : Found\n"
    printf "  ROOT folder      : Found\n"
    printf "  BASE_URL         : Valid\n"
    printf "  JAVA_EXECUTABLE  : Found\n"
    printf "  servers          : %s found\n\n" "$SERVER_COUNT"
    printf "1. Run distro export\n2. Back to home\n3. Exit\n"
    choice=$(ask_choice "Select menu: ")
    case "$choice" in
      1) npm start -- generate distro; pause; result_menu "distribution 파일 생성이 완료되었습니다.\nOutput : $ROOT_PATH/distribution.json"; return ;;
      2) return ;;
      3) exit_helper ;;
    esac
  done
}

ensure_list_servers() {
  refresh_status
  if [ "$ENV_FOUND" -ne 1 ]; then WARNING=".env 파일이 존재하지 않습니다."; return 1; fi
  if [ -z "$ROOT_VALUE" ]; then WARNING="ROOT 값이 비어 있습니다. 메뉴를 통해 .env 파일을 재생성하거나 수동으로 값을 입력해 주세요."; return 1; fi
  if [ "$ROOT_FOUND" -ne 1 ]; then WARNING="ROOT 폴더가 존재하지 않습니다."; return 1; fi
  if [ "$SERVERS_FOUND" -ne 1 ]; then WARNING="ROOT folder는 존재하지만 내부에 servers folder가 존재하지 않습니다. 구성을 확인해 주세요."; return 1; fi
  if [ "$SERVER_COUNT" -eq 0 ]; then WARNING="생성된 서버가 존재하지 않습니다. 서버 생성 후 확인할 수 있습니다."; return 1; fi
  return 0
}

list_servers_screen() {
  PAGE="List of servers created"
  if ! ensure_list_servers; then return; fi
  print_header
  printf "생성된 서버 목록입니다.\n\n"
  find "$ROOT_PATH/servers" -mindepth 1 -maxdepth 1 -type d -exec basename {} \; | sort
  printf "\nServer count : %s\n" "$SERVER_COUNT"
  printf "\n1. Back to home\n2. Exit\n"
  choice=$(ask_choice "Select menu: ")
  [ "$choice" = "2" ] && exit_helper
}

delete_env_only() {
  printf ".env 파일을 삭제하시겠습니까? (y/n): "
  IFS= read -r confirm
  if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
    rm -f "$ENV_FILE"
    result_menu ".env 파일이 삭제되었습니다."
  fi
}

delete_root_only() {
  refresh_status
  if [ -z "$ROOT_PATH" ]; then
    result_menu "ROOT 값이 비어 있어 삭제할 ROOT folder가 없습니다."
    return
  fi
  printf "ROOT folder 및 내부 파일을 모두 삭제하시겠습니까? (%s) (y/n): " "$ROOT_PATH"
  IFS= read -r confirm
  if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
    rm -rf -- "$ROOT_PATH"
    result_menu "ROOT folder가 삭제되었습니다."
  fi
}

delete_env_and_root() {
  refresh_status
  printf ".env 파일과 ROOT folder 및 내부 파일을 모두 삭제하시겠습니까? (y/n): "
  IFS= read -r confirm
  if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
    [ -n "$ROOT_PATH" ] && rm -rf -- "$ROOT_PATH"
    rm -f "$ENV_FILE"
    result_menu ".env 파일과 ROOT folder가 삭제되었습니다."
  fi
}

reset_all_except_original() {
  print_header
  if [ ! -f "$RESET_LIST" ]; then
    result_menu ".reset_exclusion_list 파일이 존재하지 않습니다."
    return
  fi
  cat <<'EOF'
현재 clone된 Git 레포의 원본 구조를 제외한 모든 추가 데이터를 삭제합니다.
.reset_exclusion_list에 포함되지 않은 최상위 파일 및 폴더가 삭제됩니다.
EOF
  printf "\n계속하시겠습니까? (y/n): "
  IFS= read -r confirm
  if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
    return
  fi

  for item in .[!.]* .??* *; do
    [ -e "$item" ] || continue
    keep=0
    while IFS= read -r pattern || [ -n "$pattern" ]; do
      pattern=$(trim "$pattern")
      case "$pattern" in ""|\#*) continue ;; esac
      if [ "$item" = "$pattern" ]; then
        keep=1
        break
      fi
    done < "$RESET_LIST"
    if [ "$keep" -eq 0 ]; then
      rm -rf -- "$item"
    fi
  done
  result_menu "Git 원본 구조 외의 데이터가 삭제되었습니다."
}

reset_menu() {
  PAGE="Nebula Reset"
  while :; do
    print_header
    cat <<'EOF'
Nebula Helper에서 생성하거나 초기화한 파일 및 폴더를 정리할 수 있습니다.

1. Delete .env only
2. Delete ROOT folder only
3. Delete .env and ROOT folder
4. Delete all data except original data
5. Back to home
6. Exit
EOF
    choice=$(ask_choice "Select menu: ")
    case "$choice" in
      1) delete_env_only; return ;;
      2) delete_root_only; return ;;
      3) delete_env_and_root; return ;;
      4) reset_all_except_original; return ;;
      5) return ;;
      6) exit_helper ;;
    esac
  done
}

exit_helper() {
  PAGE="Exit"
  print_header
  printf "Nebula Helper를 종료합니다.\n"
  exit 0
}

while :; do
  show_home
  IFS= read -r menu
  case "$menu" in
    1) step1 ;;
    2) step2 ;;
    3) step3 ;;
    4) step4 ;;
    5) step5 ;;
    6) list_servers_screen ;;
    7) reset_menu ;;
    8) exit_helper ;;
    *) WARNING="올바른 메뉴 번호를 선택해 주세요." ;;
  esac
done
