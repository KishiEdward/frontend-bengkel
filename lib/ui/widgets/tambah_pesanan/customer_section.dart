import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/customer_provider.dart';
import '../../../data/models/customer_model.dart';

class CustomerSection extends StatefulWidget {
  final Function(CustomerModel?) onCustomerSelected;

  const CustomerSection({super.key, required this.onCustomerSelected});

  @override
  State<CustomerSection> createState() => _CustomerSectionState();
}

class _CustomerSectionState extends State<CustomerSection> {
  CustomerModel? selectedCustomer;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CustomerProvider>(context, listen: false).fetchCustomer();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CustomerProvider>(
      builder: (context, provider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "1. Data Pelanggan",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF005088),
              ),
            ),

            const SizedBox(height: 16),

            Autocomplete<CustomerModel>(
              displayStringForOption: (CustomerModel option) => option.nama,
              optionsBuilder: (TextEditingValue textEditingValue) {
                // Jika kolom pencarian kosong, tampilkan semua customer
                if (textEditingValue.text == '') {
                  return provider.listCustomer;
                }
                // Filter berdasarkan nama yang diketik
                return provider.listCustomer.where((CustomerModel option) {
                  return option.nama.toLowerCase().contains(
                    textEditingValue.text.toLowerCase(),
                  );
                });
              },
              onSelected: (CustomerModel selection) {
                setState(() {
                  selectedCustomer = selection;
                });
                // Mengirim data customer yang dipilih ke parent screen
                widget.onCustomerSelected(selection);
              },
              fieldViewBuilder:
                  (
                    context,
                    textEditingController,
                    focusNode,
                    onFieldSubmitted,
                  ) {
                    // Menjaga agar teks nama tetap muncul jika customer sudah terpilih
                    if (selectedCustomer != null &&
                        textEditingController.text.isEmpty) {
                      textEditingController.text = selectedCustomer!.nama;
                    }

                    return TextFormField(
                      controller: textEditingController,
                      focusNode: focusNode,
                      decoration: const InputDecoration(
                        labelText: "Cari & Pilih Customer",
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.search),
                      ),
                      validator: (val) =>
                          selectedCustomer == null ? "Pilih customer" : null,
                      onChanged: (val) {
                        // Jika teks dihapus bersih, reset data pilihan
                        if (val.isEmpty) {
                          setState(() {
                            selectedCustomer = null;
                          });
                          widget.onCustomerSelected(null);
                        }
                      },
                    );
                  },
            ),

            const SizedBox(height: 8),

            if (selectedCustomer != null)
              Card(
                color: Colors.blue[50],

                child: Padding(
                  padding: const EdgeInsets.all(12),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Text(
                        selectedCustomer!.nama,

                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),

                      const SizedBox(height: 4),

                      Text(selectedCustomer!.alamat),

                      const SizedBox(height: 4),

                      Text(selectedCustomer!.noTelp),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
