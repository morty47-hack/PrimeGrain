import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TransportScreen extends StatefulWidget {
  final String segmentLabel;

  const TransportScreen({super.key, required this.segmentLabel});

  @override
  State<TransportScreen> createState() => _TransportScreenState();
}

class _TransportScreenState extends State<TransportScreen> {
  final _formKey = GlobalKey<FormState>();

  final _vehicleController = TextEditingController();
  final _driverController = TextEditingController();
  final _driverPhoneController = TextEditingController();
  final _carrierController = TextEditingController();

  String _transportType = 'Private';

  final String baseUrl = 'http://localhost/primegrain/api/transport/save.php';

  @override
  void dispose() {
    _vehicleController.dispose();
    _driverController.dispose();
    _driverPhoneController.dispose();
    _carrierController.dispose();
    super.dispose();
  }

  // ✅ SAVE & SEND TO BACKEND
  void _save() async {
    if (!_formKey.currentState!.validate()) return;

    final url = Uri.parse('$baseUrl/transport.php');

    try {
      final response = await http.post(
        url,
        body: {
          'vehicle': _vehicleController.text.trim(),
          'driver': _driverController.text.trim(),
          'phone': _driverPhoneController.text.trim(),
          'type': _transportType,
          'carrier':
              _transportType == 'Public' ? _carrierController.text.trim() : '',
        },
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transport synced successfully'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Server error: ${response.statusCode}'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Connection error: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPublic = _transportType == 'Public';

    return Scaffold(
      appBar: AppBar(
        title: Text('Transport • ${widget.segmentLabel}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Vehicle & driver',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),

              // 🚗 Vehicle
              TextFormField(
                controller: _vehicleController,
                decoration: const InputDecoration(
                  labelText: 'Vehicle number plate',
                  hintText: 'e.g. KDA 123A',
                  prefixIcon: Icon(Icons.directions_car_outlined),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter the vehicle registration number';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 12),

              // 👤 Driver
              TextFormField(
                controller: _driverController,
                decoration: const InputDecoration(
                  labelText: 'Driver full name',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter the driver name';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 12),

              // 📞 Phone
              TextFormField(
                controller: _driverPhoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Driver phone number',
                  hintText: 'e.g. 07XXXXXXXX',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter the driver phone number';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // 🚚 Transport Type
              const Text(
                'Transport type',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),

              DropdownButtonFormField<String>(
                initialValue: _transportType,
                items: const [
                  DropdownMenuItem(
                    value: 'Private',
                    child: Text('Private vehicle'),
                  ),
                  DropdownMenuItem(
                    value: 'Public',
                    child: Text('Public / 3rd party carrier'),
                  ),
                ],
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    _transportType = value;
                  });
                },
              ),

              const SizedBox(height: 12),

              // 🚛 Carrier (only if Public)
              if (isPublic)
                TextFormField(
                  controller: _carrierController,
                  decoration: const InputDecoration(
                    labelText: 'Carrier company name',
                    hintText: 'e.g. G4S, Fargo Courier',
                    prefixIcon: Icon(Icons.local_shipping_outlined),
                  ),
                  validator: (value) {
                    if (isPublic && (value == null || value.isEmpty)) {
                      return 'Enter the carrier company name';
                    }
                    return null;
                  },
                ),

              const SizedBox(height: 24),

              // 💾 Save Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _save,
                  child: const Text('Save transport'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
