import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/onboarding_controller.dart';
import '../widgets/auth_widgets.dart';
import 'login_screen.dart';
import 'onboarding_splash_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmFocus = FocusNode();

  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmFocus.dispose();
    super.dispose();
  }

  void _onRegister() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmController.text;

    if (email.isEmpty || !email.contains('@')) {
      setState(() => _error = 'Please enter a valid email.');
      return;
    }
    if (password.length < 6) {
      setState(() => _error = 'Password must be at least 6 characters.');
      return;
    }
    if (password != confirm) {
      setState(() => _error = 'Passwords do not match.');
      return;
    }

    setState(() => _error = null);
    context.read<OnboardingController>().setAuth(email, password);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const OnboardingSplashScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Hello! Register to get\nstarted',
      children: [
        AuthTextField(
          hint: 'Email',
          keyboardType: TextInputType.emailAddress,
          controller: _emailController,
          focusNode: _emailFocus,
          nextFocus: _passwordFocus,
        ),
        const SizedBox(height: 16),
        AuthTextField(
          hint: 'Password',
          obscureText: true,
          controller: _passwordController,
          focusNode: _passwordFocus,
          nextFocus: _confirmFocus,
        ),
        const SizedBox(height: 16),
        AuthTextField(
          hint: 'Confirm Password',
          obscureText: true,
          controller: _confirmController,
          focusNode: _confirmFocus,
          onSubmitted: _onRegister,
        ),
        if (_error != null) ...[
          const SizedBox(height: 12),
          Text(
            _error!,
            style: const TextStyle(color: Colors.redAccent, fontSize: 13),
          ),
        ],
        const SizedBox(height: 24),
        PrimaryButton(
          label: 'Register',
          onPressed: _onRegister,
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Already have an account? ',
              style: TextStyle(color: Colors.white70),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const LoginScreen(),
                  ),
                );
              },
              child: const Text(
                'Login now',
                style: TextStyle(
                  color: kLimeAccent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

