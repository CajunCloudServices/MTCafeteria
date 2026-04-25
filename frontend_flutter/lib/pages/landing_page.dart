import 'package:flutter/material.dart';

import '../models/landing_item.dart';
import '../theme/stitch_tokens.dart';
import '../widgets/ui/stitch_buttons.dart';
import '../widgets/ui/stitch_card.dart';
import '../widgets/ui/stitch_chip.dart';

String _landingChipLabel(String type) {
  switch (type.toLowerCase()) {
    case 'reminder':
      return 'Reminder';
    case 'special event':
      return 'High Priority';
    case 'announcement':
    default:
      return 'Announcement';
  }
}

Color _landingAccent(String type) {
  switch (type.toLowerCase()) {
    case 'reminder':
      return StitchColors.reminderAccent;
    case 'special event':
      return StitchColors.specialEventAccent;
    case 'announcement':
    default:
      return StitchColors.announcementAccent;
  }
}

String _landingFormatDateRange(String startRaw, String endRaw) {
  final start = _landingFormatDateShort(startRaw);
  final end = _landingFormatDateShort(endRaw);
  if (endRaw.trim().isEmpty || start == end) return start;
  return '$start – $end';
}

String _landingFormatDateShort(String raw) {
  final parsed = DateTime.tryParse(raw);
  if (parsed == null) return raw;
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  final local = parsed.toLocal();
  return '${months[local.month - 1]} ${local.day}';
}

String _landingFormatDateLong(String raw) {
  final parsed = DateTime.tryParse(raw);
  if (parsed == null) return raw;
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  final local = parsed.toLocal();
  return '${months[local.month - 1]} ${local.day}, ${local.year}';
}

