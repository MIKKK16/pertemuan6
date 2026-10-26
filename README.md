# Laporan Praktikum 06 - State Management

> Nama: **David Pratama Tampubolon** · NIM: **23520009** ·
>

---

## Praktikum 1: Dasar State dengan Model-View

<img width="774" height="417" alt="image" src="https://github.com/user-attachments/assets/cad209be-a46d-4c1a-bdc5-4771ba2d9726" />

Kode Praktikum 1 ada di `master_plan/snapshots/praktikum1/` (salin `main.dart` dan `plan_screen.dart` ke `lib/`, `lib/views/`). Model (`task.dart`, `plan.dart`, `data_layer.dart`) ada di `lib/models/`.

### Soal 2 - Maksud Langkah 4 (`data_layer.dart`)

File `data_layer.dart` hanya berisi `export 'plan.dart'; export 'task.dart';`. Pola ini disebut *barrel file*: satu pintu masuk untuk seluruh file di lapisan data. Alasannya:

- View cukup menulis satu baris `import '../models/data_layer.dart';` untuk mendapatkan `Plan` **dan** `Task`, tidak perlu impor satu per satu.
- Jika nanti model bertambah (mis. `user.dart`), cukup tambah satu baris export di sini; file-file view tidak perlu diubah.
- Memperjelas batas antar lapisan: view hanya bergantung pada "data layer", bukan pada detail file di dalamnya.

### Soal 3 - Mengapa perlu variabel `plan`, dan mengapa `const`?

- **Perlu**, karena `_PlanScreenState` harus menyimpan data yang sedang ditampilkan. `ListView` membaca `plan.tasks`, dan setiap perubahan (tambah task, centang, ubah teks) dilakukan dengan membuat `Plan` baru yang ditugaskan ke `plan` di dalam `setState`. Tanpa variabel ini, view tidak punya sumber data dan tidak ada yang bisa di-rebuild.
- **`const Plan()`** dipakai karena `Plan` bersifat *immutable* (semua field `final`, konstruktor `const`). Nilai awal berupa plan kosong yang tidak pernah dimutasi; objek `const` dibuat sekali pada waktu kompilasi (lebih hemat) dan mencegah mutasi tidak sengaja (mis. `plan.tasks.add(...)` akan error karena `tasks` default-nya `const []`). Perhatikan: yang `const` adalah *nilai awalnya*; variabelnya sendiri bukan konstanta, sehingga tetap bisa diganti dengan objek `Plan` baru.

### Soal 4 - Hasil Langkah 9

<img width="773" height="287" alt="image" src="https://github.com/user-attachments/assets/49aa8632-1568-4de8-8daf-257ed1e01328" />

<img width="774" height="491" alt="image" src="https://github.com/user-attachments/assets/479a8067-ee74-4032-a218-230b81b526f0" />

<img width="940" height="99" alt="image" src="https://github.com/user-attachments/assets/29d02943-89ff-4935-bf19-36b7df355eae" />

<img width="940" height="90" alt="image" src="https://github.com/user-attachments/assets/5dcbb1e5-69cf-43a0-aa6e-522efa0eb100" />

<img width="940" height="159" alt="image" src="https://github.com/user-attachments/assets/cb109b5f-d7c7-4437-9b65-29664322c4df" />

Yang dibuat: daftar tugas dinamis. Tombol `+` (FloatingActionButton) menambah `Task` kosong ke `plan.tasks`. Setiap item ditampilkan oleh `_buildTaskTile` sebagai `ListTile` berisi `Checkbox` (mengubah `complete`) dan `TextFormField` (mengubah `description`). Karena data immutable, setiap perubahan membuat `Task` dan `Plan` baru (`List<Task>.from(...)..[index] = Task(...)`) lalu dibungkus `setState` agar UI digambar ulang.

### Soal 5 - Kegunaan Langkah 11 (`initState`) dan Langkah 13 (`dispose`)

- **`initState()`** dipanggil **sekali** ketika objek State dibuat, sebelum `build` pertama. Dipakai untuk inisialisasi: membuat `ScrollController` dan memasang listener yang menghapus fokus dari TextField saat list di-scroll (agar keyboard tidak menghalangi).
- **`dispose()`** dipanggil ketika State dihapus permanen dari widget tree. Dipakai untuk melepas resource (`scrollController.dispose()`) supaya tidak terjadi kebocoran memori / listener yang tetap hidup. `super.dispose()` dipanggil terakhir.

---

## Praktikum 2: InheritedWidget dan InheritedNotifier

