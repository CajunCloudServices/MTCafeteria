import 'package:flutter/material.dart';

import '../models/landing_item.dart';

/// Home screen announcement board.
class LandingPage extends StatelessWidget {
  const LandingPage({
    super.key,
    required this.items,
    required this.canManage,
    required this.isPilotProfile,
    required this.onCreate,
    required this.onUpdate,
    required this.onDelete,
  });

  final List<LandingItem> items;
  final bool canManage;
  final bool isPilotProfile;
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
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: const Color(0xFFC1D1E4),
                              width: 1,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x0F183A63),
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
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
                                  padding: EdgeInsets.all(isMobile ? 12 : 14),
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
            if (isPilotProfile) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _promptForPilotAnnouncementCreate(context),
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

  Future<void> _promptForPilotAnnouncementCreate(BuildContext context) async {
    final isApproved = await showDialog<bool>(
      context: context,
      builder: (_) => const _PilotAnnouncementPasswordDialog(),
    );
    if (isApproved != true) return;
    if (!context.mounted) return;
    await _showLandingDialog(context, onSave: onCreate);
  }

  Widget _content(LandingItem item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.title,
          style: TextStyle(
            fontSize: item.type.toLowerCase() == 'announcement' ? 18 : 16,
            fontWeight: FontWeight.w800,
            color: Color(0xFF16385F),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          item.content,
          style: const TextStyle(
            color: Color(0xFF324F73),
            height: 1.3,
            fontWeight: FontWeight.w400,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 6,
          runSpacing: 4,
          children: [
            const Icon(Icons.event, size: 14, color: Color(0xFF446488)),
            Text(
              _formatDateRange(item.startDate, item.endDate),
              style: const TextStyle(
                fontWeight: FontWeight.w600,
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Text(
        type,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w800,
          fontSize: 13,
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
    await showDialog<void>(
      context: context,
      builder: (_) => _LandingEditorDialog(existing: existing, onSave: onSave),
    );
  }
}

class _PilotAnnouncementPasswordDialog extends StatefulWidget {
  const _PilotAnnouncementPasswordDialog();

  @override
  State<_PilotAnnouncementPasswordDialog> createState() =>
      _PilotAnnouncementPasswordDialogState();
}

class _PilotAnnouncementPasswordDialogState
    extends State<_PilotAnnouncementPasswordDialog> {
  final TextEditingController _passwordController = TextEditingController();
  String? _errorText;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_passwordController.text.trim() == 'admin') {
      Navigator.of(context).pop(true);
      return;
    }
    setState(() {
      _errorText = 'Incorrect password';
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Admin Password'),
      content: SizedBox(
        width: 360,
        child: TextField(
          controller: _passwordController,
          obscureText: true,
          autofocus: true,
          decoration: InputDecoration(
            labelText: 'Password',
            errorText: _errorText,
          ),
          onSubmitted: (_) => _submit(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Continue')),
      ],
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
      text:
          widget.existing?.endDate ??
          DateTime.now().toIso8601String().split('T').first,
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
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF3FF),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF9FB9DB), width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14183A63),
            blurRadius: 10,
            offset: Offset(0, 3),
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
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF16385F),
                  ),
                ),
                if (canManage) ...[
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: onAdd,
                      icon: const Icon(Icons.add),
                      label: const Text('Add'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF1C4F8A),
                        side: const BorderSide(color: Color(0xFFC1D1E4)),
                        backgroundColor: Colors.white,
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
                        'Announcements',
                        style: TextStyle(
                          fontSize: 32,
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
                      side: const BorderSide(color: Color(0xFFC1D1E4)),
                      backgroundColor: Colors.white,
                    ),
                  ),
              ],
            ),
    );
  }
}
