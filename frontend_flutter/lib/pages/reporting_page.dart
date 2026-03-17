import 'package:flutter/material.dart';

import '../models/point_assignment.dart';
import '../models/user_session.dart';

/// Reporting screen for point notifications, assignments, and approvals.
class ReportingPage extends StatelessWidget {
  const ReportingPage({
    super.key,
    required this.user,
    required this.pendingAssignments,
    required this.onAcceptAssignment,
    required this.onRefresh,
    required this.canSubmitPointRequests,
    required this.canApprovePointRequests,
    required this.pointSentAssignments,
    required this.pointApprovalAssignments,
    required this.pointAssignableUsers,
    required this.pointInboxError,
    required this.pointSentError,
    required this.pointAssignableUsersError,
    required this.pointApprovalQueueError,
    required this.onAssignPoints,
    required this.onApprovePointAssignment,
    required this.onRefreshPointCenter,
  });

  final UserSession user;
  final List<PointAssignment> pendingAssignments;
  final Future<void> Function(int assignmentId, String initials)
  onAcceptAssignment;
  final Future<void> Function() onRefresh;
  final bool canSubmitPointRequests;
  final bool canApprovePointRequests;
  final List<PointAssignment> pointSentAssignments;
  final List<PointAssignment> pointApprovalAssignments;
  final List<AssignableUser> pointAssignableUsers;
  final String? pointInboxError;
  final String? pointSentError;
  final String? pointAssignableUsersError;
  final String? pointApprovalQueueError;
  final Future<void> Function({
    required int assignedToUserId,
    required int pointsDelta,
    required String assignmentDate,
    required String reason,
    required String assignmentDescription,
  })
  onAssignPoints;
  final Future<void> Function(int assignmentId) onApprovePointAssignment;
  final Future<void> Function() onRefreshPointCenter;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          key: const ValueKey('point-notifications-card'),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Point Notifications',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 6),
                const Text(
                  'Review and acknowledge each assignment with your initials.',
                ),
                const SizedBox(height: 10),
                if (pointInboxError != null)
                  _SectionErrorBanner(message: pointInboxError!),
                if (pendingAssignments.isEmpty)
                  const Text('No pending point notifications.')
                else
                  ...pendingAssignments.map(
                    (assignment) => Container(
                      key: ValueKey('pending-point-${assignment.id}'),
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAF4FF),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(
                            0xFF1F5E9C,
                          ).withValues(alpha: 0.28),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '+${assignment.pointsDelta} point(s) - ${_formatDate(assignment.assignmentDate)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF163A63),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(assignment.reason),
                          const SizedBox(height: 4),
                          Text(
                            'Assigned by: ${assignment.assignedByEmail}',
                            style: const TextStyle(
                              color: Color(0xFF476385),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              onPressed: () =>
                                  _promptAccept(context, assignment),
                              child: const Text('Acknowledge with Initials'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        _PointCenterSection(
          canSubmitPointRequests: canSubmitPointRequests,
          canApprovePointRequests: canApprovePointRequests,
          pointSentAssignments: pointSentAssignments,
          pointApprovalAssignments: pointApprovalAssignments,
          pointAssignableUsers: pointAssignableUsers,
          pointSentError: pointSentError,
          pointAssignableUsersError: pointAssignableUsersError,
          pointApprovalQueueError: pointApprovalQueueError,
          onAssignPoints: onAssignPoints,
          onApprovePointAssignment: onApprovePointAssignment,
          onRefreshPointCenter: onRefreshPointCenter,
        ),
      ],
    );
  }

  Future<void> _promptAccept(
    BuildContext context,
    PointAssignment assignment,
  ) async {
    String initialsInput = '';

    // Wait to mutate app state until the employee explicitly confirms.
    final initials = await showDialog<String>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: const Text('Acknowledge Point Assignment'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('+${assignment.pointsDelta} point(s)'),
                const SizedBox(height: 6),
                Text(assignment.reason),
                const SizedBox(height: 10),
                TextField(
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(labelText: 'Your initials'),
                  onChanged: (value) {
                    setDialogState(() {
                      initialsInput = value.trim().toUpperCase();
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: initialsInput.length < 2
                  ? null
                  : () => Navigator.of(dialogContext).pop(initialsInput),
              child: const Text('Confirm'),
            ),
          ],
        ),
      ),
    );

    if (initials == null || initials.length < 2) return;

    try {
      await onAcceptAssignment(assignment.id, initials);
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Points acknowledged.')));
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not acknowledge points. Please try again.'),
        ),
      );
    }
  }

  String _formatDate(String raw) {
    final parsed = DateTime.tryParse(raw);
    if (parsed == null) return raw;
    final local = parsed.toLocal();
    return '${local.month}/${local.day}/${local.year}';
  }
}

