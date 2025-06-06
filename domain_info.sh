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
install_tool "awk" "awk"
install_tool "column" "bsdmainutils"
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

# تابع ذخیره خروجی
save_output() {
  local content="$1"
  local target="$2"
  local timestamp
  timestamp=$(date +"%Y%m%d-%H%M%S")
  local filename="output-$target-$timestamp.txt"
  echo -e "$content" > "$filename"
  echo -e "\e[35mResult saved to $filename\e[0m"
}

# تابع نمایش لیست‌ها به صورت ستونی رنگی
pretty_column() {
  local color="$1"
  shift
  if [[ $# -gt 0 ]]; then
    printf "%b\n" "$@" | column | sed "s/^/    /" | sed "s/.*/\x1b[${color}m&\x1b[0m/"
  else
    echo -e "\e[31m    (None found)\e[0m"
  fi
}

# تابع اطلاعات دامنه
get_domain_info() {
  local domain=$1
  local out=""
  # تبدیل دامنه فارسی به پونی‌کد اگر idn نصب است
  if $idn_support; then
    domain=$(idn "$domain")
  fi

  out+="\n\e[34m----------------------------------\n"
  out+="Domain information: $domain\n"
  out+="----------------------------------\e[0m\n"

  # چک کردن اینترنت
  check_internet

  out+="\n\e[33m=== WHOIS ===\e[0m\n"
  if ! whois_output=$(whois "$domain" 2>/dev/null); then
    out+="\e[31mError: Failed to fetch WHOIS data for $domain\e[0m\n"
  else
    whois_lines=$(echo "$whois_output" | grep -E "Domain Name|Registrar|Creation Date|Expiration Date|Name Server")
    if [[ -z "$whois_lines" ]]; then
      out+="\e[31mNo relevant WHOIS data found.\e[0m\n"
    else
      out+=$(echo -e "$whois_lines" | column -t | sed "s/^/    /")"\n"
    fi
  fi

  out+="\n\e[33m=== Nslookup ===\e[0m\n"
  if ! ns_output=$(nslookup "$domain" 2>/dev/null); then
    out+="\e[31mError: Nslookup failed for $domain\e[0m\n"
  else
    ip_addresses=$(echo "$ns_output" | grep "Address:" | awk '{print $2}' | grep -v '^$' | sort -u)
    out+="\e[36mIP Addresses:\e[0m\n"
    if [[ -n "$ip_addresses" ]]; then
      out+=$(echo "$ip_addresses" | sed "s/^/    /")"\n"
    else
      out+="    \e[31mNo IP addresses found.\e[0m\n"
    fi
  fi

  # نمایش Name Serverها
  out+="\n\e[33m=== Name Servers (NS) ===\e[0m\n"
  ns_records=$(nslookup -type=ns "$domain" 2>/dev/null | grep "nameserver =" | awk '{print $4}' | sed 's/\.$//' | sort -u)
  if [[ -n "$ns_records" ]]; then
    out+=$(echo "$ns_records" | sed "s/^/    /")"\n"
  else
    out+="    \e[31mNo NS records found.\e[0m\n"
  fi

  # نمایش MX رکوردها
  out+="\n\e[33m=== MX Record ===\e[0m\n"
  mx_records=$(nslookup -type=mx "$domain" 2>/dev/null | grep "mail exchanger" | awk -F'= ' '{print $2}' | sort -u)
  if [[ -n "$mx_records" ]]; then
    out+=$(echo "$mx_records" | sed "s/^/    /")"\n"
  else
    out+="    \e[31mNo MX records found.\e[0m\n"
  fi

  # نمایش TXT رکوردها
  out+="\n\e[33m=== TXT Record ===\e[0m\n"
  txt_records=$(nslookup -type=txt "$domain" 2>/dev/null | grep "text =" | awk -F'text = ' '{print $2}' | sed 's/"//g' | sort -u)
  if [[ -n "$txt_records" ]]; then
    out+=$(echo "$txt_records" | sed "s/^/    /")"\n"
  else
    out+="    \e[31mNo TXT records found.\e[0m\n"
  fi

  # نمایش CNAME رکورد
  out+="\n\e[33m=== CNAME Record ===\e[0m\n"
  cname_record=$(nslookup -type=cname "$domain" 2>/dev/null | grep "canonical name" | awk -F'= ' '{print $2}' | sed 's/\.$//' | sort -u)
  if [[ -n "$cname_record" ]]; then
    out+=$(echo "$cname_record" | sed "s/^/    /")"\n"
  else
    out+="    \e[31mNo CNAME record found.\e[0m\n"
  fi

  echo -e "$out"
  echo -e "\e[32m=== End of Results ===\e[0m"
  # ذخیره خروجی (اختیاری)
  echo -e "\e[33mDo you want to save the output to a file? (y/n): \e[0m"
  read -r save_confirm </dev/tty
  if [[ "$save_confirm" =~ ^[Yy]$ ]]; then
    save_output "$out" "$domain"
  fi
}

# تابع اطلاعات IP
get_ip_info() {
  local ip=$1
  local out=""

  # چک کردن اینترنت
  check_internet

  out+="\n\e[34m----------------------------------\n"
  out+="IP Information: $ip\n"
  out+="----------------------------------\e[0m\n"

  out+="\n\e[33m=== WHOIS ===\e[0m\n"
  if ! whois_output=$(whois "$ip" 2>/dev/null); then
    out+="\e[31mError: Failed to fetch WHOIS data for $ip\e[0m\n"
  else
    whois_lines=$(echo "$whois_output" | grep -E "NetName|Organization|CIDR|Country")
    if [[ -z "$whois_lines" ]]; then
      out+="\e[31mNo relevant WHOIS data found.\e[0m\n"
    else
      out+=$(echo -e "$whois_lines" | column -t | sed "s/^/    /")"\n"
    fi
  fi

  # Reverse DNS و PTR رکورد
  out+="\n\e[33m=== Reverse DNS / PTR ===\e[0m\n"
  reverse_dns=$(nslookup "$ip" 2>/dev/null | grep "name =" | awk '{print $4}' | sed 's/\.$//')
  if [[ -z "$reverse_dns" || "$reverse_dns" == "undefined.hostname.localhost" ]]; then
    out+="    \e[31mNo reverse DNS (PTR) found for $ip\e[0m\n"
  else
    out+="    Hostname: $reverse_dns\n"
  fi

  echo -e "$out"
  echo -e "\e[32m=== End of Results ===\e[0m"
  # ذخیره خروجی (اختیاری)
  echo -e "\e[33mDo you want to save the output to a file? (y/n): \e[0m"
  read -r save_confirm </dev/tty
  if [[ "$save_confirm" =~ ^[Yy]$ ]]; then
    save_output "$out" "$ip"
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
done

# حذف اختیاری اسکریپت
echo -e "\e[33mDo you want to delete this script file? (y/n): \e[0m"
read -r del_confirm </dev/tty
if [[ "$del_confirm" =~ ^[Yy]$ ]]; then
  rm -f "$0"
  echo -e "\e[32mScript deleted.\e[0m"
fi
