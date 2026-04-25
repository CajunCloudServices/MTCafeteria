part of '../dashboard_page.dart';

enum _StudentManagerPortalPane { announcements, points, reports, tasks }

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
    required this.backController,
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
  final ManagerPortalBackController backController;

  @override
  State<_StudentManagerPortalSection> createState() =>
      _StudentManagerPortalSectionState();
}

class _StudentManagerPortalSectionState
    extends State<_StudentManagerPortalSection> {
  _StudentManagerPortalPane? _selectedPane;

  @override
  void initState() {
    super.initState();
    widget.backController.attach(_handleBack);
  }

  @override
  void didUpdateWidget(covariant _StudentManagerPortalSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.backController, widget.backController)) {
      oldWidget.backController.detach(_handleBack);
      widget.backController.attach(_handleBack);
    }
  }

  @override
  void dispose() {
    widget.backController.detach(_handleBack);
    super.dispose();
  }

  /// Returns true when the header back button was consumed by closing an
  /// open sub-pane. Returning false lets the shell pop out of the portal.
  bool _handleBack() {
    if (_selectedPane == null) return false;
    setState(() => _selectedPane = null);
    return true;
  }

  Future<void> _selectPane(_StudentManagerPortalPane pane) async {
    if (pane == _StudentManagerPortalPane.tasks) {
      await widget.onOpenTaskEditor();
      if (!mounted) return;
      return;
    }
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
    final pane = _selectedPane;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (pane == null)
          _PortalToolsGrid(onSelect: _selectPane)
        else
          _PortalPaneBody(
            pane: pane,
            widgetState: this,
          ),
      ],
    );
  }
}

class _PortalToolsGrid extends StatelessWidget {
  const _PortalToolsGrid({required this.onSelect});

  final Future<void> Function(_StudentManagerPortalPane) onSelect;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 720;
        final tiles = [
          _PortalTile(
            icon: Icons.campaign_rounded,
            title: 'Edit Announcements',
            description:
                'Draft, schedule, and publish global messages to the team.',
            onTap: () => onSelect(_StudentManagerPortalPane.announcements),
          ),
          _PortalTile(
            icon: Icons.stars_rounded,
            title: 'Assign Points',
            description:
                'Award achievement points and track staff progression.',
            onTap: () => onSelect(_StudentManagerPortalPane.points),
          ),
          _PortalTile(
            icon: Icons.analytics_rounded,
            title: 'View Reports',
            description:
                'Generate and export operational data summaries.',
            onTap: () => onSelect(_StudentManagerPortalPane.reports),
          ),
          _PortalTile(
            icon: Icons.work_rounded,
            title: 'Edit Jobs & Tasks',
            description:
                'Manage job listings, shift roles, and task definitions.',
            onTap: () => onSelect(_StudentManagerPortalPane.tasks),
          ),
        ];

        if (!isWide) {
          return Column(
            children: [
              for (var i = 0; i < tiles.length; i++) ...[
                if (i > 0) const SizedBox(height: StitchSpacing.md),
                tiles[i],
              ],
            ],
          );
        }

        return Column(
          children: [
            Row(
              children: [
                Expanded(child: tiles[0]),
                const SizedBox(width: StitchSpacing.md),
                Expanded(child: tiles[1]),
              ],
            ),
            const SizedBox(height: StitchSpacing.md),
            Row(
              children: [
                Expanded(child: tiles[2]),
                const SizedBox(width: StitchSpacing.md),
                Expanded(child: tiles[3]),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _PortalTile extends StatelessWidget {
  const _PortalTile({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return StitchCard(
      padding: const EdgeInsets.all(StitchSpacing.xl2),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: StitchColors.surfaceContainer,
              borderRadius: BorderRadius.circular(StitchRadii.md),
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: StitchColors.primary, size: 24),
          ),
          const SizedBox(height: StitchSpacing.xl),
          Text(title, style: StitchText.titleLg),
          const SizedBox(height: 6),
          Text(description, style: StitchText.body),
          const SizedBox(height: StitchSpacing.md),
          Row(
            children: [
              Text(
                'Access Tool',
                style: StitchText.bodyStrong.copyWith(
                  color: StitchColors.primary,
                ),
              ),
              const SizedBox(width: 6),
              const Icon(
                Icons.arrow_forward_rounded,
                size: 16,
                color: StitchColors.primary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PortalPaneBody extends StatelessWidget {
  const _PortalPaneBody({required this.pane, required this.widgetState});

  final _StudentManagerPortalPane pane;
  final _StudentManagerPortalSectionState widgetState;

  @override
  Widget build(BuildContext context) {
    final w = widgetState.widget;
    switch (pane) {
      case _StudentManagerPortalPane.announcements:
        return SizedBox(
          height: 720,
          child: LandingPage(
            items: w.landingItems,
            canManage: true,
            onCreate: w.onCreateAnnouncement,
            onUpdate: w.onUpdateAnnouncement,
            onDelete: w.onDeleteAnnouncement,
          ),
        );
      case _StudentManagerPortalPane.points:
        return ReportingPage(
          user: w.user,
          pendingAssignments: w.pendingAssignments,
          onAcceptAssignment: w.onAcceptPointAssignment,
          onRefresh: w.onRefreshPointCenter,
          canSubmitPointRequests: w.user.canSubmitPointRequests,
          canApprovePointRequests: w.user.canManagePoints,
          pointSentAssignments: w.pointSentAssignments,
          pointApprovalAssignments: w.pointApprovalAssignments,
          pointAssignableUsers: w.pointAssignableUsers,
          pointInboxError: w.pointInboxError,
          pointSentError: w.pointSentError,
          pointAssignableUsersError: w.pointAssignableUsersError,
          pointApprovalQueueError: w.pointApprovalQueueError,
          onAssignPoints: w.onAssignPoints,
          onApprovePointAssignment: w.onApprovePointAssignment,
          onRefreshPointCenter: w.onRefreshPointCenter,
        );
      case _StudentManagerPortalPane.reports:
        return DailyShiftReportsView(
          reports: w.dailyShiftReports,
          error: w.dailyShiftReportsError,
          onRefresh: w.onRefreshDailyShiftReports,
        );
      case _StudentManagerPortalPane.tasks:
        return const SizedBox.shrink();
    }
  }
}