<img width="940" height="505" alt="image" src="https://github.com/user-attachments/assets/9b850597-6496-46bd-a88a-148a69cd0bbc" />

Kode ada di `master_plan/snapshots/praktikum2/` (`main.dart`, `plan_provider.dart`, `plan_screen.dart`).

### Soal 2 - Mana yang InheritedWidget? Mengapa `InheritedNotifier`?

Pada Langkah 1, **`PlanProvider`** adalah InheritedWidget-nya. Ia `extends InheritedNotifier<ValueNotifier<Plan>>`, dan `InheritedNotifier` adalah turunan khusus dari `InheritedWidget`. Cara kerjanya: data (`ValueNotifier<Plan>`) ditaruh di atas pohon widget, dan widget di bawahnya mengambilnya lewat `PlanProvider.of(context)` (`dependOnInheritedWidgetOfExactType`).

`InheritedNotifier` dipilih (bukan `InheritedWidget` biasa) karena:

- `InheritedWidget` biasa immutable; agar dependent ter-update, widget induk harus dibangun ulang dan membuat `InheritedWidget` baru.
- `InheritedNotifier` otomatis **mendengarkan** `Listenable` (di sini `ValueNotifier`) dan memberi tahu dependent setiap `notifier.value` berubah. Jadi view cukup mengubah `planNotifier.value = Plan(...)`, tanpa `setState` dan tanpa membangun ulang widget induk.

### Soal 3 - Maksud method pada Langkah 3

```dart
int get completedCount => tasks.where((task) => task.complete).length;
String get completenessMessage => '$completedCount out of ${tasks.length} tasks';
```

- `completedCount` menghitung jumlah task yang sudah dicentang.
- `completenessMessage` menyusun teks progres, mis. `2 out of 5 tasks`.

Keduanya berupa *getter turunan* (derived data) yang dihitung dari `tasks`, bukan disimpan sebagai field tambahan. Hasilnya: tidak ada data ganda yang bisa tidak sinkron, logika bisnis berada di **model** (bukan di view), dan view cukup menampilkan `plan.completenessMessage` (dipakai di footer `SafeArea` dan, di Praktikum 3, di subtitle daftar plan).

### Soal 4 - Hasil Langkah 9

<img width="940" height="351" alt="image" src="https://github.com/user-attachments/assets/2d257476-3205-42a9-977b-6b204b979900" />

<img width="940" height="599" alt="image" src="https://github.com/user-attachments/assets/5b7d249d-24cb-4f44-8925-60440e35a23d" />

<img width="940" height="600" alt="image" src="https://github.com/user-attachments/assets/51b43904-a016-4f00-bc9b-6c9ea58cba91" />

Secara tampilan hampir sama dengan Praktikum 1, tetapi ada footer progres ("x out of y tasks") dan arsitekturnya berubah: data tidak lagi disimpan di `State` milik `PlanScreen`, melainkan di `ValueNotifier<Plan>` yang disediakan `PlanProvider`. `ValueListenableBuilder` membangun ulang UI setiap `Plan` berubah. Inilah pemisahan view dan model yang dimaksud modul.

---

## Praktikum 3: State di Multiple Screens

![GIF Praktikum 3](docs/praktikum3.gif)

Kode final ada di `master_plan/lib/`.

### Soal 2 - Maksud diagram

Diagram menunjukkan dua pohon widget sebelum dan sesudah `Navigator.push`:

- **Kiri (`PlanCreatorScreen`)**: `MaterialApp → PlanProvider → PlanCreatorScreen → Column → (TextField, Expanded → ListView)`. Layar ini berisi kolom input "Add a plan" dan daftar semua plan.
- **Kanan (`PlanScreen`)**: setelah `Navigator.push(MaterialPageRoute(... PlanScreen(plan: plan)))`, layar baru muncul: `PlanScreen → Scaffold → Column → (Expanded → ListView, SafeArea → Text)` yaitu daftar task dan footer progres.

Inti pelajarannya adalah **"Lift State Up"**: `PlanProvider` diletakkan di atas `MaterialApp`/`Navigator`, sehingga layar mana pun yang di-push (yang berada di bawah Navigator) tetap bisa mengakses data yang sama lewat `PlanProvider.of(context)`. Pada Praktikum 2, provider dipasang di `home`, sehingga route baru **tidak** bisa menemukannya. Karena `List<Plan>` hidup di atas semua layar, perubahan di `PlanScreen` (centang task) langsung tercermin di `PlanCreatorScreen` (subtitle "x out of y tasks").

### Soal 3 - Hasil Langkah 14

