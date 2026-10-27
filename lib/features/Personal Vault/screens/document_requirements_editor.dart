
import 'package:flutter/material.dart';

class DocumentRequirementsEditor extends StatefulWidget {
  const DocumentRequirementsEditor({
    super.key,
    required this.requirements,
    required this.onChanged,
  });

  final List<String> requirements;
  final ValueChanged<List<String>> onChanged;

  @override
  State<DocumentRequirementsEditor> createState() =>
      _DocumentRequirementsEditorState();
}

class _DocumentRequirementsEditorState
    extends State<DocumentRequirementsEditor> {
  final TextEditingController _inputController =
      TextEditingController();

  static const Color purple = Color(0xFF725763);
static const Color ink = Color(0xFF302B31);
static const Color muted = Color(0xFF776F77);

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  void _addRequirements() {
    final lines = _inputController.text
        .split(RegExp(r'\r?\n'))
        .map(_cleanName)
        .where((name) => name.isNotEmpty);

    final updated = List<String>.from(widget.requirements);
    final existing = updated
        .map((name) => name.toLowerCase())
        .toSet();

    for (final name in lines) {
      if (existing.add(name.toLowerCase())) {
        updated.add(name);
      }
    }

    if (updated.length == widget.requirements.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter at least one new requirement.'),
        ),
      );
      return;
    }

    widget.onChanged(updated);
    _inputController.clear();
  }

  String _cleanName(String value) {
    return value
        .trim()
        .replaceFirst(
          RegExp(r'^[-*\u2022]\s*'),
          '',
        )
        .replaceFirst(
          RegExp(r'^\d+[\.)]\s*'),
          '',
        )
        .trim();
  }

  void _removeRequirement(int index) {
    final updated = List<String>.from(widget.requirements);
    updated.removeAt(index);
    widget.onChanged(updated);
  }

  Future<void> _editRequirement(int index) async {
    final controller = TextEditingController(
      text: widget.requirements[index],
    );

    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Edit Requirement'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 150,
          decoration: const InputDecoration(
            labelText: 'Document name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(
                dialogContext,
                _cleanName(controller.text),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    controller.dispose();

    if (!mounted || result == null || result.isEmpty) return;

    final duplicate = widget.requirements
        .asMap()
        .entries
        .any(
          (entry) =>
              entry.key != index &&
              entry.value.toLowerCase() == result.toLowerCase(),
        );

    if (duplicate) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This requirement already exists.'),
        ),
      );
      return;
    }

    final updated = List<String>.from(widget.requirements);
    updated[index] = result;
    widget.onChanged(updated);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF7F3F4),
            borderRadius: BorderRadius.circular(22),
          ),
          child: TextField(
            controller: _inputController,
            minLines: 4,
            maxLines: 8,
            maxLength: 4000,
            style: const TextStyle(
              fontSize: 13,
              color: ink,
              height: 1.6,
            ),
            decoration: const InputDecoration(
              hintText:
                  'Enter one document per line:\n'
                  'Valid Passport\n'
                  'Bank Statement\n'
                  'Employment Letter',
              hintStyle: TextStyle(
                color: muted,
                height: 1.6,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(18),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: _addRequirements,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add to Checklist'),
            style: FilledButton.styleFrom(
              textStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              backgroundColor: purple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            const Expanded(
              child: Text(
                'YOUR CHECKLIST',
                style: TextStyle(
                  color: ink,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            Text(
              '${widget.requirements.length} documents',
              style: const TextStyle(
                color: purple,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (widget.requirements.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F3F4),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Text(
              'No requirements added yet.\n'
              'Enter document names above to build your checklist.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: muted,
                fontSize: 12,
                height: 1.6,
              ),
            ),
          )
        else
          for (var index = 0;
              index < widget.requirements.length;
              index++)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(17),
                  border: Border.all(
                    color: const Color(0xFFECE3E8),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: Color(0xFFECE3E8),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          color: purple,
                          fontWeight: FontWeight.w800,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.requirements[index],
                        style: const TextStyle(
                          color: ink,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Edit requirement',
                      onPressed: () => _editRequirement(index),
                      icon: const Icon(
                        Icons.edit_outlined,
                        color: purple,
                        size: 19,
                      ),
                    ),
                    IconButton(
                      tooltip: 'Remove requirement',
                      onPressed: () => _removeRequirement(index),
                      icon: const Icon(
                        Icons.close_rounded,
                        color: Color(0xFF9A6C75),
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),
      ],
    );
  }
}
