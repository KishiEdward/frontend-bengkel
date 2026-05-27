import 'material_model.dart';

class PesananMaterial {
  final int id;
  final int qty;
  final double hargaSatuan;
  final MaterialModel material;

  PesananMaterial({
    required this.id,
    required this.qty,
    required this.hargaSatuan,
    required this.material,
  });

  factory PesananMaterial.fromJson(Map<String, dynamic> json) {
    return PesananMaterial(
      id: json['ID'] ?? 0,
      qty: json['qty'] ?? 0,
      hargaSatuan: (json['harga_satuan'] ?? 0).toDouble(),
      material: MaterialModel.fromJson(json['material'] ?? {}),
    );
  }
}
