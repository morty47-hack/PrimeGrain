import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../payments/payments_screen.dart';
import '../shop/cart_screen.dart';
import '../shop/product_details_screen.dart';
import '../transport/transport_screen.dart';
import '../../services/assets_service.dart';
import '../../models/product.dart';

enum UserSegment { customer, retailer, wholesaler, transport }

class HomeScreen extends StatefulWidget {
  static const routeName = '/home';

  final UserSegment initialSegment;

  const HomeScreen({
    super.key,
    this.initialSegment = UserSegment.customer,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  UserSegment _currentSegment = UserSegment.customer;
  late final Future<List<String>> _imagesFuture;

  String _segmentLabel(UserSegment segment) {
    switch (segment) {
      case UserSegment.customer:
        return 'Customers';
      case UserSegment.retailer:
        return 'Retailers';
      case UserSegment.wholesaler:
        return 'Wholesalers';
      case UserSegment.transport:
        return 'Transport';
    }
  }

  @override
  void initState() {
    super.initState();
    _imagesFuture = AssetsService.listProductImages();
    _currentSegment = widget.initialSegment;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: _imagesFuture,
      builder: (context, snapshot) {
        final images = snapshot.data ?? const <String>[];

        final pages = [
          _DashboardView(
            segment: _currentSegment,
            images: images,
            onOpenShop: () => setState(() => _selectedIndex = 1),
            onOpenProduct: (name, price, imagePath) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ProductDetailsScreen(
                    appProductId: '',
                    name: name,
                    segmentLabel: _segmentLabel(_currentSegment),
                    basePrice: price,
                    imagePath: imagePath,
                    description:
                        'High-quality Kenyan grain, cleaned and graded for consistency.',
                    pairing: 'Perfect with your favourite Kenyan staples.',
                  ),
                ),
              );
            },
          ),
          _CatalogView(segment: _currentSegment, images: images),
          const PaymentsScreen(showAppBar: false),
          const _ProfileView(),
        ];

        return Scaffold(
          appBar: AppBar(
            title: const Text('PrimeGrain'),
            centerTitle: true,
            actions: [
              IconButton(
                onPressed: () {
                  _showSegmentPicker(context);
                },
                icon: const Icon(Icons.segment),
                tooltip: 'Switch segment',
              ),
              IconButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const CartScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.shopping_cart_outlined),
                tooltip: 'Cart',
              ),
            ],
          ),
          body: SafeArea(
            child: snapshot.connectionState == ConnectionState.waiting
                ? const Center(child: CircularProgressIndicator())
                : pages[_selectedIndex],
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.shopping_bag_outlined),
                selectedIcon: Icon(Icons.shopping_bag),
                label: 'Shop',
              ),
              NavigationDestination(
                icon: Icon(Icons.payments_outlined),
                selectedIcon: Icon(Icons.payments),
                label: 'Payments',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSegmentPicker(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              const Text(
                'Choose your segment',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              ListTile(
                leading: const Icon(Icons.home_outlined),
                title: const Text('Customer'),
                subtitle: const Text('Households and small buyers'),
                onTap: () {
                  setState(() {
                    _currentSegment = UserSegment.customer;
                  });
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.storefront_outlined),
                title: const Text('Retailer'),
                subtitle: const Text('Shops and mini-markets'),
                onTap: () {
                  setState(() {
                    _currentSegment = UserSegment.retailer;
                  });
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.local_shipping_outlined),
                title: const Text('Wholesaler'),
                subtitle: const Text('Bulk and institutional buyers'),
                onTap: () {
                  setState(() {
                    _currentSegment = UserSegment.wholesaler;
                  });
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.local_shipping),
                title: const Text('Transport'),
                subtitle: const Text('Drivers and delivery partners'),
                onTap: () {
                  setState(() {
                    _currentSegment = UserSegment.transport;
                  });
                  Navigator.of(context).pop();
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }
}

class _DashboardView extends StatelessWidget {
  final UserSegment segment;
  final List<String> images;
  final VoidCallback onOpenShop;
  final void Function(String name, double price, String imagePath) onOpenProduct;

  const _DashboardView({
    required this.segment,
    required this.images,
    required this.onOpenShop,
    required this.onOpenProduct,
  });

  @override
  Widget build(BuildContext context) {
    if (segment == UserSegment.transport) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          child: ListTile(
            leading: const Icon(Icons.local_shipping_outlined),
            title: const Text('Transport options'),
            subtitle: const Text('Set vehicle, driver and carrier details.'),
            trailing: const Icon(Icons.chevron_right),
            onTap: onOpenShop,
          ),
        ),
      );
    }

    return _CatalogView(segment: segment, images: images);
  }
}

