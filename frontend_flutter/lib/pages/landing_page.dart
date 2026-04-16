import 'package:flutter/material.dart';
import 'package:url_launcher/link.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/landing_item.dart';
import '../theme/app_ui_tokens.dart';

const String _feedbackFormUrl =
    'https://docs.google.com/forms/d/e/1FAIpQLSdpUPvjK-C2K9TbxKC0-L57WfJe2OFBVqHQpXwuFklC8DNI_Q/viewform?usp=header';

Color _landingTypeColor(String type) {
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

String _landingFormatDateRange(String startRaw, String endRaw) {
  final start = _landingFormatDate(startRaw);
  final end = _landingFormatDate(endRaw);
  if (endRaw.trim().isEmpty || start == end) return start;
  return '$start · $end';
}

String _landingFormatDate(String raw) {
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

  Future<void> _openFeedbackForm(BuildContext context) async {
    final opened = await launchUrl(
      Uri.parse(_feedbackFormUrl),
      webOnlyWindowName: '_blank',
    );
    if (opened || !context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Could not open the feedback form.')),
    );
  }

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
              child: ListView.separated(
                itemCount: items.length + 1,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  if (index < items.length) {
                    final item = items[index];
                    return _AnnouncementCard(
                      item: item,
                      isMobile: isMobile,
                      canManage: canManage,
                      onOpen: () => _showAnnouncementDetails(
                        context,
                        item: item,
                        canManage: canManage,
                        onEdit: () => _showLandingDialog(
                          context,
                          existing: item,
                          onSave: (payload) => onUpdate(item.id, payload),
                        ),
                        onDelete: () => onDelete(item.id),
                      ),
                    );
                  }

                  return Link(
                    uri: Uri.parse(_feedbackFormUrl),
                    target: LinkTarget.blank,
                    builder: (context, followLink) => _AnnouncementCard(
                      item: const LandingItem(
                        id: -1,
                        type: 'Announcement',
                        title: 'App Feedback',
                        content: 'Tell us how the app is working on your shift.',
                        startDate: '',
                        endDate: '',
                      ),
                      isMobile: isMobile,
                      canManage: false,
                      onOpen: () {
                        if (followLink != null) {
                          followLink();
                          return;
                        }
                        _openFeedbackForm(context);
                      },
                    ),
                  );
                },
              ),
            ),
            if (canManage) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () =>
                      _showLandingDialog(context, onSave: onCreate),
                  icon: const Icon(Icons.add_comment_outlined),
                  label: const Text('Add Announcement'),
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Future<void> _showAnnouncementDetails(
    BuildContext context, {
    required LandingItem item,
    required bool canManage,
    required VoidCallback onEdit,
    required Future<void> Function() onDelete,
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _AnnouncementDetailsSheet(
        item: item,
        canManage: canManage,
        onEdit: () {
          Navigator.of(sheetContext).pop();
          onEdit();
        },
        onDelete: () async {
          Navigator.of(sheetContext).pop();
          await onDelete();
        },
      ),
    );
  }

  Future<void> _showLandingDialog(
    BuildContext context, {
    LandingItem? existing,
    required Future<void> Function(Map<String, dynamic>) onSave,
  }) async {
    await showDialog<void>(
      context: context,
      builder: (_) => _LandingEditorDialog(existing: existing, onSave: onSave),
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
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 18 : 24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF4F8FF), Color(0xFFEAF2FD)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppUiTokens.cardRadius),
        border: Border.all(color: const Color(0xFFB7CDEA), width: 1.1),
        boxShadow: AppUiTokens.cardShadowSoft,
      ),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Reminders',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF16385F),
                  ),
                ),
                if (canManage) ...[
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: onAdd,
                      icon: const Icon(Icons.add),
                      label: const Text('Add'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF1C4F8A),
                        side: const BorderSide(color: Color(0xFFC6D8ED)),
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
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
                        'Reminders',
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF16385F),
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
                      foregroundColor: const Color(0xFF1C4F8A),
                      side: const BorderSide(color: Color(0xFFC6D8ED)),
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}

class _AnnouncementCard extends StatelessWidget {
  const _AnnouncementCard({
    required this.item,
    required this.isMobile,
    required this.canManage,
    required this.onOpen,
  });

  final LandingItem item;
  final bool isMobile;
  final bool canManage;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final accent = _landingTypeColor(item.type);
    final preview = item.content.trim();
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(AppUiTokens.cardRadius),
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppUiTokens.cardRadius),
            border: Border.all(color: AppUiTokens.shellBorder),
            boxShadow: AppUiTokens.cardShadowSoft,
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(isMobile ? 14 : 16, 14, 14, 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 10,
                  height: isMobile ? 56 : 64,
                  decoration: BoxDecoration(
                    color: accent,
                    borderRadius: BorderRadius.circular(
                      AppUiTokens.accentRadius,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: isMobile ? 20 : 22,
                                fontWeight: FontWeight.w900,
                                height: 1.06,
                                letterSpacing: -0.35,
                                color: const Color(0xFF123A65),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.chevron_right_rounded,
                            size: 22,
                            color: Color(0xFF7A95B4),
                          ),
                        ],
                      ),
                      if (preview.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          preview,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF506C8E),
                            height: 1.25,
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                          ),
                        ),
                      ],
                      const SizedBox(height: 10),
                      _AnnouncementDateChip(
                        label: _landingFormatDateRange(
                          item.startDate,
                          item.endDate,
                        ),
                      ),
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

class _AnnouncementDateChip extends StatelessWidget {
  const _AnnouncementDateChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F8FC),
        borderRadius: BorderRadius.circular(AppUiTokens.chipRadius),
        border: Border.all(color: AppUiTokens.chipBorder),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: Color(0xFF4A678A),
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
    final accent = _landingTypeColor(item.type);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(12, 12, 12, bottomInset + 12),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppUiTokens.sheetRadius),
            boxShadow: const [
              BoxShadow(
                color: Color(0x22183A63),
                blurRadius: 30,
                offset: Offset(0, 14),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 46,
                      height: 5,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD4DFED),
                        borderRadius: BorderRadius.circular(
                          AppUiTokens.accentRadius,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (item.type.toLowerCase() != 'announcement')
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: accent.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(
                              AppUiTokens.chipRadius,
                            ),
                            border: Border.all(
                              color: accent.withValues(alpha: 0.24),
                            ),
                          ),
                          child: Text(
                            item.type,
                            style: TextStyle(
                              color: accent,
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      _AnnouncementDateChip(
                        label: _landingFormatDateRange(
                          item.startDate,
                          item.endDate,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      height: 1.05,
                      letterSpacing: -0.5,
                      color: Color(0xFF123A65),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    item.content,
                    style: const TextStyle(
                      color: Color(0xFF3E5B7D),
                      fontSize: 16,
                      height: 1.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (canManage) ...[
                    const SizedBox(height: 22),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: onEdit,
                            icon: const Icon(Icons.edit_outlined),
                            label: const Text('Edit'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: onDelete,
                            icon: const Icon(Icons.delete_outline),
                            label: const Text('Delete'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF9A2D2D),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
