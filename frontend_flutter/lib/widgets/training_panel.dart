import 'package:flutter/material.dart';

import '../models/training.dart';

/// Legacy compact training summary panel used in simpler dashboard contexts.
class TrainingPanel extends StatelessWidget {
  const TrainingPanel({
    super.key,
    required this.today,
    required this.todaysTraining,
    required this.trainings,
  });

  final String? today;
  final Training? todaysTraining;
  final List<Training> trainings;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Two-Minute Trainings',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (today != null)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text('Today: $today'),
              ),
            const SizedBox(height: 12),
            if (todaysTraining != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Highlighted for today',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      todaysTraining!.title,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(todaysTraining!.content),
                  ],
                ),
              ),
            const SizedBox(height: 12),
            ...trainings.map(
              (training) => ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: Text(training.title),
                subtitle: Text(training.assignedDate),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
