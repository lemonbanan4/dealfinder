import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../l10n/app_localizations.dart';
import '../../../widgets/glass_card.dart';
import '../../auth/providers/validators.dart';
import '../data/newsletter_repository.dart';

/// "Get the deals first" — a compact newsletter signup form.
///
/// Self-contained: owns its own form state and submit flow so it can be
/// dropped into any page without external wiring.
class NewsletterSignupSection extends ConsumerStatefulWidget {
  const NewsletterSignupSection({super.key});

  @override
  ConsumerState<NewsletterSignupSection> createState() =>
      _NewsletterSignupSectionState();
}

class _NewsletterSignupSectionState
    extends ConsumerState<NewsletterSignupSection> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final l10n = AppLocalizations.of(context)!;

    setState(() => _isSubmitting = true);
    try {
      await ref
          .read(newsletterRepositoryProvider)
          .subscribe(_emailController.text.trim());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.newsletterThanks),
            backgroundColor: const Color(0xFF00E676),
          ),
        );
        _emailController.clear();
      }
    } on PostgrestException catch (e) {
      final message = e.code == '23505'
          ? l10n.newsletterAlreadySignedUp
          : e.message;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: const Color(0xFFFF4757),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.newsletterSomethingWentWrong),
            backgroundColor: const Color(0xFFFF4757),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isWide = MediaQuery.sizeOf(context).width >= 560;
    final l10n = AppLocalizations.of(context)!;

    final formContent = Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            l10n.newsletterHeadline,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: isDark
                  ? Colors.white
                  : theme.colorScheme.onPrimaryContainer,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.newsletterSubtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark
                  ? Colors.white70
                  : theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: isWide
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _EmailField(controller: _emailController),
                      ),
                      const SizedBox(width: 12),
                      _SubmitButton(
                        isSubmitting: _isSubmitting,
                        onPressed: _submit,
                      ),
                    ],
                  )
                : Column(
                    children: [
                      _EmailField(controller: _emailController),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: _SubmitButton(
                          isSubmitting: _isSubmitting,
                          onPressed: _submit,
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      decoration: BoxDecoration(
        color: isDark ? null : theme.colorScheme.primaryContainer,
      ),
      child: Center(
        child: isDark
            ? ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: GlassCard(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 32,
                  ),
                  child: formContent,
                ),
              )
            : formContent,
      ),
    );
  }
}

class _EmailField extends StatelessWidget {
  const _EmailField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.emailAddress,
      autofillHints: const [AutofillHints.email],
      style: TextStyle(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.black
            : null,
      ),
      decoration: InputDecoration(
        hintText: AppLocalizations.of(context)!.emailAddressHint,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      validator: Validators.validateEmail,
    );
  }
}

class _SubmitButton extends StatelessWidget {
  const _SubmitButton({required this.isSubmitting, required this.onPressed});

  final bool isSubmitting;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: isSubmitting ? null : onPressed,
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      ),
      child: isSubmitting
          ? const SizedBox.square(
              dimension: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : Text(AppLocalizations.of(context)!.register),
    );
  }
}
