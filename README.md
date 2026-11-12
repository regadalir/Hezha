# کیبورد کوردی سورانی — Hazhir Hezha

کیبورد سفارشی آیفون با همان چیدمان عکس. روی کلید فاصله نوشته شده: `© Hazhir Hezha`

## چیدمان

```
ق  ڤ  ف  غ  ع  ھ  ە  ت  ح  خ      ← نگه‌داشتن = عدد ١ تا ٠
ش  س  ی  ێ  ل  ڵ  ا  ن  ج  چ
ب  ز  ر  ڕ  د  وو و  ۆ  ک  گ
⟷  ئ  پ  ژ  م  ؟  ،  .  ⌫
🌐   ½   [ © Hazhir Hezha ]   !؟   ←
```

- `⟷` نیم‌فاصله
- `½` صفحهٔ عددها، `!؟` صفحهٔ علامت‌ها و حرکت‌ها
- `🌐` رفتن به کیبورد بعدی

## ساختن (روی ویندوز، بدون مک)

1. یک مخزن (repository) در GitHub بسازید و همهٔ این پوشه را در آن بارگذاری کنید.
2. در تب **Actions**، اجرای **Build IPA** را باز کنید و وقتی تمام شد فایل `HazhirKeyboard` را از بخش Artifacts دانلود کنید. داخلش `HazhirKeyboard.ipa` است.
3. با [Sideloadly](https://sideloadly.io) و Apple ID خودتان فایل ipa را روی آیفون نصب کنید.
4. در آیفون: **Settings › General › VPN & Device Management** و به Apple ID خود اعتماد (Trust) کنید.
5. **Settings › General › Keyboard › Keyboards › Add New Keyboard…** و `HazhirKeyboard` را انتخاب کنید.

با Apple ID رایگان، برنامه هر ۷ روز باید دوباره با Sideloadly نصب شود.

## ساختن (روی مک)

```bash
brew install xcodegen
```

```bash
xcodegen generate
```

بعد `HazhirKeyboard.xcodeproj` را در Xcode باز کنید، برای هر دو target تیم (Team) خود را انتخاب کنید و روی آیفون اجرا کنید.

## تغییر چیدمان

حرف‌ها در `letterRows` بالای فایل `Keyboard/KeyboardViewController.swift` هستند؛ نوشتهٔ روی فاصله در `Style.brand`.
