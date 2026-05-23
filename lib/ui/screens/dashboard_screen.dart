import 'package:flutter/material.dart';
import 'package:front_bengkel/ui/screens/detail_screen.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/pesanan_provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Ambil data dari backend saat halaman pertama kali dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PesananProvider>(context, listen: false).fetchPesanan();
    });
  }

  // Format angka jadi Rupiah
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
      // RefreshIndicator untuk fitur Pull-to-Refresh
      body: RefreshIndicator(
        onRefresh: () async {
          await Provider.of<PesananProvider>(
            context,
            listen: false,
          ).fetchPesanan();
        },
        child: Consumer<PesananProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading && provider.listPesanan.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (provider.errorMessage.isNotEmpty &&
                provider.listPesanan.isEmpty) {
              return Center(
                child: Text(
                  provider.errorMessage,
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }

            if (provider.listPesanan.isEmpty) {
              return const Center(child: Text("Belum ada pesanan masuk."));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.listPesanan.length,
              itemBuilder: (context, index) {
                final pesanan = provider.listPesanan[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
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
                          style: const TextStyle(color: Colors.orange),
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
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF11caa0),
        onPressed: () {},
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
