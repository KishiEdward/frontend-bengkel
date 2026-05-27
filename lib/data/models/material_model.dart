class MaterialModel {
  final int id;

  final String nama;

  final String satuan;

  final double hargaDefault;

  MaterialModel({
    required this.id,
    required this.nama,
    required this.satuan,
    required this.hargaDefault,
  });

  factory MaterialModel.fromJson(Map<String, dynamic> json) {
    return MaterialModel(
      id: json['ID'] ?? 0,

      nama: json['nama'] ?? '',

      satuan: json['satuan'] ?? '',

      hargaDefault: (json['harga_default'] ?? 0).toDouble(),
    );
  }
}
