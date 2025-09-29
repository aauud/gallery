// models.dart bertujuan menyimpan tipe data (models) untuk keperluan anotasi.
import 'package:flutter/material.dart';

// karena anotasi gambar ada 2 tipe, dapat dideklarasikan seperti line 5
enum AnnotationType {draw, marker}
// "draw" untuk gambar membentuk garis hasil drag, "marker" untuk menempatkan semacam penanda hasil klik (dalam program ini, menggunakan bintang)
// ditaruh di luar class Annotation karena ditentukan sebagai tipe data global yang dapat digunakan di class lain

class Annotation {
  // 'draw/marker' di line 5 bisa dipanggil dengan jelas misalnya dengan "AnnotationType.draw" saat menentukan tipe anotasi
  // maka dapat dideklarasikan line 12:
  final AnnotationType type;

  final List<Offset> points; // kebutuhan anotasi tipe 'draw', menggunakan List untuk menggambarkan kumpulan titik yang mampu membentuk garis untuk anotasi
  final Offset? point;       // kebutuhan anotasi tipe 'marker', nullable (ditandai dengan '?'), titik/koordinat di mana markernya ditempatkan
  final IconData? icon;      // kebutuhan anotasi tipe 'marker', nullable, menyimpan icon marker (nanti akan menggunakan "star")
  final Color color;         // warna anotasi
  final double annWidth;     // ketebalan anotasi

  // Constructor tipe draw
  Annotation.draw({
    required this.points,
    required this.color,
    required this.annWidth,
  }) : type = AnnotationType.draw, point = null, icon = null; // menentukan tipe dan inisialisasi variabel

  // Constructor tipe marker
  Annotation.marker({
    required Offset this.point,
    required this.icon,
    required this.color,
    required this.annWidth,
  }) : type = AnnotationType.marker, points = const []; // menentukan tipe dan inisialisasi list kosong karena 'points' tidak digunakan
}
