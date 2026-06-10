import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../providers/pesanan_provider.dart';
import 'detail_screen.dart';
import 'tambah_pesan_screen.dart';

class PesananScreen extends StatefulWidget {
  const PesananScreen({super.key});

  @override
  State<PesananScreen> createState() => _PesananScreenState();
}

class _PesananScreenState extends State<PesananScreen> {
  String _selectedFilter = 'Diproses'; // Tab Default

  // Filter Tanggal Default: Bulan & Tahun Saat Ini
  late String _selectedBulan;
  late String _selectedTahun;

  // Variabel Paginasi
  int _currentPage = 1;
  final int _itemsPerPage = 10;

  @override
  void initState() {
    super.initState();
    // Inisialisasi default filter ke "Bulan & Tahun Sekarang"
    _selectedBulan = DateTime.now().month.toString().padLeft(2, '0');
    _selectedTahun = DateTime.now().year.toString();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PesananProvider>(context, listen: false).fetchPesanan();
    });
  }

  String formatRupiah(double number) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(number);
  }

  // Widget Pembuat Tombol Tab
  Widget _buildTab(String title, String filterValue, Color activeColor) {
    bool isActive = _selectedFilter == filterValue;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedFilter = filterValue;
            _currentPage = 1; // Kembali ke hal 1 jika ganti tab
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? activeColor : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.black54,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Daftar Pesanan',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF005088),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Consumer<PesananProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.listPesanan.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          // ==========================================
          // 1. FILTERING DATA
          // ==========================================
          var filteredList = provider.listPesanan.where((p) {
            // Filter Status
            bool matchStatus = false;
            String status = p.status.toLowerCase();
            if (_selectedFilter == 'Diproses') {
              matchStatus = status != 'selesai' && status != 'batal';
            } else if (_selectedFilter == 'Selesai') {
              matchStatus = status == 'selesai';
            } else if (_selectedFilter == 'Batal') {
              matchStatus = status == 'batal';
            }

            // Filter Bulan & Tahun (Mendeteksi Tgl Order ATAU Tgl Deadline)
            bool matchWaktu = true;

            if (_selectedBulan != 'Semua' || _selectedTahun != 'Semua') {
              bool matchOrder = true;
              bool matchDeadline = true;

              // CEK TANGGAL ORDER
              String stringTglOrder = p.tglOrder;
              if (stringTglOrder.length >= 10) {
                String tahunOrder = stringTglOrder.substring(0, 4);
                String bulanOrder = stringTglOrder.substring(5, 7);

                if (_selectedTahun != 'Semua' && tahunOrder != _selectedTahun) {
                  matchOrder = false;
                }
                if (_selectedBulan != 'Semua' && bulanOrder != _selectedBulan) {
                  matchOrder = false;
                }
              } else {
                matchOrder = false;
              }

              // CEK TANGGAL DEADLINE
              String stringTglDeadline = p.tglDeadline;
              if (stringTglDeadline.length >= 10) {
                String tahunDeadline = stringTglDeadline.substring(0, 4);
                String bulanDeadline = stringTglDeadline.substring(5, 7);

                if (_selectedTahun != 'Semua' &&
                    tahunDeadline != _selectedTahun) {
                  matchDeadline = false;
                }
                if (_selectedBulan != 'Semua' &&
                    bulanDeadline != _selectedBulan) {
                  matchDeadline = false;
                }
              } else {
                matchDeadline = false;
              }

              // Lolos jika salah satunya cocok
              matchWaktu = matchOrder || matchDeadline;
            }

            return matchStatus && matchWaktu;
          }).toList();

          // ==========================================
          // 2. SORTING (Pesanan terbaru di paling atas)
          // ==========================================
          filteredList.sort((a, b) => b.id.compareTo(a.id));

          // ==========================================
          // 3. PAGINASI (Maksimal 10 per halaman)
          // ==========================================
          int totalItems = filteredList.length;
          int totalPages = (totalItems / _itemsPerPage).ceil();
          if (totalPages == 0) totalPages = 1;
          if (_currentPage > totalPages) _currentPage = totalPages;

          int startIndex = (_currentPage - 1) * _itemsPerPage;
          int endIndex = startIndex + _itemsPerPage;
          if (endIndex > totalItems) endIndex = totalItems;

          final displayedPesanan = filteredList.sublist(startIndex, endIndex);

          return Column(
            children: [
              // HEADER FILTER (Bulan & Tahun)
              Container(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedBulan,
                        decoration: const InputDecoration(
                          labelText: "Bulan",
                          isDense: true,
                          border: OutlineInputBorder(),
                        ),
                        items:
                            [
                                  "Semua",
                                  "01",
                                  "02",
                                  "03",
                                  "04",
                                  "05",
                                  "06",
                                  "07",
                                  "08",
                                  "09",
                                  "10",
                                  "11",
                                  "12",
                                ]
                                .map(
                                  (e) => DropdownMenuItem(
                                    value: e,
                                    child: Text(
                                      e == "Semua" ? "Semua Bulan" : e,
                                    ),
                                  ),
                                )
                                .toList(),
                        onChanged: (v) => setState(() {
                          _selectedBulan = v!;
                          _currentPage = 1;
                        }),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedTahun,
                        decoration: const InputDecoration(
                          labelText: "Tahun",
                          isDense: true,
                          border: OutlineInputBorder(),
                        ),
                        items: ["Semua", "2024", "2025", "2026", "2027", "2028"]
                            .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)),
                            )
                            .toList(),
                        onChanged: (v) => setState(() {
                          _selectedTahun = v!;
                          _currentPage = 1;
                        }),
                      ),
                    ),
                  ],
                ),
              ),

              // HEADER TAB (Status)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    _buildTab('Diproses', 'Diproses', Colors.blue),
                    const SizedBox(width: 8),
                    _buildTab('Selesai', 'Selesai', Colors.green),
                    const SizedBox(width: 8),
                    _buildTab('Batal', 'Batal', Colors.red),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // LIST PESANAN (Scrollable)
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    await Provider.of<PesananProvider>(
                      context,
                      listen: false,
                    ).fetchPesanan();
                  },
                  child: displayedPesanan.isEmpty
                      ? ListView(
                          children: const [
                            Padding(
                              padding: EdgeInsets.all(32),
                              child: Center(
                                child: Text(
                                  "Tidak ada data pesanan di periode ini.",
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ),
                            ),
                          ],
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          itemCount: displayedPesanan.length,
                          itemBuilder: (context, index) {
                            final pesanan = displayedPesanan[index];
                            return Card(
                              elevation: 2,
                              margin: const EdgeInsets.only(bottom: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(16),
                                title: Text(
                                  "${pesanan.namaCustomer}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 8),
                                    Text(
                                      "Tanggal: ${pesanan.tglOrder.substring(0, 10)}",
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "Harga: ${formatRupiah(pesanan.hargaJual)}",
                                      style: const TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "Status: ${pesanan.status}",
                                      style: TextStyle(
                                        color:
                                            pesanan.status.toLowerCase() ==
                                                'selesai'
                                            ? Colors.green
                                            : pesanan.status.toLowerCase() ==
                                                  'batal'
                                            ? Colors.red
                                            : Colors.orange,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: const Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          DetailScreen(pesananId: pesanan.id),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                ),
              ),

              // ==========================================
              // KONTROL PAGINASI DI BAWAH LAYAR
              // ==========================================
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _currentPage > 1
                          ? () => setState(() => _currentPage--)
                          : null,
                      icon: const Icon(Icons.chevron_left),
                      label: const Text("Prev"),
                    ),
                    Text(
                      "Halaman $_currentPage dari $totalPages",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    ElevatedButton.icon(
                      onPressed: _currentPage < totalPages
                          ? () => setState(() => _currentPage++)
                          : null,
                      icon: const Icon(
                        Icons.chevron_right,
                        size: 0,
                      ), // Menyembunyikan icon default
                      label: const Row(
                        children: [Text("Next "), Icon(Icons.chevron_right)],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF11caa0),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const TambahPesananScreen(),
            ),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
