import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../widgets/primary_button.dart';
import '../../services/cart_manager.dart';

class ProductDetailsScreen extends StatelessWidget {
  final String appProductId;
  final String name;
  final String segmentLabel;
  final double basePrice;
  final String imagePath;
  final String description;
  final String pairing;

  const ProductDetailsScreen({
    super.key,
    required this.appProductId,
    required this.name,
    required this.segmentLabel,
    required this.basePrice,
    required this.imagePath,
    required this.description,
    required this.pairing,
  });

  (double minKg, double maxKg) _kgBounds(String segmentLabel) {
    switch (segmentLabel) {
      case 'Retailers':
        return (5, 500);
      case 'Wholesalers':
        return (100, 100000);
      default:
        return (0.5, 5);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'en_KE', symbol: 'KSh ');
    final (minKg, maxKg) = _kgBounds(segmentLabel);
    final kgController = TextEditingController(text: '1.0');

    return Scaffold(
      appBar: AppBar(
        title: Text(name),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 220,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  colors: [Color(0xFF16794F), Color(0xFFFFB300)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                image: DecorationImage(
                  image: AssetImage(imagePath),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black26,
                    BlendMode.darken,
                  ),
                ),
              ),
              alignment: Alignment.bottomLeft,
              padding: const EdgeInsets.all(16),
              child: Chip(
                label: Text(
                  segmentLabel,
                  style: const TextStyle(color: Colors.white),
                ),
                backgroundColor: Colors.black54,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              name,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  currency.format(basePrice),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'per unit',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: const [
                Icon(Icons.star, color: Colors.amber, size: 20),
                SizedBox(width: 4),
                Text('4.8'),
                SizedBox(width: 4),
                Text('(120 reviews)'),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Product details',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(description),
            const SizedBox(height: 16),
            const Text(
              'Best enjoyed with',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(pairing),
            const SizedBox(height: 16),
            const Text(
              'Minimum order',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              'Min ${minKg.toStringAsFixed(minKg % 1 == 0 ? 0 : 1)}kg • Max ${maxKg.toStringAsFixed(0)}kg',
            ),
            const SizedBox(height: 16),
            const Text(
              'Origin & traceability',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            const Text(
              'Sourced from trusted Kenyan farmers. Each batch includes harvest date and county of origin.',
            ),
            const SizedBox(height: 24),
            const Text(
              'Order quantity (kg)',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            TextField(
              controller: kgController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                hintText: 'Enter kilograms you want',
                prefixIcon: Icon(Icons.scale_outlined),
              ),
            ),
            const SizedBox(height: 16),
            PrimaryButton(
              text: 'Add to cart',
              onPressed: () async {
                final parsed = double.tryParse(kgController.text) ?? 0;
                if (parsed < minKg || parsed > maxKg) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Enter kg between $minKg and $maxKg for $segmentLabel',
                      ),
                    ),
                  );
                  return;
                }

                try {
                  await CartManager.instance.addItemToServer(
                    appProductId: appProductId,
                    name: name,
                    segmentLabel: segmentLabel,
                    unitPrice: basePrice,
                    kg: parsed,
                  );
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Added to cart (saved to database)'),
                    ),
                  );
                } catch (e) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to add to cart: $e'),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

