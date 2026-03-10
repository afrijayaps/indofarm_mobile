import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../application/auth/auth_controller.dart';
import '../../application/auth/auth_state.dart';
import '../../core/theme/app_theme.dart';
import '../common/widgets/custom_text_field.dart';
import '../common/widgets/if_primitives.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  static const _maxFailedAttempts = 5;
  static const _lockSeconds = 30;

  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  int _failedAttempts = 0;
  int _remainingLockSeconds = 0;
  Timer? _lockTimer;

  bool get _isLocked => _remainingLockSeconds > 0;

  @override
  void dispose() {
    _lockTimer?.cancel();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authControllerProvider, (previous, next) {
      final wasSubmitting = previous?.status == AuthStatus.initializing;
      final failedLogin =
          next.status == AuthStatus.unauthenticated && next.error != null;
      if (wasSubmitting && failedLogin) {
        _registerFailedAttempt();
      }

      if (next.status == AuthStatus.authenticated) {
        _resetLockState();
      }
    });

    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.status == AuthStatus.initializing;
    final isSubmitDisabled = isLoading || _isLocked;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(
                context,
              ).colorScheme.primaryContainer.withValues(alpha: 0.4),
              Theme.of(context).scaffoldBackgroundColor,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 430),
                child: Column(
                  children: [
                    const IFHeroHeader(
                      title: 'Indofarm.app',
                      subtitle: 'Masuk untuk mulai input dan monitoring farm.',
                      leadingIcon: Icons.agriculture,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    IFSectionCard(
                      padding: const EdgeInsets.all(18),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CustomTextField(
                              controller: _phoneController,
                              hintText: '822xxxxxxx',
                              labelText: 'Nomor HP',
                              prefixText: '+62 ',
                              prefixIcon: const Icon(
                                Icons.phone_iphone_outlined,
                              ),
                              keyboardType: TextInputType.phone,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              textInputAction: TextInputAction.next,
                              validator: _validatePhone,
                            ),
                            const SizedBox(height: 10),
                            CustomTextField(
                              controller: _passwordController,
                              obscureText: true,
                              hintText: 'Password',
                              labelText: 'Password',
                              prefixIcon: const Icon(Icons.lock_outline),
                              textInputAction: TextInputAction.done,
                              validator: (value) =>
                                  (value == null || value.isEmpty)
                                  ? 'Password wajib'
                                  : null,
                            ),
                            const SizedBox(height: 14),
                            if (_isLocked)
                              _InlineAlert(
                                text:
                                    'Terlalu banyak percobaan. Coba lagi dalam $_remainingLockSeconds detik.',
                                color: Theme.of(context).colorScheme.error,
                              ),
                            if (authState.error != null)
                              _InlineAlert(
                                text: authState.error!,
                                color: Theme.of(context).colorScheme.error,
                              ),
                            if (authState.verificationUrl != null)
                              TextButton.icon(
                                onPressed: () => _openVerification(
                                  authState.verificationUrl!,
                                ),
                                icon: const Icon(Icons.verified_user_outlined),
                                label: const Text('Lanjut verifikasi nomor'),
                              ),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton.icon(
                                onPressed: isSubmitDisabled ? null : _submit,
                                icon: isLoading
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(Icons.login),
                                label: Text(
                                  isLoading
                                      ? 'Memproses...'
                                      : _isLocked
                                      ? 'Tunggu $_remainingLockSeconds dtk'
                                      : 'Masuk',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openVerification(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _submit() async {
    if (_isLocked) {
      return;
    }
    if (!_formKey.currentState!.validate()) return;
    await ref
        .read(authControllerProvider.notifier)
        .login(
          email: _toLoginIdentifier(),
          password: _passwordController.text.trim(),
        );
  }

  String? _validatePhone(String? value) {
    final local = _normalizeLocalPhone(value ?? '');
    if (local.isEmpty) {
      return 'Nomor HP wajib';
    }
    if (local.length < 8 || local.length > 13) {
      return 'Nomor HP tidak valid';
    }
    return null;
  }

  String _toLoginIdentifier() {
    final local = _normalizeLocalPhone(_phoneController.text);
    return '+62$local';
  }

  String _normalizeLocalPhone(String input) {
    var digits = input.replaceAll(RegExp(r'[^0-9]'), '');
    while (digits.startsWith('0')) {
      digits = digits.substring(1);
    }
    if (digits.startsWith('62')) {
      digits = digits.substring(2);
    }
    return digits;
  }

  void _registerFailedAttempt() {
    if (!mounted || _isLocked) {
      return;
    }

    final nextCount = _failedAttempts + 1;
    if (nextCount < _maxFailedAttempts) {
      setState(() => _failedAttempts = nextCount);
      return;
    }

    _startLockCountdown();
  }

  void _startLockCountdown() {
    _lockTimer?.cancel();
    setState(() {
      _failedAttempts = _maxFailedAttempts;
      _remainingLockSeconds = _lockSeconds;
    });

    _lockTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_remainingLockSeconds <= 1) {
        timer.cancel();
        setState(() {
          _remainingLockSeconds = 0;
          _failedAttempts = 0;
        });
        return;
      }

      setState(() => _remainingLockSeconds -= 1);
    });
  }

  void _resetLockState() {
    if (!mounted) {
      return;
    }
    _lockTimer?.cancel();
    setState(() {
      _failedAttempts = 0;
      _remainingLockSeconds = 0;
    });
  }
}

class _InlineAlert extends StatelessWidget {
  const _InlineAlert({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: AppCorners.sm,
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
    );
  }
}
