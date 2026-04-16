import 'package:flutter/material.dart';

/// Prompts for the dedicated Task & Job Editor password and returns it on
/// success, or `null` if the user cancels.
///
/// The password is not validated here; the backend is the authority. The
/// dialog only exists to collect the credential in one consistent place so
/// the rest of the app never prompts for it inline.
Future<String?> promptForTaskEditorPassword(
  BuildContext context, {
  String title = 'Task Editor Password',
  String helper = 'Enter the task-editor password to edit jobs and tasks.',
}) async {
  return showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _TaskEditorPasswordDialog(title: title, helper: helper),
  );
}

class _TaskEditorPasswordDialog extends StatefulWidget {
  const _TaskEditorPasswordDialog({
    required this.title,
    required this.helper,
  });

  final String title;
  final String helper;

  @override
  State<_TaskEditorPasswordDialog> createState() =>
      _TaskEditorPasswordDialogState();
}

class _TaskEditorPasswordDialogState extends State<_TaskEditorPasswordDialog> {
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    final value = _passwordController.text.trim();
    if (value.isEmpty) return;
    Navigator.of(context).pop(value);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.helper, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 12),
            TextField(
              controller: _passwordController,
              obscureText: true,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => _submit(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Unlock')),
      ],
    );
  }
}