/// Assignment and approval tools shown below the employee inbox.
class _PointCenterSection extends StatefulWidget {
  const _PointCenterSection({
    required this.canSubmitPointRequests,
    required this.canApprovePointRequests,
    required this.pointSentAssignments,
    required this.pointApprovalAssignments,
    required this.pointAssignableUsers,
    required this.pointSentError,
    required this.pointAssignableUsersError,
    required this.pointApprovalQueueError,
    required this.onAssignPoints,
    required this.onApprovePointAssignment,
    required this.onRefreshPointCenter,
  });

  final bool canSubmitPointRequests;
  final bool canApprovePointRequests;
  final List<PointAssignment> pointSentAssignments;
  final List<PointAssignment> pointApprovalAssignments;
  final List<AssignableUser> pointAssignableUsers;
  final String? pointSentError;
  final String? pointAssignableUsersError;
  final String? pointApprovalQueueError;
  final Future<void> Function({
    required int assignedToUserId,
    required int pointsDelta,
    required String assignmentDate,
    required String reason,
    required String assignmentDescription,
  })
  onAssignPoints;
  final Future<void> Function(int assignmentId) onApprovePointAssignment;
  final Future<void> Function() onRefreshPointCenter;

  @override
  State<_PointCenterSection> createState() => _PointCenterSectionState();
}

class _PointCenterSectionState extends State<_PointCenterSection> {
  /// These presets mirror the cafeteria point policy and drive both label and
  /// default point-value selection.
  static const List<_ReasonOption> _reasonOptions = [
    _ReasonOption('Late < 30 minutes', 1),
    _ReasonOption('Late > 30 minutes', 2),
    _ReasonOption('No-Show', 4),
    _ReasonOption('No-Show sick', 2),
    _ReasonOption('Missing uniform', 2),
    _ReasonOption('On your phone', 1),
    _ReasonOption('Custom points', null),
  ];

  final TextEditingController _customPointsController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  int? _selectedUserId;
  String _selectedReason = _reasonOptions.first.label;
  bool _isWeekend = false;
  DateTime _selectedDate = DateTime.now();
  bool _submitting = false;

