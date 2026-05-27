class BiayaTambahanModel {
  final int id;

  final String kategori;

  final String keterangan;

  final double nominal;

  BiayaTambahanModel({
    required this.id,

    required this.kategori,

    required this.keterangan,

    required this.nominal,
  });

  factory BiayaTambahanModel.fromJson(Map<String, dynamic> json) {
    return BiayaTambahanModel(
      id: json['ID'] ?? 0,

      kategori: json['kategori'] ?? 'tambahan',

      keterangan: json['keterangan'] ?? '-',

      nominal: (json['nominal'] ?? 0).toDouble(),
    );
  }
}
