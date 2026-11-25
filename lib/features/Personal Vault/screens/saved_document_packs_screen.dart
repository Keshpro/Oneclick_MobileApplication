import 'package:flutter/material.dart';

import '../services/document_pack_service.dart';
import 'saved_document_pack_details_screen.dart';

class SavedDocumentPacksScreen extends StatefulWidget {
  const SavedDocumentPacksScreen({super.key});

  @override
  State<SavedDocumentPacksScreen> createState() =>
      _SavedDocumentPacksScreenState();
}

class _SavedDocumentPacksScreenState extends State<SavedDocumentPacksScreen> {
  static const background = Color(0xFFF5F3F2);
  static const card = Color(0xFFFFFDFC);
  static const mauve = Color(0xFF725763);
  static const softMauve = Color(0xFFECE3E8);
  static const ink = Color(0xFF302B31);
  static const muted = Color(0xFF776F77);
  static const green = Color(0xFF47866D);

  late final DocumentPackService _service;
  String? _deletingPackId;
  String _searchQuery = '';

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
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        foregroundColor: ink,
        title: const Text(
          'Saved Document Packs',
          style: TextStyle(
            color: ink,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
            child: Container(
              decoration: BoxDecoration(
                color: card,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFEDE6E9)),
              ),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.trim().toLowerCase();
                  });
                },
                style: const TextStyle(color: ink, fontSize: 13),
                decoration: const InputDecoration(
                  hintText: 'Search saved packs...',
                  hintStyle: TextStyle(color: muted, fontSize: 13),
                  prefixIcon: Icon(Icons.search_rounded, color: mauve),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<SavedDocumentPack>>(
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
                    child: CircularProgressIndicator(color: mauve),
                  );
                }

                final packs = snapshot.data!;

                if (packs.isEmpty) {
                  return _message(
                    Icons.folder_open_outlined,
                    'You have not saved any document packs yet.',
                  );
                }

                final visiblePacks = packs.where((savedPack) {
                  return savedPack.pack.name
                      .toLowerCase()
                      .contains(_searchQuery);
                }).toList();

                if (visiblePacks.isEmpty) {
                  return _message(
                    Icons.search_off_rounded,
                    'No document packs match your search.',
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 6, 20, 30),
                  itemCount: visiblePacks.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final savedPack = visiblePacks[index];
                    final pack = savedPack.pack;
                    final total = pack.totalRequirements;
                    final matched = pack.matchedRequirements;
                    final complete = total > 0 && matched == total;
                    final progress = total > 0
                        ? (matched / total).clamp(0.0, 1.0)
                        : 0.0;

                    return Material(
                      color: card,
                      borderRadius: BorderRadius.circular(24),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(24),
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
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: const Color(0xFFEDE6E9),
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x0C302B31),
                                blurRadius: 18,
                                offset: Offset(0, 7),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: softMauve,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: const Icon(
                                      Icons.folder_copy_outlined,
                                      color: mauve,
                                      size: 25,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          pack.name,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: ink,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          '$matched of $total documents matched · ${complete ? 'Complete' : 'In Progress'}',
                                          style: const TextStyle(
                                            color: muted,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    complete
                                        ? Icons.check_circle_outline
                                        : Icons.info_outline,
                                    color: complete ? green : mauve,
                                    size: 23,
                                  ),
                                  const SizedBox(width: 4),
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
                                              color: mauve,
                                            ),
                                          )
                                        : const Icon(
                                            Icons.delete_outline_rounded,
                                            color: Color(0xFFB96C75),
                                          ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              Row(
                                children: [
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(6),
                                      child: LinearProgressIndicator(
                                        value: progress,
                                        minHeight: 6,
                                        backgroundColor: softMauve,
                                        valueColor:
                                            const AlwaysStoppedAnimation<Color>(mauve),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    '$matched/$total',
                                    style: const TextStyle(
                                      color: muted,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
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
                fontSize: 12,
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
