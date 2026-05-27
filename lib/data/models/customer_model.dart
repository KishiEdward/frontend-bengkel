class CustomerModel {
  final int id;
  final String nama;
  final String alamat;
  final String noTelp;

  CustomerModel({
    required this.id,
    required this.nama,
    required this.alamat,
    required this.noTelp,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['ID'] ?? 0,
      nama: json['nama'] ?? '',
      alamat: json['alamat'] ?? '',
      noTelp: json['no_telp'] ?? '',
    );
  }
}
