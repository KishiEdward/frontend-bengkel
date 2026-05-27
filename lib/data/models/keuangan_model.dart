class KeuanganModel {
  final double totalBiayaMaterial;

  final double totalBiayaJasa;

  final double totalBiayaTambahan;

  final double hppAktual;

  final double marginAktual;

  final double totalTerbayar;

  final double sisaTagihan;

  KeuanganModel({
    required this.totalBiayaMaterial,

    required this.totalBiayaJasa,

    required this.totalBiayaTambahan,

    required this.hppAktual,

    required this.marginAktual,

    required this.totalTerbayar,

    required this.sisaTagihan,
  });

  factory KeuanganModel.fromJson(Map<String, dynamic> json) {
    return KeuanganModel(
      totalBiayaMaterial: (json['total_biaya_material'] ?? 0).toDouble(),

      totalBiayaJasa: (json['total_biaya_jasa'] ?? 0).toDouble(),

      totalBiayaTambahan: (json['total_biaya_tambahan'] ?? 0).toDouble(),

      hppAktual: (json['hpp_aktual'] ?? 0).toDouble(),

      marginAktual: (json['margin_aktual'] ?? 0).toDouble(),

      totalTerbayar: (json['total_terbayar'] ?? 0).toDouble(),

      sisaTagihan: (json['sisa_tagihan'] ?? 0).toDouble(),
    );
  }
}
