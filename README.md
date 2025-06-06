# Domain/IP Info Tool

ابزار حرفه‌ای دریافت اطلاعات دامنه و IP  
A Professional Domain/IP Information Shell Script Tool

---

## فارسی

### معرفی  
این اسکریپت Bash به شما امکان می‌دهد تنها با وارد کردن نام دامنه یا آدرس IP، اطلاعات کامل و جامعی از قبیل WHOIS، NS، MX، TXT، CNAME، PTR (Reverse DNS) و ... را به صورت منظم و رنگی مشاهده و در صورت نیاز در فایل ذخیره نمایید. این ابزار مناسب مدیران سرور، کارشناسان امنیت، سئوکارها و هر کاربری است که نیاز به بررسی سریع اطلاعات دامنه یا IP دارد.

### قابلیت‌ها
- نصب خودکار پیش‌نیازها (whois, nslookup و ...)
- دریافت اطلاعات کامل WHOIS دامنه و IP
- نمایش IPهای دامنه و لیست کامل Name Serverها (NS)
- نمایش رکوردهای MX، TXT و CNAME
- نمایش رکورد PTR (Reverse DNS) برای IP
- پشتیبانی از دامنه‌های فارسی (IDN)
- نمایش نتایج به صورت ستونی و رنگی
- قابلیت ذخیره خروجی هر کوئری در فایل متنی
- حذف اختیاری اسکریپت پس از اجرا
- دارای راهنمای داخلی (help)

### روش اجرا سریع
برای اجرا کافیست این دستور را در ترمینال وارد کنید:
```bash
curl -sL https://raw.githubusercontent.com/Argh94/domain-info/main/domain_info.sh | bash
```

### یا دانلود و اجرا به صورت دستی:
```bash
git clone https://github.com/Argh94/domain-info.git
cd domain-info
chmod +x domain_info.sh
./domain_info.sh
```

### نمونه خروجی:
```
Please enter the domain or IP address (or type 'exit' to quit):
173.244.56.6

----------------------------------
IP Information: 173.244.56.6
----------------------------------

=== WHOIS ===
    CIDR:          173.244.32.0/19
    NetName:       LOGICWEB
    Organization:  LogicWeb         Inc.  (LOGIC-25)              Country:       US

=== Reverse DNS / PTR ===
    No reverse DNS (PTR) found for 173.244.56.6

=== End of Results ===
Do you want to save the output to a file? (y/n):
```

### نکته
- برای دامنه‌های فارسی، اسکریپت به صورت خودکار تبدیل به punycode را انجام می‌دهد (در صورت نصب بودن ابزار idn).
- برای استفاده نیاز به اینترنت فعال دارید.

### توسعه‌دهنده
- Author: Argh94
- [GitHub Profile](https://github.com/Argh94)

---

## English

### Introduction  
This Bash script allows you to retrieve detailed and comprehensive information about any domain or IP address by simply entering it, including WHOIS, NS, MX, TXT, CNAME, PTR (Reverse DNS), and more. The output is presented in a clean, colored, and column-aligned format. You can also save each query's result to a file. This tool is ideal for sysadmins, security researchers, SEO experts, and anyone needing quick domain/IP insights.

### Features
- Automatic installation of dependencies (whois, nslookup, etc.)
- Full WHOIS info for domains and IPs
- Shows all IPs and Name Servers (NS) of a domain
- Displays MX, TXT, and CNAME records
- Shows PTR (Reverse DNS) records for IPs
- Supports Internationalized Domain Names (IDN)
- Results in pretty, colorized, column-aligned output
- Option to save each query’s output to a text file
- Optionally deletes itself after execution for convenience
- Built-in help message

### Quick Start
Just run this command in your terminal:
```bash
curl -sL https://raw.githubusercontent.com/Argh94/domain-info/main/domain_info.sh | bash
```

### Or download and run manually:
```bash
git clone https://github.com/Argh94/domain-info.git
cd domain-info
chmod +x domain_info.sh
./domain_info.sh
```

### Sample Output:
```
Please enter the domain or IP address (or type 'exit' to quit):
173.244.56.6

----------------------------------
IP Information: 173.244.56.6
----------------------------------

=== WHOIS ===
    CIDR:          173.244.32.0/19
    NetName:       LOGICWEB
    Organization:  LogicWeb         Inc.  (LOGIC-25)              Country:       US

=== Reverse DNS / PTR ===
    No reverse DNS (PTR) found for 173.244.56.6

=== End of Results ===
Do you want to save the output to a file? (y/n):
```

### Notes
- For Persian/IDN domains, the script automatically converts to punycode (if `idn` is installed).
- You need an active internet connection for the tool to work.

### Developer
- Author: Argh94
- [GitHub Profile](https://github.com/Argh94)

---

**پیشنهادها و ایرادات را از طریق Issues در گیت‌هاب اعلام فرمایید.**  
**For suggestions and bug reports, please open an Issue on GitHub!**
