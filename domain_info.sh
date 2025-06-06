#!/bin/bash

# تابع بررسی اتصال اینترنت
check_internet() {
  if ! ping -c 1 -W 2 8.8.8.8 &>/dev/null; then
    echo -e "\e[31mError: No internet connection. Please check your connection.\e[0m"
    exit 1
  fi
}

# تابع نصب ابزارها
install_tool() {
  local tool=$1
  local package=$2
  if ! command -v "$tool" &>/dev/null; then
    echo -e "\e[33mInstalling $tool...\e[0m"
    if [[ -n $(command -v pkg) ]]; then
      pkg update -y && pkg install "$package" -y
    elif [[ -n $(command -v apt) ]]; then
      apt update -y && apt install "$package" -y
    else
      echo -e "\e[31mError: Package manager not supported.\e[0m"
      exit 1
    fi
  fi
}

# نصب ابزارها قبل از هر چیزی
install_tool "whois" "whois"
install_tool "nslookup" "dnsutils"
install_tool "awk" "awk"      # برای اطمینان از وجود awk
if command -v idn &>/dev/null; then
  idn_support=true
else
  idn_support=false
fi

# پاک کردن صفحه و نمایش سربرگ
clear
echo -e "\e[32m          ▄▀▄     ▄▀▄"
echo -e "\e[32m         ▄█░░▀▀▀▀▀░░█▄"
echo -e "\e[32m     ▄▄  █░░░░░░░░░░░█  ▄▄"
echo -e "\e[32m    █▄▄█ █░░█░░┬░░█░░█ █▄▄█"
echo -e "\e[36m ╔════════════════════════════════════╗"
echo -e "\e[32m ║ ♚ Project: Domain/IP Info Tool     ║"
echo -e "\e[32m ║ ♚ Author: Argh94                   ║"
echo -e "\e[32m ║ ♚ GitHub: https://GitHub.com/Argh94║"
echo -e "\e[36m ╚════════════════════════════════════╝"
echo -e "\e[0m"

# تابع اعتبارسنجی IP
is_ip() {
  local ip=$1
  local regex='^([0-9]{1,3}\.){3}[0-9]{1,3}$'
  if [[ $ip =~ $regex ]]; then
    for octet in ${ip//./ }; do
      if (( octet < 0 || octet > 255 )); then
        return 1
      fi
    done
    return 0
  else
    return 1
  fi
}

# تابع راهنما
show_help() {
  echo -e "\e[36mUsage: Enter a domain (e.g. example.com) or IP (e.g. 8.8.8.8) to get info."
  echo -e "Type 'exit' to quit."
  echo -e "Type 'help' or '-h' or '--help' to see this message again.\e[0m"
}

# تابع اطلاعات دامنه
get_domain_info() {
  local domain=$1
  # تبدیل دامنه فارسی به پونی‌کد اگر idn نصب است
  if $idn_support; then
    domain=$(idn "$domain")
  fi

  echo -e "\n\e[34m----------------------------------"
  echo "Domain information: $domain"
  echo -e "----------------------------------\e[0m"

  # چک کردن اینترنت
  check_internet

  echo -e "\n\e[33m=== WHOIS ===\e[0m"
  if ! whois_output=$(whois "$domain" 2>/dev/null); then
    echo -e "\e[31mError: Failed to fetch WHOIS data for $domain\e[0m"
  else
    echo "$whois_output" | grep -E "Domain Name|Registrar|Creation Date|Expiration Date|Name Server" || echo -e "\e[31mNo relevant WHOIS data found.\e[0m"
  fi

  echo -e "\n\e[33m=== Nslookup ===\e[0m"
  if ! nslookup "$domain" 2>/dev/null; then
    echo -e "\e[31mError: Nslookup failed for $domain\e[0m"
  fi

  echo -e "\n\e[33m=== IP ===\e[0m"
  nslookup "$domain" 2>/dev/null | grep "Address:" | awk '{print $2}' | grep -v '^$' || echo -e "\e[31mNo IP addresses found.\e[0m"

  echo -e "\n\e[33m=== MX Record ===\e[0m"
  nslookup -type=mx "$domain" 2>/dev/null | grep "mail exchanger" || echo -e "\e[31mNo MX records found.\e[0m"

  echo -e "\n\e[33m=== TXT Record ===\e[0m"
  nslookup -type=txt "$domain" 2>/dev/null | grep "text =" || echo -e "\e[31mNo TXT records found.\e[0m"
}

# تابع اطلاعات IP
get_ip_info() {
  local ip=$1

  # چک کردن اینترنت
  check_internet

  echo -e "\n\e[34m----------------------------------"
  echo "IP Information: $ip"
  echo -e "----------------------------------\e[0m"

  echo -e "\n\e[33m=== WHOIS ===\e[0m"
  if ! whois_output=$(whois "$ip" 2>/dev/null); then
    echo -e "\e[31mError: Failed to fetch WHOIS data for $ip\e[0m"
  else
    echo "$whois_output" | grep -E "NetName|Organization|CIDR|Country" || echo -e "\e[31mNo relevant WHOIS data found.\e[0m"
  fi

  echo -e "\n\e[33m=== Reverse DNS ===\e[0m"
  if ! reverse_dns=$(nslookup "$ip" 2>/dev/null | grep "name =" | awk '{print $4}' | sed 's/\.$//'); then
    echo -e "\e[31mNo reverse DNS found for $ip\e[0m"
  else
    echo "Hostname: $reverse_dns"
  fi
}

# حلقه دریافت ورودی
while true; do
  echo -e "\e[32mPlease enter the domain or IP address (or type 'exit' to quit): \e[0m"
  read -r address </dev/tty

  # راهنما
  if [[ "$address" =~ ^(--help|-h|help)$ ]]; then
    show_help
    continue
  fi

  # خروج
  if [ "$address" = "exit" ]; then
    echo -e "\e[32m=== Goodbye! ===\e[0m"
    break
  fi

  if [ -z "$address" ]; then
    echo -e "\e[31mError: No input provided. Please enter a valid domain or IP.\e[0m"
    continue
  fi

  if is_ip "$address"; then
    get_ip_info "$address"
  else
    get_domain_info "$address"
  fi
  echo -e "\e[32m=== End of Results ===\e[0m"
done

# حذف اختیاری اسکریپت
echo -e "\e[33mDo you want to delete this script file? (y/n): \e[0m"
read -r del_confirm </dev/tty
if [[ "$del_confirm" =~ ^[Yy]$ ]]; then
  rm -f "$0"
  echo -e "\e[32mScript deleted.\e[0m"
fi
