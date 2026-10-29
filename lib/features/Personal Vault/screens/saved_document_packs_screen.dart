
import 'package:flutter/material.dart';

import '../services/document_pack_service.dart';
import 'saved_document_pack_details_screen.dart';

class SavedDocumentPacksScreen extends StatefulWidget {
  const SavedDocumentPacksScreen({super.key});

  @override
  State<SavedDocumentPacksScreen> createState() =>
      _SavedDocumentPacksScreenState();
}

class _SavedDocumentPacksScreenState
    extends State<SavedDocumentPacksScreen> {
  static const background = Color(0xFFE9EBF2);
  static const card = Color(0xFFEEF0F6);
  static const purple = Color(0xFF6667FF);
  static const ink = Color(0xFF303344);
  static const muted = Color(0xFF707383);
  static const green = Color(0xFF00A978);

  late final DocumentPackService _service;
  String? _deletingPackId;

  @override
  void initState() {
    super.initState();
    _service = DocumentPackService();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        title: const Text(
          'Saved Document Packs',
          style: TextStyle(
            color: ink,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: StreamBuilder<List<SavedDocumentPack>>(
        stream: _service.getSavedPacks(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _message(
              Icons.error_outline,
              'Unable to load saved document packs.',
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: purple),
            );
          }

          final packs = snapshot.data!;

          if (packs.isEmpty) {
            return _message(
              Icons.folder_open_outlined,
              'You have not saved any document packs yet.',
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: packs.length,
            separatorBuilder: (_, _) =>
                const SizedBox(height: 14),
            itemBuilder: (context, index) {
              final savedPack = packs[index];
              final pack = savedPack.pack;
              final total = pack.totalRequirements;
              final matched = pack.matchedRequirements;

              return InkWell(
                borderRadius: BorderRadius.circular(26),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SavedDocumentPackDetailsScreen(
                        pack: pack,
                      ),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: card,
                  borderRadius: BorderRadius.circular(26),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0xFFD5D7E0),
                      offset: Offset(4, 4),
                      blurRadius: 9,
                    ),
                    BoxShadow(
                      color: Colors.white70,
                      offset: Offset(-3, -3),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 25,
                      backgroundColor:
                          const Color(0xFFE5E5FF),
                      child: const Icon(
                        Icons.folder_copy_outlined,
                        color: purple,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            pack.name,
                            style: const TextStyle(
                              color: ink,
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 7),
                          Text(
                            '$matched of $total documents matched',
                            style: const TextStyle(
                              color: muted,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      total > 0 && matched == total
                          ? Icons.check_circle_outline
                          : Icons.info_outline,
                      color: total > 0 && matched == total
                          ? green
                          : purple,
                    ),                    
                    const SizedBox(width: 8),
                    IconButton(
                      tooltip: 'Delete document pack',
                      onPressed: _deletingPackId != null
                          ? null
                          : () => _confirmDelete(savedPack),
                      icon: _deletingPackId == savedPack.id
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: purple,
                              ),
                            )
                          : const Icon(
                              Icons.delete_outline_rounded,
                              color: Color(0xFFD65A70),
                            ),
                    ),

                        ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _message(IconData icon, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 44, color: muted),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: muted,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
Future<void> _confirmDelete(SavedDocumentPack savedPack) async {
  if (_deletingPackId != null) return;

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Delete Document Pack?'),
      content: Text(
        'Are you sure you want to delete "${savedPack.pack.name}"?\n\n'
        'The original documents in Personal Vault will not be deleted.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          child: const Text(
            'Delete',
            style: TextStyle(color: Colors.red),
          ),
        ),
      ],
    ),
  );

  if (confirmed != true || !mounted) return;

  setState(() {
    _deletingPackId = savedPack.id;
  });

  try {
    await _service.deletePack(savedPack.id);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Document pack deleted successfully.'),
      ),
    );
  } catch (error) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Unable to delete document pack: $error'),
      ),
    );
  } finally {
    if (mounted) {
      setState(() {
        _deletingPackId = null;
      });
    }
  }
}

}
