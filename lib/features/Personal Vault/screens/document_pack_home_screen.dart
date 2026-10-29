
import 'package:flutter/material.dart';

import 'document_pack_requirements_screen.dart';
import 'saved_document_packs_screen.dart';

class DocumentPackHomeScreen extends StatelessWidget {
  const DocumentPackHomeScreen({super.key});

  static const background = Color(0xFFE9EBF2);
  static const card = Color(0xFFEEF0F6);
  static const purple = Color(0xFF6667FF);
  static const ink = Color(0xFF303344);
  static const muted = Color(0xFF707383);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: ink,
                        ),
                      ),
                      const SizedBox(width: 10),
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
                    ],
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Manage Your Document Packs',
                    style: TextStyle(
                      color: ink,
                      fontSize: 21,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Create a new document pack or access your previously saved packs.',
                    style: TextStyle(
                      color: muted,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 28),
                  _optionCard(
                    context,
                    icon: Icons.create_new_folder_outlined,
                    title: 'Create New Pack',
                    description:
                        'Build a checklist and match documents from your Vault.',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const DocumentPackRequirementsScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 18),
                  _optionCard(
                    context,
                    icon: Icons.folder_open_outlined,
                    title: 'My Saved Packs',
                    description:
                        'View document packs you have already saved.',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const SavedDocumentPacksScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _optionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return Material(
      color: card,
      borderRadius: BorderRadius.circular(28),
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  color: Color(0xFFE5E5FF),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: purple, size: 28),
              ),
              const SizedBox(width: 16),
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
                    const SizedBox(height: 7),
                    Text(
                      description,
                      style: const TextStyle(
                        color: muted,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: purple,
              ),
            ],
          ),
        ),
      ),
    );
  }
}