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

    showDialog(
      context: context,

      builder: (context) {
        return AlertDialog(
          title: const Text("Tambah Customer"),

          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,

              children: [
                TextField(
                  controller: namaCtrl,

                  decoration: const InputDecoration(labelText: "Nama Customer"),
                ),

                const SizedBox(height: 12),

                TextField(
                  controller: alamatCtrl,

                  decoration: const InputDecoration(labelText: "Alamat"),
                ),

                const SizedBox(height: 12),

                TextField(
                  controller: telpCtrl,

                  keyboardType: TextInputType.phone,

                  decoration: const InputDecoration(labelText: "No Telepon"),
                ),
              ],
            ),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Batal"),
            ),

            ElevatedButton(
              onPressed: () async {
                if (namaCtrl.text.isEmpty) {
                  return;
                }

                bool sukses =
                    await Provider.of<CustomerProvider>(
                      context,
                      listen: false,
                    ).tambahCustomer(
                      nama: namaCtrl.text,

                      alamat: alamatCtrl.text,

                      noTelp: telpCtrl.text,
                    );

                if (!mounted) return;

                // ignore: use_build_context_synchronously
                Navigator.pop(context);

                // ignore: use_build_context_synchronously
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
  }

  @override
  Widget build(BuildContext context) {
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

      body: Consumer<CustomerProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.listCustomer.isEmpty) {
            return const Center(child: Text("Belum ada customer"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),

            itemCount: provider.listCustomer.length,

            itemBuilder: (context, index) {
              CustomerModel customer = provider.listCustomer[index];

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
                      if (customer.alamat.isNotEmpty) Text(customer.alamat),

                      if (customer.noTelp.isNotEmpty) Text(customer.noTelp),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
