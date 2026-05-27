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

    final listStatus = ["Menunggu DP", "WIP", "Menunggu Pelunasan", "Selesai"];

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text("Ubah Status"),

            content: DropdownButtonFormField<String>(
              initialValue: listStatus.contains(statusSaatIni)
                  ? statusSaatIni
                  : "Menunggu DP",

              items: listStatus
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
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("Batal"),
              ),

              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);

                  await Provider.of<DetailPesananProvider>(
                    context,
                    listen: false,
                  ).ubahStatusPesanan(pesananId, statusPilihan);
                },
                child: const Text("Update"),
              ),
            ],
          );
        },
      ),
    );
  }
}
