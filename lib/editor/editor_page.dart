import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'models.dart';
import 'painter.dart';
import 'toolbar.dart';
import 'dart:typed_data'; // untuk keperluan download/simpan file
import 'dart:ui' as ui;

import 'dart:html' as html; // Untuk keperluan download/simpan file (hanya web, tidak bisa android)

class EditorPage extends StatefulWidget {
  const EditorPage({super.key, required String title});

  @override
  State<EditorPage> createState() => _EditorPageState();
}
                                                  //  v untuk mendukung jalannya controller AnimationController, nanti perlu ada parameter "vsync: this" karena controllernya 1 itu saja
class _EditorPageState extends State<EditorPage> with SingleTickerProviderStateMixin {

  final GlobalKey _repaintKey = GlobalKey();           // Menandai widget (RepaintBoundary) untuk membatasi lingkup hasil simpan
  final List<Annotation> _annotations = [];            // Menyimpan semua anotasi yang dibuat user
  final TransformationController _transformationController = TransformationController(); // Untuk mengatur zoom dan pan pada InteractiveViewer
  late final AnimationController _animationController; // Untuk animasi saat zoom-in dan zoom-out
  Animation<Matrix4>? _animation;
  Offset? _lastDoubleTap; // untuk menyimpan/mengetahui posisi terakhir double tap
  // Menentukan keadaan awal
  String _mode = 'view';
  Color _color = Colors.black;
  double _annWidth = 5.0;

