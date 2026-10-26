# Cara memakai kode ini

```bash
flutter create week3_todo
cd week3_todo
flutter pub add flutter_riverpod
```

Lalu salin folder `lib/` dan `test/` dari folder ini ke project Anda (timpa `lib/main.dart`).
Nama package pada `test/stats_notifier_test.dart` (`package:week3_todo/...`) harus sama
dengan nama project; jika berbeda, ubah baris import tersebut.

Jalankan:

```bash
flutter analyze
flutter test
flutter run
```
