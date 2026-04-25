import 'package:flutter/material.dart';

import '../theme/stitch_tokens.dart';
import '../widgets/ui/stitch_buttons.dart';
import '../widgets/ui/stitch_card.dart';

/// Stitch-aligned email/password login (see `login/code.html`).
class LoginPage extends StatefulWidget {
  const LoginPage({
    super.key,
    required this.isLoading,
    required this.error,
    required this.onLogin,
  });

  final bool isLoading;
  final String? error;
  final Future<void> Function(String email, String password) onLogin;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController(text: 'employee@mtc.local');
  final _passwordController = TextEditingController(text: 'password123');
  bool _obscure = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (widget.isLoading) return;
    widget.onLogin(_emailController.text.trim(), _passwordController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 448),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            StitchCard(
              padding: const EdgeInsets.all(StitchSpacing.xl3),
              elevation: StitchCardElevation.card,
              ring: true,
              radius: StitchRadii.md,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _BrandBlock(),
                  const SizedBox(height: StitchSpacing.xl2),
                  _StitchField(
                    label: 'Email Address',
                    hint: 'staff@mtc.edu',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    icon: Icons.mail_outline_rounded,
                    keyName: 'login-email-field',
                  ),
                  const SizedBox(height: StitchSpacing.lg),
                  _StitchField(
                    label: 'Password',
                    hint: '••••••••',
                    controller: _passwordController,
                    icon: Icons.lock_outline_rounded,
                    obscure: _obscure,
                    keyName: 'login-password-field',
                    trailing: IconButton(
                      splashRadius: 20,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints.tightFor(
                        width: 32,
                        height: 32,
                      ),
                      onPressed: () => setState(() => _obscure = !_obscure),
                      icon: Icon(
                        _obscure
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        size: 20,
                        color: StitchColors.onSurfaceVariant,
                      ),
                    ),
                    trailingLabel: TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'Forgot?',
                        style: StitchText.caption.copyWith(
                          color: StitchColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  if (widget.error != null) ...[
                    const SizedBox(height: StitchSpacing.lg),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: StitchColors.errorContainer,
                        borderRadius: BorderRadius.circular(StitchRadii.md),
                        border: Border.all(
                          color: StitchColors.error.withValues(alpha: 0.28),
                        ),
                      ),
                      child: Text(
                        widget.error!,
                        style: StitchText.bodyStrong.copyWith(
                          color: StitchColors.onErrorContainer,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: StitchSpacing.xl2),
                  StitchPrimaryButton(
                    label: widget.isLoading ? 'Signing In…' : 'Sign In',
                    onPressed: _submit,
                    trailingIcon: widget.isLoading
                        ? null
                        : Icons.arrow_forward_rounded,
                    loading: widget.isLoading,
                  ),
                ],
              ),
            ),
            const SizedBox(height: StitchSpacing.xl2),
            Text(
              'Secure Operational Portal © MTC Cafeteria',
              style: StitchText.caption.copyWith(
                color: StitchColors.onSurfaceVariant.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BrandBlock extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: StitchColors.primary,
            borderRadius: BorderRadius.circular(StitchRadii.sm),
            boxShadow: StitchShadows.cardSoft,
          ),
          alignment: Alignment.center,
          child: const Icon(
            Icons.restaurant_rounded,
            color: StitchColors.onPrimary,
            size: 30,
          ),
        ),
        const SizedBox(height: 12),
        Text('MTC Cafeteria', style: StitchText.titleLg),
        const SizedBox(height: 2),
        Text(
          'Operations Command Center',
          style: StitchText.body,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

/// Bottom-line, underline-only field like the Stitch login.
class _StitchField extends StatelessWidget {
  const _StitchField({
    required this.label,
    required this.controller,
    required this.icon,
    this.hint,
    this.keyboardType,
    this.obscure = false,
    this.trailing,
    this.trailingLabel,
    this.keyName,
  });

  final String label;
  final String? hint;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final IconData icon;
  final bool obscure;
  final Widget? trailing;
  final Widget? trailingLabel;
  final String? keyName;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label.toUpperCase(),
              style: StitchText.fieldLabel.copyWith(letterSpacing: 0.8),
            ),
            if (trailingLabel != null) trailingLabel!,
          ],
        ),
        const SizedBox(height: 4),
        Container(
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: StitchColors.outlineVariant,
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: StitchColors.onSurfaceVariant),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  key: keyName == null ? null : ValueKey(keyName!),
                  controller: controller,
                  keyboardType: keyboardType,
                  obscureText: obscure,
                  style: StitchText.bodyLg.copyWith(
                    color: StitchColors.onSurface,
                  ),
                  cursorColor: StitchColors.primary,
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: StitchText.body.copyWith(
                      color: StitchColors.onSurfaceVariant.withValues(
                        alpha: 0.5,
                      ),
                    ),
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    filled: false,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
        ),
      ],
    );
  }
}
