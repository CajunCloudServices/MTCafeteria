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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.check_circle, color: Color(0xFF2E7D32), size: 28),
                SizedBox(width: 10),
                Text(
                  'Shift Complete',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF103760),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              'All trainees checked off: $checkedOffCount/${widget.traineeCount}',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: Color(0xFF264D76),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFEAF4FF),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFF1F5E9C).withValues(alpha: 0.35),
                ),
              ),
              child: const Text(
                'All trainees checked off. Submit your shift report and check in with your supervisor.',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF113A67),
                  height: 1.35,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
