import 'package:flutter/material.dart';

// ✅ FIX: Use full correct path (recommended)
import 'package:primegrain/screens/payments/mpesa_payment_screen.dart';

class PaymentsScreen extends StatefulWidget {
  final bool showAppBar;

  const PaymentsScreen({super.key, this.showAppBar = true});

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  bool _cardEnabled = true;
  bool _codEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.showAppBar
          ? AppBar(title: const Text('Payments'))
          : null,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          // ✅ M-PESA CLICKABLE TILE
          Card(
            child: ListTile(
              leading: const Icon(Icons.phone_iphone_outlined),
              title: const Text('M-Pesa (STK Push)'),
              subtitle: const Text('Pay via Safaricom M-Pesa'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MpesaPaymentScreen(),
                  ),
                );
              },
            ),
          ),

          // ✅ CARD OPTION
          Card(
            child: ListTile(
              leading: const Icon(Icons.credit_card_outlined),
              title: const Text('Debit / Credit Card'),
              trailing: Switch(
                value: _cardEnabled,
                onChanged: (value) {
                  setState(() {
                    _cardEnabled = value;
                  });
                },
              ),
            ),
          ),

          // ✅ CASH OPTION
          Card(
            child: ListTile(
              leading: const Icon(Icons.money_outlined),
              title: const Text('Cash on Delivery'),
              trailing: Switch(
                value: _codEnabled,
                onChanged: (value) {
                  setState(() {
                    _codEnabled = value;
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}