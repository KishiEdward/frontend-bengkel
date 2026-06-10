import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/detail_pesanan_provider.dart';

class StatusDialog {
  static Future<void> show(
    BuildContext context, {
    required int pesananId,
    required String statusSaatIni,
  }) async {
    String statusPilihan = statusSaatIni;

    // Urutan baku status pesanan + Batal di akhir
    final listSemuaStatus = [
      "Menunggu DP",
      "WIP",
      "Menunggu Pelunasan",
      "Selesai",
      "Batal",
    ];

    // 1. Cari indeks status saat ini
    int currentIndex = listSemuaStatus.indexOf(statusSaatIni);
    if (currentIndex == -1) currentIndex = 0;

    // 2. Logika Daftar Status yang Diizinkan
    List<String> listStatusDiizinkan = [];

    if (statusSaatIni == "Selesai" || statusSaatIni == "Batal") {
      // Jika sudah Selesai/Batal, tidak bisa diubah ke mana-mana lagi
      listStatusDiizinkan = [statusSaatIni];
    } else {
      // Hanya tampilkan status saat ini dan langkah maju selanjutnya (kecuali Batal)
      listStatusDiizinkan = listSemuaStatus
          .sublist(currentIndex)
          .where((e) => e != "Batal")
          .toList();
      // Opsi Batal selalu ada selama belum Selesai
      listStatusDiizinkan.add("Batal");
    }

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text("Ubah Status"),
            content: DropdownButtonFormField<String>(
              value: statusPilihan,
              items: listStatusDiizinkan
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (val) {
                setState(() {
                  statusPilihan = val!;
                });
              },
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Tutup"),
              ),
              // Sembunyikan tombol Update jika status sudah terkunci
              if (statusSaatIni != "Selesai" && statusSaatIni != "Batal")
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: statusPilihan == "Batal"
                        ? Colors.red
                        : Colors.blue,
                  ),
                  onPressed: () async {
                    Navigator.pop(context);

                    await Provider.of<DetailPesananProvider>(
                      context,
                      listen: false,
                    ).ubahStatusPesanan(pesananId, statusPilihan);
                  },
                  child: const Text(
                    "Update",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