  @override
  void dispose() {
    _customPointsController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final users = widget.pointAssignableUsers;
    final hasUsers = users.isNotEmpty;
    _selectedUserId ??= hasUsers ? users.first.id : null;
    final reason = _reasonOptions.firstWhere((r) => r.label == _selectedReason);
    final isCustom = reason.basePoints == null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Point Center',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                IconButton(
                  onPressed: widget.onRefreshPointCenter,
                  icon: const Icon(Icons.refresh_rounded),
                  tooltip: 'Refresh',
                ),
              ],
            ),
            if (widget.canSubmitPointRequests) ...[
              const SizedBox(height: 8),
              DropdownButtonFormField<int>(
                key: const ValueKey('assignable-user-dropdown'),
                // ignore: deprecated_member_use
                value: _selectedUserId,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Assign To'),
                items: users
                    .map(
                      (u) => DropdownMenuItem<int>(
                        value: u.id,
                        child: Text('${u.email} (${u.role})'),
                      ),
                    )
                    .toList(),
                onChanged: hasUsers
                    ? (v) => setState(() => _selectedUserId = v)
                    : null,
              ),
              if (!hasUsers) ...[
                const SizedBox(height: 8),
                _SectionErrorBanner(
                  message:
                      widget.pointAssignableUsersError ??
                      'No employees loaded. Tap refresh to reload users.',
                ),
              ],
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                key: const ValueKey('point-reason-dropdown'),
                // ignore: deprecated_member_use
                value: _selectedReason,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Reason'),
                items: _reasonOptions
                    .map(
                      (opt) => DropdownMenuItem<String>(
                        value: opt.label,
                        child: Text(opt.label),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => _selectedReason = value);
                },
              ),
              if (isCustom) ...[
                const SizedBox(height: 10),
                TextField(
                  controller: _customPointsController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Custom points'),
                ),
              ],
              const SizedBox(height: 10),
              TextField(
                controller: _descriptionController,
                maxLines: 2,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _pickDate(context),
                      icon: const Icon(Icons.calendar_today_rounded),
                      label: Text(_fmtDate(_selectedDate)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: CheckboxListTile(
                      value: _isWeekend,
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                      title: const Text('Weekend x2'),
                      onChanged: (value) =>
                          setState(() => _isWeekend = value ?? false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  key: const ValueKey('assign-points-button'),
                  onPressed: (_submitting || !hasUsers) ? null : _submit,
                  child: Text(_submitting ? 'Submitting...' : 'Assign Points'),
                ),
              ),
              const SizedBox(height: 14),
            ],
            if (widget.canApprovePointRequests) ...[
              const Text(
                'Pending Manager Approval',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              if (widget.pointApprovalQueueError != null)
                _SectionErrorBanner(message: widget.pointApprovalQueueError!),
              if (widget.pointApprovalAssignments.isEmpty)
                const Text('No pending approvals.')
              else
                ...widget.pointApprovalAssignments.map(
                  (assignment) => ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      '${assignment.assignedToEmail} • +${assignment.pointsDelta}',
                    ),
                    subtitle: Text(
                      '${_fmtDateRaw(assignment.assignmentDate)} • ${assignment.reason}',
                    ),
                    trailing: FilledButton.tonal(
                      onPressed: () async {
                        final messenger = ScaffoldMessenger.of(context);
                        await widget.onApprovePointAssignment(assignment.id);
                        if (!mounted) return;
                        messenger.showSnackBar(
                          const SnackBar(
                            content: Text('Point request approved.'),
                          ),
                        );
                      },
                      child: const Text('Approve'),
                    ),
                  ),
                ),
              const SizedBox(height: 12),
            ],
            if (widget.canSubmitPointRequests) ...[
              const Text(
                'Recent Assignments',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              if (widget.pointSentError != null)
                _SectionErrorBanner(message: widget.pointSentError!),
              if (widget.pointSentAssignments.isEmpty)
                const Text('No assignments yet.')
              else
                ...widget.pointSentAssignments.take(8).map((assignment) {
                  final statusColor =
                      assignment.status == 'PendingManagerApproval'
                      ? const Color(0xFF9A6700)
                      : assignment.status == 'PendingEmployeeAcknowledgement'
                      ? const Color(0xFF355B84)
                      : const Color(0xFF217A3C);
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4F8FE),
                      border: Border.all(color: const Color(0xFFB4C8E3)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${assignment.assignedToEmail} • +${assignment.pointsDelta}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF163A63),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${_fmtDateRaw(assignment.assignmentDate)} • ${assignment.reason}',
                        ),
                        Text(
                          assignment.status,
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _submit() async {
    final selectedReason = _reasonOptions.firstWhere(
      (r) => r.label == _selectedReason,
    );
    final basePoints =
        selectedReason.basePoints ??
        int.tryParse(_customPointsController.text.trim());
    final userId = _selectedUserId;
    final description = _descriptionController.text.trim();

    if (userId == null ||
        basePoints == null ||
        basePoints <= 0 ||
        description.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Complete all fields before submitting.')),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      final adjustedPoints = _isWeekend ? basePoints * 2 : basePoints;
      await widget.onAssignPoints(
        assignedToUserId: userId,
        pointsDelta: adjustedPoints,
        assignmentDate: _selectedDate.toIso8601String(),
        reason: _selectedReason,
        assignmentDescription: description,
      );
      if (!mounted) return;
      _customPointsController.clear();
      _descriptionController.clear();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Points submitted.')));
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  String _fmtDate(DateTime d) => '${d.month}/${d.day}/${d.year}';

  String _fmtDateRaw(String raw) {
    final parsed = DateTime.tryParse(raw);
    if (parsed == null) return raw;
    return _fmtDate(parsed.toLocal());
  }
}

class _ReasonOption {
  const _ReasonOption(this.label, this.basePoints);

  final String label;
  final int? basePoints;
}

/// Shared error surface for independently loaded point-center sections.
class _SectionErrorBanner extends StatelessWidget {
  const _SectionErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4E5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFD77F00)),
      ),
      child: Text(
        message,
        style: const TextStyle(
          color: Color(0xFF8C4F00),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
