# change-mirror

اسکریپت تغییر میرور apt در اوبونتو به میرور پیشگامان (`ubuntu.pishgaman.net`)

A tiny Bash script that switches Ubuntu's apt mirrors to `ubuntu.pishgaman.net/ubuntu`.

---

## امکانات

- پشتیبانی از فرمت قدیمی `/etc/apt/sources.list`
- پشتیبانی از فرمت جدید deb822 (`/etc/apt/sources.list.d/ubuntu.sources`، اوبونتو ۲۴.۰۴ به بعد)
- تغییر خودکار `archive.ubuntu.com`، `security.ubuntu.com` و میرورهای کشوری (مثل `ir.archive.ubuntu.com`)
- بکاپ خودکار از فایل‌های اصلی (فقط یک بار، تا فایل اصلی هیچ‌وقت بازنویسی نشود)
- امکان برگرداندن به حالت اول با یک دستور
- اجرای خودکار `apt-get update` بعد از تغییر
- ریپوهای `ports.ubuntu.com` (معماری‌هایی مثل ARM) دست‌نخورده می‌مانند

## نصب و اجرا

### روش اول: دانلود و اجرا

```bash
wget https://raw.githubusercontent.com/sabialballa/change-mirror/main/change-ubuntu-mirror.sh
sudo bash change-ubuntu-mirror.sh
```

### روش دوم: کلون ریپو

```bash
git clone https://github.com/sabialballa/change-mirror.git
cd change-mirror
sudo bash change-ubuntu-mirror.sh
```

### اجرای یک‌خطی

```bash
curl -fsSL https://raw.githubusercontent.com/sabialballa/change-mirror/main/change-ubuntu-mirror.sh | sudo bash
```

> قبل از اجرای هر اسکریپتی با دسترسی root، بهتر است محتوای آن را بخوانید.

## برگرداندن به حالت اول

```bash
sudo bash change-ubuntu-mirror.sh restore
```

بکاپ‌ها در مسیر `/etc/apt/mirror-backup` ذخیره می‌شوند.

## تنظیمات

به‌صورت پیش‌فرض آدرس میرور `http://ubuntu.pishgaman.net/ubuntu` است. برای استفاده از https یا آدرس دیگر، متغیر `MIRROR` را بدهید:

```bash
sudo MIRROR=https://ubuntu.pishgaman.net/ubuntu bash change-ubuntu-mirror.sh
```

## نکات

- اسکریپت باید با دسترسی root (`sudo`) اجرا شود.
- بسته‌های apt با کلید GPG امضا می‌شوند، بنابراین استفاده از http امن است؛ ولی در صورت پشتیبانی میرور از https می‌توانید آن را فعال کنید.
- اگر بعد از تغییر، `apt-get update` خطا داد، با دستور `restore` به حالت قبل برگردید.

---

## English

### Usage

```bash
wget https://raw.githubusercontent.com/sabialballa/change-mirror/main/change-ubuntu-mirror.sh
sudo bash change-ubuntu-mirror.sh
```

Restore the original sources:

```bash
sudo bash change-ubuntu-mirror.sh restore
```

Use a custom mirror URL (e.g. https):

```bash
sudo MIRROR=https://ubuntu.pishgaman.net/ubuntu bash change-ubuntu-mirror.sh
```

### Notes

- Supports both the classic `sources.list` and the deb822 `ubuntu.sources` format.
- The original files are backed up once to `/etc/apt/mirror-backup`.
- `ports.ubuntu.com` entries are left untouched.

## License

MIT
