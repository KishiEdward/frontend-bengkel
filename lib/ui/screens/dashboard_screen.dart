import 'package:flutter/material.dart';
import 'package:front_bengkel/ui/screens/laporan_screen.dart';
import 'package:front_bengkel/ui/screens/pesanan_screen.dart';
import 'package:provider/provider.dart';

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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PesananProvider>(context, listen: false).fetchPesanan();
    });
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
      body: ListView(
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
          const SizedBox(height: 32),

          // QUICK MENU
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.1,
            children: [
              _buildMenuCard(
                title: "Pesanan",
                icon: Icons.receipt_long,
                color: Colors.blue,
                onTap: () {
                  // ROUTING KE HALAMAN LIST PESANAN YANG BARU
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PesananScreen(),
                    ),
                  );
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
        ],
      ),
    );
  }
}
