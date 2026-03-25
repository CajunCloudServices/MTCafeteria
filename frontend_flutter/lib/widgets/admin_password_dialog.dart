import 'package:flutter/material.dart';

Future<bool> promptForAdminPassword(
  BuildContext context, {
  String title = 'Admin Password',
}) async {
  final approved = await showDialog<bool>(
    context: context,
    builder: (_) => _AdminPasswordDialog(title: title),
  );
  return approved == true;
}

class _AdminPasswordDialog extends StatefulWidget {
  const _AdminPasswordDialog({required this.title});

  final String title;

  @override
  State<_AdminPasswordDialog> createState() => _AdminPasswordDialogState();
}

class _AdminPasswordDialogState extends State<_AdminPasswordDialog> {
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
      title: Text(widget.title),
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