/// Stitch-aligned announcements feed.
///
/// Mirrors `home_feed/code.html`:
/// - Priority card with 6px accent ribbon + pill chip + gradient CTA.
/// - Standard card with round icon tile + compliance strip.
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (canManage) ...[
          _HeroHeader(onAdd: () => _openEditor(context)),
          const SizedBox(height: StitchSpacing.md),
        ] else
          const SizedBox(height: StitchSpacing.sm),
        Expanded(
          child: items.isEmpty
              ? _EmptyState(
                  canManage: canManage,
                  onAdd: () => _openEditor(context),
                )
              : ListView.separated(
                  padding: const EdgeInsets.only(bottom: 32),
                  itemCount: items.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: StitchSpacing.lg),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return _AnnouncementCard(
                      item: item,
                      onOpen: () => _showDetails(context, item: item),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Future<void> _openEditor(BuildContext context, {LandingItem? existing}) {
    return showDialog<void>(
      context: context,
      builder: (_) => _LandingEditorDialog(
        existing: existing,
        onSave: existing == null
            ? onCreate
            : (payload) => onUpdate(existing.id, payload),
      ),
    );
  }

  Future<void> _showDetails(
    BuildContext context, {
    required LandingItem item,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: false,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _AnnouncementDetailsSheet(
        item: item,
        canManage: canManage,
        onEdit: () {
          Navigator.of(sheetContext).pop();
          _openEditor(context, existing: item);
        },
        onDelete: () async {
          Navigator.of(sheetContext).pop();
          await onDelete(item.id);
        },
      ),
    );
  }
}

/// "Add announcement" action row, only shown to managers.
class _HeroHeader extends StatelessWidget {
  const _HeroHeader({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Material(
          color: StitchColors.surfaceContainer,
          borderRadius: BorderRadius.circular(StitchRadii.pill),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onAdd,
            child: const SizedBox(
              width: 40,
              height: 40,
              child: Icon(
                Icons.add_rounded,
                color: StitchColors.primary,
                size: 22,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _AnnouncementCard extends StatelessWidget {
  const _AnnouncementCard({required this.item, required this.onOpen});

  final LandingItem item;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final accent = _landingAccent(item.type);
    return StitchCard(
      onTap: onOpen,
      padding: const EdgeInsets.all(StitchSpacing.lg),
      elevation: StitchCardElevation.card,
      accentBarColor: accent.withValues(alpha: 0.32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                _landingChipLabel(item.type),
                style: StitchText.caption.copyWith(
                  color: accent.withValues(alpha: 0.88),
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                _landingFormatDateRange(item.startDate, item.endDate),
                style: StitchText.caption,
              ),
            ],
          ),
          const SizedBox(height: StitchSpacing.sm),
          Text(
            item.title,
            style: StitchText.titleMd,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.canManage, required this.onAdd});

  final bool canManage;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: StitchCard(
        padding: const EdgeInsets.all(StitchSpacing.xl2),
        elevation: StitchCardElevation.subtle,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.campaign_outlined,
              color: StitchColors.primary,
              size: 36,
            ),
            const SizedBox(height: 12),
            Text(
              'No announcements yet',
              style: StitchText.titleMd,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              'New daily briefs will appear here.',
              style: StitchText.body,
              textAlign: TextAlign.center,
            ),
            if (canManage) ...[
              const SizedBox(height: StitchSpacing.lg),
              StitchPrimaryButton(
                label: 'Add Announcement',
                icon: Icons.add_rounded,
                onPressed: onAdd,
                expand: false,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AnnouncementDetailsSheet extends StatelessWidget {
  const _AnnouncementDetailsSheet({
    required this.item,
    required this.canManage,
    required this.onEdit,
    required this.onDelete,
  });

  final LandingItem item;
  final bool canManage;
  final VoidCallback onEdit;
  final Future<void> Function() onDelete;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final bottomOffset = bottomInset + 28;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(12, 12, 12, bottomOffset),
        child: Container(
          decoration: BoxDecoration(
            color: StitchColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(StitchRadii.lg),
            boxShadow: StitchShadows.cardSoft,
          ),
          clipBehavior: Clip.antiAlias,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 18),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          StitchChip(
                            label: _landingChipLabel(item.type),
                            tone: StitchChipTone.neutral,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${_landingFormatDateLong(item.startDate)}'
                            '${item.endDate.trim().isEmpty ? '' : ' – ${_landingFormatDateLong(item.endDate)}'}',
                            style: StitchText.eyebrowSmall,
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(item.title, style: StitchText.displayEditorial),
                      const SizedBox(height: 16),
                      Text(item.content, style: StitchText.bodyLg),
                      if (canManage) ...[
                        const SizedBox(height: 22),
                        Row(
                          children: [
                            Expanded(
                              child: StitchSecondaryButton(
                                label: 'Edit',
                                icon: Icons.edit_outlined,
                                onPressed: onEdit,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: StitchSecondaryButton(
                                label: 'Delete',
                                icon: Icons.delete_outline_rounded,
                                onPressed: onDelete,
                                background: StitchColors.errorContainer,
                                foreground: StitchColors.onErrorContainer,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LandingEditorDialog extends StatefulWidget {
  const _LandingEditorDialog({this.existing, required this.onSave});

  final LandingItem? existing;
  final Future<void> Function(Map<String, dynamic>) onSave;

  @override
  State<_LandingEditorDialog> createState() => _LandingEditorDialogState();
}

class _LandingEditorDialogState extends State<_LandingEditorDialog> {
  late final TextEditingController _typeController;
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  late final TextEditingController _startDateController;
  late final TextEditingController _endDateController;

  @override
  void initState() {
    super.initState();
    _typeController = TextEditingController(
      text: widget.existing?.type ?? 'Announcement',
    );
    _titleController = TextEditingController(
      text: widget.existing?.title ?? '',
    );
    _contentController = TextEditingController(
      text: widget.existing?.content ?? '',
    );
    _startDateController = TextEditingController(
      text:
          widget.existing?.startDate ??
          DateTime.now().toIso8601String().split('T').first,
    );
    _endDateController = TextEditingController(
      text: widget.existing?.endDate ?? '',
    );
  }

  @override
  void dispose() {
    _typeController.dispose();
    _titleController.dispose();
    _contentController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final payload = {
      'type': _typeController.text.trim(),
      'title': _titleController.text.trim(),
      'content': _contentController.text.trim(),
      'startDate': _startDateController.text.trim(),
      'endDate': _endDateController.text.trim(),
    };
    await widget.onSave(payload);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.existing == null ? 'Add Announcement' : 'Edit Announcement',
        style: StitchText.titleLg,
      ),
      content: SizedBox(
        width: 460,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _typeController,
                decoration: const InputDecoration(labelText: 'Type'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _contentController,
                minLines: 2,
                maxLines: 4,
                decoration: const InputDecoration(labelText: 'Content'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _startDateController,
                decoration: const InputDecoration(
                  labelText: 'Start Date (YYYY-MM-DD)',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _endDateController,
                decoration: const InputDecoration(
                  labelText: 'End Date (YYYY-MM-DD)',
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _save, child: const Text('Save')),
      ],
    );
  }
}
