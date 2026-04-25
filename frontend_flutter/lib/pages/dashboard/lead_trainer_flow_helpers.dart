part of '../dashboard_page.dart';

extension _LeadTrainerFlowHelpers on _LeadTrainerTaskSectionState {
  bool _allTraineeCheckoffsComplete(List<TrainerTraineeTask> tasks) {
    final checkoffTasks = tasks.where((t) => t.requiresCheckoff).toList();
    if (checkoffTasks.isEmpty) return false;
    return checkoffTasks.every((t) => t.completed);
  }

  String _jobLabelForSlot(TrainerBoard trainerBoard, int slot) {
    final jobId = widget.traineeJobBySlot[slot];
    if (jobId == null) return 'Unassigned';
    for (final job in trainerBoard.jobs) {
      if (job.id == jobId) return job.name;
    }
    return 'Unassigned';
  }

  Widget _buildLeadTrainerCompletionCard(int checkedOffCount) {
    return StitchSuccessCard(
      title: 'Shift Complete',
      message:
          'All trainees checked off. Submit your shift report and check in '
          'with your supervisor.',
      stats: [
        StitchSuccessStat(
          value: '$checkedOffCount/${widget.traineeCount}',
          label: 'Trainees',
        ),
        const StitchSuccessStat(value: '100%', label: 'Compliance'),
      ],
      primaryCtaLabel: 'Back to Dashboard',
      primaryIcon: Icons.dashboard_rounded,
      onPrimary: () async {
        await widget.onReturnToDashboardHub();
      },
    );
  }
}
