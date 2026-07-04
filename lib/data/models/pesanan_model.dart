class Pesanan {
  final int id;
  final String namaCustomer;
  final String status;
  final double hargaJual;
  final String tglDeadline;
  final String tglOrder;

  Pesanan({
    required this.id,
    required this.namaCustomer,
    required this.status,
    required this.hargaJual,
    required this.tglDeadline,
    required this.tglOrder,
  });

  factory Pesanan.fromJson(Map<String, dynamic> json) {
    return Pesanan(
      id: json['ID'],
      namaCustomer: json['customer']['nama'] ?? 'Tanpa Nama',
      status: json['status'] ?? 'Unknown',
      hargaJual: (json['harga_jual'] ?? 0).toDouble(),
      tglDeadline: json['tgl_deadline'] ?? '',
      tglOrder: json['tgl_order'] ?? '',
    );
  }
}
