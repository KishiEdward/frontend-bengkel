import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/customer_provider.dart';
import '../../data/models/customer_model.dart';

class CustomerScreen extends StatefulWidget {
  const CustomerScreen({super.key});

  @override
  State<CustomerScreen> createState() => _CustomerScreenState();
}

class _CustomerScreenState extends State<CustomerScreen> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CustomerProvider>(context, listen: false).fetchCustomer();
    });
  }

  // =========================
  // DIALOG TAMBAH CUSTOMER
  // =========================
  void _showTambahDialog() {
    final namaCtrl = TextEditingController();
    final alamatCtrl = TextEditingController();
    final telpCtrl = TextEditingController();

    List<CustomerModel> similarCustomers = [];

    showDialog(
      context: context,
      builder: (context) {
        final provider = Provider.of<CustomerProvider>(context, listen: false);

        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text("Tambah Customer"),
              content: SingleChildScrollView(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Kolom Form Utama
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: namaCtrl,
                          textCapitalization: TextCapitalization.words,
                          decoration: const InputDecoration(
                            labelText: "Nama Customer",
                          ),
                          onChanged: (val) {
                            setStateDialog(() {
                              if (val.trim().isEmpty) {
                                similarCustomers = [];
                              } else {
                                // LOGIKA PENCARIAN: Hanya huruf AWAL (startsWith)
                                similarCustomers = provider.listCustomer
                                    .where(
                                      (c) => c.nama.toLowerCase().startsWith(
                                        val.toLowerCase(),
                                      ),
                                    )
                                    .take(3) // Batas tampil 3 nama
                                    .toList();
                              }
                            });
                          },
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: alamatCtrl,
                          textCapitalization: TextCapitalization.words,
                          decoration: const InputDecoration(
                            labelText: "Alamat",
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: telpCtrl,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            labelText: "No Telepon",
                          ),
                        ),
                      ],
                    ),

                    // ==========================================
                    // FLOATING WARNING BOX
                    // ==========================================
                    if (similarCustomers.isNotEmpty)
                      Positioned(
                        top: 60, // Mengambang tepat di bawah TextField Nama
                        left: 0,
                        right: 0,
                        child: Material(
                          elevation: 6,
                          borderRadius: BorderRadius.circular(6),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade50,
                              border: Border.all(color: Colors.orange.shade300),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  "Peringatan: Nama serupa sudah ada!",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.deepOrange,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                ...similarCustomers.map(
                                  (c) => Text(
                                    "- ${c.nama} (${c.noTelp.isEmpty ? '-' : c.noTelp})",
                                    // LOGIKA PEMBATAS PANJANG: Titik-titik (Ellipsis)
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Batal"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (namaCtrl.text.isEmpty) return;

                    bool sukses = await provider.tambahCustomer(
                      nama: namaCtrl.text,
                      alamat: alamatCtrl.text,
                      noTelp: telpCtrl.text,
                    );

                    if (!mounted) return;
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          sukses
                              ? "Customer berhasil ditambahkan"
                              : "Gagal menambah customer",
                        ),
                        backgroundColor: sukses ? Colors.green : Colors.red,
                      ),
                    );
                  },
                  child: const Text("Simpan"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // [KODE BUILD DI BAWAH SINI SAMA PERSIS SEPERTI SEBELUMNYA]
    // ... Copy-paste dari file lamamu agar ListView tidak ada yang terhapus ...
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Master Customer",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF005088),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showTambahDialog,
        backgroundColor: const Color(0xFF11caa0),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Cari Customer...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              onChanged: (value) =>
                  setState(() => _searchQuery = value.toLowerCase()),
            ),
          ),
          Expanded(
            child: Consumer<CustomerProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading)
                  return const Center(child: CircularProgressIndicator());
                if (provider.listCustomer.isEmpty)
                  return const Center(child: Text("Belum ada customer"));

                final filteredList = provider.listCustomer.where((customer) {
                  return customer.nama.toLowerCase().contains(_searchQuery);
                }).toList();

                if (filteredList.isEmpty)
                  return const Center(child: Text("Customer tidak ditemukan"));

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredList.length,
                  itemBuilder: (context, index) {
                    CustomerModel customer = filteredList[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFF005088),
                          child: Text(
                            customer.nama[0].toUpperCase(),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(
                          customer.nama,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (customer.alamat.isNotEmpty)
                              Text(customer.alamat),
                            if (customer.noTelp.isNotEmpty)
                              Text(customer.noTelp),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
