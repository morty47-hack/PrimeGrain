import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../services/session_service.dart';
import '../../widgets/primary_button.dart';
import '../home/segment_select_screen.dart';

class SignUpScreen extends StatefulWidget {
  static const routeName = '/signup';
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _middleNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String _selectedUserType = 'Customer';
  bool _isLoading = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _middleNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('http://localhost/primegrain/api/auth/signup.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'first_name': _firstNameController.text.trim(),
          'middle_name': _middleNameController.text.trim(),
          'last_name': _lastNameController.text.trim(),
          'email': _emailController.text.trim(),
          'password': _passwordController.text,
          'user_type': _selectedUserType,
        }),
      );

      print("STATUS CODE: ${response.statusCode}");
      print("RESPONSE BODY: ${response.body}");

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['ok'] == true) {
        final userId = (data['user_id'] as num?)?.toInt();
        if (userId == null || userId <= 0) {
          throw Exception('Signup succeeded but no user_id was returned');
        }
        await SessionService.setUserId(userId);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account created successfully 🎉')),
        );
        Navigator.of(context)
            .pushReplacementNamed(SegmentSelectScreen.routeName);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['error'] ?? 'Signup failed'),
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

    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Create account')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Card(
            elevation: 4,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Join PrimeGrain',
                      style: theme.textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sign up once, then enjoy daily logins and rewards.',
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(height: 16),

                    // FIRST + MIDDLE NAME
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _firstNameController,
                            decoration: const InputDecoration(
                              labelText: 'First name',
                              prefixIcon: Icon(Icons.person_outline),
                            ),
                            validator: (value) => value == null || value.isEmpty
                                ? 'Enter first name'
                                : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _middleNameController,
                            decoration:
                                const InputDecoration(labelText: 'Middle name'),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // LAST NAME
                    TextFormField(
                      controller: _lastNameController,
                      decoration: const InputDecoration(
                        labelText: 'Last name',
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Enter last name'
                          : null,
                    ),

                    const SizedBox(height: 12),

                    // EMAIL
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!value.contains('@')) {
                          return 'Enter a valid email';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 12),

                    // PASSWORD
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.lock_outline),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Enter a password';
                        }
                        if (value.length < 8) {
                          return 'At least 8 characters required';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 12),

                    // CONFIRM PASSWORD
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Repeat password',
                        prefixIcon: Icon(Icons.lock_outline),
                      ),
                      validator: (value) {
                        if (value != _passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // USER TYPE DROPDOWN
                    DropdownButtonFormField<String>(
                      initialValue: _selectedUserType,
                      decoration: const InputDecoration(
                        labelText: 'Account type',
                        prefixIcon: Icon(Icons.segment),
                      ),
                      items: const [
                        DropdownMenuItem(
                            value: 'Customer', child: Text('Customer')),
                        DropdownMenuItem(
                            value: 'Retailer', child: Text('Retailer')),
                        DropdownMenuItem(
                            value: 'Wholesaler', child: Text('Wholesaler')),
                      ],
                      onChanged: (value) {
                        if (value != null)
                          setState(() => _selectedUserType = value);
                      },
                    ),

                    const SizedBox(height: 20),

                    PrimaryButton(
                      text: 'Sign up',
                      isLoading: _isLoading,
                      onPressed: _isLoading ? null : _handleSignUp,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
