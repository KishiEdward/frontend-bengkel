import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../providers/detail_pesanan_provider.dart';
import '../../screens/detail_screen.dart'; // Untuk CurrencyInputFormatter

class PembayaranDialog {
  static Future<void> show(
    BuildContext context, {
    required int pesananId,
    required double sisaTagihan,
    required String statusPesanan, // TAMBAHAN: Menerima status dari screen
  }) async {
    // ==========================================
    // LOGIKA FILTER TIPE PEMBAYARAN BERDASARKAN STATUS
    // ==========================================
    List<String> listTipe = [];
    String statusLow = statusPesanan.toLowerCase();

    if (statusLow == 'menunggu dp') {
      listTipe = ["DP"];
    } else if (statusLow == 'wip') {
      listTipe = ["Cicilan", "Lunas"];
    } else if (statusLow == 'menunggu pelunasan') {
      listTipe = ["Lunas"];
    } else {
      listTipe = ["DP", "Cicilan", "Lunas"]; // Fallback aman
    }

    String tipePilihan =
        listTipe.first; // Default ke pilihan pertama yang tersedia
    final nominalCtrl = TextEditingController();
    bool isLunas =
        tipePilihan == "Lunas"; // Kunci otomatis jika opsi awalnya Lunas
    File? imageFile;

    final ImagePicker picker = ImagePicker();

    String formatRibuan(double number) {
      return NumberFormat.currency(
        locale: 'id_ID',
        symbol: '',
        decimalDigits: 0,
      ).format(number);
    }

    // Auto-fill nominal jika awal dibuka tipenya sudah Lunas
    if (isLunas) {
      nominalCtrl.text = formatRibuan(sisaTagihan);
    }

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text("Input Pembayaran"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<String>(
                    value: tipePilihan,
                    // Gunakan listTipe yang sudah difilter
                    items: listTipe
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (val) {
                      setState(() {
                        tipePilihan = val!;
                        // LOGIKA AUTO-FILL LUNAS
                        if (tipePilihan == "Lunas") {
                          isLunas = true;
                          nominalCtrl.text = formatRibuan(sisaTagihan);
                        } else {
                          isLunas = false;
                          nominalCtrl.clear();
                        }
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: "Tipe Pembayaran",
                    ),
                  ),
                  const SizedBox(height: 12),

                  TextField(
                    controller: nominalCtrl,
                    keyboardType: TextInputType.number,
                    inputFormatters: [CurrencyInputFormatter()],
                    readOnly: isLunas, // Kunci field jika Lunas
                    decoration: InputDecoration(
                      labelText: "Jumlah (Rp)",
                      border: const OutlineInputBorder(),
                      filled: isLunas,
                      fillColor: isLunas ? Colors.grey.shade200 : Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ===============================
                  // AREA UPLOAD BUKTI BAYAR
                  // ===============================
                  const Text(
                    "Bukti Transfer/Pembayaran:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () async {
                      final XFile? pickedFile = await picker.pickImage(
                        source: ImageSource.gallery,
                        imageQuality: 70,
                      );
                      if (pickedFile != null) {
                        setState(() {
                          imageFile = File(pickedFile.path);
                        });
                      }
                    },
                    child: Container(
                      height: 120,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        border: Border.all(
                          color: Colors.blue.shade200,
                          style: BorderStyle.solid,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: imageFile != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(imageFile!, fit: BoxFit.cover),
                            )
                          : const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.cloud_upload,
                                  color: Colors.blue,
                                  size: 32,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  "Tap untuk Upload Gambar",
                                  style: TextStyle(color: Colors.blue),
                                ),
                              ],
                            ),
                    ),
                  ),
                  if (imageFile != null)
                    TextButton(
                      onPressed: () => setState(() => imageFile = null),
                      child: const Text(
                        "Hapus Gambar",
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Batal"),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (nominalCtrl.text.isEmpty) return;

                  Navigator.pop(context);

                  double nominal = double.parse(
                    nominalCtrl.text.replaceAll('.', ''),
                  );

                  bool sukses =
                      await Provider.of<DetailPesananProvider>(
                        context,
                        listen: false,
                      ).catatPembayaran(
                        pesananId,
                        tipePilihan,
                        nominal,
                        imageFile: imageFile,
                      );

                  if (sukses && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Pembayaran berhasil dicatat"),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                },
                child: const Text("Simpan"),
              ),
            ],
          );
        },
      ),
    );
  }
}
