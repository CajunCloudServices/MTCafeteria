part of '../dashboard_page.dart';

enum _StudentManagerPortalPane {
  announcements,
  points,
  reports,
}

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
  final Future<void> Function(int id, Map<String, dynamic>) onUpdateAnnouncement;
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
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _PortalButton(
                      label: 'Edit Announcements',
                      icon: Icons.campaign_outlined,
                      selected:
                          _selectedPane == _StudentManagerPortalPane.announcements,
                      onPressed: () {
                        setState(() {
                          _selectedPane =
                              _StudentManagerPortalPane.announcements;
                        });
                      },
                    ),
                    _PortalButton(
                      label: 'Assign Points',
                      icon: Icons.workspace_premium_outlined,
                      selected: _selectedPane == _StudentManagerPortalPane.points,
                      onPressed: () {
                        setState(() {
                          _selectedPane = _StudentManagerPortalPane.points;
                        });
                      },
                    ),
                    _PortalButton(
                      label: 'Daily Shift Reports',
                      icon: Icons.fact_check_outlined,
                      selected:
                          _selectedPane == _StudentManagerPortalPane.reports,
                      onPressed: () async {
                        await widget.onRefreshDailyShiftReports();
                        if (!mounted) return;
                        setState(() {
                          _selectedPane = _StudentManagerPortalPane.reports;
                        });
                      },
                    ),
                    _PortalButton(
                      label: 'Edit Jobs & Tasks',
                      icon: Icons.edit_note,
                      selected: false,
                      onPressed: widget.onOpenTaskEditor,
                    ),
                  ],
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

class _PortalButton extends StatelessWidget {
  const _PortalButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        backgroundColor: selected ? const Color(0xFFE6F0FC) : Colors.white,
        side: BorderSide(
          color: selected ? const Color(0xFF7FA8D6) : const Color(0xFFC1D4EA),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      icon: Icon(icon, size: 20),
      label: Text(label),
    );
  }
}
