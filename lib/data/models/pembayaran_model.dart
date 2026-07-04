class PembayaranModel {
  final int id;
  final String tipe;
  final double jumlah;
  final String tgl;
  final String? buktiBayar; // Tambahan untuk URL gambar bukti transfer

  PembayaranModel({
    required this.id,
    required this.tipe,
    required this.jumlah,
    required this.tgl,
    this.buktiBayar,
  });

  factory PembayaranModel.fromJson(Map<String, dynamic> json) {
    return PembayaranModel(
      id: json['ID'] ?? 0,
      tipe: json['tipe'] ?? '',
      jumlah: (json['jumlah'] ?? 0).toDouble(),
      tgl: json['tgl'] ?? '',
      // Tangkap key 'bukti_bayar' dari JSON backend Golang
      buktiBayar: json['bukti_bayar'],
    );
  }
}
