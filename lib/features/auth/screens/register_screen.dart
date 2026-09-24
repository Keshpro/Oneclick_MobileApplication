import 'package:flutter/material.dart';
import '../../../shared/models/user_model.dart';
import 'pending_approval_screen.dart';

class RegisterScreen extends StatefulWidget {
  final UserRole? selectedRole;

  const RegisterScreen({Key? key, this.selectedRole}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  late UserRole _role;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _role = widget.selectedRole ?? UserRole.patient;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // TODO: Firebase Auth / Backend එක හරහා Register කිරීම සිදුකරන්න.
      // Register වෙන ඕනෑම User කෙනෙකුගේ මුලික Status එක `AccountStatus.pending` විය යුතුය.

      await Future.delayed(const Duration(seconds: 1)); // Mock Network Call

      if (!mounted) return;

      // Registration එකෙන් පසුව Pending Screen එකට යැවීම
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const PendingApprovalScreen()),
        (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ලියාපදිංචිය අසාර්ථකයි: ${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Register as ${_role.name.toUpperCase()}')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'සම්පූර්ණ නම',
                      border: OutlineInputBorder(),
                    ),
                    validator: (val) => val == null || val.isEmpty ? 'නම ඇතුළත් කරන්න' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                    validator: (val) => val == null || val.isEmpty ? 'Email එක ඇතුළත් කරන්න' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                    ),
                    validator: (val) => val == null || val.length < 6 ? 'අවම වශයෙන් අකුරු 6ක් තිබිය යුතුය' : null,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _handleRegister,
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('ලියාපදිංචි වන්න'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}