import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmation = TextEditingController();
  bool _signUp = false;
  bool _hidePassword = true;
  bool _busy = false;
  bool _guest = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _confirmation.dispose();
    super.dispose();
  }

  Future<void> _submit({bool guest = false}) async {
    if (_busy) return;
    if (!guest && !_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _busy = true;
      _guest = guest;
      _error = null;
    });
    try {
      final auth = context.read<AppAuthProvider>();
      final error = guest
          ? await auth.signInAsGuest()
          : _signUp
              ? await auth.signUp(_email.text, _password.text)
              : await auth.signIn(_email.text, _password.text);
      if (mounted) setState(() => _error = error);
      if (error == null && !guest) TextInput.finishAutofillContext();
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Unable to connect. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _switchMode() {
    setState(() {
      _signUp = !_signUp;
      _error = null;
      _password.clear();
      _confirmation.clear();
      _hidePassword = true;
      _formKey.currentState?.reset();
    });
  }

  InputDecoration _decoration(String label, IconData icon,
      {Widget? suffix, String? helper}) {
    final colors = Theme.of(context).colorScheme;
    return InputDecoration(
      labelText: label,
      helperText: helper,
      prefixIcon: Icon(icon, size: 20),
      suffixIcon: suffix,
      filled: true,
      fillColor: colors.surfaceContainerLowest,
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.outlineVariant)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.primary, width: 2)),
      errorMaxLines: 2,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(builder: (context, constraints) {
          final wide = constraints.maxWidth >= 900;
          return SingleChildScrollView(
            padding: EdgeInsets.all(wide ? 40 : 20),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                  minHeight: (constraints.maxHeight - (wide ? 80 : 40))
                      .clamp(0, double.infinity)),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1080),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (wide) ...[
                        const Expanded(child: _WelcomePanel()),
                        const SizedBox(width: 64),
                      ],
                      Expanded(
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 440),
                            child: AutofillGroup(
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(children: [
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                            color: colors.primary,
                                            borderRadius:
                                                BorderRadius.circular(14)),
                                        child: Icon(
                                            Icons
                                                .account_balance_wallet_rounded,
                                            color: colors.onPrimary,
                                            size: 24),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                          child: Text('Expense Tracker',
                                              style: text.titleMedium?.copyWith(
                                                  fontWeight:
                                                      FontWeight.w700))),
                                    ]),
                                    const SizedBox(height: 36),
                                    Text(
                                        _signUp
                                            ? 'Start your money journal.'
                                            : 'Welcome back.',
                                        style: text.headlineLarge?.copyWith(
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: -1)),
                                    const SizedBox(height: 10),
                                    Text(
                                        _signUp
                                            ? 'Create an account to keep your everyday spending in one place.'
                                            : 'Sign in to see your spending, track expenses, and pick up where you left off.',
                                        style: text.bodyMedium?.copyWith(
                                            color: colors.onSurfaceVariant,
                                            height: 1.6)),
                                    const SizedBox(height: 28),
                                    TextFormField(
                                      controller: _email,
                                      enabled: !_busy,
                                      keyboardType: TextInputType.emailAddress,
                                      textInputAction: TextInputAction.next,
                                      autofillHints: const [
                                        AutofillHints.email
                                      ],
                                      autocorrect: false,
                                      decoration: _decoration('Email address',
                                          Icons.mail_outline_rounded),
                                      validator: (value) {
                                        if (value == null ||
                                            value.trim().isEmpty) {
                                          return 'Enter your email address.';
                                        }
                                        if (!RegExp(
                                                r'^[^\s@]+@[^\s@]+\.[^\s@]+$')
                                            .hasMatch(value.trim())) {
                                          return 'Enter a valid email address.';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 18),
                                    TextFormField(
                                      controller: _password,
                                      enabled: !_busy,
                                      obscureText: _hidePassword,
                                      autocorrect: false,
                                      enableSuggestions: false,
                                      autofillHints: [
                                        _signUp
                                            ? AutofillHints.newPassword
                                            : AutofillHints.password
                                      ],
                                      textInputAction: _signUp
                                          ? TextInputAction.next
                                          : TextInputAction.done,
                                      onFieldSubmitted: (_) {
                                        if (!_signUp) _submit();
                                      },
                                      decoration: _decoration(
                                        'Password',
                                        Icons.lock_outline_rounded,
                                        helper: _signUp
                                            ? 'Use at least 6 characters.'
                                            : null,
                                        suffix: IconButton(
                                          tooltip: _hidePassword
                                              ? 'Show password'
                                              : 'Hide password',
                                          onPressed: _busy
                                              ? null
                                              : () => setState(() =>
                                                  _hidePassword =
                                                      !_hidePassword),
                                          icon: Icon(
                                              _hidePassword
                                                  ? Icons.visibility_outlined
                                                  : Icons
                                                      .visibility_off_outlined,
                                              size: 20),
                                        ),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Enter your password.';
                                        }
                                        if (_signUp && value.length < 6) {
                                          return 'Use at least 6 characters.';
                                        }
                                        return null;
                                      },
                                    ),
                                    if (_signUp) ...[
                                      const SizedBox(height: 18),
                                      TextFormField(
                                        controller: _confirmation,
                                        enabled: !_busy,
                                        obscureText: _hidePassword,
                                        autocorrect: false,
                                        enableSuggestions: false,
                                        textInputAction: TextInputAction.done,
                                        onFieldSubmitted: (_) => _submit(),
                                        decoration: _decoration(
                                            'Confirm password',
                                            Icons.lock_outline_rounded),
                                        validator: (value) =>
                                            value == null || value.isEmpty
                                                ? 'Confirm your password.'
                                                : value != _password.text
                                                    ? 'Passwords do not match.'
                                                    : null,
                                      ),
                                    ],
                                    if (_error != null) ...[
                                      const SizedBox(height: 18),
                                      Semantics(
                                        liveRegion: true,
                                        child: Container(
                                          padding: const EdgeInsets.all(14),
                                          decoration: BoxDecoration(
                                              color: colors.errorContainer,
                                              borderRadius:
                                                  BorderRadius.circular(12)),
                                          child: Text(_error!,
                                              style: TextStyle(
                                                  color:
                                                      colors.onErrorContainer)),
                                        ),
                                      ),
                                    ],
                                    const SizedBox(height: 24),
                                    FilledButton(
                                      onPressed: _busy ? null : () => _submit(),
                                      style: FilledButton.styleFrom(
                                          minimumSize:
                                              const Size.fromHeight(52),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12))),
                                      child: _busy && !_guest
                                          ? const _Spinner()
                                          : Text(
                                              _signUp
                                                  ? 'Create account'
                                                  : 'Sign in',
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.w700)),
                                    ),
                                    const SizedBox(height: 16),
                                    Wrap(
                                      alignment: WrapAlignment.center,
                                      crossAxisAlignment:
                                          WrapCrossAlignment.center,
                                      children: [
                                        Text(
                                            _signUp
                                                ? 'Already have an account?'
                                                : 'New to Expense Tracker?',
                                            style: text.bodySmall),
                                        TextButton(
                                            onPressed:
                                                _busy ? null : _switchMode,
                                            child: Text(_signUp
                                                ? 'Sign in'
                                                : 'Create account')),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Row(children: [
                                      const Expanded(child: Divider()),
                                      Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16),
                                          child: Text('or explore first',
                                              style: text.bodySmall?.copyWith(
                                                  color: colors
                                                      .onSurfaceVariant))),
                                      const Expanded(child: Divider()),
                                    ]),
                                    const SizedBox(height: 20),
                                    OutlinedButton.icon(
                                      onPressed: _busy
                                          ? null
                                          : () => _submit(guest: true),
                                      style: OutlinedButton.styleFrom(
                                          minimumSize:
                                              const Size.fromHeight(50),
                                          side: BorderSide(
                                              color: colors.outlineVariant),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12))),
                                      icon: _busy && _guest
                                          ? const _Spinner()
                                          : const Icon(
                                              Icons.person_outline_rounded,
                                              size: 20),
                                      label: const Text('Continue as guest'),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                        'Use an account to access your expenses across devices.',
                                        textAlign: TextAlign.center,
                                        style: text.bodySmall?.copyWith(
                                            color: colors.onSurfaceVariant,
                                            height: 1.5)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _Spinner extends StatelessWidget {
  const _Spinner();
  @override
  Widget build(BuildContext context) => const SizedBox(
      width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2));
}

class _WelcomePanel extends StatelessWidget {
  const _WelcomePanel();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF202A62), Color(0xFF4D5CB0)]),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Icon(Icons.insights_rounded, size: 44, color: Color(0xFFC4CDFF)),
        const SizedBox(height: 56),
        const Text('Small expenses.\nA clearer picture.',
            style: TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                height: 1.15,
                letterSpacing: -1.5)),
        const SizedBox(height: 20),
        const Text('Make sense of your everyday spending, one entry at a time.',
            style:
                TextStyle(color: Color(0xFFDBE0FF), fontSize: 16, height: 1.7)),
        const SizedBox(height: 40),
        for (final feature in [
          (Icons.receipt_long_outlined, 'Every expense, organized'),
          (Icons.donut_large_rounded, 'Monthly insights at a glance'),
          (Icons.cloud_done_outlined, 'Saved to your account'),
        ])
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Row(children: [
              Icon(feature.$1, color: const Color(0xFFC4CDFF), size: 22),
              const SizedBox(width: 14),
              Expanded(
                  child: Text(feature.$2,
                      style: const TextStyle(color: Colors.white, height: 1.5)))
            ]),
          ),
      ]),
    );
  }
}
