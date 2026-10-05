import 'package:flutter/material.dart';

class AddAccountScreen extends StatefulWidget {
  const AddAccountScreen({super.key});

  @override
  State<AddAccountScreen> createState() => _AddAccountScreenState();
}

class _AddAccountScreenState extends State<AddAccountScreen> {
  static const Color _background = Color(0xFFE9EBF2);
  static const Color _purple = Color(0xFF6961FF);
  static const Color _ink = Color(0xFF303344);
  static const Color _muted = Color(0xFF686C7C);

  final _formKey = GlobalKey<FormState>();

  final _serviceController = TextEditingController();
  final _usernameController = TextEditingController();
  final _recoveryEmailController = TextEditingController();
  final _recoveryPhoneController = TextEditingController();
  final _recoveryInstructionsController = TextEditingController();
  final _notesController = TextEditingController();

  bool _twoFactorEnabled = false;
  bool _hasBackupCodes = false;

  String _category = 'Email';

  final List<String> _categories = [
    'Email',
    'Social Media',
    'Work',
    'Education',
    'Entertainment',
    'Finance',
    'Shopping',
    'Other',
  ];

  @override
  void dispose() {
    _serviceController.dispose();
    _usernameController.dispose();
    _recoveryEmailController.dispose();
    _recoveryPhoneController.dispose();
    _recoveryInstructionsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _saveAccount() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.check_circle_rounded,
                color: _purple,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Account Ready',
                  style: TextStyle(
                    color: _ink,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            '${_serviceController.text.trim()} account access details '
            'are ready to be added to your Vault.',
            style: const TextStyle(
              color: _muted,
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text(
                'Continue Editing',
                style: TextStyle(
                  color: _muted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _purple,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Done'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: _ink,
          ),
        ),
        title: const Text(
          'Add Account Access',
          style: TextStyle(
            color: _ink,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 18, 24, 40),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 680,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),

                    const SizedBox(height: 28),

                    _buildSection(
                      title: 'Account Information',
                      subtitle:
                          'Add the basic information used to identify this account.',
                      child: Column(
                        children: [
                          _buildTextField(
                            controller: _serviceController,
                            label: 'Service or Platform',
                            hint: 'e.g. Gmail, GitHub, Netflix',
                            icon: Icons.apps_rounded,
                            requiredField: true,
                          ),

                          const SizedBox(height: 16),

                          _buildCategoryDropdown(),

                          const SizedBox(height: 16),

                          _buildTextField(
                            controller: _usernameController,
                            label: 'Email or Username',
                            hint: 'Enter login email or username',
                            icon: Icons.alternate_email_rounded,
                            requiredField: true,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    _buildSection(
                      title: 'Recovery Information',
                      subtitle:
                          'Keep the information you may need if you lose access.',
                      child: Column(
                        children: [
                          _buildTextField(
                            controller: _recoveryEmailController,
                            label: 'Recovery Email',
                            hint: 'Optional recovery email',
                            icon: Icons.mark_email_read_outlined,
                            keyboardType: TextInputType.emailAddress,
                          ),

                          const SizedBox(height: 16),

                          _buildTextField(
                            controller: _recoveryPhoneController,
                            label: 'Recovery Phone',
                            hint: 'Optional recovery phone number',
                            icon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                          ),

                          const SizedBox(height: 18),

                          _buildToggleTile(
                            icon: Icons.phonelink_lock_rounded,
                            title: 'Two-Factor Authentication',
                            subtitle:
                                'Mark whether 2FA is enabled for this account.',
                            value: _twoFactorEnabled,
                            onChanged: (value) {
                              setState(() {
                                _twoFactorEnabled = value;
                              });
                            },
                          ),

                          const SizedBox(height: 12),

                          _buildToggleTile(
                            icon: Icons.key_rounded,
                            title: 'Backup Codes Available',
                            subtitle:
                                'Mark whether recovery or backup codes are stored safely.',
                            value: _hasBackupCodes,
                            onChanged: (value) {
                              setState(() {
                                _hasBackupCodes = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    _buildSection(
                      title: 'Recovery Instructions',
                      subtitle:
                          'Write down useful steps for regaining access later.',
                      child: _buildTextField(
                        controller: _recoveryInstructionsController,
                        label: 'Instructions',
                        hint:
                            'e.g. Use recovery email, verify identity, then reset access...',
                        icon: Icons.route_outlined,
                        maxLines: 4,
                      ),
                    ),

                    const SizedBox(height: 18),

                    _buildSection(
                      title: 'Notes',
                      subtitle:
                          'Add any other useful information about this account.',
                      child: _buildTextField(
                        controller: _notesController,
                        label: 'Additional Notes',
                        hint:
                            'e.g. Student account, subscription owner, renewal details...',
                        icon: Icons.notes_rounded,
                        maxLines: 4,
                      ),
                    ),

                    const SizedBox(height: 20),

                    _buildSecurityNotice(),

                    const SizedBox(height: 28),

                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: _saveAccount,
                        icon: const Icon(
                          Icons.lock_outline_rounded,
                          size: 20,
                        ),
                        label: const Text(
                          'Save to Vault',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _purple,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(17),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    const Center(
                      child: Text(
                        'You can edit these details later from your Vault.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _muted,
                          fontSize: 12,
                        ),
                      ),
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

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: _purple.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.shield_outlined,
              color: _purple,
              size: 29,
            ),
          ),
          const SizedBox(width: 17),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Keep account access organized',
                  style: TextStyle(
                    color: _ink,
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 7),
                Text(
                  'Save login identifiers and recovery information so '
                  'important account details are easier to find later.',
                  style: TextStyle(
                    color: _muted,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.58),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: _ink,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            subtitle,
            style: const TextStyle(
              color: _muted,
              fontSize: 12.5,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool requiredField = false,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: const TextStyle(
        color: _ink,
        fontSize: 14,
      ),
      validator: requiredField
          ? (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter $label';
              }
              return null;
            }
          : null,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        alignLabelWithHint: maxLines > 1,
        labelStyle: const TextStyle(
          color: _muted,
        ),
        hintStyle: TextStyle(
          color: _muted.withValues(alpha: 0.65),
          fontSize: 13,
        ),
        prefixIcon: Padding(
          padding: EdgeInsets.only(
            bottom: maxLines > 1 ? 65 : 0,
          ),
          child: Icon(
            icon,
            color: _purple,
            size: 21,
          ),
        ),
        filled: true,
        fillColor: _background.withValues(alpha: 0.60),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 17,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: _ink.withValues(alpha: 0.06),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: _purple,
            width: 1.4,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Colors.redAccent,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Colors.redAccent,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: _category,
      decoration: InputDecoration(
        labelText: 'Category',
        prefixIcon: const Icon(
          Icons.category_outlined,
          color: _purple,
          size: 21,
        ),
        filled: true,
        fillColor: _background.withValues(alpha: 0.60),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: _ink.withValues(alpha: 0.06),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: _purple,
            width: 1.4,
          ),
        ),
      ),
      items: _categories.map((category) {
        return DropdownMenuItem<String>(
          value: category,
          child: Text(category),
        );
      }).toList(),
      onChanged: (value) {
        if (value == null) return;

        setState(() {
          _category = value;
        });
      },
    );
  }

  Widget _buildToggleTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(15, 11, 10, 11),
      decoration: BoxDecoration(
        color: _background.withValues(alpha: 0.58),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _purple.withValues(alpha: 0.09),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: _purple,
              size: 20,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: _ink,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: _muted,
                    fontSize: 11.5,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Colors.white,
            activeTrackColor: _purple,
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityNotice() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _purple.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _purple.withValues(alpha: 0.10),
        ),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: _purple,
            size: 21,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'This screen records account and recovery information. '
              'Sensitive credentials should only be stored after secure '
              'encrypted storage is implemented.',
              style: TextStyle(
                color: _muted,
                fontSize: 12.5,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}