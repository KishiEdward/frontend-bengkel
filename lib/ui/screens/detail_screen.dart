import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../providers/detail_pesanan_provider.dart';
import '../../data/models/detail_pesanan_model.dart';

import '../widgets/details/info_customer_card.dart';
import '../widgets/details/material_card.dart';
import '../widgets/details/biaya_tambahan_card.dart';
import '../widgets/details/margin_card.dart';
import '../widgets/details/pembayaran_card.dart';
import '../widgets/dialogs/status_dialog.dart';
import '../widgets/dialogs/pembayaran_dialog.dart';
import '../widgets/dialogs/biaya_tambahan_dialog.dart';

class DetailScreen extends StatefulWidget {
  final int pesananId;

  const DetailScreen({super.key, required this.pesananId});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DetailPesananProvider>(
        context,
        listen: false,
      ).fetchDetailPesanan(widget.pesananId);
    });
  }

  // =========================
  // DIALOG PEMBAYARAN (Tambahan parameter sisa tagihan)
  // =========================
  void tampilDialogPembayaran(
    BuildContext context,
    int pesananId,
    double sisaTagihan,
    String statusPesanan, // TAMBAHAN: Menerima status dari screen
  ) {
    PembayaranDialog.show(
      context,
      pesananId: pesananId,
      sisaTagihan: sisaTagihan,
      statusPesanan: statusPesanan,
    );
  }

  void tampilDialogBiayaTambahan(BuildContext context, int pesananId) {
    BiayaTambahanDialog.show(context, pesananId: pesananId);
  }

  void tampilDialogUbahStatus(
    BuildContext context,
    int pesananId,
    String statusSaatIni,
  ) {
    StatusDialog.show(
      context,
      pesananId: pesananId,
      statusSaatIni: statusSaatIni,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Detail Pesanan")),
      body: Consumer<DetailPesananProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage.isNotEmpty) {
            return Center(child: Text(provider.errorMessage));
          }

          if (provider.detailPesanan == null) {
            return const Center(child: Text("Data tidak ditemukan"));
          }

          final DetailPesananModel detail = provider.detailPesanan!;

          // Mengambil status saat ini (dibuat lowercase untuk pengecekan aman)
          final String statusLow = detail.status.toLowerCase();

          // Logika Disable Button
          final bool isSelesai = statusLow == 'selesai';
          final bool isBatal = statusLow == 'batal';
          final bool isWIP = statusLow == 'wip';

          // Jika Selesai atau Batal, semua tombol aksi mati (disabled)
          final bool isLocked = isSelesai || isBatal;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                InfoCustomerCard(detail: detail),
                const SizedBox(height: 16),
                MaterialCard(detail: detail),
                const SizedBox(height: 16),
                BiayaTambahanCard(detail: detail),
                const SizedBox(height: 16),
                MarginCard(detail: detail),
                const SizedBox(height: 16),
                PembayaranCard(detail: detail),
                const SizedBox(height: 24),

                // =====================
                // ACTION BUTTONS
                // =====================
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        // Terkunci jika sudah Selesai atau Batal
                        onPressed: isLocked
                            ? null
                            : () {
                                tampilDialogUbahStatus(
                                  context,
                                  detail.id,
                                  detail.status,
                                );
                              },
                        icon: const Icon(Icons.edit),
                        label: const Text("Status"),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        // Hanya aktif jika status sedang "WIP"
                        onPressed: isWIP
                            ? () {
                                tampilDialogBiayaTambahan(context, detail.id);
                              }
                            : null,
                        icon: const Icon(Icons.money_off),
                        label: const Text("Biaya Tambahan"),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    // Terkunci jika sudah Selesai atau Batal
                    onPressed: isLocked
                        ? null
                        : () {
                            tampilDialogPembayaran(
                              context,
                              detail.id,
                              detail.keuangan.sisaTagihan,
                              detail.status,
                            );
                          },
                    icon: const Icon(Icons.payments),
                    label: const Text("Catat Pembayaran"),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue.copyWith(text: '');
    String numericOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (numericOnly.isEmpty) return newValue.copyWith(text: '');
    final format = NumberFormat.currency(
      locale: 'id_ID',
      symbol: '',
      decimalDigits: 0,
    );
    String formatted = format.format(int.parse(numericOnly));
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
