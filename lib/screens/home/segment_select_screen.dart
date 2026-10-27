import 'package:flutter/material.dart';

import 'home_screen.dart';

class SegmentSelectScreen extends StatelessWidget {
  static const routeName = '/segment';

  const SegmentSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose segment'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Shop the way you buy',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
          ),
          const SizedBox(height: 6),
          Text(
            'You can switch later using the segment button on the top bar.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          _SegmentTile(
            icon: Icons.home_outlined,
            title: 'Customers',
            subtitle: 'Households and small buyers',
            onTap: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) =>
                      const HomeScreen(initialSegment: UserSegment.customer),
                ),
              );
            },
          ),
          _SegmentTile(
            icon: Icons.storefront_outlined,
            title: 'Retailers',
            subtitle: 'Shops and mini-markets',
            onTap: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) =>
                      const HomeScreen(initialSegment: UserSegment.retailer),
                ),
              );
            },
          ),
          _SegmentTile(
            icon: Icons.local_shipping_outlined,
            title: 'Wholesalers',
            subtitle: 'Bulk and institutional buyers',
            onTap: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) =>
                      const HomeScreen(initialSegment: UserSegment.wholesaler),
                ),
              );
            },
          ),
          _SegmentTile(
            icon: Icons.local_shipping,
            title: 'Transport',
            subtitle: 'Drivers and delivery partners',
            onTap: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) =>
                      const HomeScreen(initialSegment: UserSegment.transport),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SegmentTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SegmentTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

