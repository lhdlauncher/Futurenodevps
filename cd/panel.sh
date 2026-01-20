#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Function to print section headers
print_header() {
    echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN} $1 ${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
}

print_status() { echo -e "${YELLOW}⏳ $1...${NC}"; }
print_success() { echo -e "${GREEN}✅ $1${NC}"; }
print_error() { echo -e "${RED}❌ $1${NC}"; }

animate_progress() {
    local pid=$1
    local message=$2
    local spin='|/-\'
    print_status "$message"
    while ps -p $pid > /dev/null; do
        for i in $(seq 0 3); do
            printf "\r [%c] " "${spin:$i:1}"
            sleep 0.1
        done
    done
    printf "\r      \r"
}

clear
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}           PTERODACTYL PANEL INSTALLER           ${NC}"
echo -e "${CYAN}                 by FutureNode                 ${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"

read -p "$(echo -e "${YELLOW}🌐 Enter your domain (e.g., panel.example.com): ${NC}")" DOMAIN
[ -z "$DOMAIN" ] && print_error "Domain cannot be empty!" && exit 1

print_header "STARTING INSTALLATION PROCESS"

print_header "INSTALLING DEPENDENCIES"
apt update > /dev/null 2>&1 & animate_progress $! "Updating packages"
apt install -y curl apt-transport-https ca-certificates gnupg unzip git tar sudo lsb-release > /dev/null 2>&1 & animate_progress $! "Installing dependencies"

OS=$(lsb_release -is | tr '[:upper:]' '[:lower:]')

if [[ "$OS" == "ubuntu" ]]; then
    apt install -y software-properties-common > /dev/null 2>&1
    add-apt-repository -y ppa:ondrej/php > /dev/null 2>&1
elif [[ "$OS" == "debian" ]]; then
    curl -fsSL https://packages.sury.org/php/apt.gpg | gpg --dearmor -o /usr/share/keyrings/sury-php.gpg
    echo "deb [signed-by=/usr/share/keyrings/sury-php.gpg] https://packages.sury.org/php/ $(lsb_release -cs) main" > /etc/apt/sources.list.d/sury-php.list
fi

curl -fsSL https://packages.redis.io/gpg | gpg --dearmor -o /usr/share/keyrings/redis.gpg
echo "deb [signed-by=/usr/share/keyrings/redis.gpg] https://packages.redis.io/deb $(lsb_release -cs) main" > /etc/apt/sources.list.d/redis.list

apt update > /dev/null 2>&1

print_header "INSTALLING PHP AND SERVICES"
apt install -y php8.3 php8.3-{cli,fpm,common,mysql,mbstring,bcmath,xml,zip,curl,gd,tokenizer,ctype,dom} mariadb-server nginx redis-server > /dev/null 2>&1

curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

print_header "INSTALLING PTERODACTYL"
mkdir -p /var/www/pterodactyl
cd /var/www/pterodactyl
curl -Lo panel.tar.gz https://github.com/pterodactyl/panel/releases/latest/download/panel.tar.gz
tar -xzf panel.tar.gz
chmod -R 755 storage bootstrap/cache

print_header "DATABASE SETUP"
DB_NAME=panel
DB_USER=pterodactyl
DB_PASS=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 16)

mariadb -e "CREATE DATABASE $DB_NAME;"
mariadb -e "CREATE USER '$DB_USER'@'127.0.0.1' IDENTIFIED BY '$DB_PASS';"
mariadb -e "GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'127.0.0.1'; FLUSH PRIVILEGES;"

cp .env.example .env
sed -i "s|APP_URL=.*|APP_URL=https://$DOMAIN|" .env
sed -i "s|DB_DATABASE=.*|DB_DATABASE=$DB_NAME|" .env
sed -i "s|DB_USERNAME=.*|DB_USERNAME=$DB_USER|" .env
sed -i "s|DB_PASSWORD=.*|DB_PASSWORD=$DB_PASS|" .env

COMPOSER_ALLOW_SUPERUSER=1 composer install --no-dev --optimize-autoloader
php artisan key:generate --force
php artisan migrate --seed --force

chown -R www-data:www-data /var/www/pterodactyl

print_header "FINAL ENVIRONMENT SETUP"
sed -i '/^APP_THEME=/d;/^MAIL_/d' .env
echo "APP_THEME=FutureNode" >> .env
echo 'MAIL_FROM_NAME="FutureNode"' >> .env

print_header "INSTALLATION COMPLETE"
echo -e "${GREEN}Panel installed successfully!${NC}"
echo -e "URL: ${CYAN}https://$DOMAIN${NC}"
echo -e "Theme: ${GREEN}FutureNode${NC}"
echo -e "${CYAN}Thank you for using FutureNode!${NC}"

read -p "Create admin user now? (y/N): " yn
[[ "$yn" =~ [Yy] ]] && php artisan p:user:make