<img width="872" height="469" alt="image" src="https://github.com/user-attachments/assets/3189a3bd-cf85-469b-bacf-f50acbb8283e" />

<img width="864" height="403" alt="image" src="https://github.com/user-attachments/assets/35724296-c067-4a78-a926-fab5bd6831cc" />

Yang dibuat: layar "Master Plans" dengan kolom input untuk menambah plan baru (`addPlan` menambahkan `Plan` ke `ValueNotifier<List<Plan>>`). Jika kosong tampil ikon dan teks "Anda belum memiliki rencana apapun." Jika ada isi, `ListView` menampilkan nama plan dan progresnya; mengetuk salah satu membuka `PlanScreen` untuk mengelola task-nya.

### Perbaikan terhadap kode modul

Beberapa bagian kode di modul akan error atau berperilaku salah, dan sudah diperbaiki di `master_plan/lib/`:

<img width="867" height="467" alt="image" src="https://github.com/user-attachments/assets/6686dedf-720f-49ee-b82a-3642af1fcc97" />

| Masalah di modul | Perbaikan |
|---|---|
| `Text(_plan.name)` pada AppBar (variabel `_plan` tidak ada) | `Text(plan.name)` |
| `plan = Plan(...)` pada `_buildAddTaskButton` (`plan` adalah getter, tidak bisa di-assign) | Dihapus; data selalu dibaca dari provider |
| `_buildTaskTile` memakai `plan` dari `widget.plan` yang **basi** (tidak ikut ter-update) | `PlanScreen` memakai `currentPlan` dari provider untuk membangun list dan tile |
| `_buildMasterPlans` membaca `planNotifier.value` tanpa mendengarkan, sehingga subtitle tidak ter-update saat kembali dari `PlanScreen` | Dibungkus `ValueListenableBuilder` |
| `setState(() {})` di `addPlan` | Tidak perlu lagi karena sudah memakai `ValueListenableBuilder` |

Keterbatasan: plan dicari berdasarkan `name`, jadi dua plan dengan nama sama akan tertukar. Untuk aplikasi sungguhan, beri `id` unik pada `Plan`.

---

## Praktikum 4: ToDo dengan Riverpod

Kode: `week3_todo/lib/main.dart`, `providers/todo_provider.dart`, `pages/todo_page.dart`.

<img width="940" height="505" alt="image" src="https://github.com/user-attachments/assets/c1e5ee5d-7ca1-46a8-a4c5-276a08d2e37d" />

<img width="940" height="504" alt="image" src="https://github.com/user-attachments/assets/90c88490-afaf-457c-981b-8a3cf71d5fea" />

<img width="940" height="504" alt="image" src="https://github.com/user-attachments/assets/884526a7-e2ac-4b1c-82ae-f65cd08bc6a3" />

<img width="940" height="504" alt="image" src="https://github.com/user-attachments/assets/a77d83e8-87ea-4ca9-bd1b-20df6f07950e" />

Poin yang perlu Anda pahami untuk demo:

- `ProviderScope` membungkus aplikasi; semua provider hidup di dalamnya.
- `TodoListNotifier extends Notifier<List<Todo>>`: state diubah hanya lewat method (`add`, `toggle`, `remove`) dan **selalu dengan list baru** (immutable), karena Riverpod mendeteksi perubahan lewat perbandingan objek state.
- `ref.watch(todoListProvider)` di dalam `build` untuk rebuild otomatis; `ref.read(todoListProvider.notifier)` di dalam callback untuk memanggil method tanpa berlangganan.

---

## Praktikum 5: AsyncValue (loading, error, success)

Kode: `providers/products_provider.dart`, `pages/product_page.dart` (buka lewat ikon kotak di AppBar halaman ToDo).

<img width="940" height="386" alt="image" src="https://github.com/user-attachments/assets/9154c51e-b4f1-46a3-b499-80b935c02968" />

<img width="940" height="383" alt="image" src="https://github.com/user-attachments/assets/c47f5914-0b17-43dd-b0a5-b54f145c6504" />

<img width="940" height="372" alt="image" src="https://github.com/user-attachments/assets/499ce43a-5759-4a43-bfac-bbb22fc378e7" />

<img width="940" height="274" alt="image" src="https://github.com/user-attachments/assets/b2871a1b-f812-4bf9-939c-ee89ed554dca" />

<img width="940" height="504" alt="image" src="https://github.com/user-attachments/assets/9ef45118-b69d-4344-a311-e4c1abcddd82" />

