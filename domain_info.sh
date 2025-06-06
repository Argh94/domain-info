#!/bin/bash

# سربرگ گرافیکی
clear
echo -e "\e[32m          ▄▀▄     ▄▀▄"
echo -e "\e[32m         ▄█░░▀▀▀▀▀░░█▄"
echo -e "\e[32m     ▄▄  █░░░░░░░░░░░█  ▄▄"
echo -e "\e[32m    █▄▄█ █░░█░░┬░░█░░█ █▄▄█"
echo -e "\e[36m ╔════════════════════════════════════╗"
echo -e "\e[32m ║ ♚ Project: Domain/IP Info Tool      ║"
echo -e "\e[32m ║ ♚ Author: Argh94                   ║"
echo -e "\e[32m ║ ♚ GitHub: https://GitHub.com/Argh94║"
echo -e "\e[36m ╚════════════════════════════════════╝"
echo -e "\e[0m"

# بررسی نصب ابزارها
install_tool() {
  local tool=$1
  local package=$2
  if ! command -v "$tool" &>/dev/null; then
    echo "The $tool tool is not installed. Installing ..."
    if [[ -n $(command -v pkg) ]]; then
      pkg install "$package" -y
    elif [[ -n $(command -v apt) ]]; then
      apt update && apt install "$package" -y
    else
      echo "Error: Package manager not supported."
      exit 1
    fi
  fi
}

install_tool "whois" "whois"
install_tool "nslookup" "dnsutils"

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

# تابع اطلاعات دامنه
get_domain_info() {
  local domain=$1
  echo -e "\n----------------------------------"
  echo "Domain information: $domain"
  echo "----------------------------------"

  echo -e "\n=== WHOIS ==="
  if ! whois_output=$(whois "$domain" 2>/dev/null); then
    echo "Error: Failed to fetch WHOIS data for $domain"
  else
    echo "$whois_output" | grep -E "Domain Name|Registrar|Expiration Date" || echo "No relevant WHOIS data found."
  fi

  echo -e "\n=== Nslookup ==="
  if ! nslookup "$domain" 2>/dev/null; then
    echo "Error: Nslookup failed for $domain"
  fi

  echo -e "\n=== IP ==="
  nslookup "$domain" 2>/dev/null | grep "Address:" | awk '{print $2}' | grep -v '^$' || echo "No IP addresses found."

  echo -e "\n=== MX Record ==="
  nslookup -type=mx "$domain" 2>/dev/null | grep "mail exchanger" || echo "No MX records found."

  echo -e "\n=== TXT Record ==="
  nslookup -type=txt "$domain" 2>/dev/null | grep "text =" || echo "No TXT records found."
}

# تابع اطلاعات IP
get_ip_info() {
  local ip=$1
  echo -e "\n----------------------------------"
  echo "IP Information: $ip"
  echo "----------------------------------"

  echo -e "\n=== WHOIS ==="
  if ! whois_output=$(whois "$ip" 2>/dev/null); then
    echo "Error: Failed to fetch WHOIS data for $ip"
  else
    echo "$whois_output" | grep -E "NetName|Organization|CIDR" || echo "No relevant WHOIS data found."
  fi
}

# دریافت ورودی از کاربر
while true; do
  read -p $'\e[32mPlease enter the domain or IP address (or type "exit" to quit): \e[0m' address
  if [[ "$address" == "exit" ]]; then
    echo -e "\e[32m=== Goodbye! ===\e[0m"
    break
  fi

  if [[ -z "$address" ]]; then
    echo -e "\e[31mError: No input provided. Please enter a valid domain or IP.\e[0m"
    continue
  }

  # بررسی نوع ورودی و اجرای تابع مناسب
  if is_ip "$address"; then
    get_ip_info "$address"
  else
    get_domain_info "$address"
  fi
  echo -e "\e[32m=== End of Results ===\e[0m"
done

# حذف فایل اسکریپت پس از اجرا
rm -f "$0"
