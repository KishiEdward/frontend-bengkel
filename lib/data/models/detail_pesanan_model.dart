import 'customer_model.dart';
import 'pesanan_material_model.dart';
import 'pembayaran_model.dart';
import 'biaya_tambahan_model.dart';
import 'keuangan_model.dart';

class DetailPesananModel {
  final int id;
  final String status;
  final double hargaJual;
  final String tglOrder;

  final CustomerModel customer;

  final List<PesananMaterial> materials;
  final List<PembayaranModel> pembayarans;
  final List<BiayaTambahanModel> biayaTambahans;

  final KeuanganModel keuangan;

  DetailPesananModel({
    required this.id,
    required this.status,
    required this.hargaJual,
    required this.tglOrder,
    required this.customer,
    required this.materials,
    required this.pembayarans,
    required this.biayaTambahans,
    required this.keuangan,
  });

  factory DetailPesananModel.fromJson(Map<String, dynamic> json) {
    final pesanan = json['pesanan'] ?? {};
    final keuangan = json['keuangan'] ?? {};

    return DetailPesananModel(
      id: pesanan['ID'] ?? 0,
      status: pesanan['status'] ?? '',
      hargaJual: (pesanan['harga_jual'] ?? 0).toDouble(),
      tglOrder: pesanan['tgl_order'] ?? '',

      customer: CustomerModel.fromJson(pesanan['customer'] ?? {}),

      materials: (pesanan['pesanan_material'] as List<dynamic>? ?? [])
          .map((e) => PesananMaterial.fromJson(e))
          .toList(),

      pembayarans: (pesanan['pembayaran'] as List<dynamic>? ?? [])
          .map((e) => PembayaranModel.fromJson(e))
          .toList(),

      biayaTambahans: (pesanan['biaya_tambahan'] as List<dynamic>? ?? [])
          .map((e) => BiayaTambahanModel.fromJson(e))
          .toList(),

      keuangan: KeuanganModel.fromJson(keuangan),
    );
  }
}
