part of '../dashboard_page.dart';

enum _StudentManagerPortalPane { announcements, points, reports }

class _StudentManagerPortalSection extends StatefulWidget {
  const _StudentManagerPortalSection({
    required this.user,
    required this.landingItems,
    required this.dailyShiftReports,
    required this.pendingAssignments,
    required this.pointSentAssignments,
    required this.pointApprovalAssignments,
    required this.pointAssignableUsers,
    required this.pointInboxError,
    required this.pointSentError,
    required this.pointAssignableUsersError,
    required this.pointApprovalQueueError,
    required this.dailyShiftReportsError,
    required this.onAcceptPointAssignment,
    required this.onAssignPoints,
    required this.onApprovePointAssignment,
    required this.onRefreshPointCenter,
    required this.onRefreshDailyShiftReports,
    required this.onCreateAnnouncement,
    required this.onUpdateAnnouncement,
    required this.onDeleteAnnouncement,
    required this.onOpenTaskEditor,
  });

  final UserSession user;
  final List<LandingItem> landingItems;
  final List<DailyShiftReport> dailyShiftReports;
  final List<PointAssignment> pendingAssignments;
  final List<PointAssignment> pointSentAssignments;
  final List<PointAssignment> pointApprovalAssignments;
  final List<AssignableUser> pointAssignableUsers;
  final String? pointInboxError;
  final String? pointSentError;
  final String? pointAssignableUsersError;
  final String? pointApprovalQueueError;
  final String? dailyShiftReportsError;
  final Future<void> Function(int assignmentId, String initials)
  onAcceptPointAssignment;
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
  final Future<void> Function() onRefreshDailyShiftReports;
  final Future<void> Function(Map<String, dynamic>) onCreateAnnouncement;
  final Future<void> Function(int id, Map<String, dynamic>)
  onUpdateAnnouncement;
  final Future<void> Function(int id) onDeleteAnnouncement;
  final Future<void> Function() onOpenTaskEditor;

  @override
  State<_StudentManagerPortalSection> createState() =>
      _StudentManagerPortalSectionState();
}

class _StudentManagerPortalSectionState
    extends State<_StudentManagerPortalSection> {
  _StudentManagerPortalPane _selectedPane =
      _StudentManagerPortalPane.announcements;

  String _paneLabel(_StudentManagerPortalPane pane) {
    switch (pane) {
      case _StudentManagerPortalPane.announcements:
        return 'Edit Announcements';
      case _StudentManagerPortalPane.points:
        return 'Assign Points';
      case _StudentManagerPortalPane.reports:
        return 'Daily Shift Reports';
    }
  }

  Future<void> _selectPane(_StudentManagerPortalPane pane) async {
    if (pane == _StudentManagerPortalPane.reports) {
      await widget.onRefreshDailyShiftReports();
      if (!mounted) return;
    }
    setState(() {
      _selectedPane = pane;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Student Manager Portal',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Manager-only tools for announcements, point assignments, daily shift reports, and task administration.',
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<_StudentManagerPortalPane>(
                  initialValue: _selectedPane,
                  decoration: const InputDecoration(labelText: 'Manager tool'),
                  items: _StudentManagerPortalPane.values
                      .map(
                        (pane) => DropdownMenuItem<_StudentManagerPortalPane>(
                          value: pane,
                          child: Text(_paneLabel(pane)),
                        ),
                      )
                      .toList(growable: false),
                  onChanged: (pane) {
                    if (pane == null) return;
                    _selectPane(pane);
                  },
                ),
                const SizedBox(height: 10),
                OutlinedButton(
                  onPressed: widget.onOpenTaskEditor,
                  child: const Text('Edit Jobs & Tasks'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (_selectedPane == _StudentManagerPortalPane.announcements)
          SizedBox(
            height: 720,
            child: LandingPage(
              items: widget.landingItems,
              canManage: true,
              onCreate: widget.onCreateAnnouncement,
              onUpdate: widget.onUpdateAnnouncement,
              onDelete: widget.onDeleteAnnouncement,
            ),
          )
        else if (_selectedPane == _StudentManagerPortalPane.points)
          ReportingPage(
            user: widget.user,
            pendingAssignments: widget.pendingAssignments,
            onAcceptAssignment: widget.onAcceptPointAssignment,
            onRefresh: widget.onRefreshPointCenter,
            canSubmitPointRequests: widget.user.canSubmitPointRequests,
            canApprovePointRequests: widget.user.canManagePoints,
            pointSentAssignments: widget.pointSentAssignments,
            pointApprovalAssignments: widget.pointApprovalAssignments,
            pointAssignableUsers: widget.pointAssignableUsers,
            pointInboxError: widget.pointInboxError,
            pointSentError: widget.pointSentError,
            pointAssignableUsersError: widget.pointAssignableUsersError,
            pointApprovalQueueError: widget.pointApprovalQueueError,
            onAssignPoints: widget.onAssignPoints,
            onApprovePointAssignment: widget.onApprovePointAssignment,
            onRefreshPointCenter: widget.onRefreshPointCenter,
          )
        else
          DailyShiftReportsView(
            reports: widget.dailyShiftReports,
            error: widget.dailyShiftReportsError,
            onRefresh: widget.onRefreshDailyShiftReports,
          ),
      ],
    );
  }
}
