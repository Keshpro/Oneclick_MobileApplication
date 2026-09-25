import 'package:flutter/material.dart';

import 'register_screen.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  String? _selectedRole;

  static const _roles = [
    _RoleOption(
      value: 'patient',
      title: 'Patient',
      description: 'Find doctors and book appointments',
      icon: Icons.personal_injury_outlined,
    ),
    _RoleOption(
      value: 'doctor',
      title: 'Doctor',
      description: 'Manage appointments and your schedule',
      icon: Icons.medical_services_outlined,
    ),
    _RoleOption(
      value: 'passenger',
      title: 'Passenger',
      description: 'Request a safe ride home',
      icon: Icons.person_outline,
    ),
    _RoleOption(
      value: 'driver',
      title: 'Driver',
      description: 'Accept ride requests and help passengers',
      icon: Icons.directions_car_outlined,
    ),
  ];

  void _continue() {
    final role = _selectedRole;
    if (role == null) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RegisterScreen(initialRole: role),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Choose your role')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'How will you use OneClick?',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Select a role to create the right account for you.',
                  ),
                  const SizedBox(height: 20),

                  Expanded(
                    child: ListView.separated(
                      itemCount: _roles.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final option = _roles[index];
                        final selected =
                            _selectedRole == option.value;

                        return Card(
                          clipBehavior: Clip.antiAlias,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                              color: selected
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: InkWell(
                            onTap: () {
                              setState(
                                () => _selectedRole = option.value,
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 24,
                                    child: Icon(option.icon),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          option.title,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(option.description),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    selected
                                        ? Icons.radio_button_checked
                                        : Icons.radio_button_off,
                                    color: selected
                                        ? Theme.of(context)
                                            .colorScheme
                                            .primary
                                        : null,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed:
                        _selectedRole == null ? null : _continue,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      child: Text('Continue'),
                    ),
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

class _RoleOption {
  const _RoleOption({
    required this.value,
    required this.title,
    required this.description,
    required this.icon,
  });

  final String value;
  final String title;
  final String description;
  final IconData icon;
}