#!/bin/bash

# ===============================
# FutureNode (FN) Hosting Manager
# ===============================

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'

print_header() {
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN} $1 ${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

print_error()   { echo -e "${RED}✖ $1${NC}"; }
print_success() { echo -e "${GREEN}✔ $1${NC}"; }

check_curl() {
    if ! command -v curl &>/dev/null; then
        print_error "curl not found. Installing..."
        apt update && apt install -y curl
    fi
}

run_remote_script() {
    check_curl
    tmp=$(mktemp)
    if curl -fsSL "$1" -o "$tmp"; then
        chmod +x "$tmp"
        bash "$tmp"
        rm -f "$tmp"
    else
        print_error "Failed to download script"
    fi
    read -p "Press Enter to continue..."
}

system_info() {
    print_header "SYSTEM INFORMATION"
    echo -e "Hostname : $(hostname)"
    echo -e "User     : $(whoami)"
    echo -e "OS       : $(uname -sr)"
    echo -e "Uptime  : $(uptime -p)"
    read -p "Press Enter to continue..."
}

welcome() {
    clear
    echo -e "${CYAN}"
    echo " ███████╗███╗   ██╗"
    echo " ██╔════╝████╗  ██║"
    echo " █████╗  ██╔██╗ ██║"
    echo " ██╔══╝  ██║╚██╗██║"
    echo " ██║     ██║ ╚████║"
    echo " ╚═╝     ╚═╝  ╚═══╝"
    echo
    echo "        FUTURENODE HOSTING"
    echo -e "${NC}"
    sleep 2
}

menu() {
    clear
    print_header "FUTURENODE HOSTING MANAGER"
    echo "1) Install Panel"
    echo "2) Install Wings"
    echo "3) Update Panel"
    echo "4) Uninstall"
    echo "5) Blueprint Setup"
    echo "6) Cloudflare Setup"
    echo "7) Change Theme"
    echo "8) SSH Tools"
    echo "9) System Info"
    echo "0) Exit"
    echo
    read -p "Select option: " choice
}

welcome

while true; do
    menu
    case $choice in
        1) run_remote_script "https://raw.githubusercontent.com/nobita586/Nobita-Hosting/main/cd/panel.sh" ;;
        2) run_remote_script "https://raw.githubusercontent.com/nobita586/Nobita-Hosting/main/cd/wing.sh" ;;
        3) run_remote_script "https://raw.githubusercontent.com/nobita586/Nobita-Hosting/main/cd/up.sh" ;;
        4) run_remote_script "https://raw.githubusercontent.com/nobita586/Nobita-Hosting/main/cd/uninstalll.sh" ;;
        5) run_remote_script "https://raw.githubusercontent.com/nobita586/Nobita-Hosting/main/cd/blueprint.sh" ;;
        6) run_remote_script "https://raw.githubusercontent.com/nobita586/Nobita-Hosting/main/cd/cloudflare.sh" ;;
        7) run_remote_script "https://raw.githubusercontent.com/nobita586/Nobita-Hosting/main/cd/th.sh" ;;
        8) run_remote_script "https://raw.githubusercontent.com/nobita586/Nobita-Hosting/main/cd/ssh.sh" ;;
        9) system_info ;;
        0)
            echo -e "${GREEN}Goodbye from FutureNode!${NC}"
            exit 0
            ;;
        *) print_error "Invalid option"; sleep 1 ;;
    esac
done
