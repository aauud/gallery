/*
Mata Kuliah   : Mobile Programming
Nama          : Audelia Franetta
NIM           : 825230164
==================================
FITUR WAJIB
- Menampilkan gambar dalam InteractiveViewer
- Zoom (pinch/double-tap) & Pan (geser)
- Mode anotasi: Marker, Freehand Draw, Erase
- Toolbar untuk mode, warna, ketebalan
- Simpan hasil dengan RepaintBoundary

Fitur Bonus (opsional)
- Pilih gambar dari gallery/kamera  --> tidak diimplementasi
- Tambah teks/notes pada gambar     --> tidak diimplementasi
- Simpan langsung ke Gallery/Photos --> kurang paham :( tapi kalau termasuk: hasil anotasi bisa didownload (hanya web)
*/

import 'package:flutter/material.dart';
import 'editor/editor_page.dart'; // sambung ke file editor_page.dart dalam directory editor

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tugas Gallery',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // tujuan halaman diarahkan ke EditorPage di dalam editor_page.dart
      home: const EditorPage(title: 'Gallery Demo - Editor Page'),
    );
  }
}

/*
Materi Pendukung:
  ==============================================
  Materi                        || Sumber
  ==============================================
  Gestures (demo)               || Pertemuan 06 kelas Mobile Programming
  Icons                         || Flutter Doc https://api.flutter.dev/flutter/material/Icons-class.html
  Colors                        || Flutter Doc https://api.flutter.dev/flutter/material/Colors-class.html
  InteractiveViewer             || Flutter Doc https://api.flutter.dev/flutter/widgets/InteractiveViewer-class.html
  Offset                        || LogRocket https://blog.logrocket.com/understanding-offsets-flutter/
  Method Cascades               || Stack Overflow https://stackoverflow.com/questions/17025769/how-do-method-cascades-work-exactly-in-dart
  CustomPainter                 || Flutter Doc https://api.flutter.dev/flutter/rendering/CustomPainter-class.html
  Spacer                        || Flutter Doc https://api.flutter.dev/flutter/widgets/Spacer-class.html
  Slider                        || Flutter Doc https://api.flutter.dev/flutter/material/Slider-class.html
  RepaintBoundary               || Medium https://ms3byoussef.medium.com/optimizing-flutter-ui-with-repaintboundary-2402052224c7
  initState()                   || Medium (blog) https://medium.com/@111anilsahu/flutter-initstate-method-1aaddbf5d625
  SingleTickerProviderStateMixin|| Flutter Doc https://api.flutter.dev/flutter/widgets/SingleTickerProviderStateMixin-mixin.html
*/