import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../payments/mpesa_payment_screen.dart';
import '../../services/cart_manager.dart';
import '../../widgets/primary_button.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late Future<void> _loadFuture;

  @override
  void initState() {
    super.initState();
    _loadFuture = CartManager.instance.refreshFromServer();
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'en_KE', symbol: 'KSh ');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: () {
              setState(() {
                _loadFuture = CartManager.instance.refreshFromServer();
              });
            },
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            tooltip: 'Clear cart',
            onPressed: () async {
              await CartManager.instance.clearServer();
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cart cleared (database updated)')),
              );
            },
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: FutureBuilder<void>(
        future: _loadFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          return ValueListenableBuilder(
            valueListenable: CartManager.instance.items,
            builder: (context, items, _) {
              final total = CartManager.instance.total;

              if (items.isEmpty) {
                return const Center(
                  child: Text('Your cart is empty'),
                );
              }

              return Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return Card(
                          child: ListTile(
                            leading: const Icon(Icons.grain_outlined),
                            title: Text(item.name),
                            subtitle: Text(
                              '${item.segmentLabel} • ${item.kg.toStringAsFixed(1)} kg x ${currency.format(item.unitPrice)}',
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(currency.format(item.total)),
                                IconButton(
                                  tooltip: 'Remove item',
                                  onPressed: () async {
                                    await CartManager.instance.removeItemFromServer(
                                      productId: item.productId,
                                    );
                                    if (!context.mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Item removed from cart'),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.delete_outline),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          offset: const Offset(0, -2),
                          blurRadius: 8,
                          color: Colors.black.withValues(alpha: 0.05),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total to pay',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            Text(
                              currency.format(total),
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        PrimaryButton(
                          text: 'Proceed to checkout',
                          onPressed: () {
                            if (total <= 0) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Your cart is empty'),
                                ),
                              );
                              return;
                            }
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => MpesaPaymentScreen(
                                  initialAmount: total,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

