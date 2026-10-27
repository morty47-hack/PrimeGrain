import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../services/api_service.dart';

class MpesaPaymentScreen extends StatefulWidget {
  final double? initialAmount;

  const MpesaPaymentScreen({super.key, this.initialAmount});

  @override
  State<MpesaPaymentScreen> createState() => _MpesaPaymentScreenState();
}

class _MpesaPaymentScreenState extends State<MpesaPaymentScreen> {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController amountController = TextEditingController();

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialAmount != null && widget.initialAmount! > 0) {
      amountController.text = widget.initialAmount!.toStringAsFixed(0);
    }
  }

  @override
  void dispose() {
    phoneController.dispose();
    amountController.dispose();
    super.dispose();
  }

  Future<void> sendSTKPush() async {
    final phone = phoneController.text.trim();
    final amount = amountController.text.trim();

    if (phone.isEmpty || amount.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter phone and amount")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final response = await http.post(
        ApiService.stkPushUri,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({
          "phone": phone,
          "amount": int.parse(amount),
        }),
      );

      print("STATUS CODE: ${response.statusCode}");
      print("RAW RESPONSE: ${response.body}");

      // 🚨 FIX: HANDLE EMPTY RESPONSE
      if (response.body.isEmpty) {
        throw Exception("Empty response from server");
      }

      // 🚨 FIX: CHECK IF RESPONSE IS JSON
      final isJson = response.body.trim().startsWith("{");

      if (!isJson) {
        throw Exception("Server error (not JSON): ${response.body}");
      }

      final data = jsonDecode(response.body);

      if (data["ok"] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data["message"] ?? "STK Push sent"),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data["message"] ?? "STK Push failed"),
          ),
        );
      }
    } catch (e) {
      print("STK ERROR: $e");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("M-Pesa Payment")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: "Phone Number (2547XXXXXXXX)",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              readOnly:
                  widget.initialAmount != null && widget.initialAmount! > 0,
              decoration: const InputDecoration(
                labelText: "Amount (KES)",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : sendSTKPush,
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Pay (STK Push)"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