class _CatalogView extends StatelessWidget {
  final UserSegment segment;
  final List<String> images;

  const _CatalogView({required this.segment, required this.images});

  double _segmentPrice(double basePrice, UserSegment segment) {
    final adjusted = switch (segment) {
      UserSegment.retailer => basePrice - 5,
      UserSegment.wholesaler => basePrice - 10,
      _ => basePrice,
    };
    return adjusted < 0 ? 0 : adjusted;
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'en_KE', symbol: 'KSh ');

    String segmentLabel;
    String segmentHint;
    switch (segment) {
      case UserSegment.customer:
        segmentLabel = 'Customers';
        segmentHint = 'Best for households buying a few kilos.';
        break;
      case UserSegment.retailer:
        segmentLabel = 'Retailers';
        segmentHint = 'Pre-packed cereals ready for resale.';
        break;
      case UserSegment.wholesaler:
        segmentLabel = 'Wholesalers';
        segmentHint = 'Bulk sacks and pallet pricing.';
        break;
      case UserSegment.transport:
        segmentLabel = 'Transport';
        segmentHint = 'Set vehicle, driver and carrier details.';
        break;
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Shop by segment',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const Spacer(),
              Chip(
                label: Text(segmentLabel),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            segmentHint,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: segment != UserSegment.transport
                ? GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.68,
                    ),
                    itemCount: allProducts.length,
                    itemBuilder: (context, index) {
                      final product = allProducts[index];
                      final effectivePrice =
                          _segmentPrice(product.basePrice, segment);

                      return Card(
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ProductDetailsScreen(
                                  appProductId: product.id,
                                  name: product.name,
                                  segmentLabel: segmentLabel,
                                  basePrice: effectivePrice,
                                  imagePath: product.image,
                                  description: product.description,
                                  pairing: product.pairing,
                                ),
                              ),
                            );
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AspectRatio(
                                aspectRatio: 1.2,
                                child: Image.asset(
                                  product.image,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product.name,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'From ${currency.format(effectivePrice)} per kg',
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      product.description,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Tap to choose kg',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(color: Colors.brown),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  )
                : ListView(
                    children: [
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Text(
                            'Manage delivery details for $segmentLabel accounts.',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Card(
                        child: ListTile(
                          leading: const Icon(Icons.local_shipping_outlined),
                          title: const Text('Transport options'),
                          subtitle: Text(
                            'Set vehicle and driver for $segmentLabel deliveries.',
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => TransportScreen(
                                  segmentLabel: segmentLabel,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _ProfileView extends StatelessWidget {
  const _ProfileView();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your profile',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          const TextField(
            decoration: InputDecoration(
              labelText: 'Full name',
              prefixIcon: Icon(Icons.person_outline),
            ),
          ),
          const SizedBox(height: 12),
          const TextField(
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: 'Phone number',
              prefixIcon: Icon(Icons.phone_outlined),
            ),
          ),
          const SizedBox(height: 12),
          const TextField(
            decoration: InputDecoration(
              labelText: 'County',
              prefixIcon: Icon(Icons.location_city_outlined),
            ),
          ),
        ],
      ),
    );
  }
}

