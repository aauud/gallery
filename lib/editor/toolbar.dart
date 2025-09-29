// toolbar.dart menampilkan opsi mode, warna, ketebalan, hapus, dan simpan

import 'package:flutter/material.dart';

class ToolBar extends StatelessWidget {
  final String mode;                    // untuk menentukan mode

  // menggunakan fungsi yang prosedurnya didefinisikan di editor_page.dart
  // untuk ketika menggunakan fitur-fitur
  final Function(String) onModeChange;
  final Function(Color) onColorChange;
  final Function(double) onStrokeChange;
  final VoidCallback onClear;
  final VoidCallback onSave;
  final double annValue;

  // Constructor
  const ToolBar({
    super.key,
    required this.mode,
    required this.onModeChange,
    required this.onColorChange,
    required this.onStrokeChange,
    required this.onClear,
    required this.onSave,
    required this.annValue,
  });

  // Mulai membentuk widget
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade100,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Row(
        children: [
          // Button View
          IconButton(
            tooltip: 'View; Zoom (pinch touchpad/double tap) & Pan (geser)',
            icon: Icon(Icons.pan_tool,
              color: mode == 'view' ? Colors.blue : Colors.black54), // kalau mode ini diipilih, warnanya menjadi biru
            onPressed: () => onModeChange('view'),
          ),
          // Button Draw
          IconButton(
            tooltip: 'Freehand Draw',
            icon: Icon(Icons.brush,
              color: mode == 'draw' ? Colors.blue : Colors.black54),
            onPressed: () => onModeChange('draw'),
          ),
          // Button Marker
          IconButton(
            tooltip: 'Marker Bintang',
            icon: Icon(Icons.star,
              color: mode == 'marker' ? Colors.blue : Colors.black54),
            onPressed: () => onModeChange('marker'),
          ),
          // Slider ketebalan stroke
          const Icon(Icons.line_weight),
          Expanded(
            child: Slider(
              min: 1,   // nilai minimum
              max: 15,  // nilai maksimum
              value: annValue,
              onChanged: (v) => onStrokeChange(v),
            ),
          ),
          // Button Erase
          IconButton(
            tooltip: 'Hapus (klik pada anotasi)',
            icon: Icon(Icons.clear,
              color: mode == 'erase' ? Colors.blue : Colors.black54),
            onPressed: () => onModeChange('erase'),
          ),
          const SizedBox(width: 8), // kasih spasi
          // Opsi warna
          GestureDetector(
            onTap: () => onColorChange(Colors.black),
            child: const Icon(Icons.circle, color: Colors.black),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: () => onColorChange(Colors.red),
            child: const Icon(Icons.circle, color: Colors.red),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: () => onColorChange(Colors.blue),
            child: const Icon(Icons.circle, color: Colors.blue),
          ),
          const Spacer(), // kegunaannya seperti SizedBox, namun langsung mengambil tempat yang kosong
          // Button hapus semua anotasi yang ada
          IconButton(
            tooltip: 'Hapus semua anotasi',
            icon: const Icon(Icons.delete),
            onPressed: onClear,
          ),
          // Button simpan hasil edit dan download (web)
          IconButton(
            tooltip: 'Simpan',
            icon: const Icon(Icons.save),
            onPressed: onSave,
          ),
        ],
      ),
    );
  }
}