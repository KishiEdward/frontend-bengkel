import 'package:flutter/material.dart';
import 'package:front_bengkel/ui/screens/detail_screen.dart';
import 'package:front_bengkel/ui/screens/laporan_screen.dart';
import 'package:front_bengkel/ui/screens/tambah_pesan_screen.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/pesanan_provider.dart';
import 'customer_screen.dart';
import 'material_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

Widget _buildMenuCard({
  required String title,
  required IconData icon,
  required Color color,
  required VoidCallback onTap,
}) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(16),
    child: Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: color,
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    ),
  );
}

class _DashboardScreenState extends State<DashboardScreen> {
  // ==========================================
  // VARIABEL UNTUK MENYIMPAN STATUS FILTER
  // ==========================================
  String _selectedFilter = 'Berlangsung'; // Default yang aktif duluan

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PesananProvider>(context, listen: false).fetchPesanan();
    });
  }

  String formatRupiah(double number) {
    final formatCurrency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatCurrency.format(number);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Dashboard Bengkel',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF005088),
      ),
      body: Consumer<PesananProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.listPesanan.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          // ==========================================
          // LOGIKA FILTER BERDASARKAN TOMBOL YANG DIKLIK
          // ==========================================
          final displayedPesanan = provider.listPesanan.where((p) {
            if (_selectedFilter == 'Berlangsung') {
              return p.status.toLowerCase() != 'selesai';
            } else {
              return p.status.toLowerCase() == 'selesai';
            }
          }).toList();

          return RefreshIndicator(
            onRefresh: () async {
              await Provider.of<PesananProvider>(
                context,
                listen: false,
              ).fetchPesanan();
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  "Dashboard Bengkel",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Monitoring operasional bengkel bubut",
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 24),

                // QUICK MENU
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.2,
                  children: [
                    _buildMenuCard(
                      title: "Pesanan",
                      icon: Icons.receipt_long,
                      color: Colors.blue,
                      onTap: () {
                        Provider.of<PesananProvider>(
                          context,
                          listen: false,
                        ).fetchPesanan();
                      },
                    ),
                    _buildMenuCard(
                      title: "Customer",
                      icon: Icons.people,
                      color: Colors.green,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CustomerScreen(),
                          ),
                        );
                      },
                    ),
                    _buildMenuCard(
                      title: "Material",
                      icon: Icons.inventory,
                      color: Colors.orange,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MaterialScreen(),
                          ),
                        );
                      },
                    ),
                    _buildMenuCard(
                      title: "Laporan",
                      icon: Icons.bar_chart,
                      color: Colors.purple,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LaporanScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // ==========================================
                // TOMBOL FILTER (BERLANGSUNG VS SELESAI)
                // ==========================================
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _selectedFilter = 'Berlangsung';
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _selectedFilter == 'Berlangsung'
                                ? Colors.blue
                                : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              "Diproses",
                              style: TextStyle(
                                color: _selectedFilter == 'Berlangsung'
                                    ? Colors.white
                                    : Colors.black54,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _selectedFilter = 'Selesai';
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _selectedFilter == 'Selesai'
                                ? Colors.blue
                                : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              "Selesai",
                              style: TextStyle(
                                color: _selectedFilter == 'Selesai'
                                    ? Colors.white
                                    : Colors.black54,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // ==========================================
                // LIST PESANAN (TAMPIL SESUAI FILTER AKTIF)
                // ==========================================
                if (displayedPesanan.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text(
                        _selectedFilter == 'Berlangsung'
                            ? "Tidak ada pesanan yang sedang diproses"
                            : "Belum ada riwayat pesanan selesai",
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),

                ...displayedPesanan.map((pesanan) {
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      // Kasih border tipis kalau statusnya selesai biar beda dikit
                      side: _selectedFilter == 'Selesai'
                          ? BorderSide(color: Colors.grey.shade300)
                          : BorderSide.none,
                    ),
                    color: _selectedFilter == 'Selesai'
                        ? Colors.grey.shade50
                        : Colors.white,
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      title: Text(
                        pesanan.namaCustomer,
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
                              color: _selectedFilter == 'Selesai'
                                  ? Colors.grey
                                  : Colors.orange,
                            ),
                          ),
                        ],
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
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
                }),
              ],
            ),
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
