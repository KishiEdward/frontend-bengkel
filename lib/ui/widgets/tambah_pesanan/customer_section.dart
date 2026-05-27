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

            DropdownButtonFormField<CustomerModel>(
              initialValue: selectedCustomer,

              items: provider.listCustomer
                  .map(
                    (customer) => DropdownMenuItem(
                      value: customer,

                      child: Text(customer.nama),
                    ),
                  )
                  .toList(),

              onChanged: (value) {
                setState(() {
                  selectedCustomer = value;
                });

                widget.onCustomerSelected(value);
              },

              decoration: const InputDecoration(
                labelText: "Pilih Customer",

                border: OutlineInputBorder(),
              ),
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
