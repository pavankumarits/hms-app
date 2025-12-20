import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart';
import '../services/database_helper.dart';

class BillingFormScreen extends StatefulWidget {
  final String visitId;
  const BillingFormScreen({super.key, required this.visitId});

  @override
  State<BillingFormScreen> createState() => _BillingFormScreenState();
}

class _BillingFormScreenState extends State<BillingFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  String _status = 'unpaid';
  String _method = 'Cash';

  void _saveBill() async {
    if (_formKey.currentState!.validate()) {
      final db = AppDatabase();
      final newId = const Uuid().v4();
      
      final bill = Bill(
        id: newId,
        visitId: widget.visitId,
        amount: double.tryParse(_amountCtrl.text) ?? 0.0,
        status: _status,
        paymentMethod: _method,
        syncStatus: 'pending',
      );
      
      await db.into(db.bills).insert(bill);
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Generate Bill")),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _amountCtrl,
              decoration: const InputDecoration(labelText: "Total Amount"),
              keyboardType: TextInputType.number,
              validator: (v) => v!.isEmpty ? "Required" : null,
            ),
            DropdownButtonFormField(
              value: _status,
              items: ["unpaid", "paid", "partial"].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (v) => setState(() => _status = v.toString()),
              decoration: const InputDecoration(labelText: "Status"),
            ),
            DropdownButtonFormField(
              value: _method,
              items: ["Cash", "Card", "UPI", "Insurance"].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (v) => setState(() => _method = v.toString()),
              decoration: const InputDecoration(labelText: "Payment Method"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _saveBill, child: const Text("Save Bill"))
          ],
        ),
      ),
    );
  }
}