<img width="940" height="426" alt="image" src="https://github.com/user-attachments/assets/de168a92-5298-4b6f-9719-bfe1912ba559" />

| No | Tugas | Hasil yang diamati (isi dari hasil run Anda) |
|---|---|---|
| 1 | Jalankan, amati loading 2 detik | ![loading](docs/p5-loading.png) |
| 2 | `throw Exception('Gagal terhubung ke server');` di `build()` | ![error](docs/p5-error.png) |
| 3 | Tekan "Coba lagi", lalu pulihkan kode | ![success](docs/p5-success.png) |

Catatan teknis (Riverpod 3.x): provider yang melempar exception **otomatis di-retry** (hingga 10 kali dengan backoff 200 ms - 6,4 detik), sehingga UI error baru muncul setelah lama. Karena itu `main.dart` memakai `ProviderScope(retry: (retryCount, error) => null, ...)`. Jika Anda memakai Riverpod 2.x, hapus parameter `retry` ([dokumentasi retry](https://riverpod.dev/docs/concepts2/retry)).

### Soal 4 - Refleksi: mengapa menampilkan stale data dengan indikator refresh kadang lebih baik?

Mengosongkan layar menjadi spinner saat refresh membuat pengguna kehilangan konteks (posisi scroll, item yang sedang dibaca) dan terasa lambat. Dengan menampilkan data lama sambil menunjukkan indikator refresh kecil, aplikasi tetap terasa responsif dan tetap berguna. Pola ini penting ketika:

- **pull-to-refresh / refresh berkala** pada feed, daftar produk, atau dashboard;
- **jaringan lambat atau tidak stabil**: data lama masih lebih berguna daripada layar kosong atau error total;
- **gagal refresh**: data lama tetap ditampilkan dengan pesan error ringan (snackbar), bukan menghapus semuanya;
- data besar atau mahal diambil ulang.

Pada kode `refresh()` di modul, `state = const AsyncLoading()` justru menghapus data lama. Untuk mempertahankannya, gunakan `AsyncLoading<List<String>>().copyWithPrevious(state)`, lalu di UI cek `isRefreshing` / `hasValue`.

---

## AI Challenge

Folder `docs/ai/` diisi oleh Anda: prompt yang dipakai, output awal AI, perbaikan, dan hasil testing.

Kode yang saya siapkan (AI co-developer): `lib/providers/stats_provider.dart`, `lib/pages/stats_page.dart`, `test/stats_notifier_test.dart`. Buka halaman lewat ikon grafik di AppBar halaman ToDo.

### Verification Checklist

| Item | Temuan |
|---|---|
| State diubah immutable? | Ya. `Todo`/`Stats` tidak memakai `state.add()`; list selalu dibuat baru (`[...state, ...]`). `StatsNotifier` hanya mengganti `state` dengan `AsyncValue` baru. |
| `ref.watch` hanya di `build`, `ref.read` di callback? | Ya. `StatsPage` memakai `watch` di `build`, `read(...notifier).reload()` di `onPressed`. Di notifier, `ref.read` dipakai di dalam method (`_fetchStats`) karena bukan konteks rebuild. |
| Ketiga state `AsyncValue` ditangani? | Ya: `loading` (spinner), `error` (pesan + tombol retry), `data` (ListView 3 item). |
| Provider bertipe eksplisit dan tidak duplikat? | Ya: `AsyncNotifierProvider<StatsNotifier, List<String>>`, plus `statsRandomProvider` dan `statsDelayProvider` yang berbeda tujuan (agar bisa di-override saat test). |
| API lama? | Tidak memakai `StateProvider`, `StateNotifierProvider`, atau `Consumer` bertingkat; memakai `AsyncNotifier` + `ConsumerWidget`. |
| `flutter analyze` dan `flutter test` | **Isi dari hasil run Anda** (saya tidak bisa menjalankan Flutter di lingkungan ini, jadi kode belum pernah dikompilasi). Tempel output-nya di `docs/ai/`. |

Penjelasan desain yang perlu Anda kuasai saat demo:

- Peluang gagal 30% dibuat dengan `Random().nextDouble() < 0.3`. `Random` dan delay dijadikan provider supaya test deterministik dan cepat (`Duration.zero`, `FakeRandom`).
- `AsyncValue.guard` mengubah exception menjadi `AsyncError` tanpa `try/catch`.
- Test mencakup: sukses, error, nilai batas 0.3, pemulihan lewat `reload()`, dan transisi `AsyncLoading`.
- Retry otomatis Riverpod 3.x dimatikan (`retry: (_, __) => null`) di aplikasi maupun di test.
