#!/bin/bash

Colors for output

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
WHITE='\033[1;37m'
NC='\033[0m'

print_header() {
echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN} $1 ${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
}

print_status() { echo -e "${YELLOW}⏳ $1...${NC}"; }
print_success() { echo -e "${GREEN}✅ $1${NC}"; }
print_error() { echo -e "${RED}❌ $1${NC}"; }
print_warning() { echo -e "${MAGENTA}⚠️  $1${NC}"; }

animate_text() {
local text="$1"
for (( i=0; i<${#text}; i++ )); do
echo -n "${text:$i:1}"
sleep 0.05
done
echo
}

check_curl() {
if ! command -v curl &>/dev/null; then
print_error "curl is not installed"
print_status "Installing curl..."
if command -v apt-get &>/dev/null; then
sudo apt-get update && sudo apt-get install -y curl
elif command -v yum &>/dev/null; then
sudo yum install -y curl
elif command -v dnf &>/dev/null; then
sudo dnf install -y curl
else
print_error "Install curl manually"
exit 1
fi
print_success "curl installed"
fi
}

run_remote_script() {
local url=$1
local name=$(basename "$url" .sh | sed 's/.*/\u&/')
print_header "RUNNING SCRIPT: $name"
check_curl

tmp=$(mktemp)  
if curl -fsSL "$url" -o "$tmp"; then  
    chmod +x "$tmp"  
    bash "$tmp"  
    rm -f "$tmp"  
else  
    print_error "Failed to download script"  
fi  
read -p "$(echo -e "${YELLOW}Press Enter to continue...${NC}")"

}

system_info() {
print_header "SYSTEM INFORMATION"
echo -e "${WHITE}Hostname:${NC} $(hostname)"
echo -e "${WHITE}User:${NC} $(whoami)"
echo -e "${WHITE}OS:${NC} $(uname -srm)"
echo -e "${WHITE}Uptime:${NC} $(uptime -p)"
echo -e "${WHITE}Memory:${NC} $(free -h | awk '/Mem:/ {print $3"/"$2}')"
echo -e "${WHITE}Disk:${NC} $(df -h / | awk 'NR==2 {print $3"/"$2 " ("$5")"}')"
read -p "$(echo -e "${YELLOW}Press Enter to continue...${NC}")"
}

show_menu() {
clear
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}        🚀 FUTURENODE HOSTING MANAGER           ${NC}"
echo -e "${CYAN}              Control Panel                    ${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e ""
echo -e "${GREEN}1)${NC} Panel Installation"
echo -e "${GREEN}2)${NC} Wings Installation"
echo -e "${GREEN}3)${NC} Panel Update"
echo -e "${GREEN}4)${NC} Uninstall Tools"
echo -e "${GREEN}5)${NC} Blueprint Setup"
echo -e "${GREEN}6)${NC} Cloudflare Setup"
echo -e "${GREEN}7)${NC} Change Theme"
echo -e "${GREEN}8)${NC} SSH Configuration"
echo -e "${GREEN}9)${NC} System Information"
echo -e "${RED}0) Exit${NC}"
echo -e ""
echo -e "${YELLOW}Select an option [0-9]:${NC}"
}

welcome_animation() {
clear
echo -e "${CYAN}"
echo " ███████╗██╗   ██╗████████╗██╗   ██╗██████╗ "
echo " ██╔════╝██║   ██║╚══██╔══╝██║   ██║██╔══██╗"
echo " █████╗  ██║   ██║   ██║   ██║   ██║██████╔╝"
echo " ██╔══╝  ██║   ██║   ██║   ██║   ██║██╔══██╗"
echo " ██║     ╚██████╔╝   ██║   ╚██████╔╝██║  ██║"
echo " ╚═╝      ╚═════╝    ╚═╝    ╚═════╝ ╚═╝  ╚═╝"
echo -e "${NC}"
echo -e "${CYAN}           FutureNode Hosting Manager${NC}"
sleep 2
}

welcome_animation

while true; do
show_menu
read -r choice
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
echo -e "${GREEN}Exiting FutureNode Hosting Manager...${NC}"
echo -e "${CYAN}Thank you for using FutureNode!${NC}"
sleep 2
exit 0
;;
*)
print_error "Invalid option"
sleep 2
;;
esac
done