  // Disarankan setup controller dilakukan dalam initState() agar controller cukup dipanggil 1 kali di awal
  // Baik untuk performa program
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..addListener(() {
        if (_animation != null) {
          _transformationController.value = _animation!.value;
        }
      });
  }
  // seperti kebalikan dari initState(), untuk menutup controller
  @override
  void dispose() {
    _animationController.dispose();
    _transformationController.dispose();
    super.dispose();
  }

  // Ubah posisi koordinat layar ke posisi koordinat gambar yang bisa di-zoom/pan
  Offset _toScene(Offset localPoint) {
    try {
      return _transformationController.toScene(localPoint);
    } catch (e) {
      return localPoint;
    }
  }
  // Memungkinkan penghapusan anotasi tanpa harus klik tepat di anotasi tersebut
  int? _findAnnotationNear(Offset scenePos, {double threshold = 18.0}) {
    for (int i = _annotations.length - 1; i >= 0; i--) {
      final a = _annotations[i];
      if (a.type == AnnotationType.marker) {
        if ((a.point! - scenePos).distance <= threshold) return i;
      } else {
        for (final p in a.points) {
          if ((p - scenePos).distance <= threshold) return i;
        }
      }
    }
    return null;
  }
  // Menyimpan hasil gambar (dalam RepaintBoundary) ke dalam bytes atau png
    // harusnya bisa untuk memilih file lokal juga tapi gagal implementasinya :(
  Future<Uint8List?> _saveToImageBytes() async {
    try {
      final boundary = _repaintKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) { // kalau terjadi kesalahan
      debugPrint('save error: $e');
      return null;
    }
  }
  // Untuk download file di web
  void _downloadWeb(Uint8List bytes, {String filename = 'hasil_edit.png'}) {
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.document.createElement('a') as html.AnchorElement
      ..href = url
      ..download = filename
      ..style.display = 'none';
    html.document.body!.append(anchor);
    anchor.click();
    anchor.remove();
    html.Url.revokeObjectUrl(url);
  }
  // Gesture (lebih sederhana diimplementasi setelah menggunakan InteractiveViewer)
  void _onPanStart(DragStartDetails d) { // saat mulai pan
    if (_mode != 'draw') return;
    final scene = _toScene(d.localPosition);
    setState(() {
      _annotations.add(Annotation.draw(
        points: [scene],
        color: _color,
        annWidth: _annWidth,
      ));
    });
  }
  void _onPanUpdate(DragUpdateDetails d) { // saat menggeserkan layar
    if (_mode != 'draw') return;
    final scene = _toScene(d.localPosition);
    if (_annotations.isNotEmpty && _annotations.last.type == AnnotationType.draw) {
      setState(() => _annotations.last.points.add(scene));
    }
  }
  void _onTapUp(TapUpDetails d) { // saat melepaskan klik
    final scene = _toScene(d.localPosition);
    if (_mode == 'marker') {
      // Tambah marker bintang
      setState(() => _annotations.add(
        Annotation.marker(
          point: scene,
          icon: Icons.star,
          color: _color,
          annWidth: _annWidth,
        ),
      ));
    } else if (_mode == 'erase') { // Hapus anotasi terdekat
      final idx = _findAnnotationNear(scene, threshold: 18.0);
      if (idx != null) setState(() => _annotations.removeAt(idx));
    }
  }
  void _onDoubleTapDown(TapDownDetails details) { // Double tap untuk zoom in/out
    _lastDoubleTap = details.localPosition;
  }
  void _handleDoubleTap() {
    if (_lastDoubleTap == null) return;
    final currentScale = _transformationController.value.getMaxScaleOnAxis();
    final targetScale = (currentScale < 1.8) ? 2.5 : 1.0;
    final scenePoint = _toScene(_lastDoubleTap!);
    // Matrix4 untuk menentukan zoom ke titik di mana double tap dilakukan
    final Matrix4 end = Matrix4.identity()
      ..translate(-scenePoint.dx * (targetScale - 1), -scenePoint.dy * (targetScale - 1))
      ..scale(targetScale);
    _animation = Matrix4Tween(
      begin: _transformationController.value,
      end: end,
    ).animate(CurveTween(curve: Curves.easeOut).animate(_animationController));
    _animationController.forward(from: 0);
  }

  // Membuat sisi UI
  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;
    final editorHeight = media.height * 0.72;
    return Scaffold(
      appBar: AppBar(title: const Text('Tugas Edit Gambar')),
      body: Column(
        children: [
          // Toolbar
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, -2))],
            ),
            child: Column(
              children: [
                ToolBar(
                  mode: _mode,
                  onModeChange: (m) => setState(() => _mode = m),
                  onColorChange: (c) => setState(() => _color = c),
                  onStrokeChange: (w) => setState(() => _annWidth = w),
                  onClear: () => setState(() => _annotations.clear()),
                  onSave: () async {
                    final bytes = await _saveToImageBytes();
                    if (bytes == null) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Penyimpanan gagal')));
                      return;
                    }
                    if (kIsWeb) { // untuk menyesuaikan jika program dijalankan dalam web/android
                      _downloadWeb(bytes, filename: 'hasil_edit.png');
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Hasil edit dalam proses download')));
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Bytes tersimpan: ${bytes.length}')));
                    }
                  },
                  annValue: _annWidth,
                ),
                // Menunjukkan kondisi/status mode,warna,ketebalan yang aktif
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Row(
                    children: [
                      Text('Mode: $_mode', style: const TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(width: 12),
                      const Text('Color:'),
                      const SizedBox(width: 12),
                      CircleAvatar(radius: 8, backgroundColor: _color),
                      const SizedBox(width: 12),
                      Text('Stroke: ${_annWidth.toStringAsFixed(1)}'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Area untuk anotasi
          Expanded(
            child: Center(
              child: RepaintBoundary(
                key: _repaintKey,
                child: Container(
                  color: Colors.grey[200],
                  width: double.infinity,
                  height: editorHeight,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // InteractiveViewer untuk zoom/pan
                      GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onDoubleTapDown: _onDoubleTapDown,
                        onDoubleTap: () {
                          if (_mode == 'view') _handleDoubleTap();
                        },
                        child: InteractiveViewer(
                          transformationController: _transformationController,
                          panEnabled: _mode == 'view',
                          scaleEnabled: _mode == 'view',
                          minScale: 0.5,
                          maxScale: 4.0,
                          child: Image.asset('images/fitness-center.jpg'),
                        ),
                      ),

                      Positioned.fill( // overlay layer untuk menyesuaikan foto, sehingga boundary untuk anotasi fleksibel dengan gambar yang dipilih untuk diedit
                        child: IgnorePointer(
                          ignoring: _mode == 'view', // mengabaikan input jika dalam mode view
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onPanStart: _onPanStart,
                            onPanUpdate: _onPanUpdate,
                            onTapUp: _onTapUp,
                            child: CustomPaint(
                              painter: Painter(_annotations),
                              size: Size.infinite,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}