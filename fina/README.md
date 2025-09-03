# Fina Ride UI 🚗

یک رابط کاربری مدرن و iOS‑style برای اپلیکیشن رزرو سفر با Flutter.  
تمرکز پروژه روی تجربه‌ی روان اسکرول، گرادیان‌های مدرن، و تعاملات ساده و موبایل‌محور است.

- Ride Preview: نقشه + پنل کشویی (Draggable Sheet) + CTA
- Car Details: هدر تصویری، عنوان/ریویو/ستاره‌ها/Tags، Spec و نوار قیمت/Select

---

## Technologies Used

- Flutter (Dart ≥ 3.9.0)
- BLoC pattern  
  - flutter_bloc: ^8.1.3  
  - equatable: ^2.0.5
- Material + cupertino_icons: ^1.0.8
- iOS‑style bouncing scroll (BouncingScrollPhysics) و حذف Glow
- DraggableScrollableSheet با snap (peek/mid/expanded)
- گرادیان‌های نرم برای خوانایی روی تصویر هدر
- Responsive scaling مطابق فیگما با ضریب `s = width / 375.0`
- Navigation با Navigator (push/pop)
- Asset management (case‑sensitive)

---

## Features

- Ride Preview Screen
  - پنل کشویی با DraggableScrollableSheet (حالت‌های snap: peek/mid/expanded)
  - CTA (Select) → ناوبری به صفحه Car Details
  - Top status overlay (تصویر Top_bar)
- Car Details Screen
  - هدر تصویری تمام‌عرض (bmw.png) با ارتفاع پویا و alignment پایین‌تر
  - عنوان، “110 reviews” با underline، ۵ ستاره چسبیده
  - Chips آماده به‌صورت تصویر (Tags.png)
  - بلاک امکانات (Spec.png) با ابعاد اسکیل‌شده
  - نوار قیمت و دکمه Select (Bottom.png) با حاشیه افقی 16
  - اسکرول روان و بدون اورفلو

---

## Getting Started

1) Clone this repository:
```bash
git clone https://github.com/<YourUsername>/<YourRepo>.git
cd <YourRepo>
```

2) Install dependencies:
```bash
flutter pub get
```

3) Run the project:
```bash
flutter run
```

Environment:
- Flutter stable
- Dart SDK: ^3.9.0

Assets (ضروری):
- images: `Map.png`, `Top_bar.png`, `Bottom.png`, `bmw.png`
- icons: `Chevron.png`, `Heart.png`, `star.png`, `Tags.png`, `Spec.png`  
توجه: نام فایل‌ها حساس به حروف بزرگ/کوچک است (مثال: `Tags.png` درست است).

اگر Asset جدید اضافه شد:
```bash
flutter pub get
# در صورت نیاز:
flutter clean && flutter pub get
```

---

## Screenshots

> تصاویر خروجی خودت را اضافه کن (پیشنهاد: `assets/readme/...`)

```md
![Ride Preview](assets/readme/ride_preview.png)
![Car Details](assets/readme/car_details.png)
```

---

## Implementation Highlights

- Responsive scale (مطابق فریم 375px فیگما)
```dart
final s = MediaQuery.of(context).size.width / 375.0;
// مثال‌ها:
final starSize   = 14 * s;
final tagsHeight = 26 * s;
final ctaHeight  = 106 * s;
```

- Draggable Sheet با snap (در Ride Preview)
```dart
DraggableScrollableSheet(
  initialChildSize: peek,
  minChildSize: peek,
  maxChildSize: expanded,
  snap: true,
  snapSizes: [peek, mid, expanded],
  builder: (_, scrollController) => /* content */,
);
```

- گرادیان اتصال هدر به پس‌زمینه برای خوانایی
```dart
DecoratedBox(
  decoration: BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Colors.transparent, Colors.transparent, Color(0x33000000), pageBg],
      stops: [0.0, 0.6, 0.85, 1.0],
    ),
  ),
);
```

---

## Notes

- Select در RidePreview → CarDetailsScreen (Navigator.push)
- Back (Chevron) در هر دو صفحه → Navigator.pop
- CarDetails کاملاً اسکرول‌پذیر است تا هیچ اوورفلو/حاشوری دیده نشود.
- اگر Assets لود نشد: مسیر و حروف بزرگ/کوچک را چک کن، سپس Hot Restart.

---

## Roadmap

- [ ] گالری هدر (سوایپ + indicator 1/12)
- [ ] Collapsing / Parallax header
- [ ] Heart با وضعیت (BLoC/Cubit)
- [ ] دیتای داینامیک برای Spec/CTA/Tags
- [ ] Golden/Widget Tests

---

## License

MIT 

---

## Developer

Mahdi-Shabani