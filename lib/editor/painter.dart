// painter.dart mendefinisikan CustomPainter yang akan digunakan untuk menggambarkan anotasi.
import 'package:flutter/material.dart';
import 'models.dart';

class Painter extends CustomPainter {
  // List menyimpan semua anotasi yang dibuat user
  final List<Annotation> _annotation;

  // Constructor
  Painter(this._annotation);

  // Methods
  @override
  void paint(Canvas canvas, Size size) {
    // Loop penempatan titik/anotasi untuk membentuk gambar
    for (final ann in _annotation) { // untuk mengisi Path() di line 24
      if (ann.type == AnnotationType.draw) { // untuk freehand draw
        final paint = Paint()
          ..color = ann.color              // penulisan lebih singkat dari "paint.color = ann.color;"
          ..strokeWidth = ann.annWidth
          ..style = PaintingStyle.stroke;

        if (ann.points.isNotEmpty) {
          final path = Path(); // untuk tracking path/mengikuti input gerak user
          path.moveTo(ann.points.first.dx, ann.points.first.dy); // mulai dari titik pertama
          for (int i = 1; i < ann.points.length; i++) {
            path.lineTo(ann.points[i].dx, ann.points[i].dy); // terus-menerus sambung titik itu ke titik berikutnya sehingga membentuk garis
          }
          canvas.drawPath(path, paint); // memunculkan anotasi
        }
      } else if (ann.type == AnnotationType.marker) { // untuk marker
        if (ann.point != null && ann.icon != null) {
          final icon = ann.icon!;
          final textStyle = TextStyle(
            fontSize: ann.annWidth * 3.0,
            color: ann.color,
            fontFamily: icon.fontFamily,
          );
          final tp = TextPainter( // untuk kebutuhan pengunaan icon
            text: TextSpan(
              text: String.fromCharCode(icon.codePoint),
              style: textStyle,
            ),
            textDirection: TextDirection.ltr,
          );
          tp.layout(); // mengakses nilai tp.width dan tp.height
          tp.paint(canvas, ann.point! - Offset(tp.width / 2, tp.height / 2)); // dari materi pendukung tentang Offset
        }
      }
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
  // format mengikuti Flutter Doc tentang CustomPainter
  // lakukan repaint setiap ada perubahan
}