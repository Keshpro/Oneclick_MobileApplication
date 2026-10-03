import 'package:flutter/material.dart';

class DocumentPackExportScreen extends StatelessWidget {
  const DocumentPackExportScreen({super.key});

  static const background = Color(0xFFE9EBF2);
  static const card = Color(0xFFEEF0F6);
  static const purple = Color(0xFF6667FF);
  static const ink = Color(0xFF303344);
  static const muted = Color(0xFF707383);
  static const green = Color(0xFF00A978);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 50),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _header(context),
                  const SizedBox(height: 18),
                  _progress(),
                  const SizedBox(height: 28),
                  _readyCard(),
                  const SizedBox(height: 28),

                  const Text(
                    'Pack Contents',
                    style: TextStyle(
                      color: ink,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 16),

                  _document(
                    'Valid Passport',
                    'US_Passport_2030.pdf',
                  ),

                  const SizedBox(height: 12),

                  _document(
                    'Proof of Accommodation',
                    'Apartment_Lease_Agreement_2025.pdf',
                  ),

                  const SizedBox(height: 12),

                  _document(
                    'Travel Health Insurance',
                    'International_Health_Policy_2025.pdf',
                  ),

                  const SizedBox(height: 12),

                  _document(
                    'Bank Statement',
                    'Bank_Statement_Jan_2025.pdf',
                  ),

                  const SizedBox(height: 28),

                  _packName(),

                  const SizedBox(height: 28),

                  const Text(
                    'Export Options',
                    style: TextStyle(
                      color: ink,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 16),

                  _exportOption(
                    context,
                    icon: Icons.folder_zip_outlined,
                    title: 'Encrypted ZIP',
                    description:
                        'Download all selected documents as one protected package.',
                    button: 'Download ZIP',
                  ),

                  const SizedBox(height: 18),

                  _exportOption(
                    context,
                    icon: Icons.link_rounded,
                    title: 'Secure Share Link',
                    description:
                        'Create a controlled link for the complete document pack.',
                    button: 'Create Secure Link',
                  ),

                  const SizedBox(height: 22),

                  _saveButton(context),

                  const SizedBox(height: 15),

                  Center(
                    child: TextButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(
                        Icons.arrow_back_rounded,
                        color: muted,
                      ),
                      label: const Text(
                        'Back to Gap Resolution',
                        style: TextStyle(color: muted),
                      ),
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

  Widget _header(BuildContext context) {
    return Row(
      children: [
        _circle(
          Icons.arrow_back_ios_new_rounded,
          () => Navigator.pop(context),
        ),
        const SizedBox(width: 16),
        const Expanded(
          child: Text(
            'Document Pack Builder',
            style: TextStyle(
              color: ink,
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        _circle(Icons.more_vert, () {}),
      ],
    );
  }

  Widget _progress() {
    return _surface(
      child: Column(
        children: [
          const Row(
            children: [
              Text(
                '● Step 4 of 4',
                style: TextStyle(
                  color: purple,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Spacer(),
              Text(
                'Ready to Export',
                style: TextStyle(
                  color: ink,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          Row(
            children: [
              _step('✓', 'Requisite', false),
              _line(),
              _step('✓', 'Matches', false),
              _line(),
              _step('✓', 'Gaps', false),
              _line(),
              _step('4', 'Export', true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _readyCard() {
    return _surface(
      child: const Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Color(0xFFE2F7F0),
            child: Icon(
              Icons.check_circle_outline,
              color: green,
              size: 31,
            ),
          ),

          SizedBox(width: 17),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'All 4 Requirements Satisfied',
                  style: TextStyle(
                    color: ink,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Your pack is ready for final review and export.',
                  style: TextStyle(
                    color: muted,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _document(
    String requirement,
    String file,
  ) {
    return _surface(
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Color(0xFFE2F7F0),
            child: Icon(
              Icons.check_rounded,
              color: green,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  requirement,
                  style: const TextStyle(
                    color: ink,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  file,
                  style: const TextStyle(
                    color: muted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          const Icon(
            Icons.description_outlined,
            color: purple,
          ),
        ],
      ),
    );
  }

  Widget _packName() {
    return _surface(
      child: const Row(
        children: [
          Icon(
            Icons.folder_copy_outlined,
            color: purple,
            size: 28,
          ),
          SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PACK NAME',
                  style: TextStyle(
                    color: muted,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Schengen Visa & Residency',
                  style: TextStyle(
                    color: ink,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.edit_outlined,
            color: purple,
          ),
        ],
      ),
    );
  }

  Widget _exportOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required String button,
  }) {
    return _surface(
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F2F7),
                  shape: BoxShape.circle,
                  boxShadow: _shadow(),
                ),
                child: Icon(
                  icon,
                  color: purple,
                ),
              ),

              const SizedBox(width: 15),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: ink,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      description,
                      style: const TextStyle(
                        color: muted,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          InkWell(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '$button will be connected to backend functionality later.',
                  ),
                ),
              );
            },
            borderRadius: BorderRadius.circular(25),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F1F6),
                borderRadius: BorderRadius.circular(25),
                boxShadow: _shadow(),
              ),
              child: Text(
                button,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: purple,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _saveButton(BuildContext context) {
    return InkWell(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Document pack saved to Vault for this demo.',
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(30),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F1F6),
          borderRadius: BorderRadius.circular(30),
          boxShadow: _shadow(),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bookmark_add_outlined,
              color: purple,
            ),
            SizedBox(width: 9),
            Text(
              'Save Pack to Vault',
              style: TextStyle(
                color: purple,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _step(
    String number,
    String label,
    bool active,
  ) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color:
                  active ? purple : const Color(0xFFF1F2F7),
              boxShadow: _shadow(),
            ),
            child: Text(
              number,
              style: TextStyle(
                color: active ? Colors.white : purple,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: active ? purple : muted,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _line() {
    return Container(
      width: 18,
      height: 3,
      color: purple,
    );
  }

  Widget _surface({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(30),
        boxShadow: _shadow(),
      ),
      child: child,
    );
  }

  Widget _circle(
    IconData icon,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: const Color(0xFFF0F1F6),
          shape: BoxShape.circle,
          boxShadow: _shadow(),
        ),
        child: Icon(icon, color: ink),
      ),
    );
  }

  static List<BoxShadow> _shadow() {
    return const [
      BoxShadow(
        color: Colors.white70,
        offset: Offset(-3, -3),
        blurRadius: 8,
      ),
      BoxShadow(
        color: Color(0xFFD5D7E0),
        offset: Offset(4, 4),
        blurRadius: 9,
      ),
    ];
  }
}