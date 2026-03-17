import 'package:flutter/material.dart';

import '../models/landing_item.dart';

/// Home screen announcement board.
class LandingPage extends StatelessWidget {
  const LandingPage({
    super.key,
    required this.items,
    required this.canManage,
    required this.onCreate,
    required this.onUpdate,
    required this.onDelete,
  });

  final List<LandingItem> items;
  final bool canManage;
  final Future<void> Function(Map<String, dynamic>) onCreate;
  final Future<void> Function(int id, Map<String, dynamic>) onUpdate;
  final Future<void> Function(int id) onDelete;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 760;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HeaderPanel(
              canManage: canManage,
              onAdd: () => _showLandingDialog(context, onSave: onCreate),
              isMobile: isMobile,
            ),
            const SizedBox(height: 10),
            Expanded(
              child: items.isEmpty
                  ? const Card(
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: Text('No announcements yet.'),
                        ),
                      ),
                    )
                  : ListView.separated(
                      itemCount: items.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final item = items[index];
                        final accent = _typeColor(item.type);

                        return Container(
                          decoration: BoxDecoration(
                            color: Color.alphaBlend(
                              accent.withValues(alpha: 0.03),
                              Colors.white,
                            ),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: const Color(0xFFC1D1E4),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 6,
                                decoration: BoxDecoration(
                                  color: accent,
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    bottomLeft: Radius.circular(10),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.all(isMobile ? 10 : 12),
                                  child: isMobile
                                      ? Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            if (item.type.toLowerCase() !=
                                                'announcement') ...[
                                              _typeBadge(item.type),
                                              const SizedBox(height: 10),
                                            ],
                                            _content(item),
                                            if (canManage) ...[
                                              const SizedBox(height: 8),
                                              Row(
                                                children: [
                                                  IconButton(
                                                    icon: const Icon(
                                                      Icons.edit_outlined,
                                                    ),
                                                    onPressed: () =>
                                                        _showLandingDialog(
                                                          context,
                                                          existing: item,
                                                          onSave: (payload) =>
                                                              onUpdate(
                                                                item.id,
                                                                payload,
                                                              ),
                                                        ),
                                                  ),
                                                  IconButton(
                                                    icon: const Icon(
                                                      Icons.delete_outline,
                                                    ),
                                                    onPressed: () =>
                                                        onDelete(item.id),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ],
                                        )
                                      : Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            if (item.type.toLowerCase() !=
                                                'announcement') ...[
                                              _typeBadge(item.type),
                                              const SizedBox(width: 14),
                                            ],
                                            Expanded(child: _content(item)),
                                            if (canManage)
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  IconButton(
                                                    icon: const Icon(
                                                      Icons.edit_outlined,
                                                    ),
                                                    onPressed: () =>
                                                        _showLandingDialog(
                                                          context,
                                                          existing: item,
                                                          onSave: (payload) =>
                                                              onUpdate(
                                                                item.id,
                                                                payload,
                                                              ),
                                                        ),
                                                  ),
                                                  IconButton(
                                                    icon: const Icon(
                                                      Icons.delete_outline,
                                                    ),
                                                    onPressed: () =>
                                                        onDelete(item.id),
                                                  ),
                                                ],
                                              ),
                                          ],
                                        ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _content(LandingItem item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Color(0xFF16385F),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          item.content,
          style: const TextStyle(
            color: Color(0xFF324F73),
            height: 1.3,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.event, size: 14, color: Color(0xFF446488)),
            const SizedBox(width: 6),
            Text(
              _formatDateRange(item.startDate, item.endDate),
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: Color(0xFF446488),
                fontSize: 13,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _typeBadge(String type) {
    final color = _typeColor(type);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.28)),
      ),
      child: Text(
        type,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  Color _typeColor(String type) {
    switch (type.toLowerCase()) {
      case 'reminder':
        return const Color(0xFF8C5B00);
      case 'special event':
        return const Color(0xFF8C1D40);
      case 'announcement':
      default:
        return const Color(0xFF1F5E9C);
    }
  }

  String _formatDateRange(String startRaw, String endRaw) {
    final start = _formatDate(startRaw);
    final end = _formatDate(endRaw);
    if (start == end) return start;
    return '$start - $end';
  }

  String _formatDate(String raw) {
    final parsed = DateTime.tryParse(raw);
    if (parsed == null) return raw;
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final local = parsed.toLocal();
    final month = months[local.month - 1];
    return '$month ${local.day}, ${local.year}';
  }

  Future<void> _showLandingDialog(
    BuildContext context, {
    LandingItem? existing,
    required Future<void> Function(Map<String, dynamic>) onSave,
  }) async {
    // One dialog handles both create and edit so validation stays consistent.
    final typeController = TextEditingController(
      text: existing?.type ?? 'Announcement',
    );
    final titleController = TextEditingController(text: existing?.title ?? '');
    final contentController = TextEditingController(
      text: existing?.content ?? '',
    );
    final startDateController = TextEditingController(
      text:
          existing?.startDate ??
          DateTime.now().toIso8601String().split('T').first,
    );
    final endDateController = TextEditingController(
      text:
          existing?.endDate ??
          DateTime.now().toIso8601String().split('T').first,
    );

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          existing == null ? 'Add Announcement' : 'Edit Announcement',
        ),
        content: SizedBox(
          width: 460,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: typeController,
                decoration: const InputDecoration(labelText: 'Type'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: contentController,
                minLines: 2,
                maxLines: 4,
                decoration: const InputDecoration(labelText: 'Content'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: startDateController,
                decoration: const InputDecoration(
                  labelText: 'Start Date (YYYY-MM-DD)',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: endDateController,
                decoration: const InputDecoration(
                  labelText: 'End Date (YYYY-MM-DD)',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final payload = {
                'type': typeController.text.trim(),
                'title': titleController.text.trim(),
                'content': contentController.text.trim(),
                'startDate': startDateController.text.trim(),
                'endDate': endDateController.text.trim(),
              };
              await onSave(payload);
              if (context.mounted) {
                Navigator.of(context).pop();
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    typeController.dispose();
    titleController.dispose();
    contentController.dispose();
    startDateController.dispose();
    endDateController.dispose();
  }
}

/// Header card for the landing page with manager-only add action.
class _HeaderPanel extends StatelessWidget {
  const _HeaderPanel({
    required this.canManage,
    required this.onAdd,
    required this.isMobile,
  });

  final bool canManage;
  final VoidCallback onAdd;
  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1C4F8A), Color(0xFF2E6AA4)],
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFF124374).withValues(alpha: 0.4),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33113A67),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Announcements',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 0.2,
                  ),
                ),
                if (canManage) ...[
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: onAdd,
                    icon: const Icon(Icons.add),
                    label: const Text('Add'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Color(0xB3FFFFFF)),
                      backgroundColor: const Color(0x1FFFFFFF),
                    ),
                  ),
                ],
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Announcements',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
                if (canManage)
                  OutlinedButton.icon(
                    onPressed: onAdd,
                    icon: const Icon(Icons.add),
                    label: const Text('Add'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Color(0xB3FFFFFF)),
                      backgroundColor: const Color(0x1FFFFFFF),
                    ),
                  ),
              ],
            ),
    );
  }
}
