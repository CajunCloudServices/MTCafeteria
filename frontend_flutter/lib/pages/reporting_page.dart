import 'package:flutter/material.dart';

import '../models/point_assignment.dart';
import '../models/user_session.dart';
import '../theme/stitch_tokens.dart';
import '../widgets/ui/stitch_buttons.dart';
import '../widgets/ui/stitch_card.dart';
import '../widgets/ui/stitch_chip.dart';

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
        StitchCard(
          key: const ValueKey('point-notifications-card'),
          padding: const EdgeInsets.all(StitchSpacing.xl2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Point Notifications', style: StitchText.titleLg),
              const SizedBox(height: StitchSpacing.md),
              if (pointInboxError != null)
                _SectionErrorBanner(message: pointInboxError!),
              if (pendingAssignments.isEmpty)
                Text('No pending point notifications.', style: StitchText.body)
              else
                ...pendingAssignments.map(
                  (assignment) => Padding(
                    key: ValueKey('pending-point-${assignment.id}'),
                    padding: const EdgeInsets.only(bottom: 12),
                    child: StitchCard(
                      padding: const EdgeInsets.all(StitchSpacing.lg),
                      elevation: StitchCardElevation.subtle,
                      ring: true,
                      accentBarColor: StitchColors.primary,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              StitchChip(
                                label: '+${assignment.pointsDelta} pt',
                                tone: StitchChipTone.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _formatDate(assignment.assignmentDate),
                                style: StitchText.eyebrowSmall,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(assignment.reason, style: StitchText.titleSm),
                          const SizedBox(height: 4),
                          Text(
                            'Assigned by ${assignment.assignedByEmail}',
                            style: StitchText.caption,
                          ),
                          const SizedBox(height: 12),
                          StitchPrimaryButton(
                            label: 'Acknowledge with Initials',
                            icon: Icons.how_to_reg_rounded,
                            onPressed: () => _promptAccept(context, assignment),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: StitchSpacing.lg),
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
                Text(
                  '+${assignment.pointsDelta} point(s)',
                  style: StitchText.titleMd,
                ),
                const SizedBox(height: 6),
                Text(assignment.reason, style: StitchText.body),
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

    return StitchCard(
      padding: const EdgeInsets.all(StitchSpacing.xl2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text('Point Center', style: StitchText.titleLg)),
              Material(
                color: StitchColors.surfaceContainer,
                borderRadius: BorderRadius.circular(StitchRadii.pill),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: widget.onRefreshPointCenter,
                  child: const SizedBox(
                    width: 40,
                    height: 40,
                    child: Icon(
                      Icons.refresh_rounded,
                      size: 20,
                      color: StitchColors.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (widget.canSubmitPointRequests) ...[
            const SizedBox(height: StitchSpacing.md),
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
                  child: StitchSecondaryButton(
                    label: _fmtDate(_selectedDate),
                    icon: Icons.calendar_today_rounded,
                    onPressed: () => _pickDate(context),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: CheckboxListTile(
                    value: _isWeekend,
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                    title: Text('Weekend x2', style: StitchText.bodyStrong),
                    onChanged: (value) =>
                        setState(() => _isWeekend = value ?? false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: StitchSpacing.md),
            StitchPrimaryButton(
              key: const ValueKey('assign-points-button'),
              label: _submitting ? 'Submitting…' : 'Assign Points',
              icon: Icons.send_rounded,
              loading: _submitting,
              onPressed: (_submitting || !hasUsers) ? null : _submit,
            ),
            const SizedBox(height: StitchSpacing.lg),
          ],
          if (widget.canApprovePointRequests) ...[
            Text('PENDING MANAGER APPROVAL', style: StitchText.eyebrow),
            const SizedBox(height: 10),
            if (widget.pointApprovalQueueError != null)
              _SectionErrorBanner(message: widget.pointApprovalQueueError!),
            if (widget.pointApprovalAssignments.isEmpty)
              Text('No pending approvals.', style: StitchText.body)
            else
              ...widget.pointApprovalAssignments.map(
                (assignment) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: StitchCard(
                    padding: const EdgeInsets.all(StitchSpacing.md),
                    elevation: StitchCardElevation.subtle,
                    ring: true,
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${assignment.assignedToEmail} • +${assignment.pointsDelta}',
                                style: StitchText.bodyStrong,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${_fmtDateRaw(assignment.assignmentDate)} • ${assignment.reason}',
                                style: StitchText.caption,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        StitchSecondaryButton(
                          label: 'Approve',
                          onPressed: () async {
                            final messenger = ScaffoldMessenger.of(context);
                            await widget.onApprovePointAssignment(
                              assignment.id,
                            );
                            if (!mounted) return;
                            messenger.showSnackBar(
                              const SnackBar(
                                content: Text('Point request approved.'),
                              ),
                            );
                          },
                          expand: false,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            const SizedBox(height: StitchSpacing.md),
          ],
          if (widget.canSubmitPointRequests) ...[
            Text('RECENT ASSIGNMENTS', style: StitchText.eyebrow),
            const SizedBox(height: 10),
            if (widget.pointSentError != null)
              _SectionErrorBanner(message: widget.pointSentError!),
            if (widget.pointSentAssignments.isEmpty)
              Text('No assignments yet.', style: StitchText.body)
            else
              ...widget.pointSentAssignments.take(8).map((assignment) {
                final StitchChipTone statusTone;
                switch (assignment.status) {
                  case 'PendingManagerApproval':
                    statusTone = StitchChipTone.tertiary;
                  case 'PendingEmployeeAcknowledgement':
                    statusTone = StitchChipTone.secondary;
                  default:
                    statusTone = StitchChipTone.success;
                }
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: StitchCard(
                    padding: const EdgeInsets.all(StitchSpacing.md),
                    elevation: StitchCardElevation.subtle,
                    ring: true,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${assignment.assignedToEmail} • +${assignment.pointsDelta}',
                          style: StitchText.bodyStrong,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${_fmtDateRaw(assignment.assignmentDate)} • ${assignment.reason}',
                          style: StitchText.caption,
                        ),
                        const SizedBox(height: 8),
                        StitchChip(label: assignment.status, tone: statusTone),
                      ],
                    ),
                  ),
                );
              }),
          ],
        ],
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
      padding: const EdgeInsets.all(StitchSpacing.md),
      decoration: BoxDecoration(
        color: StitchColors.errorContainer,
        borderRadius: BorderRadius.circular(StitchRadii.md),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: StitchColors.onErrorContainer,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: StitchText.bodyStrong.copyWith(
                color: StitchColors.onErrorContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
