class Pesanan {
  final int id;
  final String namaCustomer;
  final String status;
  final double hargaJual;
  final String tglDeadline;

  Pesanan({
    required this.id,
    required this.namaCustomer,
    required this.status,
    required this.hargaJual,
    required this.tglDeadline,
  });

  factory Pesanan.fromJson(Map<String, dynamic> json) {
    return Pesanan(
      id: json['ID'],
      namaCustomer: json['customer']['nama'] ?? 'Tanpa Nama',
      status: json['status'] ?? 'Unknown',
      hargaJual: (json['harga_jual'] ?? 0).toDouble(),
      tglDeadline: json['tgl_deadline'] ?? '',
    );
  }
}
