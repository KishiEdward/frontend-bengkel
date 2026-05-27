class PembayaranModel {
  final int id;
  final String tipe;
  final double jumlah;
  final String tgl;

  PembayaranModel({
    required this.id,
    required this.tipe,
    required this.jumlah,
    required this.tgl,
  });

  factory PembayaranModel.fromJson(Map<String, dynamic> json) {
    return PembayaranModel(
      id: json['ID'] ?? 0,
      tipe: json['tipe'] ?? '',
      jumlah: (json['jumlah'] ?? 0).toDouble(),
      tgl: json['tgl'] ?? '',
    );
  }
}
